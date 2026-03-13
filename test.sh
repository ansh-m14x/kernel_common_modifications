#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- 1. ABI & KMI Settings (Nuke checks) ---
export ABI_DEFINITION=
export KMI_SYMBOL_LIST_STRICT_MODE=0
export SKIP_ABI_CHECKS=1
export KMI_ENFORCE=0

# --- 2. Device & Toolchain variables ---
export PATH=/usr/lib/llvm-22/bin:$PATH
export KERNEL_REPO="/root/kernel_common"
export KERNEL_ROOT="/root/kernel_common"
export GKI_ROOT="/root/kernel_common"
export DEVICE="m14x"
export ARCH=arm64
export SUBARCH=arm64
export CC="ccache clang-22"
export HOSTCC="ccache clang-22"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LLVM=1
export LTO=thin
export LLVM_IAS=1
export TARGET_SOC=s5e8535
export SOC_NAME=s5e8535
export DTC_FLAGS="-@"
export PLATFORM_VERSION=15
export ANDROID_MAJOR_VERSION=t
export DEPMOD=depmod

# --- 3. Internal Paths ---
OUTDIR="$KERNEL_ROOT/out"
MODULES_OUTDIR="$KERNEL_ROOT/modules_out"
FINAL_STAGING="/root/staging"
IN_DLKM="/root/backups/modules"

# --- 4. Preparation ---
echo "Cleaning old build artifacts..."
#rm -rf "$OUTDIR" "$MODULES_OUTDIR" "$FINAL_STAGING"
#mkdir -p "$FINAL_STAGING/lib/modules/0.0"

# --- 5. Compilation ---
echo "===================================================="
echo "Configuring and Building for $DEVICE..."
echo "===================================================="

# Step A: Generate Config
make -j$(nproc --all) O=out ${DEVICE}_defconfig su.config

# Step B: Prepare.
make -j4 prepare O=out

# Step B: Compile Kernel Image
make -j$(nproc --all) O=out

# Step C: Install and Strip Modules
echo "Installing and stripping modules to modules_out..."
make -j$(nproc --all) O=out \
    INSTALL_MOD_STRIP="--strip-debug --keep-section=.ARM.attributes" \
    INSTALL_MOD_PATH="$MODULES_OUTDIR" \
    modules_install

# --- 6. Module Filtering & Dependency Logic ---
echo "Filtering modules based on OEM modules.load..."
missing_modules=""

# 1. Copy essential metadata FIRST so depmod can see them
echo "Copying metadata for depmod..."
cp "$MODULES_OUTDIR/lib/modules/"*"/modules.builtin" "$FINAL_STAGING/lib/modules/0.0/"
cp "$MODULES_OUTDIR/lib/modules/"*"/modules.order" "$FINAL_STAGING/lib/modules/0.0/"
cp "$IN_DLKM/modules.load" "$FINAL_STAGING/lib/modules/0.0/modules.load"
#for file in $(find . -name "*.ko"); do cp "$file" "$FINAL_STAGING/lib/modules/0.0/"; done

# We read the list of modules required for boot
while read -r module; do
    [ -z "$module" ] && continue
    # Locate the built .ko file
    found=$(find "$MODULES_OUTDIR/lib/modules" -name "$module" -type f | head -n 1)
    
    if [ -f "$found" ]; then
#        cp -f "$found" "$FINAL_STAGING/lib/modules/0.0/"
    else
        missing_modules="$missing_modules $module"
    fi
done < "$IN_DLKM/modules.load"

if [ -n "$missing_modules" ]; then
    echo "WARNING: The following modules from modules.load were not found: $missing_modules"
fi

#echo "Generating modules.dep using System.map..."
## Use the dummy version '0.0' to avoid version string issues with '@'
#depmod -b "$FINAL_STAGING" -F "$OUTDIR/System.map" 0.0
#
#echo "Fixing module paths for Android (Absolute paths)..."
## Converts relative paths in modules.dep to /lib/modules/...
#sed -i 's/\([^ ]\+\)/\/lib\/modules\/\1/g' "$FINAL_STAGING/lib/modules/0.0/modules.dep"

# --- 7. Finalizing Output ---
# Copy the final binaries to staging
cp "$OUTDIR/arch/arm64/boot/Image" "$KERNEL_ROOT/Image"
#cp "$OUTDIR/System.map" "$FINAL_STAGING/System.map"

echo -e "\n\033[1;32m====================================================\033[0m"
echo -e "\033[1;32mBUILD SUCCESSFUL!\033[0m"
echo -e "Kernel Image: $KERNEL_ROOT/Image"
echo -e "\033[1;32m====================================================\033[0m"

# --- 8. Cleaning ---
#rm -fr $OUTDIR
#rm -fr $MODULES_OUTDIR
# -------------------

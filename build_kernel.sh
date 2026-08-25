#!/bin/bash

# Environment paths
export PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r450784d/bin:$PATH
export PATH=$(pwd)/toolchain/build/kernel/build-tools/path/linux-x86/:$PATH

# Fixed HOSTCFLAGS and HOSTLDFLAGS
export HOSTCFLAGS="-I$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/include"
export HOSTLDFLAGS="-L$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -Wl,-rpath,$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -fuse-ld=lld"

# Kernel build variables & explicit LLVM binaries
export DTC_FLAGS="-@"
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export LLVM=1
export LLVM_IAS=1
export CC=clang
export LD=ld.lld
export AR=llvm-ar
export NM=llvm-nm
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export READELF=llvm-readelf
export OBJSIZE=llvm-size
export STRIP=llvm-strip
export DEPMOD=depmod
export ARCH=arm64
export TARGET_SOC=s5e8535

# Build steps
make m14x_defconfig
make -j$(nproc)

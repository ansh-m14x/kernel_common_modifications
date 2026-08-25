#!/bin/bash

# Define Toolchain Paths
export PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r450784d/bin:$PATH
export PATH=$(pwd)/toolchain/build/kernel/build-tools/path/linux-x86/:$PATH

# Host Compiler & Linker Flags
export HOSTCFLAGS="-I$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/include"
export HOSTLDFLAGS="-L$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -Wl,-rpath,$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -fuse-ld=lld"

# Target & System Architecture Flags
export ARCH=arm64
export TARGET_SOC=s5e8535
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export DTC_FLAGS="-@"
export DEPMOD=depmod

# Explicit LLVM Environment Bindings (Fixes missing llvm-ar / BPF build failures)
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

# Execute Compilation
make m14x_defconfig
make -j$(nproc)

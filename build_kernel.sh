#!/bin/bash

# Environment paths
export PATH=$(pwd)/toolchain/clang/host/linux-x86/clang-r450784d/bin:$PATH
export PATH=$(pwd)/toolchain/build/kernel/build-tools/path/linux-x86/:$PATH

# System header fallbacks appended to fix missing sys/types.h in host sysroot
export HOSTCFLAGS="--sysroot=$(pwd)/toolchain/build/kernel/build-tools/sysroot -I/usr/include -I/usr/include/x86_64-linux-gnu -I$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/include"
export HOSTLDFLAGS="--sysroot=$(pwd)/toolchain/build/kernel/build-tools/sysroot -Wl,-rpath,$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -L$(pwd)/toolchain/prebuilts/kernel-build-tools/linux-x86/lib64 -fuse-ld=lld --rtlib=compiler-rt"

# Kernel build variables
export DTC_FLAGS="-@"
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export LLVM=1
export LLVM_IAS=1
export DEPMOD=depmod
export ARCH=arm64
export TARGET_SOC=s5e8535

# Build steps
make m14x_defconfig
make -j$(nproc)

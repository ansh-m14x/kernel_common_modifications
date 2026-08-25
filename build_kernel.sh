#!/bin/bash

# Define Toolchain Path (Proton Clang)
export PATH=$(pwd)/proton-clang/bin:$PATH

# Architecture & Platform Setup
export ARCH=arm64
export SUBARCH=arm64
export TARGET_SOC=s5e8535
export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export DTC_FLAGS="-@"
export DEPMOD=depmod

# Proton Clang LLVM Toolchain Flags
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
export LLVM=1
export LLVM_IAS=1

# Generate Base Config
make m14x_defconfig

# Convert Full LTO to ThinLTO (Prevents link delays) & Fallback BTF Fix
scripts/config --file .config --disable CONFIG_LTO_CLANG_FULL
scripts/config --file .config --enable CONFIG_LTO_CLANG_THIN
scripts/config --file .config --disable CONFIG_DEBUG_INFO_BTF

# Start Multi-Threaded Build
make -j$(nproc)

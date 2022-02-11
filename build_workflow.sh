#!/bin/bash -e

ARG_PLATFORM="$1"
echo Building for ${ARG_PLATFORM}...

VERSION="$(git rev-parse --short HEAD)"
if [[ x$ARG_PLATFORM == x"linux/arm/v7" ]]; then
  TRIPLET=arm-linux-gnueabihf
  # CMAKE_TOOLCHAIN_FILE=armhf.cmake
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35 -mfpu=vfpv4"
  SQUASH_NAME=mono-${VERSION}-armhf.squashfs
elif [[ x$ARG_PLATFORM == x"linux/arm64" ]]; then
  TRIPLET=aarch64-linux-gnu
  # CMAKE_TOOLCHAIN_FILE=aarch64.cmake
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35 -mfpu=vfpv4"
  SQUASH_NAME=mono-${VERSION}-aarch64.squashfs
else
  echo ERROR: Unknown platform ${ARG_PLATFORM}, exiting...
  exit 1
fi

# Configure
./autogen.sh --host="${TRIPLET}" --prefix="$(pwd)/built" --with-csc=mcs --with-mcs-build --enable-system-aot CFLAGS="${FLAGS}" CXXFLAGS="${FLAGS}" CCFLAGS="${FLAGS}"

# Make && Make Install
make -j$((`nproc`+1))
make install

# TODO:: AOT...
# Package
cd built
mksquashfs {bin,etc,include,lib,share} "${SQUASH_NAME}"

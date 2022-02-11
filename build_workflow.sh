#!/bin/bash -e

ARG_PLATFORM="$1"
echo Building for ${ARG_PLATFORM}...

VERSION="$(git rev-parse --short HEAD)"
if [[ x$ARG_PLATFORM == x"armhf" ]]; then
  TRIPLET=arm-linux-gnueabihf
  # CMAKE_TOOLCHAIN_FILE=armhf.cmake
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35 -mfpu=vfpv4"
  SQUASH_NAME=mono-${VERSION}-armhf.squashfs
elif [[ x$ARG_PLATFORM == x"aarch64" ]]; then
  TRIPLET=aarch64-linux-gnu
  # CMAKE_TOOLCHAIN_FILE=aarch64.cmake
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35"
  SQUASH_NAME=mono-${VERSION}-aarch64.squashfs
else
  echo ERROR: Unknown platform ${ARG_PLATFORM}, exiting...
  exit 1
fi

# Set env config
export QEMU_CPU=cortex-a35
export QEMU_LD_PREFIX="/usr/${TRIPLET}"
export CC="${TRIPLET}-gcc"
export CXX="${TRIPLET}-g++"

# Configure
./autogen.sh --host=${TRIPLET} --target=${TRIPLET} --prefix="$(pwd)/built" --with-tls=__thread --with-profile4_x=yes --with-runtime-preset=net_4_x,aot --with-csc=mcs --enable-mcs-build --enable-system-aot CFLAGS="${FLAGS}" CXXFLAGS="${FLAGS}" CCFLAGS="${FLAGS}" CC="${TRIPLET}-gcc" CXX="${TRIPLET}-g++"

# Make && Make Install
make -j$((`nproc`+1))
make install

# TODO:: AOT...
# Package
cd built
mksquashfs * "${SQUASH_NAME}"

#!/bin/bash -e

ARG_PLATFORM=$0
shift
echo Building for $ARG_PLATFORM...

VERSION="$(git rev-parse --short HEAD)"
if [[ x$ARG_PLATFORM == "xlinux/arm/v7" ]]; then
  CROSSESSENTIALS=crossbuild-essential-armhf
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35 -mfpu=vfpv4"
  SQUASH_NAME=mono-$(VERSION)-armhf.squashfs
elif [[ x$ARG_PLATFORM == "xlinux/arm64" ]]; then
  CROSSESSENTIALS=crossbuild-essential-aarch64
  FLAGS="-mcpu=cortex-a35 -mtune=cortex-a35 -mfpu=vfpv4"
  SQUASH_NAME=mono-$(VERSION)-aarch64.squashfs
else
  echo ERROR:: Unknown platform, exiting...
  exit 1
fi

# Install deps
sudo apt-get install git autoconf libtool automake build-essential gettext cmake python3 curl squashfs-tools $CROSSESSENTIALS

# Configure
./autogen.sh --prefix=$(pwd)/built --with-csc=mcs --with-mcs-build --enable-system-aot CFLAGS=$FLAGS CXXFLAGS=$FLAGS CCFLAGS=$FLAGS

# Make && Make Install
make -j$((`nproc`+1))
make install

# TODO:: AOT...
# Package
cd built
mksquashfs {bin,etc,include,lib,share} $SQUASH_NAME

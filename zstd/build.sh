#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir

# zstd was added to Python in version 3.14, which uses this minimum API level.
# zstd also requires the same API level for fseeko and ftello on 32-bit ABIs
# (https://android.googlesource.com/platform/bionic/+/HEAD/docs/32-bit-abi.md).
ANDROID_API_LEVEL=24
. ../android-env.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=zstd-$version.tar.gz
wget -c https://github.com/facebook/zstd/releases/download/v$version/$src_filename

build_dir=$version_dir/$HOST
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd zstd-$version

prefix=$build_dir/prefix
mkdir $prefix

make -j $CPU_COUNT -C lib libzstd.a-release libzstd.pc PREFIX=$prefix
make -C lib install-static install-pc PREFIX=$prefix

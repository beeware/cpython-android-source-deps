#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir
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

make -j $CPU_COUNT lib-release PREFIX=$prefix
make install PREFIX=$prefix

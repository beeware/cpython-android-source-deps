#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir
. ../build-common.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=libffi-$version.tar.gz
wget -c https://github.com/libffi/libffi/releases/download/v$version/$src_filename

build_dir=$version_dir/$abi
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

prefix=$build_dir/prefix
mkdir $prefix

./configure --host=$host_triplet --prefix=$prefix --disable-shared --with-pic
make -j $CPU_COUNT
make install

#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir
. ../android-env.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=libffi-$version.tar.gz
wget -c https://github.com/libffi/libffi/releases/download/v$version/$src_filename

build_dir=$version_dir/$HOST
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

patch -p1 -i $recipe_dir/long_double.patch
patch -p1 -i $recipe_dir/open_temp_exec_file.patch

prefix=$build_dir/prefix
mkdir $prefix

./configure --host=$HOST --prefix=$prefix --disable-shared --with-pic
make -j $CPU_COUNT
make install

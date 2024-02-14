#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir
. ../android-env.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=bzip2-$version.tar.gz
wget -c https://sourceware.org/pub/bzip2/$src_filename

build_dir=$version_dir/$HOST
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

CFLAGS+=" -O2 -fPIC"
# -e is needed to override explicit assignment to CC, CFLAGS etc. in the Makefile.
make -e -j $CPU_COUNT bzip2 bzip2recover

prefix=$build_dir/prefix
mkdir $prefix
make install PREFIX=$prefix

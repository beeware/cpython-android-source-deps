#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))

# Unfortunately the URL represents the version as an integer, and also includes a year
# subdirectory. For example, version 3.39.2 is at /2022/sqlite-autoconf-3390200.tar.gz.
year=2024
version=${1:?}
read major minor micro < <(echo $version | tr '.' ' ')
version_int=$(printf "%d%02d%02d00" $major $minor $micro)

cd $recipe_dir
. ../android-env.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=sqlite-autoconf-$version_int.tar.gz
wget -c https://www.sqlite.org/$year/$src_filename

build_dir=$version_dir/$HOST
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

patch -p1 -i "$recipe_dir/soname.patch"
patch -p1 -i "$recipe_dir/strerror_r.patch"

CFLAGS+=" -Os"  # This is off by default, but it's recommended in the README.
./configure --host=$HOST --disable-static --disable-static-shell --with-pic
make -j $CPU_COUNT

prefix=$build_dir/prefix
mkdir $prefix
make install prefix=$prefix

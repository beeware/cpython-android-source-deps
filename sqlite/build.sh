#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))

# Unfortunately the URL represents the version as an integer, and also includes a year
# subdirectory. For example, version 3.39.2 is at /2022/sqlite-autoconf-3390200.tar.gz.
year=2022
version=${1:?}
read major minor micro < <(echo $version | tr '.' ' ')
version_int=$(printf "%d%02d%02d00" $major $minor $micro)

cd $recipe_dir
. ../build-common.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=sqlite-autoconf-$version_int.tar.gz
wget -c https://www.sqlite.org/$year/$src_filename

build_dir=$version_dir/$abi
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

CFLAGS+=" -Os"  # This is off by default, but it's recommended in the README.
./configure --host=$host_triplet --disable-static --disable-static-shell --with-pic
make -j $CPU_COUNT

prefix=$build_dir/prefix
mkdir $prefix
make install prefix=$prefix

# We add a _python suffix in case libraries of the same name are provided by Android
# itself. And we update the SONAME to match, so that anything compiled against the
# library will store the modified name. This is necessary on API 22 and older, where the
# dynamic linker ignores the SONAME attribute and uses the filename instead.
cd $prefix/lib
for name in sqlite3; do
    old_name=$(basename $(realpath lib$name.so))  # Follow symlinks.
    new_name="lib${name}_python.so"
    mv "$old_name" "$new_name"
    ln -s "$new_name" "$old_name"
    patchelf --set-soname "$new_name" "$new_name"
done

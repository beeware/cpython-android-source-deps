#!/bin/bash
set -eu

recipe_dir=$(dirname $(realpath $0))
version=${1:?}

cd $recipe_dir
. ../android-env.sh

version_dir=$recipe_dir/build/$version
mkdir -p $version_dir
cd $version_dir
src_filename=openssl-$version.tar.gz

if echo $version | grep -q '^1\.'; then
    tag="OpenSSL_$(echo $version | sed 's/\./_/g')"
else
    tag="openssl-$version"
fi
wget -c "https://github.com/openssl/openssl/releases/download/$tag/$src_filename"

build_dir=$version_dir/$HOST
rm -rf $build_dir
mkdir $build_dir
cd $build_dir
tar -xf $version_dir/$src_filename
cd $(basename $src_filename .tar.gz)

patch -p1 -i "$recipe_dir/at_secure.patch"
patch -p1 -i "$recipe_dir/configuration.patch"

version_major=$(echo "$version" | sed 's/\..*//')
patch -p1 -i "$recipe_dir/soname-$version_major.patch"

# CFLAGS environment variable replaces default flags rather than adding to them.
CFLAGS+=" -O2"
export LDLIBS="-latomic"

if [[ $HOST =~ '64' ]]; then
    bits="64"
else
    bits="32"
fi
./Configure android-python$bits shared
make -j $CPU_COUNT

prefix=$build_dir/prefix
mkdir $prefix
make install_sw DESTDIR=$prefix

mv $prefix/usr/local/* $prefix
rm -r $prefix/usr

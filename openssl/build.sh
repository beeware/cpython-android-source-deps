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

patch -p1 -i $recipe_dir/at_secure.patch

# CFLAGS environment variable replaces default flags rather than adding to them.
CFLAGS+=" -O2"
export LDLIBS="-latomic"

if [[ $HOST =~ '64' ]]; then
    bits="64"
else
    bits="32"
fi
./Configure linux-generic$bits shared
make -j $CPU_COUNT

prefix=$build_dir/prefix
mkdir $prefix
make install_sw DESTDIR=$prefix

mv $prefix/usr/local/* $prefix
rm -r $prefix/usr

# We add a _python suffix in case libraries of the same name are provided by Android
# itself. And we update the SONAME to match, so that anything compiled against the
# library will store the modified name. This is necessary on API 22 and older, where the
# dynamic linker ignores the SONAME attribute and uses the filename instead.
cd $prefix/lib
for name in crypto ssl; do
    old_name=$(basename $(realpath lib$name.so))  # Follow symlinks.
    new_name="lib${name}_python.so"
    if [ "$name" = "crypto" ]; then
        crypto_old_name=$old_name
        crypto_new_name=$new_name
    fi

    mv "$old_name" "$new_name"
    ln -s "$new_name" "$old_name"
    patchelf --set-soname "$new_name" "$new_name"
    if [ "$name" = "ssl" ]; then
        patchelf --replace-needed "$crypto_old_name" "$crypto_new_name" "$new_name"
    fi
done

#!/bin/bash
set -eu

name=${1:?}
version=${2:?}
build=${3:?}
export HOST=${4:?}

if [ "$(uname)" != "Linux" ]; then
    echo 'These scripts may not work on non-Linux platforms. For example, building '
    echo 'OpenSSL 3.0.13 on macOS led to the runtime error: dlopen failed: cannot find '
    echo '"libcrypto_python.so" from verneed[1] in DT_NEEDED list for '
    echo '"/data/data/org.python.testbed/files/python/lib/python3.13/lib-dynload/_ssl.cpython-313-aarch64-linux-android.so".'
    echo 'The cause of this is unknown.'
    exit 1
fi

recipe_dir=$(dirname $(realpath $0))/$name
$recipe_dir/build.sh $version

build_dir=$recipe_dir/build/$version/$HOST
tarball=$build_dir/$name-$version-$build-$HOST.tar.gz
echo "Creating $tarball"
cd $build_dir/prefix
tar -czf $tarball *

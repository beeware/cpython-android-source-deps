#!/bin/bash
set -eu

name=${1:?}
version=${2:?}
build=${3:?}
export HOST=${4:?}

recipe_dir=$(dirname $(realpath $0))/$name
$recipe_dir/build.sh $version

build_dir=$recipe_dir/build/$version/$HOST
tarball=$build_dir/$name-$version-$build-$HOST.tar.gz
echo "Creating $tarball"
cd $build_dir/prefix
tar -czf $tarball *

#!/bin/bash
set -eu

name=${1:?}
version=${2:?}
build=${3:?}
export abi=${4:?}
export api_level=21

recipe_dir=$(dirname $(realpath $0))/$name
$recipe_dir/build.sh $version

dist_dir=$recipe_dir/dist
mkdir -p $dist_dir

# Same format as the wheel tag
tag=$(echo android_${api_level}_$abi | tr '-' '_')

cd $recipe_dir/build/$version/$abi/prefix
tarball=$dist_dir/$name-$version-$build-$tag.tar.gz
tar -czf $tarball *
echo "Created $tarball"

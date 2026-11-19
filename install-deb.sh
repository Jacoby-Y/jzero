#!/usr/bin/env bash
# Bump the patch version in j3.toml, build the release .deb, and install it.
set -euo pipefail
cd "$(dirname "$0")"

old=$(grep -m1 '^version = ' j3.toml | cut -d'"' -f2)
IFS=. read -r major minor patch <<< "$old"
new="$major.$minor.$((patch + 1))"
sed -i "0,/^version = \"$old\"/s//version = \"$new\"/" j3.toml
echo "version $old -> $new"

j3c build --release
sudo apt install -y "./target/dist/jzero_${new}_amd64.deb"

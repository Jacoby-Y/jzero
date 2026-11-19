#!/usr/bin/env bash
# Zip the Windows dev build (it has the `JZERO_ACTIONS` hook) and put it on the `ci` release
# for .github/workflows/windows.yml. Run after `j3c build`.
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d)
mkdir "$tmp/jzero"
cp target/x86_64-pc-windows-gnu/jzero.exe ~/.cache/j3/sdl2-mingw/dll/*.dll "$tmp/jzero/"
cp -r assets "$tmp/jzero/"
(cd "$tmp" && zip -qr jzero-ci-windows.zip jzero)
gh release view ci >/dev/null 2>&1 || gh release create ci --prerelease --title "CI build" --notes "Windows dev build under test. Not for use."
gh release upload ci "$tmp/jzero-ci-windows.zip" --clobber
rm -rf "$tmp"

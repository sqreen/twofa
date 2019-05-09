#!/bin/bash

# ./build.sh >/dev/null
BIN="./.build/x86_64-apple-macosx10.10/debug/TwoFa"
echo "==> Codesign"
codesign -dv --verbose=4 "$BIN"
echo "==> Deps"
otool -L "$BIN"
echo "==> Entitlements"
codesign -d --entitlements - "$BIN"

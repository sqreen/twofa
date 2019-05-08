#!/bin/bash
set -e

EXECUTABLE="./.build/x86_64-apple-macosx10.10/debug/TwoFa"

swift build -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist
codesign --entitlements "Supporting/twofa.entitlements" -f -s "Mac Developer: Janis Kirsteins (39TW4P3R2T)" "$EXECUTABLE"
"$EXECUTABLE" $@

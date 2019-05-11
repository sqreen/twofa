#!/bin/bash
set -e

CONFIG="release"
EXECUTABLE="$(find .build -name TwoFa | grep $CONFIG | grep -v dSYM)"

BUILDOUT="$(swift build \
-c $CONFIG \
--static-swift-stdlib \
-Xlinker -sectcreate \
-Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist)"

ID="Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)"

codesign --entitlements "Supporting/twofa.entitlements" -s "$ID" "$EXECUTABLE"

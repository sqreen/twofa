#!/bin/bash
set -e

CONFIG="release"

BUILDOUT="$(swift build \
-c $CONFIG \
-Xlinker -sectcreate \
-Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist)"

EXECUTABLE="$(find .build -name TwoFa | grep $CONFIG | grep -v dSYM | grep macosx)"

ID="Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)"

codesign --entitlements "Supporting/twofa.entitlements" -s "$ID" "$EXECUTABLE"

mv -v "$EXECUTABLE" "${EXECUTABLE%TwoFa}twofa"
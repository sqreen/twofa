#!/bin/bash
set -e

CONFIG="release"
ID="Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)"

echo "==> Building"
BUILDOUT="$(swift build \
-c $CONFIG \
-Xlinker -sectcreate \
-Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist)"

EXECUTABLE="$(find .build -name TwoFa | grep $CONFIG | grep -v dSYM | grep macosx)"
echo "    built: $EXECUTABLE"

echo "==> Codesigning"
echo "    identity: $ID"
codesign --entitlements "Supporting/twofa.entitlements" -s "$ID" "$EXECUTABLE"
echo "    done"

echo "==> Renaming output"
echo "    $EXECUTABLE -> ${EXECUTABLE%TwoFa}twofa"
mv "$EXECUTABLE" "${EXECUTABLE%TwoFa}twofa"
#!/bin/bash
set -e

EXECUTABLE="./.build/x86_64-apple-macosx/release/TwoFa"

swift build \
-c release \
--static-swift-stdlib \
-Xlinker -sectcreate \
-Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist

ID="Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)"

codesign --entitlements "Supporting/twofa.entitlements" -s "$ID" "$EXECUTABLE"

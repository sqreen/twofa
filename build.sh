#!/bin/bash
set -e

EXECUTABLE="./.build/x86_64-apple-macosx10.10/debug/TwoFa"

#-Xlinker -L -Xlinker /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift_static/macosx/ \

swift build \
--static-swift-stdlib \
-Xlinker -sectcreate \
-Xlinker __TEXT -Xlinker __info_plist -Xlinker Supporting/Info.plist \
-Xlinker -lobjc \
-Xlinker -lSystem \

ID="Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)"
# Developer ID Application: Notakey Latvia, SIA (N2JEMR5FZG)

codesign --entitlements "Supporting/twofa.entitlements" -f -s "$ID" "$EXECUTABLE"
"$EXECUTABLE" $@

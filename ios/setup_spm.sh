#!/bin/bash
# setup_spm.sh
# Vendors NISdk 6.0.0 Swift source into ios/Sources/NISdk/ for SPM.
# Run once from the ios/ directory, then commit Sources/NISdk/.
#
# Usage:
#   cd ios/
#   bash setup_spm.sh

set -e

NISDK_VERSION="v6.0.0"
NISDK_REPO="https://github.com/network-international/payment-sdk-ios.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NISDK_TARGET="$SCRIPT_DIR/Sources/NISdk"
TMP_DIR=$(mktemp -d)

echo "▶ Cloning NISdk $NISDK_VERSION …"
git clone --depth 1 --branch "$NISDK_VERSION" "$NISDK_REPO" "$TMP_DIR"

echo "▶ Copying Swift sources → Sources/NISdk/ …"
rm -rf "$NISDK_TARGET"
mkdir -p "$NISDK_TARGET"
cp -r "$TMP_DIR/NISdk/Source/." "$NISDK_TARGET/"

if [ -d "$TMP_DIR/NISdk/Resources" ]; then
    echo "▶ Copying resources → Sources/NISdk/Resources/ …"
    cp -r "$TMP_DIR/NISdk/Resources" "$NISDK_TARGET/Resources"
fi

rm -rf "$TMP_DIR"

echo ""
echo "✅ Done! Final structure:"
echo "   ios/"
echo "   ├── Package.swift"
echo "   ├── network_international_payment_sdk.podspec"
echo "   ├── Classes/"
echo "   │   └── NetworkInternationalPaymentSdkPlugin.swift"
echo "   └── Sources/"
echo "       └── NISdk/          ← vendored NISdk $NISDK_VERSION"
echo "           ├── (Swift sources)"
echo "           └── Resources/"
echo ""
echo "Next steps:"
echo "  1. git add Sources/NISdk && git commit -m 'vendor NISdk $NISDK_VERSION for SPM'"
echo "  2. flutter config --enable-swift-package-manager"
echo "  3. flutter pub get"

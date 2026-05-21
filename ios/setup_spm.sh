#!/bin/bash
# setup_spm.sh — run once from the ios/ directory.
# Vendors NISdk v6.0.0 Swift source into the SPM package.
#
# Usage:
#   cd ios/
#   bash setup_spm.sh

set -e

NISDK_VERSION="v6.0.0"
NISDK_REPO="https://github.com/network-international/payment-sdk-ios.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NISDK_TARGET="$SCRIPT_DIR/network_international_payment_sdk/Sources/NISdk"
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
echo "✅ Done! Final SPM structure:"
echo "   ios/"
echo "   ├── network_international_payment_sdk.podspec"
echo "   ├── setup_spm.sh"
echo "   └── network_international_payment_sdk/"
echo "       ├── Package.swift"
echo "       └── Sources/"
echo "           ├── network_international_payment_sdk/"
echo "           │   └── NetworkInternationalPaymentSdkPlugin.swift"
echo "           └── NISdk/          ← vendored $NISDK_VERSION"
echo ""
echo "Next steps:"
echo "  1. git add network_international_payment_sdk/Sources/NISdk"
echo "  2. git commit -m 'vendor NISdk $NISDK_VERSION for SPM support'"
echo "  3. flutter pub get"
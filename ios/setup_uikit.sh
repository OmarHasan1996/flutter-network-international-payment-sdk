find network_international_payment_sdk/Sources/NISdk -name "*.swift" | while read file; do
  if ! grep -q "^import UIKit" "$file"; then
    sed -i '' '1s/^/import UIKit\n/' "$file"
    echo "✅ Patched: $file"
  else
    echo "⏭️  Already patched: $file"
  fi
done
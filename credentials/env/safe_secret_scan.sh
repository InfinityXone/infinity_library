#!/bin/bash

OUTPUT=secret_inventory.txt

echo "🔍 Running SAFE secret scan (non-recursive, controlled)..." | tee $OUTPUT
echo "===========================================================" | tee -a $OUTPUT

SCAN_DIRS=(
    "$HOME"
    "/home/etherverse"
    "/opt/infinity_library"
    "/etc/vault"
    "/etc/ssl/infinity_library"
    "/etc/nginx/conf.d"
    "/home/etherverse/.config"
    "/home/etherverse/secrets"
)

KEYWORDS="password|passwd|secret|token|api|key|credential"

echo "📂 Scanning the following directories:" | tee -a $OUTPUT
printf '%s\n' "${SCAN_DIRS[@]}" | tee -a $OUTPUT
echo "===========================================================" | tee -a $OUTPUT
echo | tee -a $OUTPUT

for DIR in "${SCAN_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "📁 Checking: $DIR" | tee -a $OUTPUT

        find "$DIR" -maxdepth 4 -type f 2>/dev/null \
            | grep -E "\.(json|env|conf|txt|yaml|yml|ini|key|pem)$" \
            | while read -r FILE; do
            
                SIZE=$(stat -c%s "$FILE" 2>/dev/null)
                if [ "$SIZE" -gt 2000000 ]; then
                    echo "⚠️ SKIPPED large file: $FILE" | tee -a $OUTPUT
                    continue
                fi

                if grep -qiE "$KEYWORDS" "$FILE" 2>/dev/null; then
                    echo "🔐 POSSIBLE SECRET: $FILE" | tee -a $OUTPUT
                fi
            done

        echo | tee -a $OUTPUT
    fi
done

echo "===========================================================" | tee -a $OUTPUT
echo "✔ SAFE SCAN COMPLETE. Results saved to: $OUTPUT"
echo "===========================================================" | tee -a $OUTPUT

echo
echo "📄 Would you like to open the result file?"
read -p "(y/n): " OPEN_FILE

if [[ "$OPEN_FILE" == "y" || "$OPEN_FILE" == "Y" ]]; then
    nano "$OUTPUT"
else
    echo "You can open it later using:  nano $OUTPUT"
fi

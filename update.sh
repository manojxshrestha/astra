#!/bin/bash
# astra Framework Update Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Updating astra Framework..."
echo ""

# Update package lists
echo "[*] Updating system packages..."
sudo apt update -y 2>/dev/null || echo "[!] Could not update packages"

# Update Python packages
echo ""
echo "[*] Updating Python packages..."
if [[ -f "$SCRIPT_DIR/venv/bin/activate" ]]; then
    source "$SCRIPT_DIR/venv/bin/activate"
    pip install --upgrade pip > /dev/null 2>&1
    pip list --outdated | grep -v "^-" | awk '{print $1}' | xargs -I {} pip install {} > /dev/null 2>&1 || true
fi

# Update framework scripts
echo ""
echo "[*] Setting permissions..."
find "$SCRIPT_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null
find "$SCRIPT_DIR" -name "*.py" -type f -exec chmod +x {} \; 2>/dev/null

echo ""
echo "[+] Update complete!"

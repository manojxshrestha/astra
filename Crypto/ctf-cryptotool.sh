#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] CTF-CryptoTool - Multi-Cipher Brute Force${NC}"
echo ""
echo " Supports:"
echo "  - Affine, Atbash, Baconian"
echo "  - Caesar, Vigenère, Rail Fence"
echo "  - Rot13, XOR, and more..."
echo ""

if [[ ! -d "$TOOLS_DIR/CTF-CryptoTool" ]]; then
    echo -e "${YELLOW}[!] CTF-CryptoTool not installed${NC}"
    echo "Run 'CA' from crypto-suite menu to install"
    exit 0
fi

echo -n "Enter cipher text: "
read TEXT

if [[ -z "$TEXT" ]]; then
    echo -e "${YELLOW}[!] No text provided${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[*] Running CTF-CryptoTool...${NC}"
cd "$TOOLS_DIR/CTF-CryptoTool"
python3 decoder.py -c "$TEXT"
echo ""

exit 0

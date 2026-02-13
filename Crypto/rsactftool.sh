#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] RsaCtfTool - RSA Attack Toolkit${NC}"
echo ""
echo " Attacks:"
echo "  - Wiener's attack"
echo "  - Fermat's factorization"
echo "  - Boneh-Durfee"
echo "  - FactorDB lookup"
echo "  - And many more..."
echo ""

if [[ ! -d "$TOOLS_DIR/RsaCtfTool/src/RsaCtfTool" ]]; then
    echo -e "${YELLOW}[!] RsaCtfTool not installed${NC}"
    echo "Run 'CA' from crypto-suite menu to install"
    exit 0
fi

echo -n "Enter public key file path: "
read KEYFILE

if [[ -z "$KEYFILE" ]]; then
    echo -e "${YELLOW}[!] No key file provided${NC}"
    exit 0
fi

if [[ ! -f "$KEYFILE" ]]; then
    echo -e "${YELLOW}[!] Key file not found: $KEYFILE${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[*] Running RsaCtfTool...${NC}"
cd "$TOOLS_DIR/RsaCtfTool/src/RsaCtfTool"
python3 main.py --publickey "$KEYFILE" --attack all
echo ""

exit 0

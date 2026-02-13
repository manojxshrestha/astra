#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}[*] codext - Exotic Encodings${NC}"
echo ""
echo " codext handles exotic encodings:"
echo "  - base91, base92, base100, base122"
echo "  - base65536, base32768"
echo "  - ASCII85, UTF7, UTF16"
echo "  - And many more..."
echo ""

if ! command -v codext &>/dev/null; then
    echo -e "${YELLOW}[!] codext not installed${NC}"
    echo "Run 'CA' from crypto-suite menu to install"
    exit 0
fi

echo -n "Enter encoding to decode (base91, ascii85, utf16, etc.): "
read ENCODING

echo -n "Enter text to decode: "
read TEXT

if [[ -z "$ENCODING" || -z "$TEXT" ]]; then
    echo -e "${YELLOW}[!] Missing encoding or text${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[*] Running codext...${NC}"
codext decode "$ENCODING" "$TEXT"
echo ""

exit 0

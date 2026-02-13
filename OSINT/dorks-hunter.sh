#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] Dorks Hunter - Google Dorks${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -d "$TOOLS_DIR/dorks_hunter" ]]; then
        cd "$TOOLS_DIR/dorks_hunter"
        bash gitdorks_go.py -gh "$TARGET" -w wordlist.txt
    else
        echo -e "${YELLOW}[!] dorks_hunter not installed. Run: cd ~/Tools && git clone https://github.com/six2dez/dorks_hunter${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

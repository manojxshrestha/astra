#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] Spoofy - SPF/DMARC Checks${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/Spoofy/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/Spoofy"
        "$TOOLS_DIR/Spoofy/venv/bin/python3" spoofy.py -d "$TARGET"
    elif [[ -f "$TOOLS_DIR/Spoofy/spoofy.py" ]]; then
        cd "$TOOLS_DIR/Spoofy"
        python3 spoofy.py -d "$TARGET"
    else
        echo -e "${YELLOW}[!] Spoofy not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

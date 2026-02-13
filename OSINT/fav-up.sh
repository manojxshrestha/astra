#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] fav-up - Favicon Analysis${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/fav-up/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/fav-up"
        "$TOOLS_DIR/fav-up/venv/bin/python3" fav-up.py -d "$TARGET"
    elif [[ -f "$TOOLS_DIR/fav-up/fav-up.py" ]]; then
        cd "$TOOLS_DIR/fav-up"
        python3 fav-up.py -d "$TARGET"
    else
        echo -e "${YELLOW}[!] fav-up not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

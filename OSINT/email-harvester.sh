#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] EmailHarvester - Email Gathering${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/EmailHarvester/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/EmailHarvester"
        "$TOOLS_DIR/EmailHarvester/venv/bin/python3" Main.py -t "$TARGET"
    elif [[ -f "$TOOLS_DIR/EmailHarvester/Main.py" ]]; then
        cd "$TOOLS_DIR/EmailHarvester"
        python3 Main.py -t "$TARGET"
    else
        echo -e "${YELLOW}[!] EmailHarvester not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

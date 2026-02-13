#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] metagoofil - Metadata Extraction${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/metagoofil/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/metagoofil"
        mkdir -p results
        "$TOOLS_DIR/metagoofil/venv/bin/python3" metagoofil.py -d "$TARGET" -o results/
    elif [[ -f "$TOOLS_DIR/metagoofil/metagoofil.py" ]]; then
        cd "$TOOLS_DIR/metagoofil"
        mkdir -p results
        python3 metagoofil.py -d "$TARGET" -o results/
    else
        echo -e "${YELLOW}[!] metagoofil not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

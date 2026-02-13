#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] Cloud Enum - Cloud Resources${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/cloud_enum/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/cloud_enum"
        python3 cloud_enum.py -d "$TARGET"
    elif [[ -f "$TOOLS_DIR/cloud_enum/cloud_enum.py" ]]; then
        cd "$TOOLS_DIR/cloud_enum"
        python3 cloud_enum.py -d "$TARGET"
    else
        echo -e "${YELLOW}[!] cloud_enum not installed. Run: cd ~/Tools/cloud_enum && pip install -r requirements.txt${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

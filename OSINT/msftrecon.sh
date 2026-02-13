#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] msftrecon - Microsoft Recon${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/msftrecon/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/msftrecon"
        "$TOOLS_DIR/msftrecon/venv/bin/python3" msftrecon.py --domain "$TARGET"
    elif [[ -f "$TOOLS_DIR/msftrecon/msftrecon.py" ]]; then
        cd "$TOOLS_DIR/msftrecon"
        python3 msftrecon.py --domain "$TARGET"
    else
        echo -e "${YELLOW}[!] msftrecon not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] LeakSearch - Data Leak Search${NC}"
echo ""
read -p "[*] Enter company/domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/LeakSearch/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/LeakSearch"
        "$TOOLS_DIR/LeakSearch/venv/bin/python3" leaksearch.py -k "$TARGET"
    elif [[ -f "$TOOLS_DIR/LeakSearch/leaksearch.py" ]]; then
        cd "$TOOLS_DIR/LeakSearch"
        python3 leaksearch.py -k "$TARGET"
    else
        echo -e "${YELLOW}[!] LeakSearch not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

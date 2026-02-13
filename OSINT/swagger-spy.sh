#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"

echo -e "${CYAN}[*] SwaggerSpy - API Detection${NC}"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    if [[ -f "$TOOLS_DIR/SwaggerSpy/venv/bin/python3" ]]; then
        cd "$TOOLS_DIR/SwaggerSpy"
        "$TOOLS_DIR/SwaggerSpy/venv/bin/python3" swaggerspy.py -u "https://$TARGET"
    elif [[ -f "$TOOLS_DIR/SwaggerSpy/swaggerspy.py" ]]; then
        cd "$TOOLS_DIR/SwaggerSpy"
        python3 swaggerspy.py -u "https://$TARGET"
    else
        echo -e "${YELLOW}[!] SwaggerSpy not installed${NC}"
    fi
else
    echo -e "${YELLOW}[!] Missing target${NC}"
fi

#!/bin/bash

BLUE='\033[1;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}[*] Email Harvesting${NC}"
echo ""

if [[ -z "$1" ]]; then
    echo -n "[*] Enter domain to harvest emails: "
    read TARGET
else
    TARGET="$1"
fi

if [[ -z "$TARGET" ]]; then
    echo -e "${YELLOW}[!] No target specified${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[*] Harvesting emails for: $TARGET${NC}"
echo ""

if command -v theHarvester &>/dev/null; then
    echo -e "${CYAN}[*] Running theHarvester...${NC}"
    theHarvester -d "$TARGET" -b all -h 2>/dev/null | grep -E "[@]" | sort -u
    echo ""
fi

if command -v emailfinder &>/dev/null; then
    echo -e "${CYAN}[*] Running EmailFinder...${NC}"
    emailfinder -d "$TARGET" 2>/dev/null
    echo ""
fi

echo -e "${CYAN}[*] Searching via crt.sh...${NC}"
curl -s "https://crt.sh/?q=%25.${TARGET}&output=json" 2>/dev/null | jq -r '.[].name_value' 2>/dev/null | grep -E "[@]" | sort -u
echo ""

echo -e "${GREEN}[*] Email harvesting completed${NC}"

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORDLIST_DIR="$(cd "$SCRIPT_DIR/../wordlists" && pwd)"
DORKS_FILE="$WORDLIST_DIR/dorks.txt"

BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

f_banner() {
    echo ""
    echo -e "${YELLOW}Google Dorks${NC}"
    echo ""
}

clear
f_banner

if pgrep firefox > /dev/null; then
    echo "[!] Close Firefox before running script."
    echo
    exit 1
fi

echo -n "Target domain: "
read TARGET

if [ -z "$TARGET" ]; then
    echo "[!] No target specified"
    exit 1
fi

echo ""
echo -e "${BLUE}[*] Opening dorks in browser (Ctrl+C to stop)${NC}"
echo ""

while IFS= read -r dork; do
    [[ -z "$dork" || "$dork" == \#* ]] && continue
    
    DORK_URL="https://www.google.com/search?q=$(echo "$dork" | sed "s/site\.com/$TARGET/g" | sed 's/ /+/g' | sed 's/"/%22/g')"
    echo -e "${YELLOW}[*] Opening: $dork${NC}"
    xdg-open "$DORK_URL" &
    sleep 5
done < "$DORK_FILE"

echo ""
echo -e "${BLUE}[*] Done!${NC}"

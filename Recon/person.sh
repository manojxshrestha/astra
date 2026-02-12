#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

f_runlocally() {
    echo "[*] This script is designed to run locally."
}

f_banner() {
    echo ""
    echo -e "${YELLOW}Person Reconnaissance${NC}"
    echo ""
}

f_error() {
    echo "[!] Invalid choice"
    sleep 2
}

clear
f_banner

if pgrep firefox > /dev/null; then
    echo
    echo "[!] Close Firefox before running script."
    echo
    exit 1
fi

echo -e "${BLUE}RECON${NC}"
echo
echo -n "First name: "
read -r FIRST

if [ -z "$FIRST" ]; then
    f_error
fi

echo -n "Last name:  "
read -r LAST

if [ -z "$LAST" ]; then
    f_error
fi

echo "[*] Opening search results in browser..."
xdg-open https://www.whitepages.com/name/"$FIRST"-"$LAST"/ &
sleep 1
xdg-open https://www.fastbackgroundcheck.com/people/"$FIRST"-"$LAST"/ &
sleep 1
xdg-open https://www.411.com/name/"$FIRST"-"$LAST"/ &
sleep 1
URIPATH="https://www.advancedbackgroundchecks.com/search/results.aspx?type=&fn=${FIRST}&mi=&ln=${LAST}&age=&city=&state="
xdg-open "$URIPATH" &
sleep 1
xdg-open "https://www.familytreenow.com/search/genealogy/results?first=$FIRST&last=$LAST" &
sleep 1
xdg-open https://www.peekyou.com/"$FIRST"%5f"$LAST" &
sleep 1
xdg-open https://www.addresses.com/people/"$FIRST"+"$LAST" &
sleep 1
xdg-open https://radaris.com/p/"$FIRST"/"$LAST"/ &
sleep 1
xdg-open https://www.spokeo.com/"$FIRST"-"$LAST" &
sleep 1
xdg-open https://www.truepeoplesearch.com/results?name="$FIRST"%20"$LAST" &
sleep 1
xdg-open https://www.usphonebook.com/"$FIRST"-"$LAST" &
sleep 1
xdg-open https://www.facebook.com/public/"$FIRST"-"$LAST" &
sleep 1
xdg-open https://www.youtube.com/results?search_query="$FIRST"+"$LAST" &

echo ""
echo "[*] Search pages opened in browser."
echo ""

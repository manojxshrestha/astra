#!/bin/bash

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="subdomains.txt"

run_cmd() {
    local cmd="$1"
    echo -e "${CYAN}[*] Running: $cmd${NC}"
    eval "$cmd"
}

echo -e "${CYAN}${BOLD}[*] Subdomain Enumeration${NC}"
echo ""

if [[ -z "$1" ]]; then
    echo -n "[*] Enter target domain: "
    read TARGET
else
    TARGET="$1"
fi

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] No target domain specified${NC}"
    exit 1
fi

echo -e "${GREEN}[*] Enumerating subdomains for: $TARGET${NC}"
echo ""

echo -e "${CYAN}[*] Running Subfinder...${NC}"
subfinder -all -silent -d "$TARGET" 2>/dev/null | tee tmp-subfinder-$TARGET.txt &
PID1=$!

echo -e "${CYAN}[*] Running Amass...${NC}"
amass enum -passive -d "$TARGET" 2>/dev/null | tee tmp-amass-$TARGET.txt &
PID2=$!

echo -e "${CYAN}[*] Running Assetfinder...${NC}"
assetfinder --subs-only "$TARGET" 2>/dev/null | tee tmp-assetfinder-$TARGET.txt &
PID3=$!

echo -e "${CYAN}[*] Running Findomain...${NC}"
findomain -t "$TARGET" -q -r 2>/dev/null | tee tmp-findomain-$TARGET.txt &
PID4=$!

echo -e "${CYAN}[*] Running crtsh...${NC}"
curl -s "https://crt.sh/?q=%25.${TARGET}&output=json" 2>/dev/null | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | tee tmp-crtsh-$TARGET.txt &
PID5=$!

wait $PID1 $PID2 $PID3 $PID4 $PID5 2>/dev/null

echo ""
echo -e "${CYAN}[*] Merging results...${NC}"

if compgen -G "tmp-*" > /dev/null; then
    sort -u tmp-$TARGET.txt > "$OUTPUT_FILE"
    RESULT=$(wc -l < "$OUTPUT_FILE")
    echo -e "${GREEN}[+] Found $RESULT unique subdomains${NC}"
    echo -e "${GREEN}[+] Results saved to: $OUTPUT_FILE${NC}"
    rm -f tmp-$TARGET.txt
else
    echo -e "${YELLOW}[!] No subdomains found${NC}"
fi

echo ""

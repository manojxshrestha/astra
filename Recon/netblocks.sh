#!/bin/bash


OUTPUT_FILE="$HOME/netblocks.txt"
MEDIUM='=================================================================='

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo
echo "This returns a list of Class A owners."
echo
echo -n "Do you wish to continue? (y/N) "
read -r CHOICE

if [[ -z "$CHOICE" || "$CHOICE" =~ ^[Nn]$ ]]; then
    echo
    exit
elif [[ ! "$CHOICE" =~ ^[Yy]$ ]]; then
    echo
    echo "$MEDIUM"
    echo
    echo -e "${RED}[!] Invalid choice.${NC}"
    echo
    exit 1
fi

echo
echo "[*] Takes about 100 sec."
echo

trap 'rm -f tmp tmp2' EXIT

for i in $(seq 1 255); do
    echo "Querying whois for $i.0.0.0."
    whois "$i.0.0.0" | grep -E 'CIDR|OrgName' >> tmp
    echo >> tmp
done

grep -Eiv '%|no address' tmp > tmp2
cat -s tmp2 > "$OUTPUT_FILE"

rm -f tmp*

echo
echo "$MEDIUM"
echo
echo "[*] Query complete."
echo
echo -e "Results saved to ${YELLOW}$OUTPUT_FILE${NC}"
echo



SMALL='========================================'

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo
echo "Show IP addresses of subdomains."
echo
echo "Usage: target.com"
echo
echo -n "Domain: "
read -r DOMAIN

if [ -z "$DOMAIN" ]; then
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    echo -e "${RED}[!] No domain entered.${NC}"
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    exit 1
fi

if [[ ! "$DOMAIN" =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,63}$ ]]; then
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    echo -e "${RED}[!] Invalid domain.${NC}"
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    exit 1
fi

if [ ! -f /usr/share/dnsenum/dns.txt ]; then
    echo
    echo "$SMALL"
    echo
    echo -e "${RED}[!] Subdomain list not found at /usr/share/dnsenum/dns.txt${NC}"
    echo
    exit 1
fi

echo
echo "$SMALL"
echo

while IFS= read -r i; do
    if RESULT=$(host "$i.$DOMAIN" | grep 'has address'); then
        echo "$RESULT" | cut -d ' ' -f1,4 >> tmp
    else
        echo
        echo -e "${RED}[!] Failed to resolve $i.$DOMAIN${NC}"
        echo
        exit 1
    fi
done < /usr/share/dnsenum/dns.txt

if [ -s tmp ]; then
    column -t tmp | sort -u
else
    echo -e "${RED}[!] No subdomains resolved successfully.${NC}"
fi

rm -f tmp

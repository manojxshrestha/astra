

SMALL='========================================'

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo
echo -n "Enter a domain: "
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

if [[ ! "$DOMAIN" =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}$ ]]; then
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    echo -e "${RED}[!] Invalid domain.${NC}"
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    exit 1
fi

sslyze "$DOMAIN" --resum --certinfo=basic --compression --reneg --sslv2 --sslv3 --hide_rejected_ciphers > tmp

grep 'X509v3 Subject Alternative Name:' tmp | sed 's/      X509v3 Subject Alternative Name:   //g; s/, DNS:/\n/g; s/www.//g; s/DNS://g' > tmp2

sed 's/[ \t]*$//' tmp2 | sort -u > tmp3

echo
echo "$SMALL"
echo
echo "Extracted Subdomains:"
cat tmp3

rm tmp*

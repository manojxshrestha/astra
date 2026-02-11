

MEDIUM='=================================================================='

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo
echo -n "Enter the location of your folder: "
read -r LOCATION

if [ -z "$LOCATION" ]; then
    echo
    echo "$MEDIUM"
    echo
    echo -e "${RED}[!] Invalid choice or entry.${NC}"
    echo
    exit 1
fi

if [ ! -d "$LOCATION" ]; then
    echo
    echo "$MEDIUM"
    echo
    echo -e "${RED}[!] Invalid choice or entry.${NC}"
    echo
    exit 1
fi

cd "$LOCATION" || exit

if [ ! -f index.htm ]; then
    echo
    echo -e "${RED}[!] index.htm not found in $LOCATION.${NC}"
    echo
    exit 1
fi

sed -i 's|href="https://github.com/leebaird/discover"|href="https://www.acme.org"|g' index.htm
cd pages/ || exit
sed -i 's|href="https://github.com/leebaird/discover"|href="https://www.acme.org"|g' *.htm

firefox ../index.htm &

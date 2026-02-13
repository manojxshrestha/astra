#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}[*] Hash Identifier${NC}"
echo ""
echo " Identifies hash types:"
echo "  - MD4, MD5, SHA1, SHA256, SHA512"
echo "  - NTLM, MySQL, PostgreSQL"
echo "  - Bcrypt, Scrypt, Argon2"
echo "  - And many more..."
echo ""

read -p "Enter hash to identify: " HASH

if [[ -n "$HASH" ]]; then
    echo ""
    echo -e "${GREEN}[*] Identifying hash...${NC}"
    
    # Use hashid if available
    if command -v hashid &>/dev/null; then
        hashid "$HASH"
    # Fallback to length-based detection
    else
        LEN=${#HASH}
        echo ""
        echo "Hash length: $LEN characters"
        
        if [[ "$LEN" -eq 32 ]]; then
            echo "Possible: MD5, MD4, NTLM, MD2"
        elif [[ "$LEN" -eq 40 ]]; then
            echo "Possible: SHA1, RIPEMD160"
        elif [[ "$LEN" -eq 56 ]]; then
            echo "Possible: SHA224, SHA3-224"
        elif [[ "$LEN" -eq 64 ]]; then
            echo "Possible: SHA256, SHA3-256, GOST"
        elif [[ "$LEN" -eq 96 ]]; then
            echo "Possible: SHA384, SHA3-384"
        elif [[ "$LEN" -eq 128 ]]; then
            echo "Possible: SHA512, SHA3-512, Whirlpool"
        elif [[ "$HASH" =~ ^\$2[ayb]?\$ ]]; then
            echo "Possible: bcrypt"
        elif [[ "$HASH" =~ ^\$scrypt\$ ]]; then
            echo "Possible: scrypt"
        elif [[ "$HASH" =~ ^\$argon2 ]]; then
            echo "Possible: Argon2"
        else
            echo "Unknown format"
        fi
        
        echo ""
        echo -e "${YELLOW}Install hashid for better detection:${NC}"
        echo "  pip3 install hashid"
    fi
else
    echo -e "${YELLOW}[!] No hash provided${NC}"
fi

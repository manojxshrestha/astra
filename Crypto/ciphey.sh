#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}[*] Ciphey - Auto Decoder${NC}"
echo ""
echo " Ciphey automatically decrypts:"
echo "  - Base encodings (base16, base32, base64, base85)"
echo "  - Classical ciphers (Caesar, ROT13, Vigenère)"
echo "  - Hashes (MD5, SHA1, SHA256)"
echo "  - And many more..."
echo ""

# Check if input is being piped
if [[ ! -t 0 ]]; then
    TEXT=$(cat)
else
    echo -n "Enter text to decode: "
    read TEXT
fi

# Remove whitespace
TEXT=$(echo "$TEXT" | tr -d '\n\r\t ')

if [[ -z "$TEXT" ]]; then
    echo -e "${YELLOW}[!] No text provided${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}[*] Trying basic decoders...${NC}"
echo ""

DECODED_SOMETHING=0

# Try base64
DECODED=$(echo "$TEXT" | base64 -d 2>/dev/null) && if [[ -n "$DECODED" && "$DECODED" != "$TEXT" ]]; then
    echo -e "${GREEN}[+] Base64 decoded:${NC}"
    echo "$DECODED"
    echo ""
    DECODED_SOMETHING=1
fi

# Try base32 (only if input looks like base32)
if [[ "$TEXT" =~ ^[A-Z2-7=]+$ ]]; then
    DECODED_32=$(echo "$TEXT" | base32 -d 2>/dev/null) && if [[ -n "$DECODED_32" && "$DECODED_32" != "$TEXT" ]]; then
        echo -e "${GREEN}[+] Base32 decoded:${NC}"
        echo "$DECODED_32"
        echo ""
        DECODED_SOMETHING=1
    fi
fi

# Try hex (only if even length and valid hex)
if [[ $((${#TEXT} % 2)) -eq 0 && "$TEXT" =~ ^[0-9a-fA-F]+$ ]]; then
    DECODED_HEX=$(python3 -c "import binascii; print(binascii.unhexlify('$TEXT').decode('utf-8', errors='ignore'))" 2>/dev/null)
    if [[ -n "$DECODED_HEX" && "$DECODED_HEX" != "$TEXT" && "$DECODED_HEX" =~ [a-zA-Z0-9] ]]; then
        echo -e "${GREEN}[+] Hex decoded:${NC}"
        echo "$DECODED_HEX"
        echo ""
        DECODED_SOMETHING=1
    fi
fi

# Try URL decode (only if contains %)
if [[ "$TEXT" =~ % ]]; then
    DECODED_URL=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$TEXT'))" 2>/dev/null)
    if [[ -n "$DECODED_URL" && "$DECODED_URL" != "$TEXT" ]]; then
        echo -e "${GREEN}[+] URL decoded:${NC}"
        echo "$DECODED_URL"
        echo ""
        DECODED_SOMETHING=1
    fi
fi

# Try ROT13 (only if contains letters)
if [[ "$TEXT" =~ [a-zA-Z] ]]; then
    DECODED_ROT13=$(echo "$TEXT" | tr 'A-Za-z' 'N-ZA-Mn-za-m')
    if [[ -n "$DECODED_ROT13" && "$DECODED_ROT13" != "$TEXT" ]]; then
        echo -e "${GREEN}[+] ROT13 decoded:${NC}"
        echo "$DECODED_ROT13"
        echo ""
        DECODED_SOMETHING=1
    fi
fi

if [[ $DECODED_SOMETHING -eq 0 ]]; then
    echo -e "${YELLOW}[!] Could not decode automatically${NC}"
    echo ""
    echo -e "${YELLOW}[*] For full auto-decoding, use:${NC}"
    echo "   - CyberChef: https://gchq.github.io/CyberChef/"
    echo ""
fi

exit 0

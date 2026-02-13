#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"
WORDLIST_DIR="/usr/share/wordlists"

echo -e "${CYAN}[*] Hash Crack - Hashcat & John${NC}"
echo ""
echo " Choose cracking method:"
echo "   1. Hashcat - GPU accelerated"
echo "   2. John the Ripper - CPU based"
echo ""

read -p "Choice: " METHOD

if [[ "$METHOD" == "1" ]]; then
    echo ""
    echo -e "${CYAN}[*] Hashcat Mode${NC}"
    read -p "Enter hash: " HASH
    read -p "Enter hash mode (0=MD5, 100=SHA1, 1400=SHA256, etc.): " MODE
    read -p "Enter wordlist [/usr/share/wordlists/rockyou.txt]: " WORDLIST
    
    WORDLIST=${WORDLIST:-"$WORDLIST_DIR/rockyou.txt"}
    
    if [[ -n "$HASH" ]] && [[ -n "$MODE" ]]; then
        if command -v hashcat &>/dev/null; then
            echo ""
            echo -e "${GREEN}[*] Running Hashcat...${NC}"
            hashcat -m "$MODE" "$HASH" "$WORDLIST" --show
        else
            echo -e "${RED}[!] Hashcat not installed${NC}"
        fi
    else
        echo -e "${YELLOW}[!] Missing hash or mode${NC}"
    fi
    
elif [[ "$METHOD" == "2" ]]; then
    echo ""
    echo -e "${CYAN}[*] John the Ripper Mode${NC}"
    read -p "Enter hash file: " HASHFILE
    read -p "Enter wordlist [/usr/share/wordlists/rockyou.txt]: " WORDLIST
    
    WORDLIST=${WORDLIST:-"$WORDLIST_DIR/rockyou.txt"}
    
    if [[ -n "$HASHFILE" ]]; then
        if [[ -f "$HASHFILE" ]]; then
            if command -v john &>/dev/null; then
                echo ""
                echo -e "${GREEN}[*] Running John...${NC}"
                john --wordlist="$WORDLIST" "$HASHFILE"
            else
                echo -e "${RED}[!] John not installed${NC}"
            fi
        else
            echo -e "${YELLOW}[!] Hash file not found${NC}"
        fi
    else
        echo -e "${YELLOW}[!] No hash file provided${NC}"
    fi
else
    echo -e "${YELLOW}[!] Invalid choice${NC}"
fi

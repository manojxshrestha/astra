#!/bin/bash

#############################################################################
#                                                                           #
#  CRYPTOGRAPHY SUITE                                                    #
#  Cryptography & Hash Cracking Tools                                     #
#                                                                           #
#  Includes:                                                               #
#  - Cipher decryption tools                                             #
#  - RSA attack tools                                                    #
#  - Hash cracking tools                                                 #
#                                                                           #
#############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

banner() {
    echo ""
    echo -e "${CYAN}─────── CRYPTOGRAPHY SUITE ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── CRYPTOGRAPHY TOOLS ───────"
    echo ""
    echo -e "${YELLOW}Auto Decoders${NC}"
    echo "   C1.  ciphey - Auto decode (base, hex, classical ciphers)"
    echo "   C2.  codext - Exotic encodings (base91, base65536)"
    echo ""
    echo -e "${YELLOW}Classical Ciphers${NC}"
    echo "   C3.  ciphey - Classical cipher decoder"
    echo "   C4.  ctfcryptotool - Multi-cipher brute force"
    echo ""
    echo -e "${YELLOW}RSA Attacks${NC}"
    echo "   C5.  rsactftool - RSA attack toolkit"
    echo ""
    echo -e "${YELLOW}Hash Identification${NC}"
    echo "   C6.  hash-identify - Identify hash type"
    echo ""
    echo -e "${YELLOW}Hash Cracking (Hashcat)${NC}"
    echo "   C7.  MD5/MD4 cracking"
    echo "   C8.  SHA1/SHA2 cracking"
    echo "   C9.  bcrypt/scrypt/Argon2"
    echo "   C10. NTLM/Net-NTLM cracking"
    echo "   C11. MySQL/PostgreSQL cracking"
    echo "   C12. Custom hash mode"
    echo ""
    echo -e "${YELLOW}Tools${NC}"
    echo "   CA.  Install/Update Crypto Tools"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
}

run_selection() {
    local choice="$1"
    
    case "$choice" in
        C1|c1)
            echo -e "${BLUE}[*] Ciphey - Auto Decoder${NC}"
            bash "$SCRIPT_DIR/ciphey.sh"
            ;;
        C2|c2)
            echo -e "${BLUE}[*] codext - Exotic Encodings${NC}"
            bash "$SCRIPT_DIR/codext.sh"
            ;;
        C3|c3)
            echo -e "${BLUE}[*] Ciphey - Classical Cipher Decoder${NC}"
            bash "$SCRIPT_DIR/ciphey.sh"
            ;;
        C4|c4)
            echo -e "${BLUE}[*] CTF-CryptoTool - Multi-Cipher${NC}"
            bash "$SCRIPT_DIR/ctf-cryptotool.sh"
            ;;
        C5|c5)
            echo -e "${BLUE}[*] RsaCtfTool - RSA Attacks${NC}"
            bash "$SCRIPT_DIR/rsactftool.sh"
            ;;
        C6|c6)
            echo -e "${BLUE}[*] Hash Identifier${NC}"
            bash "$SCRIPT_DIR/hash-identify.sh"
            ;;
        C7|c7)
            echo -e "${BLUE}[*] MD5/MD4 Hash Cracking${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "md5"
            ;;
        C8|c8)
            echo -e "${BLUE}[*] SHA1/SHA2 Hash Cracking${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "sha"
            ;;
        C9|c9)
            echo -e "${BLUE}[*] bcrypt/scrypt/Argon2 Cracking${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "modern"
            ;;
        C10|c10)
            echo -e "${BLUE}[*] NTLM/Net-NTLM Cracking${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "ntlm"
            ;;
        C11|c11)
            echo -e "${BLUE}[*] Database Hash Cracking${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "db"
            ;;
        C12|c12)
            echo -e "${BLUE}[*] Custom Hash Mode${NC}"
            bash "$SCRIPT_DIR/hash-crack.sh" "custom"
            ;;
        CA|ca)
            echo -e "${BLUE}[*] Install/Update Crypto Tools${NC}"
            cd "$SCRIPT_DIR"
            bash install.sh
            ;;
        0)
            echo ""
            log_info "Returning to main menu..."
            return 1
            ;;
        *)
            echo -e "${RED}[!] Invalid choice: $choice${NC}"
            return 0
            ;;
    esac
}

banner

while true; do
    show_menu
    read -p "Select option (0-12, A): " choice
    
    if [[ -z "$choice" ]]; then
        continue
    fi
    
    if [[ "$choice" == "0" ]]; then
        break
    fi
    
    run_selection "$choice"
    
    echo ""
    read -p "Press Enter to continue..."
    banner
done

echo ""
log_info "Returning to main menu..."

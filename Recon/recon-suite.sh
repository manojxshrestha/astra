#!/bin/bash

#############################################################################
#                                                                           #
#  RECONNAISSANCE SUITE                                                   #
#  Phase 1: Gather information about the target                             #
#                                                                           #
#  Includes:                                                               #
#  - Passive reconnaissance (OSINT, DNS, email harvesting)                  #
#  - Active reconnaissance (network discovery, whois, traceroute)             #
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
 ║                      RECON SUITE                                         ║
 ║                   Phase 1: Information Gathering                         ║
 ║                                                                           ║
 ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  RECONNAISSANCE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Passive Reconnaissance${NC}"
    echo "   R1.  Domain Information (whois, dig, nslookup)"
    echo "   R2.  DNS Enumeration"
    echo "   R3.  Email Harvesting"
    echo "   R4.  Subdomain Discovery"
    echo "   R5.  Google Dorks (Google Hacking)"
    echo "   R6.  Social Media Recon"
    echo ""
    echo -e "${YELLOW}Active Reconnaissance${NC}"
    echo "   R7.  Network Discovery (ping sweep)"
    echo "   R8.  Traceroute"
    echo "   R9.  Port Scanning (basic)"
    echo "   R10. OS Fingerprinting"
    echo ""
    echo -e "${YELLOW}Tools & Automation${NC}"
    echo "   RA.  Run All Recon Scripts"
    echo "   RB.  Reconnaissance from List"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

run_recon_script() {
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

show_tools() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  RECONNAISSANCE TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Scripts Location: $SCRIPT_DIR"
    echo ""
    find "$SCRIPT_DIR" -name "*.sh" -type f 2>/dev/null | while read -r script; do
        echo "  $(basename "$script")"
    done
}

usage() {
    cat << EOF
USAGE: $0 [OPTIONS]

OPTIONS:
    R1                      Domain information gathering
    R2                      DNS enumeration
    R3                      Email harvesting
    R4                      Subdomain discovery
    R5                      Google dorks
    R7                      Network discovery (ping sweep)
    R8                      Traceroute
    --menu                  Show interactive menu
    --help                  Show this help
    --paths                 Show tool paths

EXAMPLES:
    $0 R1 example.com
    $0 R2 example.com
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        R1|r1)
            log_info "Running Domain Information Gathering..."
            run_recon_script "domain.sh" "$@"
            ;;
        R2|r2)
            log_info "Running DNS Enumeration..."
            run_recon_script "passive.sh" "$@"
            ;;
        R3|r3)
            log_info "Running Email Harvesting..."
            run_recon_script "person.sh" "$@"
            ;;
        R4|r4)
            log_info "Running Subdomain Discovery..."
            run_recon_script "generateTargets.sh" "$@"
            ;;
        R5|r5)
            log_info "Running Google Dorks..."
            log_warn "Google Dorks require manual research"
            echo "Common dorks:"
            echo "  site:example.com"
            echo "  filetype:xls site:example.com"
            echo "  intitle:\"index of\" site:example.com"
            ;;
        R7|r7)
            log_info "Running Network Discovery (Ping Sweep)..."
            run_recon_script "ping-sweep.sh" "$@"
            ;;
        R8|r8)
            log_info "Running Traceroute..."
            run_recon_script "dns-forward.sh" "$@"
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
        --paths)
            show_tools
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

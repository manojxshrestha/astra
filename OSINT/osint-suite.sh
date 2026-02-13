#!/bin/bash

#############################################################################
#                                                                           #
#  OSINT SUITE                                                            #
#  Phase 1: Information Gathering                                         #
#                                                                           #
#  Includes:                                                               #
#  - Full OSINT automation (osint.sh)                                     #
#  - Individual OSINT tools                                                #
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

banner() {
    echo ""
    echo -e "${CYAN}─────── OSINT SUITE ───────"
    echo -e "─────── Phase 1: Information Gathering ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── OSINT TOOLS ───────"
    echo ""
    echo -e "${YELLOW}Full Automation${NC}"
    echo "   O1.  osint - Full OSINT Scan"
    echo ""
    echo -e "${YELLOW}Domain Reconnaissance${NC}"
    echo "   O2.  cloud-enum - Cloud resources"
    echo "   O3.  dorks-hunter - Google dorks"
    echo "   O4.  whois - Whois lookup"
    echo ""
    echo -e "${YELLOW}Email & People${NC}"
    echo "   O5.  email-harvester - Email gathering"
    echo "   O6.  leak-search - Data leak search"
    echo ""
    echo -e "${YELLOW}Technical Recon${NC}"
    echo "   O7.  fav-up - Favicon analysis"
    echo "   O8.  metagoofil - Metadata extraction"
    echo "   O9.  swagger-spy - API detection"
    echo ""
    echo -e "${YELLOW}Third Party${NC}"
    echo "   O10. spoofy - SPF/DMARC checks"
    echo "   O11. msftrecon - Microsoft recon"
    echo ""
    echo -e "${YELLOW}Tools${NC}"
    echo "   OA.  Install/Update OSINT Tools"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
}

run_selection() {
    local choice="$1"
    
    case "$choice" in
        O1|o1)
            echo -e "${BLUE}[*] Full OSINT Scan${NC}"
            cd "$SCRIPT_DIR"
            bash osint.sh
            ;;
        O2|o2)
            echo -e "${BLUE}[*] Cloud Enum${NC}"
            bash "$SCRIPT_DIR/cloud-enum.sh"
            ;;
        O3|o3)
            echo -e "${BLUE}[*] Dorks Hunter${NC}"
            bash "$SCRIPT_DIR/dorks-hunter.sh"
            ;;
        O4|o4)
            echo -e "${BLUE}[*] Whois Lookup${NC}"
            bash "$SCRIPT_DIR/whois.sh"
            ;;
        O5|o5)
            echo -e "${BLUE}[*] EmailHarvester${NC}"
            bash "$SCRIPT_DIR/email-harvester.sh"
            ;;
        O6|o6)
            echo -e "${BLUE}[*] LeakSearch${NC}"
            bash "$SCRIPT_DIR/leak-search.sh"
            ;;
        O7|o7)
            echo -e "${BLUE}[*] fav-up${NC}"
            bash "$SCRIPT_DIR/fav-up.sh"
            ;;
        O8|o8)
            echo -e "${BLUE}[*] metagoofil${NC}"
            bash "$SCRIPT_DIR/metagoofil.sh"
            ;;
        O9|o9)
            echo -e "${BLUE}[*] SwaggerSpy${NC}"
            bash "$SCRIPT_DIR/swagger-spy.sh"
            ;;
        O10|o10)
            echo -e "${BLUE}[*] Spoofy${NC}"
            bash "$SCRIPT_DIR/spoofy.sh"
            ;;
        O11|o11)
            echo -e "${BLUE}[*] msftrecon${NC}"
            bash "$SCRIPT_DIR/msftrecon.sh"
            ;;
        OA|oa)
            echo -e "${BLUE}[*] Install/Update OSINT Tools${NC}"
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
    read -p "Select option (0-11, A): " choice
    
    if [[ "$choice" == "0" ]]; then
        break
    fi
    
    run_selection "$choice" || break
    
    echo ""
    read -p "Press Enter to continue..."
    banner
done

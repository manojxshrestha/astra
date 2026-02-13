#!/bin/bash

#############################################################################
#                                                                           #
#  OSINT SUITE                                                            #
#  Phase 1: OSINT & Information Gathering                                 #
#                                                                           #
#  Includes:                                                               #
#  - infoshyt - Full OSINT automation                                     #
#  - Individual OSINT tools                                               #
#                                                                           #
#############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFOSHYT_DIR="$SCRIPT_DIR"
TOOLS_DIR="$HOME/Tools"

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

banner() {
    echo ""
    echo -e "${CYAN}─────── OSINT SUITE ───────"
    echo -e "─────── Information Gathering ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── OSINT TOOLS ───────"
    echo ""
    echo -e "${YELLOW}Full Automation${NC}"
    echo "   O1.  infoshyt - Full OSINT Scan"
    echo ""
    echo -e "${YELLOW}Domain Reconnaissance${NC}"
    echo "   O2.  Cloud Enum - Cloud resources"
    echo "   O3.  Dorks Hunter - Google dorks"
    echo "   O4.  Subdomain Enumeration"
    echo "   O5.  Whois Lookup"
    echo ""
    echo -e "${YELLOW}Email & People${NC}"
    echo "   O6.  EmailHarvester - Email gathering"
    echo "   O7.  LeakSearch - Data leak search"
    echo ""
    echo -e "${YELLOW}Technical Recon${NC}"
    echo "   O8.  fav-up - Favicon analysis"
    echo "   O9.  metagoofil - Metadata extraction"
    echo "   O10. SwaggerSpy - API detection"
    echo ""
    echo -e "${YELLOW}Third Party${NC}"
    echo "   O11. Spoofy - SPF/DMARC checks"
    echo "   O12. msftrecon - Microsoft recon"
    echo ""
    echo -e "${YELLOW}Tools${NC}"
    echo "   OA.  Install/Update OSINT Tools"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
}

run_cmd() {
    local cmd="$1"
    echo -e "${GREEN}[>] Running: ${cmd}${NC}"
    eval "$cmd"
}

check_tools() {
    log_info "Checking OSINT tools..."
    [[ -d "$INFOSHYT_DIR" ]] && log_good "infoshyt: Found" || log_warn "infoshyt: Not found"
    [[ -d "$TOOLS_DIR" ]] && log_good "Tools: Found" || log_warn "Tools: Not found"
}

handle_selection() {
    local choice="$1"
    
    case "$choice" in
        O1|o1)
            echo -e "${BLUE}[*] infoshyt - Full OSINT Scan${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$INFOSHYT_DIR"
                run_cmd "bash infoshyt.sh -d $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O2|o2)
            echo -e "${BLUE}[*] Cloud Enum${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/cloud_enum"
                run_cmd "python3 cloud_enum.py -d $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O3|o3)
            echo -e "${BLUE}[*] Dorks Hunter${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/dorks_hunter"
                run_cmd "python3 gitdorks_go.py -gh $TARGET -w wordlist.txt"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O4|o4)
            echo -e "${BLUE}[*] Subdomain Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$INFOSHYT_DIR"
                run_cmd "bash infoshyt.sh -d $TARGET -GOOGLE false -GITHUB false -METADATA false"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O5|o5)
            echo -e "${BLUE}[*] Whois Lookup${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                run_cmd "whois $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O6|o6)
            echo -e "${BLUE}[*] EmailHarvester${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/EmailHarvester"
                run_cmd "python3 Main.py -t $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O7|o7)
            echo -e "${BLUE}[*] LeakSearch${NC}"
            echo ""
            echo -n "[*] Enter company/domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/LeakSearch"
                run_cmd "python3 leaksearch.py -k $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O8|o8)
            echo -e "${BLUE}[*] fav-up - Favicon Analysis${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/fav-up"
                run_cmd "python3 fav-up.py -d $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O9|o9)
            echo -e "${BLUE}[*] metagoofil - Metadata Extraction${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/metagoofil"
                run_cmd "python3 metagoofil.py -d $TARGET -o results/"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O10|o10)
            echo -e "${BLUE}[*] SwaggerSpy - API Detection${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/SwaggerSpy"
                run_cmd "python3 swaggerspy.py -u https://$TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O11|o11)
            echo -e "${BLUE}[*] Spoofy - SPF/DMARC Checks${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/Spoofy"
                run_cmd "python3 spoofy.py -d $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        O12|o12)
            echo -e "${BLUE}[*] msftrecon - Microsoft Recon${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            if [[ -n "$TARGET" ]]; then
                cd "$TOOLS_DIR/msftrecon"
                run_cmd "python3 msftrecon.py --domain $TARGET"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        OA|oa)
            echo -e "${BLUE}[*] Install/Update OSINT Tools${NC}"
            echo ""
            cd "$INFOSHYT_DIR"
            run_cmd "bash install.sh"
            ;;
        0)
            echo ""
            log_info "Returning to main menu..."
            break
            ;;
        *)
            echo -e "${RED}[!] Invalid choice: $choice${NC}"
            ;;
    esac
}

banner
check_tools

while true; do
    show_menu
    read -p "Select option (0-9, A): " choice
    
    case "$choice" in
        0)
            echo ""
            log_info "Returning to main menu..."
            break
            ;;
        *)
            handle_selection "$choice"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    banner
done


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

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
    echo ""
    echo -e "${CYAN}─────── RECON SUITE ───────"
    echo -e "─────── Phase 1: Information Gathering ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── RECONNAISSANCE ───────"
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
}

show_tools() {
    echo ""
    echo -e "${CYAN}─────── RECONNAISSANCE TOOLS ───────"
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
    R1                       Domain information gathering
    R2                       DNS enumeration
    R3                       Email harvesting
    R4                       Subdomain discovery
    R5                       Google dorks
    R6                       Social media recon
    R7                       Network discovery (ping sweep)
    R8                       Traceroute
    R9                       Basic port scanning
    R10                      OS fingerprinting
    RA                       Run all recon scripts
    RB                       Reconnaissance from list file
    --menu                   Show interactive menu
    --help                   Show this help
    --paths                  Show tool paths

EXAMPLES:
    $0 R1 example.com
    $0 R2 example.com
    $0 RA example.com
    $0 RB targets.txt
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
        R1|r1)
            echo -e "${BLUE}[*] Domain Information Gathering${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/domain.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/domain.sh ${TARGET}"
                elif command -v whois &>/dev/null; then
                    run_cmd "whois ${TARGET}"
                else
                    echo -e "${YELLOW}[!] domain.sh or whois not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R2|r2)
            echo -e "${BLUE}[*] DNS Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/passive.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/passive.sh ${TARGET}"
                else
                    run_cmd "dig +short ${TARGET}"
                    run_cmd "nslookup ${TARGET}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R3|r3)
            echo -e "${BLUE}[*] Email Harvesting${NC}"
            echo ""
            echo -n "[*] Enter domain or email to harvest: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/person.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/person.sh ${TARGET}"
                elif command -v theHarvester &>/dev/null; then
                    run_cmd "theHarvester -d ${TARGET} -b all"
                else
                    echo -e "${YELLOW}[!] person.sh or theHarvester not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R4|r4)
            echo -e "${BLUE}[*] Subdomain Discovery${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/generateTargets.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/generateTargets.sh ${TARGET}"
                elif command -v sublist3r &>/dev/null; then
                    run_cmd "sublist3r -d ${TARGET}"
                elif command -v assetfinder &>/dev/null; then
                    run_cmd "assetfinder --subs-only ${TARGET}"
                else
                    echo -e "${YELLOW}[!] No subdomain tool found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R5|r5)
            echo -e "${BLUE}[*] Google Dorks${NC}"
            echo ""
            echo "[*] Common Google Dorks:"
            echo "    site:example.com"
            echo "    site:example.com filetype:xls"
            echo "    site:example.com inurl:admin"
            echo "    site:example.com intitle:\"index of\""
            echo "    site:example.com filetype:pdf"
            echo ""
            echo -n "[*] Press Enter to continue... "
            read
            ;;
        R6|r6)
            echo -e "${BLUE}[*] Social Media Recon${NC}"
            echo ""
            echo "[*] Resources for social media reconnaissance:"
            echo "    - LinkedIn: company employees, structure"
            echo "    - Twitter: tech stack, mentions, job postings"
            echo "    - GitHub: code, credentials, activity"
            echo "    - Crunchbase: company info, funding"
            echo "    - Hunter.io: email discovery"
            echo ""
            echo -n "[*] Press Enter to continue... "
            read
            ;;
        R7|r7)
            echo -e "${BLUE}[*] Network Discovery (Ping Sweep)${NC}"
            echo ""
            echo -n "[*] Enter target CIDR (e.g., 192.168.1.0/24): "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -sn ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R8|r8)
            echo -e "${BLUE}[*] Traceroute${NC}"
            echo ""
            echo -n "[*] Enter target hostname or IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "traceroute ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R9|r9)
            echo -e "${BLUE}[*] Basic Port Scan${NC}"
            echo ""
            echo -n "[*] Enter target IP or CIDR: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -F ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        R10|r10)
            echo -e "${BLUE}[*] OS Fingerprinting${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -O --osscan-guess ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        RA|ra)
            echo -e "${BLUE}[*] Run All Recon Scripts${NC}"
            echo ""
            echo -n "[*] Enter target domain: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                echo "[*] Running recon scripts on: ${TARGET}"
                echo ""
                [[ -x "$SCRIPT_DIR/domain.sh" ]] && run_cmd "$SCRIPT_DIR/domain.sh ${TARGET}"
                [[ -x "$SCRIPT_DIR/passive.sh" ]] && run_cmd "$SCRIPT_DIR/passive.sh ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        RB|rb)
            echo -e "${BLUE}[*] Reconnaissance from List${NC}"
            echo ""
            echo -n "[*] Enter target list file path: "
            read LIST_FILE
            echo ""
            if [[ -f "$LIST_FILE" ]]; then
                echo "[*] Processing targets from: ${LIST_FILE}"
                while IFS= read -r target; do
                    if [[ -n "$target" && "$target" != \#* ]]; then
                        echo ""
                        echo "[*] Processing: ${target}"
                        [[ -x "$SCRIPT_DIR/domain.sh" ]] && run_cmd "$SCRIPT_DIR/domain.sh ${target}" 2>/dev/null || true
                    fi
                done < "$LIST_FILE"
            else
                echo -e "${YELLOW}[!] File not found: ${LIST_FILE}${NC}"
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

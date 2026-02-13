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
    echo -e "${CYAN}─────── ENUM SUITE ───────"
    echo -e "─────── Phase 2: Identify Weaknesses ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── ENUMERATION & VULNERABILITY ANALYSIS ───────"
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
    E1                       Quick port scan
    E2                       Full port scan
    E3                       Service version detection
    E4                       OS fingerprinting
    E5                       UDP port scan
    E6                       HTTP/HTTPS enumeration
    E7                       SMB/Samba enumeration
    E8                       SNMP enumeration
    E9                       FTP enumeration
    E10                      SSH enumeration
    EV1                      Nikto web scanner
    EV2                      SSL/TLS analysis
    EV3                      Directory busting
    EV4                      Web API/CVE scanner
    EV5                      Vulnerability check lists
    --menu                   Show interactive menu
    --help                   Show this help

EXAMPLES:
    $0 E1 192.168.1.0/24
    $0 E4 192.168.1.1
    $0 EV1 http://example.com
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
        E1|e1)
            echo -e "${BLUE}[*] Quick Port Scan (nmap -F)${NC}"
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
        E2|e2)
            echo -e "${BLUE}[*] Full Port Scan (nmap -p-)${NC}"
            echo ""
            echo -n "[*] Enter target IP or CIDR: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -p- ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E3|e3)
            echo -e "${BLUE}[*] Service Version Detection${NC}"
            echo ""
            echo -n "[*] Enter target IP or CIDR: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/nse.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/nse.sh ${TARGET}"
                else
                    run_cmd "nmap -sV ${TARGET}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E4|e4)
            echo -e "${BLUE}[*] OS Fingerprinting${NC}"
            echo ""
            echo -n "[*] Enter target IP or CIDR: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -O --osscan-guess ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E5|e5)
            echo -e "${BLUE}[*] UDP Port Scan${NC}"
            echo ""
            echo -n "[*] Enter target IP or CIDR: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -sU ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E6|e6)
            echo -e "${BLUE}[*] HTTP/HTTPS Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target URL: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/web-tech.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/web-tech.sh ${TARGET}"
                else
                    echo -e "${YELLOW}[!] web-tech.sh not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E7|e7)
            echo -e "${BLUE}[*] SMB/Samba Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -p139,445 --script=smb-enum-shares.nse,smb-enum-users.nse ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E8|e8)
            echo -e "${BLUE}[*] SNMP Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -p161 --script=snmp-brute.nse,snmp-info.nse ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E9|e9)
            echo -e "${BLUE}[*] FTP Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -p21 --script=ftp-anon.nse,ftp-brute.nse ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        E10|e10)
            echo -e "${BLUE}[*] SSH Enumeration${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                run_cmd "nmap -p22 --script=ssh-brute.nse,ssh2-enum-algos.nse ${TARGET}"
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        EV1|ev1)
            echo -e "${BLUE}[*] Nikto Web Scanner${NC}"
            echo ""
            echo -n "[*] Enter target URL: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if command -v nikto &>/dev/null; then
                    run_cmd "nikto -h ${TARGET}"
                else
                    echo -e "${YELLOW}[!] nikto not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        EV2|ev2)
            echo -e "${BLUE}[*] SSL/TLS Analysis${NC}"
            echo ""
            echo -n "[*] Enter target IP or hostname: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/../Exploit/ssl.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/../Exploit/ssl.sh ${TARGET}"
                elif command -v sslscan &>/dev/null; then
                    run_cmd "sslscan ${TARGET}"
                elif command -v testssl &>/dev/null; then
                    run_cmd "testssl ${TARGET}"
                else
                    echo -e "${YELLOW}[!] SSL scanning tool not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        EV3|ev3)
            echo -e "${BLUE}[*] Directory Busting${NC}"
            echo ""
            echo -n "[*] Enter target URL: "
            read URL
            echo -n "[*] Enter wordlist path: "
            read WORDLIST
            echo ""
            if [[ -n "$URL" && -n "$WORDLIST" ]]; then
                if command -v gobuster &>/dev/null; then
                    run_cmd "gobuster dir -w ${WORDLIST} -u ${URL}"
                elif command -v dirsearch &>/dev/null; then
                    run_cmd "dirsearch -u ${URL} -w ${WORDLIST}"
                else
                    echo -e "${YELLOW}[!] gobuster or dirsearch not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing URL or wordlist${NC}"
            fi
            ;;
        EV4|ev4)
            echo -e "${BLUE}[*] Web API/CVE Scanner${NC}"
            echo ""
            echo -n "[*] Enter target IP or hostname: "
            read TARGET
            echo ""
            if [[ -n "$TARGET" ]]; then
                if [[ -x "$SCRIPT_DIR/cve.sh" ]]; then
                    run_cmd "$SCRIPT_DIR/cve.sh ${TARGET}"
                else
                    echo -e "${YELLOW}[!] cve.sh not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing target${NC}"
            fi
            ;;
        EV5|ev5)
            echo -e "${BLUE}[*] Vulnerability Check Lists${NC}"
            echo ""
            echo "[*] Useful resources for vulnerability checking:"
            echo "    - https://cve.mitre.org"
            echo "    - https://www.exploit-db.com"
            echo "    - https://nvd.nist.gov"
            echo ""
            echo -n "[*] Press Enter to continue... "
            read
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

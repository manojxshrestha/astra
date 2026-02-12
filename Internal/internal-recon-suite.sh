#!/bin/bash

#############################################################################
#                                                                           #
#  INTERNAL RECONNAISSANCE SUITE                                            #
#  Phase 6: Enumerate internal network and resources                        #
#                                                                           #
#  Includes:                                                               #
#  - User and group enumeration                                             #
#  - Network resource discovery                                             #
#  - Service enumeration                                                    #
#  - Domain information gathering                                          #
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
║                                                                           ║
║              INTERNAL RECONNAISSANCE SUITE                                ║
║              Phase 6: Enumerate internal network and resources             ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  INTERNAL RECONNAISSANCE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}User & Group Enumeration${NC}"
    echo "   I1.  Current User Info"
    echo "   I2.  All Users on System"
    echo "   I3.  Groups and Memberships"
    echo "   I4.  Sudo Privileges"
    echo ""
    echo -e "${YELLOW}Network Enumeration${NC}"
    echo "   I5.  Network Interfaces"
    echo "   I6.  ARP Table"
    echo "   I7.  Routing Table"
    echo "   I8.  DNS Information"
    echo "   I9.  Active Connections"
    echo ""
    echo -e "${YELLOW}Service Enumeration${NC}"
    echo "   I10. Running Services"
    echo "   I11. Installed Software"
    echo "   I12. Cron Jobs"
    echo "   I13. Mounted Filesystems"
    echo ""
    echo -e "${YELLOW}Domain Enumeration (Windows)${NC}"
    echo "   ID1. Domain Users"
    echo "   ID2. Domain Groups"
    echo "   ID3. Domain Computers"
    echo "   ID4. Domain Trusts"
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
    I1                      Current user info
    I5                      Network interfaces
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 I1
    $0 I5
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
        I1|i1)
            echo -e "${BLUE}[*] Current User Info${NC}"
            echo ""
            run_cmd "whoami"
            run_cmd "id"
            ;;
        I2|i2)
            echo -e "${BLUE}[*] All Users on System${NC}"
            echo ""
            run_cmd "cat /etc/passwd"
            ;;
        I3|i3)
            echo -e "${BLUE}[*] Groups and Memberships${NC}"
            echo ""
            run_cmd "groups"
            run_cmd "id"
            ;;
        I4|i4)
            echo -e "${BLUE}[*] Sudo Privileges${NC}"
            echo ""
            run_cmd "sudo -l"
            ;;
        I5|i5)
            echo -e "${BLUE}[*] Network Interfaces${NC}"
            echo ""
            if command -v ip &>/dev/null; then
                run_cmd "ip addr"
            else
                run_cmd "ifconfig -a"
            fi
            ;;
        I6|i6)
            echo -e "${BLUE}[*] ARP Table${NC}"
            echo ""
            if command -v ip &>/dev/null; then
                run_cmd "ip neigh"
            else
                run_cmd "arp -a"
            fi
            ;;
        I7|i7)
            echo -e "${BLUE}[*] Routing Table${NC}"
            echo ""
            if command -v ip &>/dev/null; then
                run_cmd "ip route"
            else
                run_cmd "route -n"
            fi
            ;;
        I8|i8)
            echo -e "${BLUE}[*] DNS Information${NC}"
            echo ""
            run_cmd "cat /etc/resolv.conf"
            ;;
        I9|i9)
            echo -e "${BLUE}[*] Active Connections${NC}"
            echo ""
            if command -v ss &>/dev/null; then
                run_cmd "ss -tulpn"
            else
                run_cmd "netstat -ant"
            fi
            ;;
        I10)
            echo -e "${BLUE}[*] Running Services${NC}"
            echo ""
            if command -v systemctl &>/dev/null; then
                run_cmd "systemctl list-units --type=service --no-pager"
            fi
            run_cmd "ps aux --no-headers | head -50"
            ;;
        I11)
            echo -e "${BLUE}[*] Installed Software${NC}"
            echo ""
            if command -v dpkg &>/dev/null; then
                run_cmd "dpkg -l | grep -v '^ii' | head -20"
            elif command -v rpm &>/dev/null; then
                run_cmd "rpm -qa --last | head -20"
            fi
            ;;
        I12)
            echo -e "${BLUE}[*] Cron Jobs${NC}"
            echo ""
            run_cmd "cat /etc/crontab"
            echo ""
            echo "[*] Cron directories:"
            ls -la /etc/cron.d/ 2>/dev/null
            ls -la /etc/cron.hourly/ 2>/dev/null
            ls -la /etc/cron.daily/ 2>/dev/null
            ;;
        I13)
            echo -e "${BLUE}[*] Mounted Filesystems${NC}"
            echo ""
            run_cmd "mount"
            echo ""
            run_cmd "cat /etc/fstab"
            ;;
        ID1)
            echo -e "${BLUE}[*] Domain Users (Windows)${NC}"
            echo ""
            if command -v net &>/dev/null; then
                run_cmd "net user /domain"
            elif command -v Get-ADUser &>/dev/null; then
                run_cmd "Get-ADUser -Filter * | Select-Object Name | head -20"
            else
                echo -e "${YELLOW}[!] Windows AD tools not available${NC}"
            fi
            ;;
        ID2)
            echo -e "${BLUE}[*] Domain Groups (Windows)${NC}"
            echo ""
            if command -v net &>/dev/null; then
                run_cmd "net group /domain"
            elif command -v Get-ADGroup &>/dev/null; then
                run_cmd "Get-ADGroup -Filter * | Select-Object Name | head -20"
            else
                echo -e "${YELLOW}[!] Windows AD tools not available${NC}"
            fi
            ;;
        ID3)
            echo -e "${BLUE}[*] Domain Computers (Windows)${NC}"
            echo ""
            if command -v net &>/dev/null; then
                run_cmd "net view /domain /computers"
            elif command -v Get-ADComputer &>/dev/null; then
                run_cmd "Get-ADComputer -Filter * | Select-Object Name | head -20"
            else
                echo -e "${YELLOW}[!] Windows AD tools not available${NC}"
            fi
            ;;
        ID4)
            echo -e "${BLUE}[*] Domain Trusts (Windows)${NC}"
            echo ""
            if command -v nltest &>/dev/null; then
                run_cmd "nltest /domain_trusts"
            elif command -v Get-ADTrust &>/dev/null; then
                run_cmd "Get-ADTrust -Filter *"
            else
                echo -e "${YELLOW}[!] Windows AD tools not available${NC}"
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

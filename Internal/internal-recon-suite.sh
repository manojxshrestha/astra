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
    
    case "$choice" in
        I1|i1)
            log_info "Current User Info"
            echo "whoami"
            echo "id"
            echo "whoami /priv"
            ;;
        I2|i2)
            log_info "All Users on System"
            echo "cat /etc/passwd"
            ;;
        I3|i3)
            log_info "Groups and Memberships"
            echo "groups"
            echo "id"
            ;;
        I4|i4)
            log_info "Sudo Privileges"
            echo "sudo -l"
            ;;
        I5|i5)
            log_info "Network Interfaces"
            echo "ip addr"
            echo "ifconfig -a"
            ;;
        I6|i6)
            log_info "ARP Table"
            echo "ip neigh"
            echo "arp -a"
            ;;
        I7|i7)
            log_info "Routing Table"
            echo "ip route"
            echo "route -n"
            ;;
        I8|i8)
            log_info "DNS Information"
            echo "cat /etc/resolv.conf"
            echo "nslookup"
            ;;
        I9|i9)
            log_info "Active Connections"
            echo "netstat -ant"
            echo "ss -tulpn"
            ;;
        I10)
            log_info "Running Services"
            echo "ps aux"
            echo "systemctl list-units --type=service"
            ;;
        I11)
            log_info "Installed Software"
            echo "dpkg -l"
            echo "rpm -qa"
            ;;
        I12)
            log_info "Cron Jobs"
            echo "cat /etc/crontab"
            echo "ls -la /etc/cron.d/"
            ;;
        I13)
            log_info "Mounted Filesystems"
            echo "mount"
            echo "cat /etc/fstab"
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

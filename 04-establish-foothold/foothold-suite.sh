#!/bin/bash

#############################################################################
#                                                                           #
#  ESTABLISH FOOTHOLD SUITE                                                #
#  Phase 4: Stabilize and maintain access                                   #
#                                                                           #
#  Includes:                                                               #
#  - Shell stabilization                                                   #
#  - Reverse shell listeners                                               #
#  - Session management                                                    #
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
║              ESTABLISH FOOTHOLD SUITE                                     ║
║              Phase 4: Stabilize and maintain access                        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ESTABLISH FOOTHOLD${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Shell Stabilization${NC}"
    echo "   F1.  Python PTY Spawn"
    echo "   F2.  Shell Upgrade Commands"
    echo "   F3.  Terminal Settings"
    echo ""
    echo -e "${YELLOW}Reverse Shell Listeners${NC}"
    echo "   F4.  Netcat Listener"
    echo "   F5.  Metasploit Handler"
    echo "   F6.  Multi-handler"
    echo ""
    echo -e "${YELLOW}Session Management${NC}"
    echo "   F7.  Check Active Sessions"
    echo "   F8.  Background/Foreground Sessions"
    echo "   F9.  Upgrade Shell to Meterpreter"
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
    F1                      Python PTY spawn
    F4                      Netcat listener
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 F1
    $0 F4 443
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        F1|f1)
            log_info "Python PTY Spawn"
            echo "python -c 'import pty; pty.spawn(\"/bin/bash\")'"
            echo "python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
            ;;
        F2|f2)
            log_info "Shell Upgrade Commands"
            echo "Ctrl+Z"
            echo "stty raw -echo; fg"
            echo "reset"
            echo "stty rows 24 cols 80"
            ;;
        F3|f3)
            log_info "Terminal Settings"
            echo "export TERM=xterm"
            echo "export TERM=xterm-256color"
            ;;
        F4|f4)
            log_info "Netcat Listener"
            echo "nc -lvnp <port>"
            echo "nc -lvnp 443"
            ;;
        F5|f5)
            log_info "Metasploit Handler"
            echo "use exploit/multi/handler"
            echo "set payload linux/x64/meterpreter_reverse_tcp"
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

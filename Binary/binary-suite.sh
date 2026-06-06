#!/bin/bash

#############################################################################
#                                                                           #
#  BINARY/REVERSING SUITE                                                 #
#  Phase X: Binary Exploitation & Reversing                                 #
#                                                                           #
#  Includes:                                                               #
#  - pwnpasi - Automated binary exploitation                                #
#  - ROPgadget - ROP chain finder                                           #
#  - checksec - Binary protection analysis                                   #
#  - pwndbg - GDB plugin for pwning                                        #
#                                                                           #
#############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PWNPASI_DIR="$HOME/pwnpasi"
ROPGADGET_DIR="$HOME/ROPgadget"

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

banner() {
    echo ""
    echo -e "${CYAN}─────── BINARY/REVERSING SUITE ───────"
    echo -e "─────── Binary Exploitation & Reversing ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── BINARY EXPLOITATION ───────"
    echo ""
    echo -e "${YELLOW}Automated Exploitation${NC}"
    echo "   B1.  PwnPasi - Auto Binary Exploitation"
    echo "   B2.  ROPgadget - Find ROP Gadgets"
    echo ""
    echo -e "${YELLOW}Binary Analysis${NC}"
    echo "   B3.  Checksec - Binary Protections"
    echo "   B4.  Extract Strings"
    echo "   B5.  objdump - Disassemble Binary"
    echo ""
    echo -e "${YELLOW}Debugging${NC}"
    echo "   B6.  pwndbg - GDB Plugin Info"
    echo "   B7.  Pwntools - Interactive Debugger"
    echo ""
    echo -e "${YELLOW}Tools${NC}"
    echo "   BA.  Install/Update All Tools"
    echo ""
    echo -e "${RED}0. Exit to Main Menu${NC}"
    echo ""
}

run_cmd() {
    local cmd="$1"
    echo -e "${GREEN}[>] Running: ${cmd}${NC}"
    bash -c "$cmd"
}

check_tools() {
    log_info "Checking tools..."
    
    [[ -d "$PWNPASI_DIR" ]] && log_good "pwnpasi: Found" || log_warn "pwnpasi: Not found"
    [[ -d "$ROPGADGET_DIR" ]] && log_good "ROPgadget: Found" || log_warn "ROPgadget: Not found"
    command -v checksec &>/dev/null && log_good "checksec: Found" || log_warn "checksec: Not found"
    command -v pwndbg &>/dev/null && log_good "pwndbg: Found" || log_warn "pwndbg: Not installed"
}

handle_selection() {
    local choice="$1"
    
    case "$choice" in
        B1|b1)
            echo -e "${BLUE}[*] PwnPasi - Automated Binary Exploitation${NC}"
            echo ""
            if [[ ! -d "$PWNPASI_DIR" ]]; then
                echo -e "${YELLOW}[!] pwnpasi not found. Install from ~/pwnpasi${NC}"
                exit 1
            fi
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                echo -n "[*] Enter target IP (press Enter for local): "
                read IP
                echo -n "[*] Enter target port (press Enter for local): "
                read PORT
                
                if [[ -n "$IP" && -n "$PORT" ]]; then
                    run_cmd "cd $PWNPASI_DIR && python3 pwnpasi.py -l '$BINARY' -ip $IP -p $PORT"
                else
                    run_cmd "cd $PWNPASI_DIR && python3 pwnpasi.py -l '$BINARY'"
                fi
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        B2|b2)
            echo -e "${BLUE}[*] ROPgadget - Find ROP Gadgets${NC}"
            echo ""
            if [[ ! -d "$ROPGADGET_DIR" ]]; then
                echo -e "${YELLOW}[!] ROPgadget not found. Install from ~/ROPgadget${NC}"
                exit 1
            fi
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                run_cmd "python3 $ROPGADGET_DIR/ROPgadget.py --binary '$BINARY'"
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        B3|b3)
            echo -e "${BLUE}[*] Checksec - Binary Protection Analysis${NC}"
            echo ""
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                if command -v checksec &>/dev/null; then
                    run_cmd "checksec --file='$BINARY'"
                else
                    run_cmd "file '$BINARY'"
                    run_cmd "readelf -l '$BINARY' 2>/dev/null | grep STACK"
                    run_cmd "readelf -h '$BINARY' 2>/dev/null"
                fi
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        B4|b4)
            echo -e "${BLUE}[*] Extract Strings${NC}"
            echo ""
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                echo -n "[*] Minimum string length (default 4): "
                read LEN
                LEN=${LEN:-4}
                run_cmd "strings -n $LEN '$BINARY' | head -50"
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        B5|b5)
            echo -e "${BLUE}[*] objdump - Disassemble Binary${NC}"
            echo ""
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                echo -n "[*] Enter function name (or press Enter for main): "
                read FUNC
                FUNC=${FUNC:-main}
                run_cmd "objdump -d '$BINARY' | grep -A 50 '$FUNC:'"
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        B6|b6)
            echo -e "${BLUE}[*] pwndbg - GDB Plugin Info${NC}"
            echo ""
            echo "[*] pwndbg is installed in framework venv"
            echo "[*] Location: ~/pwndbg/"
            echo "[*] For manual setup: cd ~/pwndbg && ./setup.sh"
            log_good "pwndbg ready for use!"
            ;;
        B7|b7)
            echo -e "${BLUE}[*] GDB Debug with Pwntools${NC}"
            echo ""
            echo -n "[*] Enter binary path: "
            read BINARY
            if [[ -n "$BINARY" && -f "$BINARY" ]]; then
                source ~/astra/venv/bin/activate
                run_cmd "pwntools"
                log_good "Use: pwn> gdb.attach(binary, gdbscript='break main\\ncontinue')"
            else
                echo -e "${YELLOW}[!] Binary not found${NC}"
            fi
            ;;
        BA|ba)
            echo -e "${BLUE}[*] Install/Update Tools${NC}"
            echo ""
            [[ ! -d "$PWNPASI_DIR" ]] && run_cmd "cd ~ && git clone https://github.com/heimao-box/pwnpasi.git"
            [[ ! -d "$ROPGADGET_DIR" ]] && run_cmd "cd ~ && git clone https://github.com/JonathanSalwan/ROPgadget.git"
            [[ ! -d "$HOME/pwndbg" ]] && run_cmd "cd ~ && git clone https://github.com/pwndbg/pwndbg.git"
            
            if [[ -d "$PWNPASI_DIR" ]]; then
                log_info "Installing pwnpasi dependencies..."
                cd "$PWNPASI_DIR" && pip3 install -r requirements.txt 2>/dev/null || pip3 install pwntools ropper libcsearcher 2>/dev/null
            fi
            
            if [[ -d "$ROPGADGET_DIR" ]]; then
                log_info "Installing ROPgadget..."
                cd "$ROPGADGET_DIR" && pip3 install -e . 2>/dev/null
            fi
            
            if [[ -d "$HOME/pwndbg" ]]; then
                log_info "Installing pwndbg..."
                cd "$HOME/pwndbg" && ./setup.sh 2>/dev/null
            fi
            
            log_good "Tools installation complete!"
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid choice: $choice${NC}"
            ;;
    esac
}

banner
check_tools
show_menu

read -p "Select option (0-9): " choice
handle_selection "$choice"

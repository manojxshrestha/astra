set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="v1.0"
AUTHOR="manojxshrestha"
GITHUB="https://github.com/manojxshrestha/pwnthebox"
banner() {
    clear
    echo ""
    echo -e "${MAGENTA}"
    cat << 'EOF'
                      .'--,
                    ,.-( (o)\
                   /   .)\ ')
                 .',.'/    /
            ()=///=))))==()
                   /
EOF
    echo -e "${NC}"
    echo -e "${CYAN}─────── ${YELLOW}pwnthebox v1.0${NC} • ${CYAN}Professional VAPT Toolkit${NC} • ${CYAN}by manojxshrestha${NC} ${CYAN}───────${NC}"
}
show_menu() {
    echo ""
    echo -e "${YELLOW}[1]${NC} ${CYAN}Recon${NC}  →  Information Gathering"
    echo "      └─ Passive & Active recon, OSINT, domain enumeration"
    echo ""
    echo -e "${YELLOW}[2]${NC} ${CYAN}Enum${NC}  →  Identify Weaknesses"
    echo "      └─ Port scanning, service detection, vulnerability scanning"
    echo ""
    echo -e "${YELLOW}[3]${NC} ${CYAN}Exploit${NC}  →  Gain Initial Access"
    echo "      └─ Exploitation, payload generation, web attacks"
    echo ""
    echo -e "${YELLOW}[4]${NC} ${CYAN}Foothold${NC}  →  Stabilize Access"
    echo "      └─ Shell stabilization, listeners, session management"
    echo ""
    echo -e "${YELLOW}[5]${NC} ${CYAN}Privilege-Escalation${NC}  →  Escalate Privileges"
    echo "      └─ Local exploits, misconfigurations, credential abuse"
    echo ""
    echo -e "${YELLOW}[6]${NC} ${CYAN}Internal${NC}  →  Post-Compromise Recon"
    echo "      └─ User enumeration, network discovery, domain info"
    echo ""
    echo -e "${YELLOW}[7]${NC} ${CYAN}Lateral${NC}  →  Move Through Network"
    echo "      └─ SSH pivoting, psexec, WMI, tunneling"
    echo ""
    echo -e "${YELLOW}[8]${NC} ${CYAN}Persistence${NC}  →  Maintain Access"
    echo "      └─ Backdoors, scheduled tasks, services, SSH keys"
    echo ""
    echo -e "${YELLOW}[9]${NC} ${CYAN}Misc${NC}  →  Additional Tools"
    echo "      └─ Actions on objectives, hash cracking, stego"
    echo ""
    echo -e "${YELLOW}[X]${NC} ${CYAN}Binary/Reversing${NC}  →  Binary Exploitation"
    echo "      └─ pwnpasi, ROPgadget, pwndbg, checksec"
    echo ""
    echo -e "${RED}[0]${NC} ${RED}Exit${NC}"
    echo ""
    echo -e "${CYAN}═══════════════ ${YELLOW}I get paid to break things. At home, I do it for free.${NC} ${CYAN}═══════════════${NC}"
    echo ""
}
log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[-]${NC} $1"; }
print_separator() {
    echo -e "${CYAN}───────────────────────────────────────────────────────────────────────────────${NC}"
}
run_script() {
    local script="$1"
    shift
    if [[ -x "$script" ]]; then
        log_info "Running: $(basename "$script")"
        "$script" "$@"
    elif [[ -f "$script" ]]; then
        log_info "Running: $(basename "$script")"
        bash "$script" "$@"
    else
        log_warn "Script not found: $script"
    fi
}
show_paths() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${YELLOW}TOOL PATHS${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e " ${BLUE}📁${NC} Reconnaissance ${CYAN}→${NC} $SCRIPT_DIR/Recon/"
    echo -e " ${BLUE}📁${NC} Enumeration ${CYAN}→${NC} $SCRIPT_DIR/Enum/"
    echo -e " ${BLUE}📁${NC} Initial Compromise ${CYAN}→${NC} $SCRIPT_DIR/Exploit/"
    echo -e " ${BLUE}📁${NC} Establish Foothold ${CYAN}→${NC} $SCRIPT_DIR/Foothold/"
    echo -e " ${BLUE}📁${NC} Privilege Escalation ${CYAN}→${NC} $SCRIPT_DIR/Privilege-Escalation/"
    echo -e " ${BLUE}📁${NC} Internal Recon ${CYAN}→${NC} $SCRIPT_DIR/Internal/"
    echo -e " ${BLUE}📁${NC} Lateral Movement ${CYAN}→${NC} $SCRIPT_DIR/Lateral/"
    echo -e " ${BLUE}📁${NC} Persistence ${CYAN}→${NC} $SCRIPT_DIR/Persistence/"
    echo -e " ${BLUE}📁${NC} Miscellaneous ${CYAN}→${NC} $SCRIPT_DIR/Misc/"
    echo ""
}
check_deps() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${YELLOW}DEPENDENCY CHECK${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    local deps=("bash" "python3" "nmap" "msfvenom" "curl" "wget")
    local installed=0
    local missing=0
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo -e " ${GREEN}✓${NC} ${GREEN}$dep${NC}"
            ((installed++))
        else
            echo -e " ${RED}✗${NC} ${RED}$dep${NC} ${YELLOW}(missing)${NC}"
            ((missing++))
        fi
    done
    echo ""
    echo -e " ${CYAN}Summary:${NC} ${GREEN}$installed installed${NC} | ${RED}$missing missing${NC}"
    echo ""
}
usage() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${YELLOW}PWNTHEBOX - Professional Penetration Testing Framework${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}USAGE:${NC} ${YELLOW}$0${NC} ${CYAN}[OPTIONS]${NC}"
    echo ""
    echo -e "${CYAN}LIFECYCLE PHASES:${NC}"
    echo -e " ${YELLOW}1${NC} Recon Suite ${CYAN}─${NC} Information gathering and OSINT"
    echo -e " ${YELLOW}2${NC} Enum Suite ${CYAN}─${NC} Port scanning and service discovery"
    echo -e " ${YELLOW}3${NC} Exploit Suite ${CYAN}─${NC} Vulnerability exploitation"
    echo -e " ${YELLOW}4${NC} Foothold Suite ${CYAN}─${NC} Shell stabilization"
    echo -e " ${YELLOW}5${NC} Privilege Escalation ${CYAN}─${NC} PE and privilege abuse"
    echo -e " ${YELLOW}6${NC} Internal Recon Suite ${CYAN}─${NC} Post-compromise enumeration"
    echo -e " ${YELLOW}7${NC} Lateral Suite ${CYAN}─${NC} Network pivoting and movement"
    echo -e " ${YELLOW}8${NC} Persistence Suite ${CYAN}─${NC} Maintain access"
    echo -e " ${YELLOW}9${NC} Misc Suite ${CYAN}─${NC} Actions on objectives"
    echo ""
    echo -e "${CYAN}OPTIONS:${NC}"
    echo -e " ${CYAN}--paths${NC} Show tool paths"
    echo -e " ${CYAN}--deps${NC} Check dependencies"
    echo -e " ${CYAN}--help${NC} Show this help message"
    echo -e " ${CYAN}--update${NC} Update framework from GitHub"
    echo ""
    echo -e "${CYAN}EXAMPLES:${NC}"
    echo -e " ${YELLOW}$0${NC} # Launch interactive menu"
    echo -e " ${YELLOW}$0 1${NC} # Run reconnaissance phase"
    echo -e " ${YELLOW}$0 5${NC} # Run privilege escalation"
    echo -e " ${YELLOW}$0 --paths${NC} # Display tool paths"
    echo ""
}
handle_selection() {
    local choice="$1"
    case "$choice" in
        1)
            echo ""
            print_separator
            log_info "Launching Phase 1: Reconnaissance"
            print_separator
            run_script "$SCRIPT_DIR/Recon/recon-suite.sh"
            ;;
        2)
            echo ""
            print_separator
            log_info "Launching Phase 2: Enumeration"
            print_separator
            run_script "$SCRIPT_DIR/Enum/enum-suite.sh"
            ;;
        3)
            echo ""
            print_separator
            log_info "Launching Phase 3: Exploitation"
            print_separator
            run_script "$SCRIPT_DIR/Exploit/compromise-suite.sh"
            ;;
        4)
            echo ""
            print_separator
            log_info "Launching Phase 4: Foothold"
            print_separator
            run_script "$SCRIPT_DIR/Foothold/foothold-suite.sh"
            ;;
        5)
            echo ""
            print_separator
            log_info "Launching Phase 5: Privilege Escalation"
            print_separator
            run_script "$SCRIPT_DIR/Privilege-Escalation/Linux/privesc.sh"
            ;;
        6)
            echo ""
            print_separator
            log_info "Launching Phase 6: Internal Recon"
            print_separator
            run_script "$SCRIPT_DIR/Internal/internal-recon-suite.sh"
            ;;
        7)
            echo ""
            print_separator
            log_info "Launching Phase 7: Lateral Movement"
            print_separator
            run_script "$SCRIPT_DIR/Lateral/lateral-suite.sh"
            ;;
        8)
            echo ""
            print_separator
            log_info "Launching Phase 8: Persistence"
            print_separator
            run_script "$SCRIPT_DIR/Persistence/persistence-suite.sh"
            ;;
        9)
            echo ""
            print_separator
            log_info "Launching Phase 9: Actions on Objectives"
            print_separator
            run_script "$SCRIPT_DIR/Misc/actions-suite.sh"
            ;;
        X|x)
            echo ""
            print_separator
            log_info "Launching Binary/Reversing Suite"
            print_separator
            run_script "$SCRIPT_DIR/Binary/binary-suite.sh"
            ;;
        recon|RECON)
            run_script "$SCRIPT_DIR/Recon/recon-suite.sh"
            ;;
        enum|ENUM)
            run_script "$SCRIPT_DIR/Enum/enum-suite.sh"
            ;;
        exploit|EXPLOIT)
            run_script "$SCRIPT_DIR/Exploit/compromise-suite.sh"
            ;;
        privesc|PRIVESC)
            run_script "$SCRIPT_DIR/Privilege-Escalation/Linux/privesc.sh"
            ;;
        --paths)
            show_paths
            read -p "Press Enter to continue..."
            ;;
        --deps)
            check_deps
            read -p "Press Enter to continue..."
            ;;
        --help|-h)
            usage
            ;;
        --update)
            echo ""
            print_separator
            log_info "Updating framework..."
            cd "$SCRIPT_DIR" && git pull
            print_separator
            log_good "Update complete!"
            read -p "Press Enter to continue..."
            ;;
        0|exit)
            echo ""
            echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║${NC} ${GREEN}Thank you for using pwnthebox Framework!${NC} ${CYAN}║${NC}"
            echo -e "${CYAN}║${NC} ${YELLOW}Stay ethical. Hack responsibly.${NC} ${CYAN}║${NC}"
            echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            log_error "Invalid selection: $choice"
            echo ""
            usage
            ;;
    esac
}

main() {
    if [[ $# -gt 0 ]]; then
        handle_selection "$1"
        exit 0
    fi
    
    while true; do
        banner
        
        # Show menu IMMEDIATELY - no waiting!
        show_menu
        
        echo ""
        read -p "Select phase (0-9, X): " choice
        
        handle_selection "$choice"
        
        echo ""
    done
}
main "$@"


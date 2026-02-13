#!/bin/bash

echo -e "\033[0;36m[*] Whois Lookup\033[0m"
echo ""
read -p "[*] Enter target domain: " TARGET

if [[ -n "$TARGET" ]]; then
    whois "$TARGET"
else
    echo -e "\033[1;33m[!] Missing target\033[0m"
fi

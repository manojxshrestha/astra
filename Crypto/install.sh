#!/bin/bash

#############################################################################
#                                                                           #
#  CRYPTOGRAPHY SUITE INSTALLER                                            #
#  Installs all crypto tools                                                #
#                                                                           #
#############################################################################

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TOOLS_DIR="$HOME/Tools"
FORCE=false

banner() {
    echo ""
    echo -e "${CYAN}─────── Crypto Tools Installer ───────${NC}"
    echo ""
}

install_ciphey() {
    echo -e "${BLUE}[*] Installing Ciphey...${NC}"
    if command -v ciphey &>/dev/null; then
        echo -e "${YELLOW}[SKIP] Ciphey already installed${NC}"
    elif python3 -c "import ciphey" 2>/dev/null; then
        echo -e "${YELLOW}[SKIP] Ciphey module already installed${NC}"
    elif [[ -d "$TOOLS_DIR/ciphey" ]]; then
        echo -e "${YELLOW}[SKIP] Ciphey directory exists${NC}"
    else
        mkdir -p "$TOOLS_DIR"
        git clone --filter="blob:none" https://github.com/ciphey/ciphey.git "$TOOLS_DIR/ciphey" 2>&1 | tail -3
        cd "$TOOLS_DIR/ciphey"
        pip3 install -e . --break-system-packages 2>&1 | tail -5 || echo -e "${YELLOW}[!] Ciphey install failed, will use basic decoders${NC}"
        echo -e "${GREEN}[OK] Ciphey (or fallback) ready${NC}"
    fi
}

install_codext() {
    echo -e "${BLUE}[*] Installing codext...${NC}"
    if command -v codext &>/dev/null; then
        echo -e "${YELLOW}[SKIP] codext already installed${NC}"
    else
        pip3 install codext --break-system-packages 2>&1 | tail -3
        echo -e "${GREEN}[OK] codext installed${NC}"
    fi
}

install_ctf_cryptotool() {
    echo -e "${BLUE}[*] Installing CTF-CryptoTool...${NC}"
    if [[ -d "$TOOLS_DIR/CTF-CryptoTool" ]]; then
        echo -e "${YELLOW}[SKIP] CTF-CryptoTool already exists${NC}"
    else
        mkdir -p "$TOOLS_DIR"
        git clone --filter="blob:none" https://github.com/karma9874/CTF-CryptoTool.git "$TOOLS_DIR/CTF-CryptoTool" 2>&1 | tail -3
        cd "$TOOLS_DIR/CTF-CryptoTool"
        pip3 install -r requirements.txt --break-system-packages 2>&1 | tail -3
        echo -e "${GREEN}[OK] CTF-CryptoTool installed${NC}"
    fi
}

install_rsactftool() {
    echo -e "${BLUE}[*] Installing RsaCtfTool...${NC}"
    if [[ -d "$TOOLS_DIR/RsaCtfTool" ]]; then
        echo -e "${YELLOW}[SKIP] RsaCtfTool already exists${NC}"
    else
        mkdir -p "$TOOLS_DIR"
        git clone --filter="blob:none" https://github.com/RsaCtfTool/RsaCtfTool.git "$TOOLS_DIR/RsaCtfTool" 2>&1 | tail -3
        cd "$TOOLS_DIR/RsaCtfTool"
        pip3 install -r requirements.txt --break-system-packages 2>&1 | tail -3
        echo -e "${GREEN}[OK] RsaCtfTool installed${NC}"
    fi
}

install_hash_tools() {
    echo -e "${BLUE}[*] Installing hashid...${NC}"
    if command -v hashid &>/dev/null; then
        echo -e "${YELLOW}[SKIP] hashid already installed${NC}"
    else
        pip3 install hashid --break-system-packages 2>&1 | tail -3
        echo -e "${GREEN}[OK] hashid installed${NC}"
    fi
}

banner

echo -e "${GREEN}[*] Installing crypto tools...${NC}"
echo ""

install_ciphey
install_codext
install_ctf_cryptotool
install_rsactftool
install_hash_tools

echo ""
echo -e "${GREEN}[SUCCESS] Crypto tools installed!${NC}"
echo ""
echo "Next steps:"
echo "  - Run ./crypto-suite.sh to access tools"
echo "  - Use hashcat/john for hash cracking (install separately if needed)"

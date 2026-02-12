#!/bin/bash

# PwnTheBox Framework Installation Script
# Professional Vulnerability Assessment & Penetration Testing Toolkit

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$SCRIPT_DIR"

# Counters
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# Function to show help
show_help() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║                    PWNTHEBOX FRAMEWORK                                      ║"
    echo "║              Professional Penetration Testing Suite                           ║"
    echo "║                       Installation Script                                     ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${GREEN}USAGE:${NC}"
    echo "    ./install.sh [OPTIONS]"
    echo ""
    echo -e "${GREEN}OPTIONS:${NC}"
    echo "    -h, --help          Show this help message"
    echo "    --check             Check installation status of all tools"
    echo "    (no arguments)      Install all tools (skip if already installed)"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo "    ./install.sh                   # Install all tools (smart install)"
    echo "    ./install.sh --check           # Check which tools are installed"
    echo "    ./install.sh -h                # Show this help"
    echo ""
    echo -e "${GREEN}FEATURES:${NC}"
    echo "    ✓ Smart detection - skips already installed tools"
    echo "    ✓ Progress tracking - shows installed/skipped/failed counts"
    echo "    ✓ Multi-OS support - Kali, Ubuntu, Debian, Arch, Fedora, macOS"
    echo "    ✓ Python venv - isolated Python environment"
    echo "    ✓ Helper scripts - activate.sh, update.sh, pwnthebox launcher"
    echo ""
    echo -e "${YELLOW}[!] Disclaimer: Use only on systems you have permission to test!${NC}"
    echo ""
    exit 0
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a Debian package is installed
package_installed_debian() {
    dpkg -l | grep -q "^ii  $1 " 2>/dev/null
}

# Function to check if a Python package is installed
python_package_installed() {
    if [[ -f "$FRAMEWORK_DIR/venv/bin/activate" ]]; then
        source "$FRAMEWORK_DIR/venv/bin/activate" 2>/dev/null
        pip show "$1" >/dev/null 2>&1
        local result=$?
        deactivate 2>/dev/null || true
        return $result
    fi
    return 1
}

# Function to check tool status
check_tool_status() {
    local tool="$1"
    local type="$2"
    local display_name="$3"
    
    local status="NOT INSTALLED"
    local color="$RED"
    
    if [[ "$type" == "command" ]]; then
        if command_exists "$tool"; then
            status="INSTALLED"
            color="$GREEN"
        fi
    elif [[ "$type" == "debian" ]]; then
        if package_installed_debian "$tool"; then
            status="INSTALLED"
            color="$GREEN"
        fi
    elif [[ "$type" == "python" ]]; then
        if python_package_installed "$tool"; then
            status="INSTALLED"
            color="$GREEN"
        fi
    elif [[ "$type" == "github" ]]; then
        # Check if theHarvester is installed from GitHub (latest version)
        if [[ -d "/tmp/theHarvester/.venv" ]]; then
            # Get installed version
            local installed_version=$(/tmp/theHarvester/.venv/bin/python -c "import theHarvester; from theHarvester import __version__; print(__version__)" 2>/dev/null || echo "unknown")
            status="INSTALLED (v$installed_version)"
            color="$GREEN"
        elif command_exists theHarvester && "$HOME/.local/bin/theHarvester" -v >/dev/null 2>&1; then
            local installed_version=$(/tmp/theHarvester/.venv/bin/python -c "import theHarvester; from theHarvester import __version__; print(__version__)" 2>/dev/null || echo "unknown")
            status="INSTALLED (v$installed_version)"
            color="$GREEN"
        fi
    fi
    
    printf "    ${color}%-20s${NC} %s\n" "$display_name" "$status"
}

# Function to check all tools status
check_status() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                               ║"
    echo "║                    PWNTHEBOX FRAMEWORK                                      ║"
    echo "║              Professional Penetration Testing Suite                           ║"
    echo "║                    Installation Status Check                                  ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_TYPE="$ID"
        OS_VERSION="$VERSION_ID"
    else
        OS_TYPE="unknown"
    fi
    
    echo -e "${BLUE}[*] Detected OS: $OS_TYPE $OS_VERSION${NC}"
    echo ""
    
    INSTALLED=0
    NOT_INSTALLED=0
    
    # Core Dependencies
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  CORE DEPENDENCIES${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    CORE_TOOLS=(
        "bash:command:Bash"
        "python3:command:Python3"
        "python3-pip:debian:Python3-pip"
        "git:command:Git"
        "curl:command:Curl"
        "wget:command:Wget"
        "vim:command:Vim"
        "tmux:command:Tmux"
        "nmap:command:Nmap"
        "jq:command:JQ"
        "dnsutils:debian:DNS-Utils"
        "whois:command:Whois"
        "enum4linux:debian:Enum4linux"
        "smbclient:debian:SMB-Client"
        "file:command:File"
    )
    
    for tool_info in "${CORE_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Exploitation Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  EXPLOITATION TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    EXPLOIT_TOOLS=(
        "metasploit-framework:debian:Metasploit"
        "exploitdb:debian:Exploit-DB"
        "sqlmap:debian:SQLMap"
        "nikto:debian:Nikto"
        "hydra:debian:Hydra"
        "john:debian:John-the-Ripper"
        "hashcat:debian:Hashcat"
    )
    
    for tool_info in "${EXPLOIT_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Reconnaissance Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  RECONNAISSANCE TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    RECON_TOOLS=(
        "theharvester:github:TheHarvester"
        "subfinder:debian:Subfinder"
        "dnstwist:debian:DNSTwist"
        "dnsrecon:debian:DNSRecon"
        "recon-ng:debian:Recon-ng"
    )
    
    for tool_info in "${RECON_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Web Application Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  WEB APPLICATION TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    WEB_TOOLS=(
        "gobuster:debian:GoBuster"
        "wfuzz:debian:WFUZZ"
        "ffuf:debian:FFUF"
    )
    
    for tool_info in "${WEB_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Binary Exploitation Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  BINARY EXPLOITATION TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    BINARY_TOOLS=(
        "gdb:command:GDB"
        "ropper:debian:Ropper"
        "ropgadget:python:ROPGadget"
        "one-gadget:python:OneGadget"
        "pwndbg:command:Pwndbg"
    )
    
    for tool_info in "${BINARY_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Steganography Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  STEGANOGRAPHY TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    STEGO_TOOLS=(
        "steghide:debian:Steghide"
        "binwalk:debian:Binwalk"
        "exiftool:debian:ExifTool"
    )
    
    for tool_info in "${STEGO_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Tunneling Tools
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  TUNNELING & PIVOTING TOOLS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    PIVOT_TOOLS=(
        "socat:debian:Socat"
        "chisel:command:Chisel"
        "proxychains:debian:Proxychains"
    )
    
    for tool_info in "${PIVOT_TOOLS[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Python Packages
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PYTHON PACKAGES (venv)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    PYTHON_PACKAGES=(
        "python-nmap:python:Python-Nmap"
        "impacket:python:Impacket"
        "requests:python:Requests"
        "beautifulsoup4:python:BeautifulSoup4"
        "scapy:python:Scapy"
        "dnspython:python:DNSPython"
        "jinja2:python:Jinja2"
    )
    
    for tool_info in "${PYTHON_PACKAGES[@]}"; do
        IFS=':' read -r tool type name <<< "$tool_info"
        if check_tool_status "$tool" "$type" "$name"; then
            INSTALLED=$((INSTALLED + 1))
        else
            NOT_INSTALLED=$((NOT_INSTALLED + 1))
        fi
    done
    
    echo ""
    
    # Summary
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  STATUS SUMMARY${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "    ${GREEN}INSTALLED:${NC}      $INSTALLED"
    echo -e "    ${RED}NOT INSTALLED:${NC}  $NOT_INSTALLED"
    echo ""
    
    if [[ $NOT_INSTALLED -eq 0 ]]; then
        echo -e "${GREEN}[✓] All tools are installed!${NC}"
    else
        echo -e "${YELLOW}[!] $NOT_INSTALLED tools are not installed.${NC}"
        echo -e "${YELLOW}[!] Run './install.sh' to install missing tools.${NC}"
    fi
    
    echo ""
    exit 0
}

# Function to install a package (Debian/Ubuntu/Kali)
install_debian() {
    local package="$1"
    local display_name="${2:-$package}"
    
    if package_installed_debian "$package"; then
        echo -e "    ${YELLOW}⊘${NC} $display_name (already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        return 0
    fi
    
    echo -n "    Installing $display_name... "
    if sudo apt install -y "$package" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        return 0
    else
        echo -e "${RED}✗${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        return 1
    fi
}

# Function to install a Python package
install_python_package() {
    local package="$1"
    local display_name="${2:-$package}"
    
    if python_package_installed "$package"; then
        echo -e "    ${YELLOW}⊘${NC} $display_name (already installed)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        return 0
    fi
    
    echo -n "    Installing $display_name... "
    if [[ -f "$FRAMEWORK_DIR/venv/bin/activate" ]]; then
        source "$FRAMEWORK_DIR/venv/bin/activate" 2>/dev/null
        if pip install "$package" > /dev/null 2>&1; then
            deactivate 2>/dev/null || true
            echo -e "${GREEN}✓${NC}"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
            return 0
        else
            deactivate 2>/dev/null || true
            echo -e "${RED}✗${NC}"
            FAILED_COUNT=$((FAILED_COUNT + 1))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} (venv not found)"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        return 1
    fi
}

# Function to install theHarvester from GitHub (latest version)
install_theharvester_github() {
    echo -e "${BLUE}[*] Installing theHarvester from GitHub (latest version)...${NC}"
    
    # Check if already installed and working from GitHub
    if command_exists theHarvester && /usr/local/bin/theHarvester -v >/dev/null 2>&1; then
        local version=$(/usr/local/bin/theHarvester -v 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
        echo -e "    ${YELLOW}⊘${NC} theHarvester v$version (already installed from GitHub)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        return 0
    fi
    
    # Remove old/broken installation
    if [[ -f "/usr/local/bin/theHarvester" ]]; then
        echo -e "${BLUE}[*] Removing old/broken theHarvester installation...${NC}"
        sudo rm -f /usr/local/bin/theHarvester 2>/dev/null || true
        sudo rm -rf /opt/theHarvester 2>/dev/null || true
    fi
    
    # Remove old apt version if installed
    if package_installed_debian "theharvester"; then
        echo -e "${BLUE}[*] Removing old apt version of theHarvester...${NC}"
        sudo apt remove -y theharvester > /dev/null 2>&1 || true
    fi
    
    # Install uv if not present
    if ! command_exists uv; then
        echo -n "    Installing uv... "
        if curl -LsSf https://astral.sh/uv/install.sh | sh > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            # Add uv to PATH for current session
            export PATH="$HOME/.cargo/bin:$PATH"
        else
            echo -e "${RED}✗${NC}"
            FAILED_COUNT=$((FAILED_COUNT + 1))
            return 1
        fi
    fi
    
    # Clone theHarvester repository
    echo -n "    Cloning theHarvester repository... "
    if [[ -d "/tmp/theHarvester" ]]; then
        rm -rf /tmp/theHarvester
    fi
    
    if git clone https://github.com/laramies/theHarvester /tmp/theHarvester > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        return 1
    fi
    
    # Install theHarvester
    echo -n "    Installing theHarvester dependencies... "
    cd /tmp/theHarvester
    
    if uv sync > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        return 1
    fi
    
    # Keep the venv in /tmp for user access
    echo -n "    Configuring theHarvester... "
    
    # Create wrapper script that uses /tmp installation (no sudo needed)
    echo -n "    Creating wrapper script... "
    
    # Create launcher script in ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/theHarvester" << 'HARVESTER_EOF'
#!/bin/bash
# Use theHarvester from /tmp with its own venv
if [[ -d "/tmp/theHarvester/.venv" ]]; then
    cd /tmp/theHarvester
    /tmp/theHarvester/.venv/bin/python -m theHarvester "$@"
else
    echo "Error: theHarvester not found. Please reinstall."
    exit 1
fi
HARVESTER_EOF
    
    chmod +x "$HOME/.local/bin/theHarvester"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    # Get version
    local version=$(/tmp/theHarvester/.venv/bin/python -c "import theHarvester; from theHarvester import __version__; print(__version__)" 2>/dev/null || echo "unknown")
    echo -e "    ${GREEN}✓${NC} theHarvester v$version installed successfully!"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    
    return 0
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        show_help
        ;;
    --check)
        check_status
        ;;
    "")
        # Continue with installation
        ;;
    *)
        echo -e "${RED}[!] Unknown option: $1${NC}"
        echo "Use './install.sh --help' for usage information."
        exit 1
        ;;
esac

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                               ║"
echo "║                    PWNTHEBOX FRAMEWORK                                      ║"
echo "║              Professional Penetration Testing Suite                           ║"
echo "║                       Installation Script                                     ║"
echo "║                                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}[!] Warning: Running as root. Some tools may not work as expected.${NC}"
    echo ""
fi

# Detect OS
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_TYPE="$ID"
    OS_VERSION="$VERSION_ID"
else
    OS_TYPE="unknown"
fi

echo -e "${BLUE}[*] Detected OS: $OS_TYPE $OS_VERSION${NC}"
echo ""

# Update package lists
echo -e "${BLUE}[*] Updating package lists...${NC}"
if [[ "$OS_TYPE" == "kali" ]] || [[ "$OS_TYPE" == "debian" ]] || [[ "$OS_TYPE" == "ubuntu" ]]; then
    sudo apt update -y > /dev/null 2>&1
elif [[ "$OS_TYPE" == "arch" ]] || [[ "$OS_TYPE" == "manjaro" ]]; then
    sudo pacman -Sy > /dev/null 2>&1
elif [[ "$OS_TYPE" == "fedora" ]] || [[ "$OS_TYPE" == "rhel" ]] || [[ "$OS_TYPE" == "centos" ]]; then
    sudo dnf check-update > /dev/null 2>&1 || true
elif [[ "$OS_TYPE" == "macos" ]]; then
    echo "[*] macOS detected. Using Homebrew for package management."
    if ! command_exists brew; then
        echo -e "${YELLOW}[!] Homebrew not found. Please install Homebrew first.${NC}"
        echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    brew update > /dev/null 2>&1
fi

echo -e "${GREEN}[+] Package lists updated.${NC}"
echo ""

# Install core dependencies
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING CORE DEPENDENCIES${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

CORE_PACKAGES=(
    "bash:Bash"
    "python3:Python3"
    "python3-pip:Python3-pip"
    "python3-venv:Python3-venv"
    "git:Git"
    "curl:Curl"
    "wget:Wget"
    "vim:Vim"
    "tmux:Tmux"
    "netcat-openbsd:Netcat"
    "nmap:Nmap"
    "jq:JQ"
    "dnsutils:DNS-Utils"
    "whois:Whois"
    "enum4linux:Enum4linux"
    "smbclient:SMB-Client"
    "smbmap:SMBMap"
    "file:File"
    "binutils:Binutils"
)

for pkg_info in "${CORE_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

echo ""

# Install exploitation tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING EXPLOITATION TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

EXPLOIT_PACKAGES=(
    "metasploit-framework:Metasploit"
    "msfpc:Msfpc"
    "exploitdb:Exploit-DB"
    "sqlmap:SQLMap"
    "nikto:Nikto"
    "hydra:Hydra"
    "john:John-the-Ripper"
    "john-data:John-Data"
    "hashcat:Hashcat"
)

for pkg_info in "${EXPLOIT_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

echo ""

# Install reconnaissance tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING RECONNAISSANCE TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Install theHarvester from GitHub (latest version)
install_theharvester_github

RECON_PACKAGES=(
    "subfinder:Subfinder"
    "dnstwist:DNSTwist"
    "dnsrecon:DNSRecon"
    "recon-ng:Recon-ng"
    "whois:Whois"
)

for pkg_info in "${RECON_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

echo ""

# Install web application tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING WEB APPLICATION TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

WEB_PACKAGES=(
    "gobuster:GoBuster"
    "wfuzz:WFUZZ"
    "dirsearch:Dirsearch"
    "ffuf:FFUF"
    "uniscan:Uniscan"
)

for pkg_info in "${WEB_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

echo ""

# Install Python tools and dependencies
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING PYTHON DEPENDENCIES${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}[*] Creating Python virtual environment...${NC}"
python3 -m venv "$FRAMEWORK_DIR/venv" 2>/dev/null || true
echo -e "    ${GREEN}✓${NC} Virtual environment ready"
echo ""

if [[ -f "$FRAMEWORK_DIR/venv/bin/activate" ]]; then
    echo -e "${BLUE}[*] Installing Python packages...${NC}"
    
    PIP_PACKAGES=(
        "requests:Requests"
        "beautifulsoup4:BeautifulSoup4"
        "lxml:LXML"
        "python-nmap:Python-Nmap"
        "impacket:Impacket"
        "dnspython:DNSPython"
        "tldextract:TLDExtract"
        "scapy:Scapy"
        "netaddr:NetAddr"
        "jinja2:Jinja2"
        "termcolor:TermColor"
        "colorama:Colorama"
        "ropgadget:ROPGadget"
        "one-gadget:OneGadget"
    )
    
    for pkg_info in "${PIP_PACKAGES[@]}"; do
        IFS=':' read -r package display_name <<< "$pkg_info"
        install_python_package "$package" "$display_name"
    done
else
    echo -e "${YELLOW}[!] Could not create virtual environment${NC}"
fi

echo ""

# Install binary exploitation tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING BINARY EXPLOITATION TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

BINARY_PACKAGES=(
    "gdb:GDB"
    "ropper:Ropper"
    "checksec:Checksec"
)

for pkg_info in "${BINARY_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

# Install pwndbg specifically
if ! command_exists pwndbg; then
    echo -e "${BLUE}[*] Installing pwndbg...${NC}"
    cd /tmp
    if [[ -d /tmp/pwndbg ]]; then
        rm -rf /tmp/pwndbg
    fi
    git clone https://github.com/pwndbg/pwndbg > /dev/null 2>&1
    cd pwndbg
    ./setup.sh > /dev/null 2>&1
    echo -e "    ${GREEN}✓${NC} pwndbg installed"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    echo -e "    ${YELLOW}⊘${NC} pwndbg (already installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
fi

echo ""

# Install steganography tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING STEGANOGRAPHY TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

STEGO_PACKAGES=(
    "steghide:Steghide"
    "binwalk:Binwalk"
    "exiftool:ExifTool"
    "foremost:Foremost"
)

for pkg_info in "${STEGO_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

echo ""

# Install tunneling/pivoting tools
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  INSTALLING TUNNELING & PIVOTING TOOLS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

PIVOT_PACKAGES=(
    "socat:Socat"
    "proxychains:Proxychains"
    "ncat:Ncat"
)

for pkg_info in "${PIVOT_PACKAGES[@]}"; do
    IFS=':' read -r package display_name <<< "$pkg_info"
    install_debian "$package" "$display_name"
done

# Install chisel from binary
if ! command_exists chisel; then
    echo -e "${BLUE}[*] Installing chisel...${NC}"
    cd /tmp
    wget -q https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz 2>/dev/null || {
        echo -e "    ${RED}✗${NC} Could not download chisel"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    }
    if [[ -f chisel_1.9.1_linux_amd64.gz ]]; then
        gunzip chisel_1.9.1_linux_amd64.gz 2>/dev/null
        sudo mv chisel_1.9.1_linux_amd64 /usr/local/bin/chisel 2>/dev/null
        sudo chmod +x /usr/local/bin/chisel 2>/dev/null
        echo -e "    ${GREEN}✓${NC} chisel installed"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    fi
else
    echo -e "    ${YELLOW}⊘${NC} chisel (already installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
fi

echo ""

# Set up directory structure
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  SETTING UP DIRECTORY STRUCTURE${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}[*] Creating necessary directories...${NC}"

DIRECTORIES=(
    "$HOME/data"
    "$HOME/data/domains"
    "$HOME/data/scans"
    "$HOME/data/exploits"
    "$HOME/data/reports"
    "$HOME/data/credentials"
    "$HOME/data/shells"
    "$HOME/data/loot"
    "$HOME/.theHarvester"
    "$HOME/.msf4"
    "$FRAMEWORK_DIR/reports"
    "$FRAMEWORK_DIR/wordlists"
)

for dir in "${DIRECTORIES[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo -e "    ${GREEN}✓${NC} Created $dir"
    else
        echo -e "    ${YELLOW}⊘${NC} $dir (already exists)"
    fi
done

echo ""

# Set execute permissions
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  SETTING PERMISSIONS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}[*] Setting execute permissions on all scripts...${NC}"
find "$FRAMEWORK_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null
find "$FRAMEWORK_DIR" -name "*.py" -type f -exec chmod +x {} \; 2>/dev/null
echo -e "    ${GREEN}✓${NC} Permissions set"
INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

echo ""

# Copy configuration files
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  CONFIGURING CONFIGURATION FILES${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}[*] Copying configuration files...${NC}"

CONFIG_DIR="$FRAMEWORK_DIR/config"

if [[ -f "$CONFIG_DIR/tmux.conf" ]]; then
    cp "$CONFIG_DIR/tmux.conf" "$HOME/.tmux.conf"
    echo -e "    ${GREEN}✓${NC} tmux.conf"
fi

if [[ -f "$CONFIG_DIR/vimrc" ]]; then
    cp "$CONFIG_DIR/vimrc" "$HOME/.vimrc"
    echo -e "    ${GREEN}✓${NC} vimrc"
fi

if [[ "$OS_TYPE" == "kali" ]]; then
    if [[ -f "$CONFIG_DIR/zshrc" ]]; then
        if ! grep -q "pwnthebox" "$HOME/.zshrc" 2>/dev/null; then
            cat "$CONFIG_DIR/zshrc" >> "$HOME/.zshrc"
            echo -e "    ${GREEN}✓${NC} Added zshrc aliases"
        else
            echo -e "    ${YELLOW}⊘${NC} zshrc aliases (already added)"
        fi
    fi
    source "$HOME/.zshrc" 2>/dev/null || true
else
    if [[ -f "$CONFIG_DIR/zshrc" ]]; then
        cp "$CONFIG_DIR/zshrc" "$HOME/.bash_aliases"
        echo -e "    ${GREEN}✓${NC} bash_aliases"
    fi
    source "$HOME/.bash_aliases" 2>/dev/null || true
fi

echo ""

# Create helper scripts
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  CREATING HELPER SCRIPTS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Create activate script
ACTIVATION_SCRIPT="$FRAMEWORK_DIR/activate.sh"
cat > "$ACTIVATION_SCRIPT" << 'ACTIVATE_EOF'
#!/bin/bash
# PwnTheBox Framework Activation Script
# Source this file to add the framework to your PATH

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PWNTHEBOX="$FRAMEWORK_DIR"
export PATH="$FRAMEWORK_DIR:$PATH"

# Activate Python virtual environment
if [[ -f "$FRAMEWORK_DIR/venv/bin/activate" ]]; then
    source "$FRAMEWORK_DIR/venv/bin/activate"
fi

# Aliases
alias pwnthebox='cd "$FRAMEWORK_DIR" && ./pwnthebox.sh'
alias recon='cd "$FRAMEWORK_DIR/Recon" && ./recon-suite.sh'
alias enum='cd "$FRAMEWORK_DIR/Enum" && ./enum-suite.sh'
alias exploit='cd "$FRAMEWORK_DIR/Exploit" && ./compromise-suite.sh'
alias privesc='cd "$FRAMEWORK_DIR/Privilege-Escalation/Linux" && ./privesc.sh'

echo -e "\033[0;32m[*] PwnTheBox Framework activated!\033[0m"
echo -e "\033[0;34m[*] Type 'pwnthebox' to launch the main menu.\033[0m"
ACTIVATE_EOF

chmod +x "$ACTIVATION_SCRIPT"
echo -e "    ${GREEN}✓${NC} Created activate.sh"

# Create quick launcher
LAUNCHER_SCRIPT="$FRAMEWORK_DIR/pwnthebox"
cat > "$LAUNCHER_SCRIPT" << 'LAUNCHER_EOF'
#!/bin/bash
# PwnTheBox Quick Launcher

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
./pwnthebox.sh "$@"
LAUNCHER_EOF

chmod +x "$LAUNCHER_SCRIPT"
echo -e "    ${GREEN}✓${NC} Created pwnthebox launcher"

# Create update script
UPDATE_SCRIPT="$FRAMEWORK_DIR/update.sh"
cat > "$UPDATE_SCRIPT" << 'UPDATE_EOF'
#!/bin/bash
# PwnTheBox Framework Update Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Updating PwnTheBox Framework..."
echo ""

# Update package lists
echo "[*] Updating system packages..."
sudo apt update -y 2>/dev/null || echo "[!] Could not update packages"

# Update Python packages
echo ""
echo "[*] Updating Python packages..."
if [[ -f "$SCRIPT_DIR/venv/bin/activate" ]]; then
    source "$SCRIPT_DIR/venv/bin/activate"
    pip install --upgrade pip > /dev/null 2>&1
    pip list --outdated | grep -v "^-" | awk '{print $1}' | xargs -I {} pip install {} > /dev/null 2>&1 || true
fi

# Update framework scripts
echo ""
echo "[*] Setting permissions..."
find "$SCRIPT_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null
find "$SCRIPT_DIR" -name "*.py" -type f -exec chmod +x {} \; 2>/dev/null

echo ""
echo "[+] Update complete!"
UPDATE_EOF

chmod +x "$UPDATE_SCRIPT"
echo -e "    ${GREEN}✓${NC} Created update.sh"

echo ""

# Add to PATH permanently
PROFILE_FILE="$HOME/.bashrc"
if [[ "$OS_TYPE" == "kali" ]]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

if ! grep -q "PWNTHEBOX" "$PROFILE_FILE" 2>/dev/null; then
    echo "" >> "$PROFILE_FILE"
    echo "# PwnTheBox Framework" >> "$PROFILE_FILE"
    echo "export PWNTHEBOX=\"$FRAMEWORK_DIR\"" >> "$PROFILE_FILE"
    echo "export PATH=\"\$PWNTHEBOX:\$PATH\"" >> "$PROFILE_FILE"
    echo "alias pwnthebox='cd \"$FRAMEWORK_DIR\" && ./pwnthebox.sh'" >> "$PROFILE_FILE"
    echo -e "    ${GREEN}✓${NC} Added PwnTheBox to PATH in $PROFILE_FILE"
else
    echo -e "    ${YELLOW}⊘${NC} PwnTheBox already in PATH"
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}[*] Installation Summary:${NC}"
echo -e "    ${GREEN}Installed:${NC} $INSTALLED_COUNT"
echo -e "    ${YELLOW}Skipped:${NC} $SKIPPED_COUNT"
echo -e "    ${RED}Failed:${NC} $FAILED_COUNT"
echo ""
echo -e "${BLUE}[*] Framework location: $FRAMEWORK_DIR${NC}"
echo ""
echo -e "${BLUE}[*] Quick Commands:${NC}"
echo "    pwnthebox              - Launch main menu"
echo "    ./pwnthebox.sh         - Launch from framework directory"
echo "    source activate.sh     - Add to current shell"
echo "    ./install.sh --check   - Check tool status"
echo ""
echo -e "${BLUE}[*] Phase Directories:${NC}"
echo "    Recon/                 - Information Gathering"
echo "    Enum/                  - Scanning & Enumeration"
echo "    Exploit/               - Exploitation Tools"
echo "    Foothold/              - Shell Stabilization"
echo "    Privilege-Escalation/   - Privilege Escalation"
echo "    Internal/              - Post-Compromise Recon"
echo "    Lateral/               - Lateral Movement"
echo "    Persistence/           - Maintain Access"
echo "    Misc/                  - Actions on Objectives"
echo ""
echo -e "${BLUE}[*] Next Steps:${NC}"
echo "    1. Review installed tools"
echo "    2. Configure API keys for premium tools (Shodan, Censys, Hunter)"
echo "    3. Read documentation in README.md"
echo "    4. Run ./pwnthebox.sh to start"
echo ""
echo -e "${YELLOW}[!] Disclaimer: Use only on systems you have permission to test!${NC}"
echo ""

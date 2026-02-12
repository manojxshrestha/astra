#!/bin/bash
# PwnTheBox Framework Activation Script
# Source this file to add the framework to your PATH

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PWNTHEBOX="$FRAMEWORK_DIR"

# Ensure pwnthebox launcher is executable and in PATH
if [[ -f "$FRAMEWORK_DIR/pwnthebox" ]]; then
    chmod +x "$FRAMEWORK_DIR/pwnthebox"
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$FRAMEWORK_DIR:"* ]]; then
        export PATH="$FRAMEWORK_DIR:$PATH"
    fi
fi

# Activate Python virtual environment
if [[ -f "$FRAMEWORK_DIR/venv/bin/activate" ]]; then
    source "$FRAMEWORK_DIR/venv/bin/activate"
fi

# Aliases for quick navigation
alias pwnthebox='cd "$FRAMEWORK_DIR" && ./pwnthebox.sh'
alias recon='cd "$FRAMEWORK_DIR/Recon" && ./recon-suite.sh'
alias enum='cd "$FRAMEWORK_DIR/Enum" && ./enum-suite.sh'
alias exploit='cd "$FRAMEWORK_DIR/Exploit" && ./compromise-suite.sh'
alias privesc='cd "$FRAMEWORK_DIR/Privilege-Escalation/Linux" && ./privesc.sh'
alias internal='cd "$FRAMEWORK_DIR/Internal" && ./internal-recon-suite.sh'
alias lateral='cd "$FRAMEWORK_DIR/Lateral" && ./lateral-suite.sh'
alias persistence='cd "$FRAMEWORK_DIR/Persistence" && ./persistence-suite.sh'
alias misc='cd "$FRAMEWORK_DIR/Misc" && ./actions-suite.sh'

# Function to show available commands
pwnthebox_help() {
    echo -e "\033[0;32m[*] PwnTheBox Framework Commands:\033[0m"
    echo ""
    echo -e "\033[0;34mFramework:\033[0m"
    echo "  pwnthebox              - Launch main menu"
    echo "  pwnthebox_help         - Show this help"
    echo ""
    echo -e "\033[0;34mPhase Navigation:\033[0m"
    echo "  recon                  - Reconnaissance phase"
    echo "  enum                   - Enumeration phase"
    echo "  exploit                - Exploitation phase"
    echo "  privesc                - Privilege Escalation phase"
    echo "  internal               - Internal Recon phase"
    echo "  lateral                - Lateral Movement phase"
    echo "  persistence            - Persistence phase"
    echo "  misc                   - Actions on Objectives phase"
    echo ""
    echo -e "\033[0;34mQuick Tools:\033[0m"
    echo "  theHarvester           - OSINT gathering tool"
    echo "  subfinder              - Subdomain enumeration"
    echo "  gobuster               - Directory/file busting"
    echo "  ffuf                  - Fuzzing tool"
    echo ""
    echo -e "\033[0;34mSystem:\033[0m"
    echo "  deactivate             - Deactivate Python venv"
    echo "  pwnthebox_update      - Update framework (run ./update.sh)"
    echo ""
}

# Print welcome message
echo ""
echo -e "\033[0;32m╔═══════════════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;32m║                                                                               ║\033[0m"
echo -e "\033[0;32m║                    PWNTHEBOX FRAMEWORK                                  ║\033[0m"
echo -e "\033[0;32m║              Professional Penetration Testing Suite                    ║\033[0m"
echo -e "\033[0;32m║                       ACTIVATED!                                        ║\033[0m"
echo -e "\033[0;32m╚═══════════════════════════════════════════════════════════════════════╝\033[0m"
echo ""
echo -e "\033[0;34m[*] Framework location: $FRAMEWORK_DIR\033[0m"
echo -e "\033[0;34m[*] Python venv: $(basename "$FRAMEWORK_DIR")/venv\033[0m"
echo ""
echo -e "\033[0;32m[*] Available commands:\033[0m"
echo "  pwnthebox              - Launch main menu"
echo "  pwnthebox_help         - Show all commands"
echo ""
echo -e "\033[0;32m[*] Phase aliases:\033[0m"
echo "  recon | enum | exploit | privesc | internal | lateral | persistence | misc"
echo ""
echo -e "\033[0;34m[*] Type 'pwnthebox_help' for full command list.\033[0m"
echo -e "\033[0;34m[*] Type 'pwnthebox' to launch the main menu.\033[0m"
echo ""

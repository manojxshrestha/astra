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
alias pwnthebox='cd "$FRAMEWORK_DIR" && ./conductor.sh'
alias recon='cd "$FRAMEWORK_DIR/Recon" && ./recon-suite.sh'
alias enum='cd "$FRAMEWORK_DIR/Enum" && ./enum-suite.sh'
alias exploit='cd "$FRAMEWORK_DIR/Exploit" && ./compromise-suite.sh'
alias privesc='cd "$FRAMEWORK_DIR/Privilege-Escalation/Linux" && ./privesc.sh'

echo -e "\033[0;32m[*] PwnTheBox Framework activated!\033[0m"
echo -e "\033[0;34m[*] Type 'pwnthebox' to launch the main menu.\033[0m"

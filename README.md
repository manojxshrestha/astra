# 🛡️ PwnTheBox Framework

**Professional Vulnerability Assessment & Penetration Testing Toolkit**

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/manojxshrestha/pwnthebox)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux%20%7C%20WSL%20%7C%20Parrot%20OS-blue.svg)](https://github.com/manojxshrestha/pwnthebox)

---

## 📋 Overview

PwnTheBox is a comprehensive penetration testing framework designed for professional security assessments. It covers the entire penetration testing lifecycle from reconnaissance to reporting, with smart automation and tool management.

## 🎯 Key Features

### ✅ Smart Installation
- Automatic dependency detection and installation
- Skips already installed tools (no redundant installations)
- Multi-OS support: Kali Linux, WSL, Parrot OS, Ubuntu, Debian, Arch, macOS
- Progress tracking with detailed status reports

### ✅ Comprehensive Tool Suite
- **9-Phase Testing Lifecycle**: Recon → Enum → Exploit → Foothold → PrivEsc → Internal → Lateral → Persistence → Actions
- **50+ Security Tools**: Recon, exploitation, web apps, binary pwn, steganography, pivoting
- **Latest theHarvester**: Automatically installs v4.10.0 from GitHub (not outdated apt version)
- **Python Virtual Environment**: Isolated dependencies for reliability

### ✅ Framework Features
- Interactive menu-driven interface (`./pwnthebox.sh`)
- CLI mode for automation (`./pwnthebox.sh 1`)
- Color-coded output for better visibility

---

## 🚀 Quick Start

### One-Line Installation
```bash
# Clone and install everything
git clone https://github.com/manojxshrestha/pwnthebox.git
cd pwnthebox
./install.sh

# Check what's installed
./install.sh --check

# Launch framework
./pwnthebox.sh
```

### Installation Options
```bash
./install.sh              # Install all tools (smart - skips already installed)
./install.sh --check     # Check installation status of all tools
./install.sh -h          # Show help
./install.sh --help      # Show help
```

### Framework Usage
```bash
# Interactive menu
./pwnthebox.sh

# Direct commands
./pwnthebox.sh 1        # Run Reconnaissance phase
./pwnthebox.sh 5        # Run Privilege Escalation
./pwnthebox.sh --deps    # Check dependencies
./pwnthebox.sh --paths   # Show tool paths
```

---

## 📁 Directory Structure

```
PwnTheBox/
├── pwnthebox.sh              # Main framework launcher
├── install.sh               # Smart installation script
├── update.sh                # Framework updater
│
├── Recon/                   # Phase 1: Information Gathering
│   ├── recon-suite.sh      # Recon menu
│   ├── domain.sh           # Domain reconnaissance
│   ├── passive.sh          # Passive reconnaissance
│   ├── person.sh           # Person/OSINT search
│   ├── generateTargets.sh  # Target generation
│   └── ...                 # More recon tools
│
├── Enum/                    # Phase 2: Scanning & Enumeration
│   ├── enum-suite.sh       # Enum menu
│   ├── nse.sh              # Nmap script engine
│   ├── cve.sh              # CVE scanning
│   ├── msf-aux.sh          # Metasploit aux modules
│   └── ...                 # More enum tools
│
├── Exploit/                # Phase 3: Initial Access
│   ├── compromise-suite.sh # Exploitation menu
│   ├── payloads.sh         # Payload generation
│   ├── shells.sh           # Reverse shells
│   ├── encoder.sh          # Encoding/obfuscation
│   ├── nikto.sh            # Web vulnerability scanner
│   ├── web-exploit.sh      # Web exploitation
│   ├── elf/                # ELF binary exploitation
│   ├── fuzz/               # Fuzzing tools
│   └── ...                 # More exploit tools
│
├── Foothold/                # Phase 4: Shell Stabilization
│   ├── foothold-suite.sh   # Foothold menu
│   └── listener.sh         # Reverse listeners
│
├── Privilege-Escalation/    # Phase 5: Privilege Escalation
│   ├── Linux/
│   │   ├── privesc.sh      # Linux PE checker v2.0
│   │   ├── checks/          # PE check modules
│   │   └── exploits/        # Exploit suggestions
│   └── Windows/
│       └── privesc.ps1     # Windows PE checker
│
├── Internal/                # Phase 6: Post-Compromise Recon
│   ├── internal-recon-suite.sh
│   └── credentials/         # Credential harvesting
│
├── Lateral/                 # Phase 7: Lateral Movement
│   ├── lateral-suite.sh    # Lateral menu
│   ├── ssh-pivot.sh        # SSH pivoting
│   ├── chisel-pivot.sh     # Chisel pivoting
│   └── socat-pivot.sh      # Socat pivoting
│
├── Persistence/             # Phase 8: Maintain Access
│   ├── persistence-suite.sh
│   └── Linux-persistence.sh
│
├── Misc/                    # Phase 9: Actions on Objectives
│   ├── actions-suite.sh
│   ├── hashes/             # Hash cracking
│   ├── logs/               # Log analysis
│   └── stego/              # Steganography
│
├── config/                  # Configuration files
│   ├── tmux.conf
│   ├── vimrc
│   ├── zshrc
│   └── deploy/             # Deployment configs
│
├── utils/                   # Utility scripts
│   ├── parse-nmap.py       # Nmap parser
│   ├── parse-nessus.py     # Nessus parser
│   └── ...                 # More utilities
│
├── reports/                 # Generated reports
├── wordlists/               # Wordlists and dictionaries
└── venv/                   # Python virtual environment
```

---

## 🛠️ Installation & Setup

### Automated Installation
```bash
# Clone repository
git clone https://github.com/manojxshrestha/pwnthebox.git
cd pwnthebox

# Run smart installer
./install.sh

# Launch framework
./pwnthebox.sh
```

### What Gets Installed

**Core Dependencies:**
- Bash, Python3, Git, Vim, Tmux, Netcat, Nmap, Wireshark, curl, wget, jq

**Reconnaissance Tools:**
- ✅ theHarvester v4.10.0 (latest from GitHub)
- Subfinder, DNSTwist, DNSRecon, Recon-ng

**Exploitation Tools:**
- Metasploit Framework, Exploit-DB, SQLMap, Nikto, Hydra, Hashcat

**Binary Exploitation:**
- GDB, Pwndbg, Ropper, ROPGadget, OneGadget (all latest versions)

**Web Application Tools:**
- GoBuster, WFUZZ, FFUF, Dirsearch, OWASP ZAP

**Post-Exploitation:**
- Steghide, Binwalk, ExifTool, Foremost
- Socat, Chisel, Proxychains

**Python Packages:**
- Requests, BeautifulSoup4, Scapy, Impacket, DNSPython, Jinja2, and more

---

## 📖 Usage Examples

### Reconnaissance
```bash
# Launch recon menu
./pwnthebox.sh 1

# Or run directly
./Recon/recon-suite.sh
./Recon/domain.sh
./Recon/passive.sh target.com
```

### Enumeration
```bash
./pwnthebox.sh 2
./Enum/enum-suite.sh
./Enum/nse.sh 192.168.1.0/24
```

### Privilege Escalation
```bash
# Linux
./Privilege-Escalation/Linux/privesc.sh --all

# Windows (PowerShell)
powershell -ep bypass -f Privilege-Escalation/Windows/privesc.ps1
```

### Using theHarvester
```bash
# After installation, theHarvester is available
theHarvester -d company.com -b all

# Or via framework
./pwnthebox.sh 1  # Select passive recon
```

### Quick Launcher
```bash
# Launch framework
./pwnthebox.sh

# Run recon
./Recon/recon-suite.sh

# Run enum
./Enum/enum-suite.sh
```

---

## 🔧 Framework Options

### Conductor.sh
```bash
./pwnthebox.sh              # Interactive menu
./pwnthebox.sh 1            # Run Recon
./pwnthebox.sh 2            # Run Enum
./pwnthebox.sh 5            # Run PrivEsc
./pwnthebox.sh --paths      # Show tool paths
./pwnthebox.sh --deps       # Check dependencies
./pwnthebox.sh --help       # Show help
```

### Installation Script
```bash
./install.sh               # Install all tools (smart)
./install.sh --check       # Check status
./install.sh -h            # Help
```

---

## 🎓 Best Practices

1. **Legal Authorization**: Always have written permission before testing
2. **OPSEC**: Use stealth mode when needed
3. **Documentation**: Document findings with timestamps
4. **Scope**: Stay within agreed boundaries
5. **Reporting**: Generate reports with `./Misc/report.sh`

---

## 📦 Requirements

- **OS**: Kali Linux, WSL, Parrot OS, Ubuntu, Debian, Arch, macOS
- **Shell**: Bash 5.0+
- **Python**: 3.8+ (3.12 recommended)
- **Permissions**: Sudo access for package installation

---

## 👨‍💻 Author

**Manoj Shrestha**

- GitHub: [@manojxshrestha](https://github.com/manojxshrestha)
- X: [@manojxshrestha](https://x.com/manojxshrestha)
- LinkedIn: [manojxshrestha](https://linkedin.com/in/manojxshrestha)

---

## 📜 License

MIT License - see LICENSE file for details.

---

## ⚠️ Disclaimer

These tools are for **authorized security testing and educational purposes only**. Always obtain proper written authorization before testing any system you do not own.

**Happy Hacking! 🐛🔒**

---

## 🙏 Acknowledgments

- Offensive Security community
- Open source security tool developers
- Penetration testing community

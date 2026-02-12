# 🛡️ VAPT Automation Framework

**Professional Vulnerability Assessment & Penetration Testing Toolkit**

[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/manojxshrestha/vapt-framework)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📋 Overview

A comprehensive collection of automation scripts designed for professional Vulnerability Assessment and Penetration Testing (VAPT). This framework provides tools for all phases of penetration testing from exploitation to forensics.

## 🎯 What's Included

### 4. Exploitation Helpers
- **Payload Generator** (`exploitation/payloads.sh`)
  - Generate reverse shells, bind shells, and command execution payloads
  - Multi-OS support (Linux, Windows, macOS)
  - Encoding options (Base64, Hex, URL, ROT13)
  
- **Reverse Shell Generator** (`exploitation/shells.sh`)
  - Interactive shell generation with listener
  - Auto-detect network interfaces
  - Multiple shell types (bash, python, perl, ruby, netcat, powershell)
  
- **Encoding & Obfuscation Toolkit** (`exploitation/encoder.sh`)
  - URL, Base64, Hex, Binary encoding
  - ROT13, Caesar cipher, Morse code
  - JWT decoding, PowerShell encoding
  - Multi-layer chaining

### 5. Post-Exploitation
- **Linux Privilege Escalation Checker** (`post-exploitation/linux/privesc.sh`)
  - System enumeration
  - SUID/SGID binary detection
  - Kernel exploit checks
  - Cron job analysis
  - Container escape detection
  
- **Windows Privilege Escalation Checker** (`post-exploitation/windows/windows-privesc-check.ps1`)
  - PowerShell-based enumeration
  - Service permission checks
  - Registry analysis
  - Scheduled task enumeration
  
- **Credential Harvester** (`post-exploitation/credentials/creds.sh`)
  - Search for passwords, API keys, tokens
  - Memory analysis
  - SSH key discovery
  - Cloud credential detection

### 6. Cryptography & Forensics
- **Hash Cracker** (`crypto-forensics/hashes/hashes.sh`)
  - Hash type identification
  - Hashcat and John the Ripper integration
  - Batch processing
  - Hash generation
  
- **Log Analyzer** (`crypto-forensics/logs/logs.sh`)
  - Authentication log analysis
  - Web server log parsing
  - Brute force detection
  - Timeline generation
  
- **Steganography Detector** (`crypto-forensics/stego/stego.sh`)
  - LSB analysis
  - Steghide extraction
  - Binwalk integration
  - Metadata analysis

### 8. Binary Exploitation
- **ELF Analyzer** (`binary-pwn/elf/elf.sh`)
  - Security feature checks (NX, PIE, Canary, RELRO)
  - ROP gadget detection
  - Symbol analysis
  - Exploit template generation
  
- **Simple Fuzzer** (`binary-pwn/fuzz/fuzzer.sh`)
  - CLI application fuzzing
  - Network service fuzzing
  - Multiple payload types
  - Wordlist support

---

## 🚀 Quick Start

### Interactive Mode
```bash
./conductor.sh
```

### Direct Tool Access
```bash
# Payload generation
./conductor.sh payload -t reverse-tcp -o linux -i 10.10.10.10 -p 4444

# Linux privilege escalation check
./conductor.sh linpriv --all

# Hash cracking
./conductor.sh hash -i "5f4dcc3b5aa765d61d8327deb882cf99"

# ELF analysis
./conductor.sh elf -f ./target_binary
```

---

## 📁 Directory Structure

```
vapt/
├── exploitation/
│   ├── payload-generator.sh
│   ├── reverse-shell-gen.sh
│   └── encoder-toolkit.sh
├── post-exploitation/
│   ├── linux/
│   │   └── linux-privesc-check.sh
│   ├── windows/
│   │   └── windows-privesc-check.ps1
│   └── credentials/
│       └── credential-harvester.sh
├── crypto-forensics/
│   ├── hashes/
│   │   └── hash-cracker.sh
│   ├── logs/
│   │   └── log-analyzer.sh
│   └── stego/
│       └── stego-detector.sh
├── binary-pwn/
│   ├── elf/
│   │   └── elf-analyzer.sh
│   └── fuzz/
│       └── simple-fuzzer.sh
├── reports/
├── wordlists/
├── utils/
└── conductor.sh
```

---

## 🔧 Installation

### Prerequisites
```bash
# Core dependencies
apt update
apt install -y bash python3 file binutils

# Optional but recommended
apt install -y steghide stegseek binwalk exiftool outguess
pip install ropgadget ropper
```

### Clone and Setup
```bash
git clone https://github.com/manojxshrestha/vapt-framework.git
cd vapt-framework
chmod +x conductor.sh
./conductor.sh
```

---

## 💡 Usage Examples

### Generate Reverse Shell
```bash
./exploitation/shells.sh -i 10.10.10.10 -p 4444 --listen
```

### Linux Privilege Escalation
```bash
sudo ./post-exploitation/linux/privesc.sh --all -o report.txt
```

### Hash Identification & Cracking
```bash
./crypto-forensics/hashes/hashes.sh -i "5f4dcc3b5aa765d61d8327deb882cf99"
```

### Steganography Analysis
```bash
./crypto-forensics/stego/stego.sh -f suspicious_image.jpg
```

### Binary Analysis
```bash
./binary-pwn/elf/elf.sh -f ./challenge_binary --all
```

---

## 👨‍💻 Author

**me**

- GitHub: [@manojxshrestha](https://github.com/manojxshrestha)
- X: [@manojxshrestha](https://x.com/manojxshrestha)
- Medium: [@manojxshrestha](https://medium.com/@manojxshrestha)

---

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## ⚠️ Disclaimer

These tools are for authorized security testing and educational purposes only. Always obtain proper authorization before testing any system you do not own.

**Happy Hunting! 🐛🔒**

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-blue" alt="Version 1.0">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Kali%20%7C%20WSL%20%7C%20Parrot%20OS-blue" alt="Platform">
  <img src="https://img.shields.io/badge/shell-Bash%205%2B-yellow" alt="Bash">
  <img src="https://img.shields.io/badge/python-3.8%2B-blue" alt="Python 3.8+">
</p>

<p align="center">
  A 9-phase penetration testing framework for authorized security assessments.
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#installation">Installation</a> •
  <a href="#phases">Phases</a> •
  <a href="docs/USER_GUIDE.md">Documentation</a>
</p>

## Overview

astra is a modular penetration testing framework organized around 9 phases from reconnaissance through actions on objectives. It includes dedicated suites for OSINT, cryptography, and binary exploitation, with an interactive menu and direct per-phase access.

## Capabilities

| | |
|---|---|
| **Phases** | 9 phases covering recon, exploitation, post-exploitation |
| **OSINT Suite** | Cloud enumeration, dorking, email harvesting, breach search, metadata extraction, Microsoft recon, SPF/DMARC analysis, API discovery |
| **Crypto Suite** | Auto-decoding, hash cracking, RSA attacks, classical cipher tools |
| **Binary Suite** | PwnPasi, ROPgadget, checksec, pwndbg, pwntools |
| **Installation** | Auto-detects installed tools, skip redundant installs, Python venv |
| **Platforms** | Kali Linux, WSL, Parrot OS, Ubuntu, Debian, Arch, macOS |

## Quick Start

```bash
git clone https://github.com/manojxshrestha/astra.git
cd astra
chmod +x astra.sh install.sh update.sh
./install.sh
./astra.sh
```

```bash
./astra.sh 1          # Run phase directly (1-9)
./astra.sh --help     # Show all options
./install.sh --check  # Verify installation
```

## Phases

| Phase | Module | Description |
|-------|--------|-------------|
| 1 | Reconnaissance | DNS, domain, passive recon, OSINT |
| 2 | Enumeration | Port scanning, service discovery, CVE scanning |
| 3 | Exploitation | Metasploit, SQLMap, payload generation, API scanning |
| 4 | Foothold | Shell stabilization, listeners |
| 5 | Privilege Escalation | Linux/Windows PE checking |
| 6 | Internal Recon | Post-compromise enumeration, credential harvesting |
| 7 | Lateral Movement | SSH/Chisel/Socat pivoting |
| 8 | Persistence | Linux/Windows persistence mechanisms |
| 9 | Actions on Objectives | Hash cracking, stego, exfiltration, reporting |

## Directory Layout

```
astra/
├── astra.sh              Main launcher
├── install.sh            Setup script
├── update.sh             Updater
├── docs/                 User guide and documentation
├── data/                 Phase output directories
├── Recon/                Phase 1
├── Enum/                 Phase 2
├── Exploit/              Phase 3
├── Foothold/             Phase 4
├── Privilege-Escalation/ Phase 5
├── Internal/             Phase 6
├── Lateral/              Phase 7
├── Persistence/          Phase 8
├── Misc/                 Phase 9 (hashes, stego, exfil, report)
├── OSINT/                OSINT tool suite
├── Crypto/               Cryptography tools
├── Binary/               Binary exploitation tools
├── config/               Dotfiles and configurations
├── utils/                Python utility scripts
├── wordlists/            Custom wordlists
└── venv/                 Python virtual environment
```

## Per-Phase Access

```bash
./Recon/recon-suite.sh
./Enum/enum-suite.sh
./Exploit/compromise-suite.sh
./Privilege-Escalation/Linux/privesc.sh --all
./Lateral/lateral-suite.sh
```

## Documentation

- [USER_GUIDE.md](docs/USER_GUIDE.md) — Complete framework usage guide
- [FRAMEWORK.md](FRAMEWORK.md) — Technical architecture and structure
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md) — Known limitations and workarounds

## License

MIT — see [LICENSE](LICENSE).

Use only against systems you own or have explicit written authorization to test. Unauthorized access is illegal.

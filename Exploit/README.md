# Phase 3: Initial Compromise

Exploit vulnerabilities to gain initial access to target systems.

## Purpose

Active exploitation to achieve:
- Initial shell access
- Web shell deployment
- Network service compromise
- Binary exploitation

## Usage

```bash
# Interactive menu
./compromise-suite.sh --menu

# Direct options
./compromise-suite.sh C1
./compromise-suite.sh CW1
```

## Tools

### Payload Generation

| Script | Description |
|--------|-------------|
| `payloads.sh` | Multi-platform payload generator (msfvenom) |
| `shells.sh` | Reverse shell generator |
| `encoder.sh` | Encoding and obfuscation toolkit |
| `payload.sh` | Quick payload generation |

### Web Exploitation

| Script | Description |
|--------|-------------|
| `web-exploit.sh` | Comprehensive web exploitation toolkit |
| `nikto.sh` | Web vulnerability scanner |
| `ssl.sh` | SSL/TLS vulnerability analysis |
| `openredirect-scanner.py` | Open redirect vulnerability scanner |
| `directObjectRef.sh` | Insecure Direct Object Reference testing |

### Binary Exploitation

| Script | Description |
|--------|-------------|
| `elf/elf.sh` | ELF binary analysis and exploitation |
| `fuzz/fuzzer.sh` | Fuzzing tools for vulnerability discovery |
| `debug/` | Debugging utilities |

### Other Tools

| Script | Description |
|--------|-------------|
| `autopwn.sh` | Automated exploitation framework |
| `listener.sh` | Reverse listener setup |
| `newModules.sh` | Custom exploit modules |

## Menu Options

- **C1**: Payload Generator (msfvenom)
- **C2**: Reverse Shell Generator
- **C3**: Web Shell Generator
- **C4**: Encoding & Obfuscation
- **CW1**: Web Exploitation Toolkit
- **CN1**: Network Exploitation
- **CB1**: ELF Binary Analyzer
- **CB2**: Fuzzer

## Examples

```bash
# Generate Linux meterpreter payload
./payloads.sh

# Generate reverse shell
./shells.sh

# Start web exploitation menu
./web-exploit.sh

# SSL/TLS testing
./ssl.sh target.com:443

# Nikto scan
./nikto.sh -h http://target.com
```

## Notes

- Always have proper authorization
- Use appropriate payloads for target environment
- Consider encoding for AV evasion
- Document all exploitation steps
- Have a listener ready before generating payloads

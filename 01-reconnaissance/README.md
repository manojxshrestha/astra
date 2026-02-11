# Phase 1: Reconnaissance

Gather information about the target organization and systems.

## Purpose

Passive and active information gathering to identify:
- Domain and DNS information
- Email addresses and personnel
- Subdomains and network infrastructure
- Technology stack and potential vulnerabilities

## Usage

```bash
# Interactive menu
./recon-suite.sh --menu

# Direct options
./recon-suite.sh R1 domain.com
./recon-suite.sh R2 domain.com
./recon-suite.sh R4 domain.com
```

## Tools

| Script | Description |
|--------|-------------|
| `domain.sh` | Domain information gathering (whois, dig, nslookup) |
| `passive.sh` | Passive reconnaissance using OSINT |
| `person.sh` | Email and personnel harvesting |
| `generateTargets.sh` | Generate target list from reconnaissance |
| `ping-sweep.sh` | Network discovery via ping sweep |
| `dns-*.sh` | Various DNS enumeration tools |
| `recon-ng.sh` | Recon-ng framework integration |
| `subdomains-from-ssl.sh` | Subdomain discovery from SSL certificates |

## Menu Options

- **R1**: Domain Information Gathering
- **R2**: DNS Enumeration
- **R3**: Email Harvesting
- **R4**: Subdomain Discovery
- **R5**: Google Dorks (manual research)
- **R7**: Network Discovery (Ping Sweep)
- **R8**: Traceroute

## Examples

```bash
# Domain information
./domain.sh example.com

# Passive reconnaissance
./passive.sh -d example.com

# Subdomain discovery
./generateTargets.sh example.com
```

## Notes

- Always perform passive reconnaissance before active scanning
- Respect scope and avoid excessive traffic
- Document all findings for reporting

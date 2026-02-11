# Phase 6: Internal Reconnaissance

Post-compromise enumeration of the internal network.

## Purpose

Discover the internal network after initial compromise:
- Internal network mapping
- Service discovery
- Credential harvesting
- Domain enumeration (Windows)

## Usage

```bash
# Interactive menu
./internal-recon-suite.sh --menu

# Direct options
./internal-recon-suite.sh I1 192.168.1.0/24
```

## Tools

| Script/Directory | Description |
|------------------|-------------|
| `credentials/creds.sh` | Credential harvesting from memory, files, browsers |
| `enum/` | Internal enumeration scripts |

## Menu Options

- **I1**: Internal Network Discovery
- **I2**: Active Directory Enumeration
- **I3**: Service Discovery
- **I4**: User Enumeration
- **I5**: Share Enumeration
- **I6**: Trust Relationship Discovery
- **I7**: Domain Controller Discovery
- **I8**: BloodHound Data Collection
- **I9**: Firewall/IDS Enumeration
- **I10**: VPN Enumeration
- **I11**: Cloud Asset Discovery
- **I12**: Kubernetes Discovery
- **I13**: Wireless Network Discovery

## Credential Harvesting

The `creds.sh` script checks for:

- **Memory Credentials**: Mimikatz-style extraction
- **File-Based**: Configuration files, databases
- **Browser Credentials**: Chrome, Firefox, Edge
- **Windows Vault**: Windows Credential Manager
- **LM/NT Hashes**: SAM database, LSASS memory
- **SSH Keys**: SSH private keys
- **Git Credentials**: Git config and credentials
- **Environment Variables**: API keys, tokens

## Examples

```bash
# Scan internal network
./internal-recon-suite.sh I1 192.168.1.0/24

# Active Directory enumeration
./internal-recon-suite.sh I2

# Credential harvesting
./credentials/creds.sh

# Collect BloodHound data
./internal-recon-suite.sh I8
```

## Discovery Techniques

1. **Internal Network Mapping**
   - ARP scanning
   - DNS enumeration
   - SMB/LDAP queries
   - Routing table analysis

2. **Active Directory Enumeration**
   - BloodHound/Sharphound
   - PowerView
   - AD module

3. **Credential Locations**
   - Memory (LSASS, SAM)
   - Files (.env, config, databases)
   - Browser storage
   - SSH keys
   - Git credentials

## Notes

- Use stealth techniques during red team engagements
- Throttle discovery to avoid detection
- Prioritize high-value targets
- Document all credentials found
- Look for domain admin paths

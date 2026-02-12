# Known Issues

This document tracks known issues and limitations in the PwnTheBox framework.

## Framework Issues

### 1. Missing Helper Scripts
Some suite scripts reference helper scripts that may not exist:
- `ping-sweep.sh` - Referenced in recon-suite.sh R7 but may not exist
- `dns-forward.sh` - Referenced in recon-suite.sh R8 but may not exist
- `web-exploit.sh` - Referenced in compromise-suite.sh CW1 but may not exist
- `payloads.sh`, `shells.sh`, `encoder.sh` - Referenced in compromise-suite.sh

**Status**: These are informational/reference scripts. Users should manually run the appropriate commands or create custom scripts as needed.

### 2. Nested Suite Script Invocation
Suite scripts call each other using relative paths that may break if the framework structure changes.
- Example: `run_enum_script "../Exploit/ssl.sh" "$TARGET"`

**Status**: Known limitation. Scripts assume they run from their expected directory.

### 3. Missing External Tools
The framework requires many external tools (nmap, gobuster, nikto, msfvenom, etc.). The `install.sh` script handles most installations, but some tools may require manual configuration:
- Metasploit Framework
- Burp Suite (commercial)
- Ligolo-ng (requires manual download)

### 4. Wordlist Dependencies
Directory busting (EV3) requires wordlists. The framework expects:
- `/usr/share/wordlists/dirb/common.txt`
- `/usr/share/wordlists/SecLists/Discovery/Web-Content/common.txt`

**Status**: install.sh installs SecLists, but users may need to customize wordlist paths.

## Script-Specific Issues

### enum-suite.sh
- E1, E2, E5 only print commands instead of executing (by design for safety)
- EV3 (Directory Busting) uses gobuster which must be installed

### compromise-suite.sh
- C3 (Web Shell Generator) only prints msfvenom command (by design)
- Binary exploitation scripts require additional tools (ROPgadget, pwntools)

### actions-suite.sh
- O1-O5 only print commands (informational/reference)

### persistence-suite.sh
- P1-P5, PW1-PW5 only print commands (informational/reference)

## Security Considerations

1. **Credential Handling**: Scripts may print credentials/hashes - ensure proper cleanup
2. **Log Files**: Check for residual log files after engagements
3. **Network Traffic**: Some tools (exfiltration scripts) may trigger network alerts

## Future Improvements

1. Add integration testing for all suite scripts
2. Create mock mode for training scenarios
3. Add output formatting options (JSON, CSV)
4. Implement campaign management for multi-target engagements
5. Add reporting integration

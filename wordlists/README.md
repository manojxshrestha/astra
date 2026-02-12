# Wordlists

This directory contains wordlists used by PwnTheBox framework.

## Included Wordlists

| File | Description |
|------|-------------|
| `raft-large-directories.txt` | Directory names for busting |
| `http-default-userpass.txt` | HTTP default credentials |
| `common-passwords.txt` | Common passwords |
| `rockyou.txt` | Popular passwords list (local only, 134MB) |

## Git Ignore

`rockyou.txt` is added to `.gitignore` because it's too large for GitHub.

## Installation

```bash
# Install from Kali packages
sudo apt install seclists

# Copy to framework wordlists
sudo cp /usr/share/wordlists/SecLists/* /home/pwn/pwnthebox/wordlists/
```

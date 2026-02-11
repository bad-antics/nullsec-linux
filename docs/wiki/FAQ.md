# FAQ

## Is NullSec Linux based on Debian or Arch?
NullSec Linux is based on Debian stable with custom kernel patches and security tool packages.

## How is it different from Kali Linux?
NullSec Linux focuses on:
- NullSec Framework integration
- Custom tooling not found in Kali
- Hardware hacking support (Flipper Zero, HackRF, etc.)
- Privacy-first default configuration

## Can I install it on bare metal?
Yes. The installer supports UEFI and Legacy BIOS, with full disk encryption (LUKS) option.

## What are the system requirements?
| | Minimum | Recommended |
|---|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 2 GB | 8+ GB |
| Disk | 20 GB | 50+ GB |
| GPU | Any | For GPU cracking |

## How do I update?
```bash
sudo apt update && sudo apt upgrade
nullsec-update  # Updates NullSec tools
```

## Can I use it as a daily driver?
Yes, but it's optimized for security work. For general use, consider dual-booting.

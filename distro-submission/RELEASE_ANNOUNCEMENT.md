# NullSec Linux 5.0.0 Release Announcement

**Release Date:** January 23, 2026  
**Codename:** "Phantom"  
**Download:** https://github.com/bad-antics/nullsec-linux/releases/tag/v5.0.0

---

## Overview

We are pleased to announce the release of **NullSec Linux 5.0.0**, a major update to our security-focused Linux distribution. This release brings significant improvements including expanded tool coverage, new specialized editions, and broader architecture support.

## What's New in 5.0.0

### 🛠️ 135+ Security Tools
- Expanded from 90+ to 135+ pre-installed security tools
- New categories: Cloud Security, AI/ML Security, Hardware Hacking, Automotive Security
- All tools tested and pre-configured for immediate use

### 🐧 5 New Specialized Editions
- **Cloud Pentest Edition** — AWS, GCP, Azure, Kubernetes security testing
- **AI/ML Security Edition** — LLM red teaming, model auditing, adversarial testing
- **Hardware Hacking Edition** — SDR, RFID, JTAG, glitch attack tools
- **Automotive Security Edition** — CAN bus, OBD-II, UDS protocol testing
- **Mobile Security Edition** — Integration with NullKia framework

### 🖥️ 4 Architecture Support
- **AMD64** — Full support with all tools
- **ARM64** — Native support for Raspberry Pi, cloud instances
- **RISC-V** — Experimental support for RISC-V boards
- **Apple Silicon** — Native M1/M2/M3 support via Asahi patches

### 🎨 Desktop Environment Updates
- XFCE 4.18 as default (lightweight, customizable)
- Hyprland 0.35+ for Wayland users
- i3wm preset for tiling window manager fans
- Custom NullSec dark theme across all environments

### 🔒 Security Improvements
- Kernel 6.8 LTS with security hardening patches
- AppArmor profiles for all pre-installed tools
- Secure boot support (signed bootloader)
- Full disk encryption in installer
- MAC address randomization on boot

### 📦 Base System
- Debian 13 (Trixie) base
- systemd 255
- Linux kernel 6.8 LTS
- GRUB 2.12 bootloader
- Calamares 3.3 graphical installer

## Download

| Edition | Architecture | Size | Download |
|---------|--------------|------|----------|
| Standard | AMD64 | 4.2 GB | [Download](https://github.com/bad-antics/nullsec-linux/releases/download/v5.0.0/nullsec-5.0.0-standard-amd64.iso) |
| Standard | ARM64 | 4.0 GB | [Download](https://github.com/bad-antics/nullsec-linux/releases/download/v5.0.0/nullsec-5.0.0-standard-arm64.iso) |
| Minimal | AMD64 | 1.8 GB | [Download](https://github.com/bad-antics/nullsec-linux/releases/download/v5.0.0/nullsec-5.0.0-minimal-amd64.iso) |
| Live | AMD64 | 3.5 GB | [Download](https://github.com/bad-antics/nullsec-linux/releases/download/v5.0.0/nullsec-5.0.0-live-amd64.iso) |
| Cloud | AMD64 | 2.8 GB | [Download](https://github.com/bad-antics/nullsec-linux/releases/download/v5.0.0/nullsec-5.0.0-cloud-amd64.iso) |

## Verification

All releases are GPG signed. Import our signing key:
```bash
curl -fsSL https://bad-antics.github.io/keys/nullsec-release.asc | gpg --import
```

Verify downloads:
```bash
gpg --verify nullsec-5.0.0-standard-amd64.iso.sig nullsec-5.0.0-standard-amd64.iso
sha256sum -c SHA256SUMS
```

## Upgrade Path

Users of NullSec Linux 4.x can upgrade using:
```bash
sudo nullsec-upgrade --to 5.0.0
```

Or perform a fresh installation (recommended for major version upgrades).

## Documentation

- [Installation Guide](https://github.com/bad-antics/nullsec-wiki/Installation-Guide)
- [Tool Documentation](https://github.com/bad-antics/nullsec-wiki/Tools)
- [FAQ](https://github.com/bad-antics/nullsec-wiki/FAQ)

## Support

- **GitHub Issues:** https://github.com/bad-antics/nullsec-linux/issues
- **Discord:** https://discord.gg/killers
- **Wiki:** https://github.com/bad-antics/nullsec-wiki

## Acknowledgments

Thanks to all contributors, testers, and the security community for feedback and support.

---

**NullSec Linux** — Security Tools. Simplified.

© 2024-2026 bad-antics | MIT License

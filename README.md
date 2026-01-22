<div align="center">

# 🐧 NullSec Linux

### Security-Focused Linux Distribution with Maximum Hardening

**by bad-antics development**

[![License: NPL](https://img.shields.io/badge/License-NullSec%20Public-red.svg)](LICENSE)
[![Base](https://img.shields.io/badge/Base-Debian%2012-blue.svg)]()
[![Tools](https://img.shields.io/badge/Security%20Tools-50+-green.svg)]()
[![Hardened](https://img.shields.io/badge/Security-Maximum%20Hardening-gold.svg)]()
[![GitHub](https://img.shields.io/badge/GitHub-bad--antics-black?logo=github)](https://github.com/bad-antics)

```
    _   __      ____  _____              __    _                  
   / | / /_  __/ / / / ___/___  _____   / /   (_)___  __  ___  __
  /  |/ / / / / / /  \__ \/ _ \/ ___/  / /   / / __ \/ / / / |/_/
 / /|  / /_/ / / /  ___/ /  __/ /__   / /___/ / / / / /_/ />  <  
/_/ |_/\__,_/_/_/  /____/\___/\___/  /_____/_/_/ /_/\__,_/_/|_|  
                                                                  
       [ bad-antics development | Security Distribution v3.0 ]
```

</div>

---

## 📥 Official Downloads

### 🌐 Download Portal: **[bad-antics.github.io](https://bad-antics.github.io)**

---

## 💎 Premium Editions (Hardened)

Stripped, hardened, production-ready images with maximum security features.

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **NullSec Pro — Full** | Complete hardened system for installation | 3.2 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-pro-3.0-amd64.iso) |
| **NullSec Pro — USB** | Bootable USB with encrypted persistence | 4.1 GB | [IMG](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-pro-usb-3.0-amd64.img) |
| **NullSec Pro — Minimal** | CLI-only, minimal attack surface | 890 MB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-pro-minimal-3.0-amd64.iso) |

### Premium Features:
- ✅ Kernel hardening (KSPP, grsecurity principles)
- ✅ Zero telemetry — completely stripped
- ✅ Full disk encryption by default
- ✅ Secure boot support
- ✅ Anti-forensics capabilities
- ✅ MAC spoofing on boot

---

## 🐧 Standard Editions

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **Full** | Complete toolkit (50+ tools) | 4.8 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-full-3.0-amd64.iso) |
| **Lite** | Essential tools only | 2.4 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-lite-3.0-amd64.iso) |
| **NetInstall** | Minimal, downloads during install | 450 MB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-netinst-3.0-amd64.iso) |

---

## ⚡ Live Boot Images

Boot directly without installation — leaves no trace on host system.

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **Live Standard** | Full toolkit in RAM | 3.6 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-live-3.0-amd64.iso) |
| **Live Stealth** | Anti-forensics, RAM-only | 2.8 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-live-stealth-3.0-amd64.iso) |
| **Live Forensics** | DFIR focused, read-only mounts | 4.2 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-live-forensics-3.0-amd64.iso) |

---

## 🖥️ Architecture Support

| Architecture | Description | Download |
|--------------|-------------|----------|
| **AMD64/x86_64** | Standard 64-bit PCs | All editions above |
| **ARM64/aarch64** | Raspberry Pi 4/5, ARM servers | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-3.0-arm64.iso) |
| **RISC-V** | StarFive, experimental | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/nullsec-3.0-riscv64.iso) |

---

## 🔍 Verify Downloads

Always verify your downloads before use!

```bash
# Download checksums
wget https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/SHA256SUMS
wget https://github.com/bad-antics/nullsec-linux/releases/download/v3.0/SHA256SUMS.sig

# Verify checksum
sha256sum -c SHA256SUMS 2>/dev/null | grep nullsec-pro

# GPG verification
gpg --keyserver keyserver.ubuntu.com --recv-keys B1F1881F70FB62A7
gpg --verify SHA256SUMS.sig SHA256SUMS
```

---

## �� Security Hardening

All NullSec Linux editions include:

### Kernel Hardening
- KASLR enabled
- SMEP/SMAP enabled
- PTI (Meltdown mitigation)
- Retpoline (Spectre mitigation)
- Kernel module signing enforced

### Binary Hardening
- PIE (Position Independent Executables)
- Full RELRO
- Stack canaries
- FORTIFY_SOURCE=2
- NX/DEP enabled

### Network Hardening
- Firewall enabled by default
- IPv6 privacy extensions
- SYN cookies enabled
- Reverse path filtering

### Application Hardening
- AppArmor profiles
- Seccomp filters
- Namespace isolation
- Capability dropping

---

## 🛠️ Pre-Installed Security Tools (50+)

All tools feature **maximum security hardening** with:
- ✅ Input validation
- ✅ Bounds checking
- ✅ Secure memory zeroing
- ✅ Constant-time crypto
- ✅ Rate limiting
- ✅ Defense in depth

### Hardened Tool Suite

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-memcorrupt](https://github.com/bad-antics/nullsec-memcorrupt) | Zig | Memory corruption analysis |
| [nullsec-netprobe](https://github.com/bad-antics/nullsec-netprobe) | Nim | Stealthy network recon |
| [nullsec-shellcraft](https://github.com/bad-antics/nullsec-shellcraft) | Racket | Shellcode generation DSL |
| [nullsec-cryptwrap](https://github.com/bad-antics/nullsec-cryptwrap) | Ada/SPARK | Formally verified crypto |
| [nullsec-procspy](https://github.com/bad-antics/nullsec-procspy) | Forth | Minimal process monitor |
| [nullsec-injector](https://github.com/bad-antics/nullsec-injector) | Rust | Memory-safe injection |
| [nullsec-stealth](https://github.com/bad-antics/nullsec-stealth) | Crystal | Steganography toolkit |
| [nullsec-portscan](https://github.com/bad-antics/nullsec-portscan) | Elixir | Async port scanner |
| [nullsec-hashwitch](https://github.com/bad-antics/nullsec-hashwitch) | Julia | Hash analysis/cracking |
| [nullsec-bingaze](https://github.com/bad-antics/nullsec-bingaze) | C++20 | Binary analysis |
| [nullsec-kernspy](https://github.com/bad-antics/nullsec-kernspy) | Go | Kernel module analyzer |
| [nullsec-netseer](https://github.com/bad-antics/nullsec-netseer) | Haskell | Network traffic analysis |
| [nullsec-sniffer](https://github.com/bad-antics/nullsec-sniffer) | Clojure | Packet analysis |
| [nullsec-keysniff](https://github.com/bad-antics/nullsec-keysniff) | F# | Input monitoring |
| [nullsec-beacon](https://github.com/bad-antics/nullsec-beacon) | Erlang | Network beacon |

---

## 🚀 Quick Start

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 64-bit x86_64 | Multi-core |
| RAM | 2 GB | 8 GB |
| Storage | 20 GB | 50 GB |
| Graphics | Any | Hardware accel |

### Create Bootable USB

```bash
# Linux/macOS
sudo dd if=nullsec-pro-3.0-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync

# Or use Ventoy for multi-ISO boot
sudo ventoy -i /dev/sdX
cp nullsec-*.iso /mnt/ventoy/
```

### First Boot

```bash
# Update system
nullsec-update

# Fetch latest tools
nullsec-fetch

# Launch framework
nullsec-framework

# Apply hardening
nullsec-harden --apply
```

---

## 📁 Directory Structure

```
/opt/nullsec/
├── bin/           # All NullSec tools
├── configs/       # Configuration files
├── payloads/      # Payload templates
├── wordlists/     # Curated wordlists
├── scripts/       # Automation scripts
└── docs/          # Documentation

/etc/nullsec/
├── hardening/     # Hardening profiles
├── firewall/      # Firewall rules
└── apparmor/      # AppArmor profiles
```

---

## 🔗 Related Projects

| Project | Description |
|---------|-------------|
| [nullsec-framework](https://github.com/bad-antics/nullsec-framework) | Unified toolkit framework |
| [nullsec-payloads](https://github.com/bad-antics/nullsec-payloads) | Payload templates |
| [nullsec-wordlists](https://github.com/bad-antics/nullsec-wordlists) | Curated wordlists |
| [nullsec-configs](https://github.com/bad-antics/nullsec-configs) | Dotfiles & configs |
| [nullsec-docs](https://github.com/bad-antics/nullsec-docs) | Full documentation |

---

## 📜 License

NullSec Public License v1.0 — For authorized security testing and education only.

---

## 🏷️ Keywords

`linux distribution` `security distro` `penetration testing` `ethical hacking` 
`kali alternative` `parrot alternative` `red team` `blue team` `CTF` 
`cybersecurity` `hacking tools` `privacy` `anonymity` `DFIR` `OSINT`
`bad-antics` `nullsec` `security research` `hardened linux` `security hardening`

---

<div align="center">

**Developed with 💀 by [bad-antics](https://github.com/bad-antics)**

*NullSec Project © 2026 — Hack Ethically*

### 🌐 **[Download Portal: bad-antics.github.io](https://bad-antics.github.io)**

[![GitHub](https://img.shields.io/badge/GitHub-bad--antics-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/bad-antics)
[![Discord](https://img.shields.io/badge/Discord-killers-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/killers)
[![Website](https://img.shields.io/badge/Downloads-bad--antics.github.io-ff0040?style=for-the-badge&logo=firefox&logoColor=white)](https://bad-antics.github.io)

</div>

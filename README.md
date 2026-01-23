<div align="center">

# �� NullSec Linux

### Security-Focused Linux Distribution with Battle-Tested Security

**by bad-antics development**

[![License: NPL](https://img.shields.io/badge/License-NullSec%20Public-red.svg)](LICENSE)
[![Base](https://img.shields.io/badge/Base-Debian%2013-blue.svg)]()
[![Tools](https://img.shields.io/badge/Security%20Tools-90+-green.svg)]()
[![Secure](https://img.shields.io/badge/Security-Maximum%20Security-gold.svg)]()
[![Version](https://img.shields.io/badge/Version-4.0-purple.svg)]()
[![GitHub](https://img.shields.io/badge/GitHub-bad--antics-black?logo=github)](https://github.com/bad-antics)

```
    _   __      ____  _____              __    _                  
   / | / /_  __/ / / / ___/___  _____   / /   (_)___  __  ___  __
  /  |/ / / / / / /  \__ \/ _ \/ ___/  / /   / / __ \/ / / / |/_/
 / /|  / /_/ / / /  ___/ /  __/ /__   / /___/ / / / / /_/ />  <  
/_/ |_/\__,_/_/_/  /____/\___/\___/  /_____/_/_/ /_/\__,_/_/|_|  
                                                                  
       [ bad-antics development | Security Distribution v4.0 ]
```

### 🔑 **[Join discord.gg/killers](https://discord.gg/killers)** for premium tools & support!

</div>

---

## 📥 Official Downloads

### 🌐 Download Portal: **[bad-antics.github.io](https://bad-antics.github.io)**

---

## 💎 Premium Editions

Stripped, locked-down, production-ready images with enterprise-grade security.

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **NullSec Pro — Full** | Complete secure system | 3.4 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-pro-4.0-amd64.iso) |
| **NullSec Pro — USB** | Bootable USB with encrypted persistence | 4.3 GB | [IMG](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-pro-usb-4.0-amd64.img) |
| **NullSec Pro — Minimal** | CLI-only, minimal attack surface | 920 MB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-pro-minimal-4.0-amd64.iso) |
| **NullSec Pro — Cloud** | AWS/GCP/Azure optimized | 1.8 GB | [AMI/VMDK](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-pro-cloud-4.0.tar.gz) |

### Premium Features:
- ✅ Kernel lockdown (KSPP, grsecurity principles)
- ✅ Zero telemetry — completely stripped
- ✅ Full disk encryption (LUKS2 + Argon2id)
- ✅ Secure boot with custom keys
- ✅ Anti-forensics capabilities
- ✅ MAC spoofing on boot
- ✅ Tor/I2P integration
- ✅ 90+ security tools pre-installed

---

## 🐧 Standard Editions

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **Full** | Complete toolkit (90+ tools) | 5.2 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-full-4.0-amd64.iso) |
| **Lite** | Essential tools only | 2.6 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-lite-4.0-amd64.iso) |
| **NetInstall** | Minimal, downloads during install | 480 MB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-netinst-4.0-amd64.iso) |

---

## ⚡ Live Boot Images

Boot directly without installation — leaves no trace on host system.

| Edition | Description | Size | Download |
|---------|-------------|------|----------|
| **Live Standard** | Full toolkit in RAM | 3.8 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-live-4.0-amd64.iso) |
| **Live Stealth** | Anti-forensics, RAM-only | 3.0 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-live-stealth-4.0-amd64.iso) |
| **Live Forensics** | DFIR focused, read-only mounts | 4.5 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-live-forensics-4.0-amd64.iso) |
| **Live Air-Gapped** | No network stack, offline only | 2.2 GB | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-live-airgap-4.0-amd64.iso) |

---

## 🖥️ Architecture Support

| Architecture | Description | Download |
|--------------|-------------|----------|
| **AMD64/x86_64** | Standard 64-bit PCs | All editions above |
| **ARM64/aarch64** | Raspberry Pi 4/5, ARM servers | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-4.0-arm64.iso) |
| **RISC-V** | StarFive VisionFive 2 | [ISO](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-4.0-riscv64.iso) |
| **Apple Silicon** | M1/M2/M3 via Asahi | [IMG](https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/nullsec-4.0-asahi.img) |

---

## 🔍 Verify Downloads

```bash
# Download checksums
wget https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/SHA256SUMS
wget https://github.com/bad-antics/nullsec-linux/releases/download/v4.0/SHA256SUMS.sig

# Verify checksum
sha256sum -c SHA256SUMS 2>/dev/null | grep nullsec-pro

# GPG verification
gpg --keyserver keyserver.ubuntu.com --recv-keys B1F1881F70FB62A7
gpg --verify SHA256SUMS.sig SHA256SUMS
```

---

## 🛡️ Security Features

### Kernel Protection
- KASLR enabled
- SMEP/SMAP enabled
- PTI (Meltdown mitigation)
- Retpoline (Spectre mitigation)
- Kernel module signing enforced
- Lockdown mode (integrity)
- KFENCE memory safety

### Binary Protection
- PIE (Position Independent Executables)
- Full RELRO
- Stack canaries
- FORTIFY_SOURCE=3
- NX/DEP enabled
- CET (Control-flow Enforcement)
- Shadow stack

### Network Security
- nftables firewall default
- IPv6 privacy extensions
- SYN cookies enabled
- Reverse path filtering
- TCP timestamps disabled
- ICMP redirect disabled

### Application Security
- AppArmor profiles
- Seccomp-bpf filters
- Namespace isolation
- Capability dropping
- Landlock LSM
- IMA/EVM integrity

---

## 🛠️ Pre-Installed Security Tools (90+)

### Offensive Tools

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-injector](https://github.com/bad-antics/nullsec-injector) | Rust | Memory-safe process injection |
| [nullsec-shellcraft](https://github.com/bad-antics/nullsec-shellcraft) | Racket | Shellcode generation DSL |
| [nullsec-exploit](https://github.com/bad-antics/nullsec-exploit) | C | Binary exploitation framework |
| [nullsec-c2](https://github.com/bad-antics/nullsec-c2) | Go | Command & control server |
| [nullsec-phish](https://github.com/bad-antics/nullsec-phish) | Python | Phishing framework |

### Network Tools

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-netprobe](https://github.com/bad-antics/nullsec-netprobe) | Nim | Stealthy network recon |
| [nullsec-portscan](https://github.com/bad-antics/nullsec-portscan) | Elixir | Async port scanner |
| [nullsec-netseer](https://github.com/bad-antics/nullsec-netseer) | Haskell | Traffic analysis |
| [nullsec-sniffer](https://github.com/bad-antics/nullsec-sniffer) | Clojure | Packet capture |
| [nullsec-flowtrace](https://github.com/bad-antics/nullsec-flowtrace) | Haskell | Flow analyzer |
| [nullsec-crystalrecon](https://github.com/bad-antics/nullsec-crystalrecon) | Crystal | Network reconnaissance |

### Analysis Tools

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-memcorrupt](https://github.com/bad-antics/nullsec-memcorrupt) | Zig | Memory corruption analysis |
| [nullsec-bingaze](https://github.com/bad-antics/nullsec-bingaze) | C++20 | Binary analysis |
| [nullsec-kernspy](https://github.com/bad-antics/nullsec-kernspy) | Go | Kernel module analyzer |
| [nullsec-zigscan](https://github.com/bad-antics/nullsec-zigscan) | Zig | Binary entropy analyzer |
| [nullsec-nimhunter](https://github.com/bad-antics/nullsec-nimhunter) | Nim | Memory forensics |
| [nullsec-ocamlparse](https://github.com/bad-antics/nullsec-ocamlparse) | OCaml | Security policy parser |

### Cryptography Tools

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-cryptwrap](https://github.com/bad-antics/nullsec-cryptwrap) | Ada/SPARK | Formally verified crypto |
| [nullsec-hashwitch](https://github.com/bad-antics/nullsec-hashwitch) | Julia | Hash analysis |
| [nullsec-adashield](https://github.com/bad-antics/nullsec-adashield) | Ada | Protocol validator |
| [nullsec-vvault](https://github.com/bad-antics/nullsec-vvault) | V | Credential vault |

### Defense Tools

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-cppsentry](https://github.com/bad-antics/nullsec-cppsentry) | C++ | Packet sentinel |
| [nullsec-swiftsentinel](https://github.com/bad-antics/nullsec-swiftsentinel) | Swift | macOS event monitor |
| [nullsec-kotlinguard](https://github.com/bad-antics/nullsec-kotlinguard) | Kotlin | Container scanner |
| [nullsec-clusterguard](https://github.com/bad-antics/nullsec-clusterguard) | Erlang | Distributed IDS |
| [nullsec-luashield](https://github.com/bad-antics/nullsec-luashield) | Lua | WAF rules engine |

### OSINT & Recon

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-reporaider](https://github.com/bad-antics/nullsec-reporaider) | Clojure | Git secret scanner |
| [nullsec-juliaprobe](https://github.com/bad-antics/nullsec-juliaprobe) | Julia | Anomaly detector |
| [nullsec-perlscrub](https://github.com/bad-antics/nullsec-perlscrub) | Perl | Log sanitizer |
| [nullsec-shelltrace](https://github.com/bad-antics/nullsec-shelltrace) | Tcl | Command auditor |
| [nullsec-fsharpsignal](https://github.com/bad-antics/nullsec-fsharpsignal) | F# | Signal correlator |

### Mobile Security

| Tool | Language | Purpose |
|------|----------|---------|
| [nullkia](https://github.com/bad-antics/nullkia) | Multi | Mobile security framework |
| [nullsec-apkanalyzer](https://github.com/bad-antics/nullsec-apkanalyzer) | Kotlin | APK analysis |
| [nullsec-iosextract](https://github.com/bad-antics/nullsec-iosextract) | Swift | iOS forensics |

### Automation & Scripting

| Tool | Language | Purpose |
|------|----------|---------|
| [nullsec-framework](https://github.com/bad-antics/nullsec-framework) | Python | Unified framework |
| [nullsec-dlangaudit](https://github.com/bad-antics/nullsec-dlangaudit) | D | Security auditor |
| [nullsec-beacon](https://github.com/bad-antics/nullsec-beacon) | Erlang | Network beacon |

---

## 🚀 Quick Start

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 64-bit x86_64 | Multi-core (4+) |
| RAM | 2 GB | 16 GB |
| Storage | 20 GB | 100 GB SSD |
| Graphics | Any | Hardware accel |

### Create Bootable USB

```bash
# Linux/macOS
sudo dd if=nullsec-pro-4.0-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync

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

# Apply security profile
nullsec-harden --profile maximum

# Start anonymity mode
nullsec-anon --tor --mac-spoof
```

---

## 📁 Directory Structure

```
/opt/nullsec/
├── bin/           # 90+ NullSec tools
├── configs/       # Configuration files
├── payloads/      # Payload templates
├── wordlists/     # Curated wordlists
├── scripts/       # Automation scripts
├── modules/       # Framework modules
└── docs/          # Documentation

/etc/nullsec/
├── Security/     # Security profiles
├── firewall/      # nftables rules
├── apparmor/      # AppArmor profiles
├── seccomp/       # Seccomp filters
└── integrity/     # IMA policies
```

---

## 🆕 What's New in v4.0

### New Tools Added
- `nullsec-cppsentry` - C++20 packet sentinel
- `nullsec-fsharpsignal` - F# signal correlator
- `nullsec-adashield` - Ada crypto validator
- `nullsec-crystalrecon` - Crystal network recon
- `nullsec-kotlinguard` - Kotlin container scanner
- `nullsec-swiftsentinel` - Swift macOS monitor
- `nullsec-ocamlparse` - OCaml policy parser
- `nullsec-clusterguard` - Erlang distributed IDS
- `nullsec-reporaider` - Clojure secret scanner
- `nullsec-luashield` - Lua WAF engine
- `nullsec-juliaprobe` - Julia anomaly detector
- `nullsec-perlscrub` - Perl log sanitizer
- `nullsec-vvault` - V credential vault
- `nullsec-nimhunter` - Nim memory forensics
- `nullsec-zigscan` - Zig binary analyzer
- `nullsec-shelltrace` - Tcl command auditor
- `nullsec-flowtrace` - Haskell flow analyzer
- `nullsec-dlangaudit` - D security auditor
- `nullkia` v2.0 - Mobile security framework

### Security Improvements
- LUKS2 with Argon2id
- Landlock LSM support
- CET/Shadow stack
- FORTIFY_SOURCE=3
- Kernel lockdown mode

### New Editions
- Cloud edition (AWS/GCP/Azure)
- Air-gapped edition
- Apple Silicon support

---

## 🔗 Related Projects

| Project | Description |
|---------|-------------|
| [nullsec-framework](https://github.com/bad-antics/nullsec-framework) | Unified toolkit framework |
| [nullsec-payloads](https://github.com/bad-antics/nullsec-payloads) | Payload templates |
| [nullsec-wordlists](https://github.com/bad-antics/nullsec-wordlists) | Curated wordlists |
| [nullsec-configs](https://github.com/bad-antics/nullsec-configs) | Dotfiles & configs |
| [nullkia](https://github.com/bad-antics/nullkia) | Mobile security framework |
| [bad-antics.github.io](https://bad-antics.github.io) | Download portal |

---

## 📜 License

NullSec Public License v1.0 — For authorized security testing and education only.

---

## 🏷️ Keywords

`linux distribution` `security distro` `penetration testing` `ethical hacking` 
`kali alternative` `parrot alternative` `red team` `blue team` `CTF` 
`cybersecurity` `hacking tools` `privacy` `anonymity` `DFIR` `OSINT`
`bad-antics` `nullsec` `security research` `secure linux` `security focused`

---

<div align="center">

**Developed with 💀 by [bad-antics](https://github.com/bad-antics)**

*NullSec Project © 2026 — Hack Ethically*

### 🌐 **[Download Portal: bad-antics.github.io](https://bad-antics.github.io)**

[![GitHub](https://img.shields.io/badge/GitHub-bad--antics-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/bad-antics)
[![Discord](https://img.shields.io/badge/Discord-killers-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/killers)
[![Website](https://img.shields.io/badge/Downloads-bad--antics.github.io-ff0040?style=for-the-badge&logo=firefox&logoColor=white)](https://bad-antics.github.io)

</div>

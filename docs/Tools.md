# 🔧 Pre-installed Tools

Complete list of security tools included in NullSec Linux Standard Edition.

---

## Reconnaissance

### Network Scanning
| Tool | Description |
|------|-------------|
| **Nmap** | Network discovery and security auditing |
| **Masscan** | Fast port scanner |
| **Unicornscan** | Asynchronous port scanner |
| **Zmap** | Internet-wide scanner |
| **RustScan** | Fast Nmap alternative in Rust |

### OSINT
| Tool | Description |
|------|-------------|
| **theHarvester** | Email, subdomain, IP harvesting |
| **Maltego** | Visual link analysis |
| **Recon-ng** | Web reconnaissance framework |
| **Shodan CLI** | Shodan.io command line |
| **SpiderFoot** | OSINT automation |
| **Amass** | Subdomain enumeration |
| **Marshall Browser** | OSINT-focused browser |

### DNS
| Tool | Description |
|------|-------------|
| **dnsenum** | DNS enumeration |
| **dnsrecon** | DNS reconnaissance |
| **Fierce** | DNS reconnaissance |
| **Sublist3r** | Subdomain enumeration |

---

## Web Application Testing

### Scanners
| Tool | Description |
|------|-------------|
| **Burp Suite** | Web vulnerability scanner |
| **OWASP ZAP** | Web app security testing |
| **Nikto** | Web server scanner |
| **WPScan** | WordPress scanner |
| **Nuclei** | Vulnerability scanner |

### Injection
| Tool | Description |
|------|-------------|
| **SQLMap** | SQL injection tool |
| **NoSQLMap** | NoSQL injection |
| **XSSer** | XSS exploitation |
| **Commix** | Command injection |

### Fuzzing
| Tool | Description |
|------|-------------|
| **ffuf** | Fast web fuzzer |
| **Gobuster** | Directory/DNS brute-forcer |
| **Dirbuster** | Directory brute force |
| **wfuzz** | Web fuzzer |

### Proxies
| Tool | Description |
|------|-------------|
| **mitmproxy** | Interactive HTTPS proxy |
| **Fiddler** | Web debugging proxy |

---

## Exploitation

### Frameworks
| Tool | Description |
|------|-------------|
| **Metasploit** | Exploitation framework |
| **Cobalt Strike** | Red team ops (license required) |
| **BeEF** | Browser exploitation |
| **RouterSploit** | Router exploitation |

### Post-Exploitation
| Tool | Description |
|------|-------------|
| **Mimikatz** | Windows credential extraction |
| **BloodHound** | Active Directory analysis |
| **PowerSploit** | PowerShell exploitation |
| **Empire** | Post-exploitation agent |

### Exploits
| Tool | Description |
|------|-------------|
| **SearchSploit** | Exploit-DB search |
| **PoC-in-GitHub** | GitHub exploit finder |

---

## Password Attacks

### Cracking
| Tool | Description |
|------|-------------|
| **John the Ripper** | Password cracker |
| **Hashcat** | GPU hash cracker |
| **Ophcrack** | Windows password cracker |
| **NullSec HashCrack** | Multi-algorithm cracker |

### Brute Force
| Tool | Description |
|------|-------------|
| **Hydra** | Network login cracker |
| **Medusa** | Parallel password cracker |
| **Ncrack** | Network auth cracker |
| **Patator** | Multi-service brute-forcer |

### Analysis
| Tool | Description |
|------|-------------|
| **hash-identifier** | Hash type identifier |
| **NullSec HashWitch** | Hash identification |
| **CeWL** | Custom wordlist generator |

---

## Wireless

### WiFi
| Tool | Description |
|------|-------------|
| **Aircrack-ng** | WiFi security suite |
| **Wifite** | Automated WiFi attacks |
| **Kismet** | Wireless detector |
| **Fern WiFi Cracker** | GUI WiFi cracker |
| **WiFi-Pumpkin** | Rogue AP framework |

### Bluetooth
| Tool | Description |
|------|-------------|
| **BlueZ** | Bluetooth stack |
| **Ubertooth** | Bluetooth sniffer tools |
| **BTScanner** | Bluetooth scanner |

---

## Forensics

### Disk Forensics
| Tool | Description |
|------|-------------|
| **Autopsy** | Digital forensics platform |
| **Sleuth Kit** | Disk analysis tools |
| **dd** | Disk imaging |
| **dcfldd** | Enhanced dd |
| **Guymager** | Forensic imager |

### Memory Forensics
| Tool | Description |
|------|-------------|
| **Volatility** | Memory analysis |
| **Rekall** | Memory forensics |
| **LiME** | Linux memory extractor |

### Network Forensics
| Tool | Description |
|------|-------------|
| **Wireshark** | Packet analyzer |
| **tcpdump** | CLI packet capture |
| **NetworkMiner** | Network forensics |
| **Zeek** | Network analysis framework |

---

## Reverse Engineering

### Disassemblers
| Tool | Description |
|------|-------------|
| **Ghidra** | NSA reverse engineering |
| **Radare2** | RE framework |
| **Cutter** | Radare2 GUI |
| **Binary Ninja** | RE platform (license) |

### Debuggers
| Tool | Description |
|------|-------------|
| **GDB** | GNU Debugger |
| **pwndbg** | GDB enhancement |
| **x64dbg** | Windows debugger |
| **OllyDbg** | Windows debugger |

### Analysis
| Tool | Description |
|------|-------------|
| **Binwalk** | Firmware analysis |
| **strings** | Extract strings |
| **objdump** | Object file dump |
| **strace/ltrace** | System call tracers |

---

## Social Engineering

| Tool | Description |
|------|-------------|
| **SET** | Social Engineering Toolkit |
| **Gophish** | Phishing framework |
| **King Phisher** | Phishing campaigns |
| **evilginx2** | MitM attack framework |

---

## Reporting

| Tool | Description |
|------|-------------|
| **Dradis** | Collaboration platform |
| **Faraday** | IPE environment |
| **CherryTree** | Note-taking |
| **Obsidian** | Knowledge base |

---

## NullSec Suite

All [NullSec Tools](https://github.com/bad-antics/nullsec-tools) are pre-installed:

| Tool | Language | Description |
|------|----------|-------------|
| `email_hunter` | Python | Email enumeration |
| `portscan` | Python/Go | Port scanner |
| `hashcrack` | Python | Hash cracker |
| `sniffer` | Python | Packet capture |
| `crawler` | Python | Web crawler |
| `hashwitch` | Rust | Hash identifier |
| `memgrep` | Rust | Memory search |
| And 30+ more... | | |

---

## Wordlists

Pre-installed wordlists in `/usr/share/wordlists/`:

| Wordlist | Size | Purpose |
|----------|------|---------|
| **rockyou.txt** | 14M | Common passwords |
| **SecLists** | 500M+ | All-purpose collection |
| **dirb** | 5M | Directory brute-force |
| **dirbuster** | 10M | Directory lists |
| **fuzzdb** | 50M | Fuzzing payloads |
| **NullSec Wordlists** | 100M+ | Custom collections |

---

## Tool Management

### Install Additional Tools
```bash
# Search for tools
apt search <tool-name>

# Install from NullSec repo
sudo apt install nullsec-<tool>

# Install from pip
pip install <tool>

# Install from source
git clone <repo>
cd <repo> && make install
```

### Update Tools
```bash
# Update all packages
sudo apt update && sudo apt upgrade

# Update specific tool
sudo apt install --only-upgrade <tool>

# Update Metasploit
msfupdate
```

### Tool Locations
| Type | Location |
|------|----------|
| System tools | `/usr/bin/`, `/usr/sbin/` |
| NullSec tools | `/opt/nullsec/` |
| Wordlists | `/usr/share/wordlists/` |
| Exploits | `/usr/share/exploitdb/` |

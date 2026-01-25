# 📦 NullSec Linux Editions

NullSec Linux is available in multiple editions, each tailored for specific security testing scenarios.

---

## Standard Edition

**Target Audience:** General penetration testers, security researchers

### Features
- 135+ pre-installed security tools
- Full desktop environment (XFCE)
- NullSec Tools suite
- Marshall Browser
- Common wordlists

### Included Tool Categories
- Web application testing
- Network scanning
- Password attacks
- Exploitation frameworks
- Forensics tools
- Reverse engineering
- Wireless testing
- OSINT tools

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 4GB | 8GB+ |
| Disk | 25GB | 50GB+ |
| CPU | 2 cores | 4+ cores |

---

## Lite Edition

**Target Audience:** Low-resource systems, Raspberry Pi, older hardware

### Features
- Core security tools only (~50 tools)
- Lightweight XFCE desktop
- Optimized for 2GB RAM systems
- Smaller ISO size (~2GB)

### Included Tools
- Nmap, Masscan
- SQLMap, Nikto
- John the Ripper
- Aircrack-ng
- Netcat, Socat
- Basic NullSec Tools

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 2GB | 4GB |
| Disk | 15GB | 25GB |
| CPU | 1 core | 2+ cores |

### Supported Platforms
- x86_64
- Raspberry Pi 4/5 (ARM64)
- Virtual machines with limited resources

---

## Cloud Edition

**Target Audience:** Cloud security testers, DevSecOps

### Features
- Cloud provider CLI tools pre-installed
- Kubernetes security tools
- Container security tools
- Terraform security scanners
- Serverless testing tools

### Included Cloud Tools
| Provider | Tools |
|----------|-------|
| **AWS** | aws-cli, Pacu, Prowler, ScoutSuite |
| **Azure** | az-cli, AzureHound, MicroBurst |
| **GCP** | gcloud, GCPBucketBrute |
| **General** | CloudSploit, cloud-enum |

### Kubernetes Tools
- kubectl, kube-hunter
- kubesec, trivy
- kube-bench, falco
- kube-score

### Container Tools
- Docker, Podman
- Dive (image analyzer)
- Clair, Anchore
- Container escape tools

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 4GB | 8GB+ |
| Disk | 30GB | 50GB+ |
| CPU | 2 cores | 4+ cores |
| Network | Fast internet | Fast internet |

---

## Automotive Edition

**Target Audience:** Automotive security researchers, vehicle pentesters

### Features
- CAN bus tools
- ECU testing tools
- OBD-II interfaces
- Vehicle protocol analyzers
- Diagnostic tools

### Included Automotive Tools
| Category | Tools |
|----------|-------|
| **CAN Bus** | can-utils, SavvyCAN, CANalyzer |
| **Diagnostics** | OBD-II readers, UDS tools |
| **ECU** | BlackFlag ECU, OpenGarage |
| **Analysis** | Kayak, ICSim, Caringorm |
| **Hardware** | ChipWhisperer support, J2534 |

### Hardware Support
- SocketCAN interfaces
- Peak CAN adapters
- Vector CAN interfaces
- ELM327 OBD-II adapters
- Macchina M2

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 4GB | 8GB+ |
| Disk | 25GB | 50GB+ |
| USB | 2.0+ | 3.0+ |
| CAN | Optional | Required for full testing |

---

## AI/ML Security Edition

**Target Audience:** AI/ML security researchers, adversarial ML testers

### Features
- Adversarial machine learning tools
- Model extraction tools
- Data poisoning frameworks
- ML pipeline security testing
- LLM security tools

### Included AI/ML Tools
| Category | Tools |
|----------|-------|
| **Adversarial** | CleverHans, ART, Foolbox |
| **Evasion** | TextFooler, DeepXplore |
| **Extraction** | ModelLeaks, PRADA |
| **Poisoning** | BadNets, TrojanNN |
| **LLM** | Prompt injection tools |

### ML Frameworks
- PyTorch, TensorFlow
- scikit-learn
- Hugging Face
- ONNX Runtime

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 8GB | 16GB+ |
| Disk | 50GB | 100GB+ |
| CPU | 4 cores | 8+ cores |
| GPU | Optional | NVIDIA CUDA recommended |

---

## Hardware Hacking Edition

**Target Audience:** Hardware security researchers, IoT pentesters

### Features
- SDR tools for radio analysis
- JTAG/SWD debugging tools
- UART/SPI/I2C tools
- RFID/NFC tools
- Firmware analysis

### Included Hardware Tools
| Category | Tools |
|----------|-------|
| **SDR** | GNU Radio, GQRX, SDR#, rtl-sdr |
| **JTAG** | OpenOCD, JTAGulator |
| **RFID** | Proxmark3, MFCUK |
| **Firmware** | Binwalk, firmware-mod-kit |
| **Logic** | sigrok, PulseView |
| **RF** | HackRF, YARD Stick One tools |

### Hardware Support
- RTL-SDR dongles
- HackRF One
- Proxmark3
- Bus Pirate
- Shikra
- Flipper Zero
- Logic analyzers

### System Requirements
| Spec | Minimum | Recommended |
|------|---------|-------------|
| RAM | 4GB | 8GB+ |
| Disk | 30GB | 50GB+ |
| USB | 2.0+ | 3.0+ (required for SDR) |
| CPU | 2 cores | 4+ cores |

---

## Edition Comparison

| Feature | Standard | Lite | Cloud | Auto | AI/ML | Hardware |
|---------|----------|------|-------|------|-------|----------|
| Tools Count | 135+ | ~50 | 80+ | 60+ | 50+ | 70+ |
| ISO Size | 4GB | 2GB | 3.5GB | 3GB | 5GB | 3.5GB |
| Min RAM | 4GB | 2GB | 4GB | 4GB | 8GB | 4GB |
| GPU Support | Optional | No | Optional | No | CUDA | No |
| Desktop | XFCE | XFCE | XFCE | XFCE | XFCE | XFCE |
| ARM64 | Planned | ✅ | Planned | ✅ | No | ✅ |

---

## Download Links

| Edition | Download | Torrent |
|---------|----------|---------|
| Standard | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |
| Lite | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |
| Cloud | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |
| Automotive | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |
| AI/ML | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |
| Hardware | [ISO](https://github.com/bad-antics/nullsec-linux/releases) | [Torrent](#) |

---

## Custom Edition Builder

Build your own custom NullSec Linux edition:

```bash
git clone https://github.com/bad-antics/nullsec-linux.git
cd nullsec-linux/builder

# Edit tool selection
nano configs/my-edition.yaml

# Build ISO
./build.sh --config configs/my-edition.yaml --output my-nullsec.iso
```

See [Building](Building.md) for detailed build instructions.

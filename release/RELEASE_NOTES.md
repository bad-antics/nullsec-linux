# NullSec Linux 5.0.0 "Phantom" Release Notes

## Highlights

- **135+ Security Tools** across 13 categories
- **9 Specialized Editions** for different use cases
- **4 Architecture Support** (AMD64, ARM64, RISC-V, Apple Silicon)
- **Debian 13 Base** with Kernel 6.8 LTS

## New Features

### Cloud Security Edition
- AWS reconnaissance and auditing tools
- Kubernetes security scanner
- GCP and Azure security tools
- Terraform IaC scanner

### AI/ML Security Edition  
- LLM red teaming toolkit
- Prompt injection scanner
- Model auditing tools
- Adversarial example generator

### Hardware Hacking Edition
- SDR analysis suite
- RFID/NFC exploitation
- JTAG debugging tools
- Voltage glitching framework

### Automotive Security Edition
- CAN bus analyzer
- OBD-II diagnostic tools
- UDS protocol tester
- Key fob analysis

## Upgrade Instructions

```bash
sudo nullsec-upgrade --to 5.0.0
```

## Known Issues

- RISC-V support is experimental
- Some tools may require additional setup on ARM64

## Checksums

See SHA256SUMS and MD5SUMS files for verification.

## Support

- GitHub: https://github.com/bad-antics/nullsec-linux/issues
- Wiki: https://github.com/bad-antics/nullsec-wiki

# Development

## Building NullSec Linux

### Prerequisites
```bash
sudo apt install live-build debootstrap squashfs-tools
```

### Build from Source
```bash
git clone https://github.com/bad-antics/nullsec-linux
cd nullsec-linux
sudo ./build.sh --edition hacker --arch amd64
```

### Build Options
```bash
# Build specific edition
sudo ./build.sh --edition forensics
sudo ./build.sh --edition minimal
sudo ./build.sh --edition server

# Build with custom packages
sudo ./build.sh --edition hacker --extra-packages ./my-packages.list

# Build ISO only (no installer)
sudo ./build.sh --iso-only
```

## Package Management

### Adding Tools
```bash
# Add to the tool list
echo "my-tool" >> config/packages/tools.list

# Rebuild
sudo ./build.sh --edition hacker
```

### Custom Repositories
```bash
# Add custom apt repo
echo "deb https://my-repo.example.com stable main" >> config/apt/sources.list
```

## Testing

```bash
# Test in QEMU
qemu-system-x86_64 -cdrom output/nullsec-linux-hacker-amd64.iso -m 4096

# Test in VirtualBox
VBoxManage createvm --name "NullSec-Test" --ostype Ubuntu_64
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

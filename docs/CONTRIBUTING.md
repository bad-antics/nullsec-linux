# Contributing to NullSec Linux

Thank you for your interest in contributing to NullSec Linux! This document provides guidelines for contributing to the project.

## Ways to Contribute

### 1. Report Bugs
- Use the [GitHub Issues](https://github.com/bad-antics/nullsec-linux/issues) tracker
- Include detailed reproduction steps
- Provide system information and logs

### 2. Request Features
- Open a feature request issue
- Describe the use case and expected behavior
- Discuss implementation approaches

### 3. Submit Pull Requests
- Fork the repository
- Create a feature branch
- Submit a PR with clear description

### 4. Improve Documentation
- Fix typos and errors
- Add examples and tutorials
- Translate documentation

### 5. Package New Tools
- Propose new security tools
- Create package definitions
- Test integration

## Development Setup

### Prerequisites

```bash
# Install build dependencies
sudo apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin
```

### Building

```bash
# Clone the repository
git clone https://github.com/bad-antics/nullsec-linux.git
cd nullsec-linux

# Build standard edition
sudo ./build/build-iso.sh standard amd64

# Build specific edition
sudo ./build/build-iso.sh cloud amd64
```

### Testing

```bash
# Test in QEMU
qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -cdrom output/nullsec-standard-5.0.0-amd64-*.iso
```

## Code Style

### Shell Scripts
- Use `shellcheck` for linting
- Follow Google Shell Style Guide
- Add comments for complex logic

### Python
- Follow PEP 8
- Use type hints
- Document with docstrings

### Documentation
- Use Markdown format
- Include code examples
- Keep language clear and concise

## Pull Request Process

1. **Fork & Clone**: Fork the repo and clone locally
2. **Branch**: Create a feature branch (`git checkout -b feature/my-feature`)
3. **Develop**: Make your changes
4. **Test**: Test your changes thoroughly
5. **Commit**: Use clear commit messages
6. **Push**: Push to your fork
7. **PR**: Open a Pull Request

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

Example:
```
feat(tools): add nuclei vulnerability scanner

- Added nuclei to security package list
- Updated documentation
- Added example configurations

Closes #123
```

## Adding New Tools

### Package List

Add to appropriate package list in `config/package-lists/`:

```bash
# config/package-lists/security.list.chroot
new-tool-name
```

### Custom Installation

For tools not in Debian repos, add to hooks:

```bash
# config/hooks/live/0100-nullsec-setup.hook.chroot

# Install custom tool
cd /opt/nullsec/tools
git clone https://github.com/example/tool.git
cd tool && make install
```

### Documentation

Update tool documentation:
- Add to README.md tool list
- Create wiki page if significant
- Add usage examples

## Security Policy

### Reporting Vulnerabilities

For security issues, please email directly or use GitHub Security Advisories. Do not open public issues for vulnerabilities.

### Responsible Disclosure

- Allow 90 days for fixes before public disclosure
- Provide detailed reproduction steps
- Coordinate disclosure timing

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Community

- **GitHub Discussions**: For questions and ideas
- **Issues**: For bugs and features

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to NullSec Linux!

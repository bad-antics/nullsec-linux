# 🐧 NullSec Linux — Custom Kernel

## Overview

NullSec Linux ships with a **custom-built kernel** compiled from upstream kernel.org sources with all upstream distro branding removed and replaced with NullSec identity. This is not a patched derivative — it's a clean rebuild with NullSec-specific build identity.

**Current Version:** `6.17.13+2-amd64`
**Base Source:** [kernel.org v6.17.13](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.13.tar.xz)
**Architecture:** `x86_64 (amd64)`

## What Makes It "NullSec"

The kernel is rebuilt from vanilla source with the following customizations:

| Component | Value |
|:----------|:------|
| `uname -r` | `6.17.13+2-amd64` |
| `EXTRAVERSION` | *(cleared — no upstream distro tag)* |
| `CONFIG_LOCALVERSION` | `+2-amd64` |
| `KBUILD_BUILD_USER` | `nullsec` |
| `KBUILD_BUILD_HOST` | `nullsec.sh` |
| `KBUILD_BUILD_TIMESTAMP` | `NullSec 6.17.13-1nullsec1 (2026-02-12)` |
| `KDEB_PKGVERSION` | `6.17.13-1` |
| `/proc/version` | `Linux version 6.17.13+2-amd64 (nullsec@nullsec.sh) #1 SMP PREEMPT_DYNAMIC NullSec 6.17.13-1nullsec1 ...` |

**No Parrot, Debian, or Ubuntu strings appear anywhere in the running kernel.**

## Packages

The kernel build produces these `.deb` packages:

| Package | Size | Purpose |
|:--------|:-----|:--------|
| `linux-image-6.17.13+2-amd64_6.17.13-1_amd64.deb` | ~164 MB | Kernel image, modules, initramfs |
| `linux-headers-6.17.13+2-amd64_6.17.13-1_amd64.deb` | ~9.2 MB | Headers for DKMS/module builds |
| `linux-libc-dev_6.17.13-1_amd64.deb` | ~1.4 MB | Userspace development headers |

Download from [Releases](https://github.com/bad-antics/nullsec-linux/releases).

## Install

```bash
# Download packages from the latest release, then:
sudo dpkg -i linux-image-6.17.13+2-amd64_6.17.13-1_amd64.deb
sudo dpkg -i linux-headers-6.17.13+2-amd64_6.17.13-1_amd64.deb
sudo update-grub
sudo reboot
```

After reboot, verify:

```bash
uname -r
# Expected: 6.17.13+2-amd64

uname -a
# Expected: Linux <hostname> 6.17.13+2-amd64 #1 SMP PREEMPT_DYNAMIC NullSec 6.17.13-1nullsec1 ...

cat /proc/version
# Should contain "nullsec@nullsec.sh" — no Parrot/Debian references
```

## Build from Source

To rebuild the kernel yourself:

```bash
# Install dependencies
sudo apt-get install -y build-essential flex bison bc dwarves \
    libssl-dev libncurses-dev libelf-dev cpio

# Run the build script
cd kernel/
chmod +x build-kernel.sh
./build-kernel.sh all

# Packages will be in kernel-build/
ls -lh kernel-build/*.deb
```

The build takes approximately 15–45 minutes depending on your hardware. The script:

1. Downloads the kernel source from kernel.org
2. Applies your running kernel's `.config`
3. Removes all upstream distro branding
4. Sets NullSec build identity strings
5. Compiles with `make bindeb-pkg`
6. Outputs `.deb` packages ready for install

### Build Options

```bash
./build-kernel.sh deps      # Install dependencies only
./build-kernel.sh download  # Download kernel source only
./build-kernel.sh config    # Download + apply config
./build-kernel.sh rebrand   # Apply NullSec branding (source must exist)
./build-kernel.sh build     # Rebrand + compile
./build-kernel.sh all       # Full pipeline (default)
```

## Kernel Config

The kernel config used for the build is in `configs/config-6.17.13-nullsec`. Key settings:

- **Preemption:** `PREEMPT_DYNAMIC` (balanced latency)
- **Security:** SELinux, AppArmor, YAMA LSM enabled
- **Networking:** Full netfilter/iptables/nftables stack
- **Filesystems:** ext4, btrfs, xfs, ntfs3, squashfs, overlayfs
- **Virtualization:** KVM, VirtIO drivers
- **Hardware:** Broad hardware support (same as base distro)
- **DKMS:** Headers package supports out-of-tree module compilation

## Verify Integrity

```bash
# After downloading .deb packages, verify checksums:
sha256sum -c SHA256SUMS
```

## Directory Structure

```
kernel/
├── build-kernel.sh              # Main build script
├── test-kernel-vm.sh            # VM testing script
├── configs/
│   └── config-6.17.13-nullsec   # Kernel .config
├── patches/                     # Custom patches (if any)
├── SHA256SUMS                   # Package checksums
└── README.md                    # This file
```

## License

The Linux kernel is licensed under [GPL-2.0](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).
NullSec build scripts are licensed under MIT.

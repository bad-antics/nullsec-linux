# 📦 Installation Guide

## Download

Download the latest NullSec Linux ISO from:
- [GitHub Releases](https://github.com/bad-antics/nullsec-linux/releases)
- [SourceForge Mirror](https://sourceforge.net/projects/nullsec-linux/)

### Verify Download

```bash
# Verify SHA256 checksum
sha256sum -c nullsec-linux-2.0-amd64.iso.sha256

# Verify GPG signature
gpg --verify nullsec-linux-2.0-amd64.iso.sig nullsec-linux-2.0-amd64.iso
```

---

## Installation Methods

### 1. Bootable USB (Recommended)

#### Using dd (Linux/macOS)
```bash
# Find your USB device
lsblk
# or on macOS
diskutil list

# Write ISO to USB (replace sdX with your device)
sudo dd if=nullsec-linux-2.0-amd64.iso of=/dev/sdX bs=4M status=progress
sync
```

#### Using Rufus (Windows)
1. Download [Rufus](https://rufus.ie/)
2. Select your USB drive
3. Select the NullSec Linux ISO
4. Click "Start"

#### Using Ventoy
1. Install [Ventoy](https://ventoy.net/) on USB drive
2. Copy ISO file to Ventoy USB
3. Boot and select NullSec Linux

---

### 2. Virtual Machine

#### VMware
1. Create new VM → Linux → Debian 12 (64-bit)
2. Assign 4GB+ RAM, 2+ CPU cores
3. Create 50GB virtual disk
4. Mount ISO and boot

#### VirtualBox
1. New → Name: NullSec Linux → Type: Linux → Debian (64-bit)
2. Memory: 4096MB
3. Hard disk: Create VDI, 50GB
4. Settings → Storage → Mount ISO
5. Settings → System → Enable EFI (optional)
6. Start

#### QEMU/KVM
```bash
# Create disk image
qemu-img create -f qcow2 nullsec.qcow2 50G

# Boot installation
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -cpu host \
  -smp 4 \
  -cdrom nullsec-linux-2.0-amd64.iso \
  -drive file=nullsec.qcow2,format=qcow2 \
  -boot d
```

#### Proxmox
1. Upload ISO to Proxmox storage
2. Create VM → OS: Linux 6.x
3. CPU: 2+ cores, RAM: 4GB+
4. Disk: 50GB
5. Mount ISO and start

---

### 3. WSL2 (Windows)

```powershell
# Enable WSL2
wsl --install

# Import NullSec Linux rootfs
wsl --import NullSec C:\WSL\NullSec nullsec-linux-rootfs.tar.gz

# Start
wsl -d NullSec
```

---

### 4. Docker

```bash
# Pull image
docker pull ghcr.io/bad-antics/nullsec-linux:latest

# Run interactive shell
docker run -it --rm \
  --name nullsec \
  --privileged \
  --net=host \
  ghcr.io/bad-antics/nullsec-linux

# Run with persistent storage
docker run -it \
  -v nullsec-data:/home/nullsec \
  ghcr.io/bad-antics/nullsec-linux
```

---

## Installation Walkthrough

### Boot Menu Options

| Option | Description |
|--------|-------------|
| **Live (amd64)** | Boot live system without installing |
| **Live (amd64 failsafe)** | Boot with safe graphics |
| **Install** | Graphical installer |
| **Install (Expert)** | Expert installation mode |
| **Forensics Mode** | Live mode without auto-mounting drives |

### Graphical Installer Steps

1. **Language** - Select your language
2. **Location** - Select timezone
3. **Keyboard** - Configure keyboard layout
4. **Network** - Configure network (or skip for later)
5. **Users** - Create user account
6. **Partitioning** - Choose disk layout:
   - Guided - Use entire disk
   - Guided - Use entire disk with LVM
   - Guided - Use entire disk with encrypted LVM (Recommended)
   - Manual - Custom partitioning
7. **Install** - Wait for installation
8. **Bootloader** - Install GRUB
9. **Reboot** - Remove USB and reboot

### Recommended Partition Layout

| Partition | Size | Type | Mount |
|-----------|------|------|-------|
| EFI | 512MB | FAT32 | /boot/efi |
| Boot | 1GB | ext4 | /boot |
| Root | 30GB+ | ext4/btrfs | / |
| Swap | 2x RAM | swap | - |
| Home | Remaining | ext4/btrfs | /home |

---

## Post-Installation

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Change Default Passwords
```bash
# Change user password
passwd

# Change root password
sudo passwd root
```

### Configure Network
```bash
# Using NetworkManager
nmtui

# Or nmcli
nmcli device wifi connect "SSID" password "password"
```

### Install Additional Tools
```bash
# Install all NullSec tools
sudo apt install nullsec-tools-full

# Or specific categories
sudo apt install nullsec-tools-web
sudo apt install nullsec-tools-wireless
sudo apt install nullsec-tools-forensics
```

### Configure VPN
```bash
# OpenVPN
sudo apt install openvpn
sudo openvpn --config your-config.ovpn

# WireGuard
sudo apt install wireguard
sudo wg-quick up wg0
```

---

## Troubleshooting

### Boot Issues

**Black screen after boot:**
- Try "failsafe" boot option
- Add `nomodeset` to kernel parameters
- Check GPU compatibility

**UEFI boot not working:**
- Disable Secure Boot in BIOS
- Enable CSM/Legacy boot

### Graphics Issues

**Wrong resolution:**
```bash
# List available resolutions
xrandr

# Set resolution
xrandr --output HDMI-1 --mode 1920x1080
```

**NVIDIA driver issues:**
```bash
# Install NVIDIA drivers
sudo apt install nvidia-driver
sudo reboot
```

### Network Issues

**WiFi not detected:**
```bash
# Check wireless interfaces
iwconfig

# Check for blocked devices
rfkill list
rfkill unblock wifi
```

**No internet:**
```bash
# Check connectivity
ping -c 4 8.8.8.8
ping -c 4 google.com

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

---

## Dual Boot Setup

### With Windows

1. Shrink Windows partition (from Windows Disk Management)
2. Boot NullSec Linux installer
3. Choose "Install alongside Windows"
4. Select free space for installation
5. GRUB will detect Windows automatically

### With Other Linux

1. Create partition for NullSec Linux
2. Install to the new partition
3. Let GRUB detect other systems
4. Or manually add to `/etc/grub.d/40_custom`

---

## Unattended Installation

Create preseed file for automated installations:

```bash
# Use preseed file
preseed/url=http://yourserver/preseed.cfg
```

See [Debian Preseed Documentation](https://wiki.debian.org/DebianInstaller/Preseed) for details.

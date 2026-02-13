#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# NullSec Linux — Kernel VM Test Script
# Boots the rebuilt kernel in QEMU and verifies branding is correct
# ═══════════════════════════════════════════════════════════════════
set -e

KERNEL_VERSION="6.17.13"
LOCALVERSION="+2-amd64"
FULL_VERSION="${KERNEL_VERSION}${LOCALVERSION}"
BUILD_DIR="/home/antics/projects/nullsec-linux/kernel-build"
VM_DIR="/home/antics/projects/nullsec-linux/vm-test"
VM_DISK="${VM_DIR}/nullsec-test.qcow2"
VM_RAM="4G"
VM_CPUS="4"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[*]${NC} $1"; }
warn()    { echo -e "${YELLOW}[~]${NC} $1"; }
error()   { echo -e "${RED}[!]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }

# ── Locate the built kernel artifacts ──
find_kernel_debs() {
    info "Looking for kernel .deb packages in ${BUILD_DIR}..."
    KERNEL_DEB=$(ls "${BUILD_DIR}"/linux-image-${FULL_VERSION}*.deb 2>/dev/null | head -1)
    if [[ -z "$KERNEL_DEB" ]]; then
        # Try without localversion in filename
        KERNEL_DEB=$(ls "${BUILD_DIR}"/linux-image-*.deb 2>/dev/null | grep -v dbg | head -1)
    fi
    if [[ -z "$KERNEL_DEB" ]]; then
        error "No kernel .deb found in ${BUILD_DIR}"
        error "Run build-kernel.sh first"
        exit 1
    fi
    success "Found: $(basename "$KERNEL_DEB")"
}

# ── Create a minimal rootfs for VM testing ──
create_test_rootfs() {
    info "Creating minimal test VM rootfs..."
    mkdir -p "${VM_DIR}/rootfs"

    if [[ -f "${VM_DISK}" ]]; then
        warn "VM disk already exists: ${VM_DISK}"
        read -rp "Rebuild? [y/N]: " REBUILD
        [[ "$REBUILD" =~ ^[yY]$ ]] || return 0
    fi

    # Create a small disk image with debootstrap minimal rootfs
    info "Creating 2GB disk image..."
    qemu-img create -f qcow2 "${VM_DISK}" 2G

    # Build rootfs directory with debootstrap
    local ROOTFS="${VM_DIR}/rootfs"
    rm -rf "${ROOTFS}"
    mkdir -p "${ROOTFS}"

    info "Bootstrapping minimal Debian rootfs (this takes a few minutes)..."
    sudo debootstrap --variant=minbase bookworm "${ROOTFS}" http://deb.debian.org/debian

    # Install the NullSec kernel into the rootfs
    info "Installing NullSec kernel into rootfs..."
    sudo cp "${KERNEL_DEB}" "${ROOTFS}/tmp/"
    sudo chroot "${ROOTFS}" dpkg -i /tmp/$(basename "${KERNEL_DEB}") 2>/dev/null || true
    sudo rm -f "${ROOTFS}/tmp/"*.deb

    # Copy NullSec os-release into the rootfs
    sudo tee "${ROOTFS}/etc/os-release" > /dev/null << 'EOF'
PRETTY_NAME="NullSec Linux 1.0 (void)"
NAME="NullSec Linux"
VERSION_ID="1.0"
VERSION="1.0 (void)"
VERSION_CODENAME=void
ID=nullsec
ID_LIKE="parrot debian"
HOME_URL="https://github.com/bad-antics"
SUPPORT_URL="https://github.com/bad-antics/nullsec-linux/issues"
BUG_REPORT_URL="https://github.com/bad-antics/nullsec-linux/issues"
EOF

    sudo tee "${ROOTFS}/etc/lsb-release" > /dev/null << 'EOF'
DISTRIB_ID=NullSec
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=void
DISTRIB_DESCRIPTION="NullSec Linux 1.0"
EOF

    sudo tee "${ROOTFS}/etc/hostname" > /dev/null <<< "nullsec-vm"

    # Set root password to "nullsec"
    sudo chroot "${ROOTFS}" bash -c 'echo "root:nullsec" | chpasswd'

    # Enable serial console for QEMU
    sudo chroot "${ROOTFS}" systemctl enable serial-getty@ttyS0.service 2>/dev/null || true
    sudo mkdir -p "${ROOTFS}/etc/systemd/system/getty@ttyS0.service.d"
    sudo tee "${ROOTFS}/etc/systemd/system/getty@ttyS0.service.d/autologin.conf" > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOF

    # Create a verification script that runs on first boot
    sudo tee "${ROOTFS}/root/verify-kernel.sh" > /dev/null << 'VERIFY'
#!/bin/bash
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       NullSec Linux — Kernel Verification                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "=== uname -a ==="
uname -a
echo ""
echo "=== uname -r ==="
uname -r
echo ""
echo "=== /proc/version ==="
cat /proc/version
echo ""
echo "=== /etc/os-release ==="
cat /etc/os-release
echo ""

# Check for Parrot references
if uname -a | grep -qi parrot; then
    echo "[FAIL] ❌ Parrot reference STILL PRESENT in uname!"
    echo "       The kernel was not properly rebranded."
else
    echo "[PASS] ✅ No Parrot references in uname — NullSec kernel verified!"
fi

if cat /proc/version | grep -qi parrot; then
    echo "[FAIL] ❌ Parrot reference in /proc/version!"
else
    echo "[PASS] ✅ /proc/version is clean"
fi

echo ""
echo "=== VERIFICATION COMPLETE ==="
echo "Press Ctrl+A then X to exit QEMU"
echo ""
VERIFY
    sudo chmod +x "${ROOTFS}/root/verify-kernel.sh"

    # Auto-run verification on login
    sudo tee -a "${ROOTFS}/root/.bashrc" > /dev/null << 'EOF'
# Auto-run kernel verification
if [ -f /root/verify-kernel.sh ]; then
    bash /root/verify-kernel.sh
fi
EOF

    # Convert rootfs to qcow2 disk image
    info "Converting rootfs to disk image..."
    local RAW_DISK="${VM_DIR}/nullsec-test.raw"
    dd if=/dev/zero of="${RAW_DISK}" bs=1M count=2048 2>/dev/null
    mkfs.ext4 -F -q "${RAW_DISK}"

    local MNT="${VM_DIR}/mnt"
    mkdir -p "${MNT}"
    sudo mount -o loop "${RAW_DISK}" "${MNT}"
    sudo cp -a "${ROOTFS}/." "${MNT}/"
    sudo umount "${MNT}"

    qemu-img convert -f raw -O qcow2 "${RAW_DISK}" "${VM_DISK}"
    rm -f "${RAW_DISK}"
    rm -rf "${MNT}"

    success "VM disk ready: ${VM_DISK}"
}

# ── Extract kernel & initrd for direct boot ──
extract_boot_files() {
    info "Extracting kernel and initrd from .deb..."

    local EXTRACT_DIR="${VM_DIR}/deb-extract"
    rm -rf "${EXTRACT_DIR}"
    mkdir -p "${EXTRACT_DIR}"
    dpkg-deb -x "${KERNEL_DEB}" "${EXTRACT_DIR}"

    # Find the vmlinuz
    VM_KERNEL=$(find "${EXTRACT_DIR}/boot" -name "vmlinuz-*" | head -1)
    if [[ -z "$VM_KERNEL" ]]; then
        error "No vmlinuz found in kernel .deb"
        exit 1
    fi
    cp "${VM_KERNEL}" "${VM_DIR}/vmlinuz"
    success "Kernel: ${VM_DIR}/vmlinuz"

    # Generate initrd from the rootfs if it exists, or create a minimal one
    if [[ -d "${VM_DIR}/rootfs/lib/modules" ]]; then
        info "Generating initramfs..."
        local KVER
        KVER=$(basename "${VM_KERNEL}" | sed 's/vmlinuz-//')
        sudo chroot "${VM_DIR}/rootfs" update-initramfs -c -k "${KVER}" 2>/dev/null || true
        local INITRD=$(find "${VM_DIR}/rootfs/boot" -name "initrd.img-*" | head -1)
        if [[ -n "$INITRD" ]]; then
            cp "${INITRD}" "${VM_DIR}/initrd.img"
            success "Initrd: ${VM_DIR}/initrd.img"
        fi
    fi
}

# ── Boot the VM ──
boot_vm() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Booting NullSec kernel in QEMU                          ${NC}"
    echo -e "${CYAN}  RAM: ${VM_RAM}  CPUs: ${VM_CPUS}                        ${NC}"
    echo -e "${CYAN}  Login: root / nullsec                                   ${NC}"
    echo -e "${CYAN}  Exit:  Ctrl+A then X                                    ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    local QEMU_ARGS=(
        -m "${VM_RAM}"
        -smp "${VM_CPUS}"
        -enable-kvm
        -nographic
        -no-reboot
    )

    if [[ -f "${VM_DIR}/vmlinuz" ]]; then
        # Direct kernel boot (faster, no bootloader needed)
        QEMU_ARGS+=(
            -kernel "${VM_DIR}/vmlinuz"
            -append "root=/dev/sda rw console=ttyS0 loglevel=3 quiet"
            -drive "file=${VM_DISK},format=qcow2,if=virtio"
        )
        if [[ -f "${VM_DIR}/initrd.img" ]]; then
            QEMU_ARGS+=(-initrd "${VM_DIR}/initrd.img")
        fi
    else
        # Full disk boot (needs bootloader in disk)
        QEMU_ARGS+=(
            -drive "file=${VM_DISK},format=qcow2,if=virtio"
            -boot c
        )
    fi

    qemu-system-x86_64 "${QEMU_ARGS[@]}"
}

# ── Quick test: just check strings in vmlinuz ──
quick_verify() {
    info "Quick verification — checking vmlinuz binary for branding strings..."
    echo ""

    local VMLINUZ
    if [[ -f "${VM_DIR}/vmlinuz" ]]; then
        VMLINUZ="${VM_DIR}/vmlinuz"
    else
        # Extract from deb
        local EXTRACT_DIR="${VM_DIR}/deb-extract"
        rm -rf "${EXTRACT_DIR}"
        mkdir -p "${EXTRACT_DIR}"
        dpkg-deb -x "${KERNEL_DEB}" "${EXTRACT_DIR}"
        VMLINUZ=$(find "${EXTRACT_DIR}/boot" -name "vmlinuz-*" | head -1)
    fi

    if [[ -z "$VMLINUZ" ]]; then
        error "Cannot find vmlinuz"
        exit 1
    fi

    # Extract strings from the compressed kernel image
    info "Scanning kernel image for version strings..."
    echo ""

    # Check for Parrot references
    local PARROT_COUNT
    PARROT_COUNT=$(strings "$VMLINUZ" | grep -ci "parrot" || true)

    echo "  Parrot references found: ${PARROT_COUNT}"

    if [[ "$PARROT_COUNT" -gt 0 ]]; then
        echo -e "  ${RED}[FAIL] ❌ Parrot references still present:${NC}"
        strings "$VMLINUZ" | grep -i "parrot" | head -10 | sed 's/^/    /'
    else
        echo -e "  ${GREEN}[PASS] ✅ No Parrot references in kernel image${NC}"
    fi

    echo ""

    # Show version strings
    info "Kernel version strings:"
    strings "$VMLINUZ" | grep -E "Linux version|nullsec|NullSec" | head -5 | sed 's/^/  /'
    echo ""

    # Show the /proc/version equivalent
    info "Expected /proc/version:"
    strings "$VMLINUZ" | grep "^Linux version" | head -1 | sed 's/^/  /'
    echo ""
}

# ── Main ──
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       NullSec Linux — Kernel VM Tester                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

case "${1:-help}" in
    quick)
        find_kernel_debs
        quick_verify
        ;;
    setup)
        find_kernel_debs
        extract_boot_files
        create_test_rootfs
        ;;
    boot)
        find_kernel_debs
        extract_boot_files
        boot_vm
        ;;
    full)
        find_kernel_debs
        extract_boot_files
        create_test_rootfs
        boot_vm
        ;;
    help|*)
        echo "Usage: $0 {quick|setup|boot|full}"
        echo ""
        echo "  quick  — Scan the built vmlinuz for Parrot strings (no VM)"
        echo "  setup  — Create the VM disk + rootfs (no boot)"
        echo "  boot   — Boot the VM with the NullSec kernel"
        echo "  full   — Setup + boot in one step"
        echo ""
        echo "Prerequisites:"
        echo "  Run build-kernel.sh first to compile the kernel"
        echo ""
        ;;
esac

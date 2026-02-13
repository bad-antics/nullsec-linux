#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# NullSec Linux — Kernel Rebuild Script
# Removes all Parrot branding from the kernel version string
# Builds .deb packages ready for install or ISO inclusion
# ═══════════════════════════════════════════════════════════════════
set -e

KERNEL_VERSION="6.17.13"
NULLSEC_VERSION="1.0"
NULLSEC_CODENAME="void"
LOCALVERSION="+2-amd64"
BUILD_DIR="/home/antics/projects/nullsec-linux/kernel-build"
JOBS=$(nproc)

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║       NullSec Linux — Kernel ${KERNEL_VERSION} Rebuild         ║"
    echo "║       Removing Parrot branding · Building .deb           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

info()    { echo -e "${GREEN}[*]${NC} $1"; }
warn()    { echo -e "${YELLOW}[~]${NC} $1"; }
error()   { echo -e "${RED}[!]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }

check_deps() {
    info "Checking build dependencies..."
    local MISSING=()
    for cmd in gcc make flex bison bc pahole; do
        command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
    done
    for lib in libssl-dev libncurses-dev libelf-dev; do
        dpkg -s "$lib" &>/dev/null || MISSING+=("$lib")
    done
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        error "Missing: ${MISSING[*]}"
        info "Installing..."
        sudo apt-get install -y build-essential flex bison bc dwarves \
            libssl-dev libncurses-dev libelf-dev cpio
    fi
    success "All dependencies satisfied"
}

download_source() {
    info "Setting up build directory: ${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"

    if [[ -d "linux-${KERNEL_VERSION}" ]]; then
        warn "Source tree already exists, reusing"
    else
        local TARBALL="linux-${KERNEL_VERSION}.tar.xz"
        if [[ ! -f "$TARBALL" ]]; then
            info "Downloading kernel ${KERNEL_VERSION} from kernel.org..."
            wget -q --show-progress \
                "https://cdn.kernel.org/pub/linux/kernel/v6.x/${TARBALL}"
        fi
        info "Extracting source..."
        tar xf "$TARBALL"
    fi
    cd "linux-${KERNEL_VERSION}"
    success "Kernel source ready: $(pwd)"
}

apply_config() {
    info "Applying running kernel config..."

    if [[ -f /boot/config-$(uname -r) ]]; then
        cp /boot/config-$(uname -r) .config
        success "Copied config from /boot/config-$(uname -r)"
    elif [[ -f /proc/config.gz ]]; then
        zcat /proc/config.gz > .config
        success "Extracted config from /proc/config.gz"
    else
        error "No kernel config found — using defconfig"
        make defconfig
    fi

    # Adapt config to new kernel (accept defaults for new options)
    make olddefconfig
    success "Config adapted to ${KERNEL_VERSION}"
}

rebrand_kernel() {
    info "Rebranding kernel — removing all Parrot references..."

    # ── 1. Set EXTRAVERSION in the top-level Makefile ──
    # The uname version string is built from:
    #   VERSION.PATCHLEVEL.SUBLEVEL-EXTRAVERSION+LOCALVERSION
    # Parrot sets EXTRAVERSION in their build. We clear it and use LOCALVERSION.
    sed -i 's/^EXTRAVERSION =.*/EXTRAVERSION =/' Makefile
    success "Cleared EXTRAVERSION in Makefile"

    # ── 2. Set LOCALVERSION via config ──
    # This gives us "6.17.13+2-amd64" in uname -r
    scripts/config --set-str CONFIG_LOCALVERSION "${LOCALVERSION}"
    success "Set CONFIG_LOCALVERSION = ${LOCALVERSION}"

    # ── 3. Disable auto-append of git revision ──
    scripts/config --disable CONFIG_LOCALVERSION_AUTO
    success "Disabled CONFIG_LOCALVERSION_AUTO"

    # ── 4. Set build identification string ──
    # This controls the (#1 SMP PREEMPT_DYNAMIC ...) part of /proc/version
    # The distro name after #1 SMP comes from KBUILD_BUILD_TIMESTAMP/HOST/USER
    export KBUILD_BUILD_USER="nullsec"
    export KBUILD_BUILD_HOST="nullsec.sh"
    # The "Parrot 6.17.13-1parrot1" part comes from the Debian changelog
    # version embedded at build time. We override via KDEB_PKGVERSION.
    # Format: <upstream>-<revision>  The revision becomes KBUILD_BUILD_VERSION
    # which appears as "#<revision>" in uname. Use "-1" so revision=1.
    # NullSec branding goes in KBUILD_BUILD_TIMESTAMP instead.
    export KDEB_PKGVERSION="${KERNEL_VERSION}-1"
    # KBUILD_BUILD_VERSION controls the #N in uname — keep it as just "1"
    export KBUILD_BUILD_VERSION="1"
    # KBUILD_BUILD_TIMESTAMP controls the string after SMP PREEMPT_DYNAMIC
    # Parrot used: "Parrot 6.17.13-1parrot1 (2026-01-08)"
    export KBUILD_BUILD_TIMESTAMP="NullSec ${KERNEL_VERSION}-1nullsec1 ($(date +%Y-%m-%d))"
    success "Set build identity: ${KBUILD_BUILD_USER}@${KBUILD_BUILD_HOST}"
    success "Set package version: ${KDEB_PKGVERSION}"
    success "Set build timestamp: ${KBUILD_BUILD_TIMESTAMP}"

    # ── 5. Patch any hardcoded Parrot strings in the source ──
    # Check for any Parrot references in version-related files
    local PARROT_REFS
    PARROT_REFS=$(grep -ril "parrot" Makefile scripts/setlocalversion 2>/dev/null || true)
    if [[ -n "$PARROT_REFS" ]]; then
        warn "Found Parrot references in: ${PARROT_REFS}"
        for f in $PARROT_REFS; do
            sed -i 's/[Pp]arrot/NullSec/g' "$f"
            success "Patched: $f"
        done
    else
        success "No hardcoded Parrot strings found in build scripts"
    fi

    echo ""
    info "Kernel identity after rebranding:"
    echo -e "  Version:  ${CYAN}${KERNEL_VERSION}${LOCALVERSION}${NC}"
    echo -e "  Package:  ${CYAN}${KDEB_PKGVERSION}${NC}"
    echo -e "  Builder:  ${CYAN}${KBUILD_BUILD_USER}@${KBUILD_BUILD_HOST}${NC}"
    echo ""
}

build_kernel() {
    info "Building kernel with ${JOBS} parallel jobs..."
    info "This will take 15-45 minutes depending on your hardware."
    echo ""

    export KBUILD_BUILD_USER="nullsec"
    export KBUILD_BUILD_HOST="nullsec.sh"
    export KDEB_PKGVERSION="${KERNEL_VERSION}-1"
    export KBUILD_BUILD_VERSION="1"
    export KBUILD_BUILD_TIMESTAMP="NullSec ${KERNEL_VERSION}-1nullsec1 ($(date +%Y-%m-%d))"

    # Build .deb packages
    make -j"${JOBS}" \
        KBUILD_BUILD_USER="${KBUILD_BUILD_USER}" \
        KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST}" \
        KDEB_PKGVERSION="${KDEB_PKGVERSION}" \
        KBUILD_BUILD_VERSION="${KBUILD_BUILD_VERSION}" \
        KBUILD_BUILD_TIMESTAMP="${KBUILD_BUILD_TIMESTAMP}" \
        bindeb-pkg > "${BUILD_DIR}/build.log" 2>&1

    echo ""
    success "Kernel build complete!"
    info "Output packages:"
    ls -lh "${BUILD_DIR}"/*.deb 2>/dev/null
}

show_summary() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  BUILD COMPLETE${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  .deb packages are in: ${BUILD_DIR}/"
    echo ""
    echo "  To test in a VM:"
    echo "    bash /home/antics/projects/nullsec-linux/test-kernel-vm.sh"
    echo ""
    echo "  To install on this system:"
    echo "    sudo dpkg -i ${BUILD_DIR}/linux-image-${KERNEL_VERSION}${LOCALVERSION}_*.deb"
    echo "    sudo dpkg -i ${BUILD_DIR}/linux-headers-${KERNEL_VERSION}${LOCALVERSION}_*.deb"
    echo "    sudo update-grub"
    echo ""
    echo "  Expected uname -r after reboot:"
    echo -e "    ${CYAN}${KERNEL_VERSION}${LOCALVERSION}${NC}"
    echo ""
    echo "  Expected uname -a (no Parrot reference):"
    echo -e "    ${CYAN}Linux nullsec ${KERNEL_VERSION}${LOCALVERSION} #1 SMP PREEMPT_DYNAMIC NullSec ${KDEB_PKGVERSION} (...) x86_64 GNU/Linux${NC}"
    echo ""
}

# ── Main ──
banner

case "${1:-all}" in
    deps)
        check_deps
        ;;
    download)
        download_source
        ;;
    config)
        download_source
        apply_config
        ;;
    rebrand)
        cd "${BUILD_DIR}/linux-${KERNEL_VERSION}"
        rebrand_kernel
        ;;
    build)
        cd "${BUILD_DIR}/linux-${KERNEL_VERSION}"
        rebrand_kernel
        build_kernel
        show_summary
        ;;
    all)
        check_deps
        download_source
        apply_config
        rebrand_kernel
        build_kernel
        show_summary
        ;;
    *)
        echo "Usage: $0 {deps|download|config|rebrand|build|all}"
        exit 1
        ;;
esac

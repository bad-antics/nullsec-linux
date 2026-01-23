#!/bin/bash
#
#    _   __      ____  _____              __    _                  
#   / | / /_  __/ / / / ___/___  _____   / /   (_)___  __  ___  __
#  /  |/ / / / / / /  \__ \/ _ \/ ___/  / /   / / __ \/ / / / |/_/
# / /|  / /_/ / / /  ___/ /  __/ /__   / /___/ / / / / /_/ />  <  
#/_/ |_/\__,_/_/_/  /____/\___/\___/  /_____/_/_/ /_/\__,_/_/|_|  
#                                                                  
# NullSec Linux Toolkit Installer
# https://github.com/bad-antics/nullsec-linux
# discord.gg/killers
#

set -e

VERSION="4.0.0"
NULLSEC_HOME="${NULLSEC_HOME:-/opt/nullsec}"
BIN_DIR="/usr/local/bin"
CONFIG_DIR="/etc/nullsec"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

banner() {
    echo -e "${MAGENTA}"
    echo '    _   __      ____  _____              __    _                  '
    echo '   / | / /_  __/ / / / ___/___  _____   / /   (_)___  __  ___  __'
    echo '  /  |/ / / / / / /  \__ \/ _ \/ ___/  / /   / / __ \/ / / / |/_/'
    echo ' / /|  / /_/ / / /  ___/ /  __/ /__   / /___/ / / / / /_/ />  <  '
    echo '/_/ |_/\__,_/_/_/  /____/\___/\___/  /_____/_/_/ /_/\__,_/_/|_|  '
    echo -e "${NC}"
    echo -e "${CYAN}    [ NullSec Linux Toolkit Installer v${VERSION} ]${NC}"
    echo -e "${YELLOW}    [ discord.gg/killers for support ]${NC}"
    echo
}

log_info() { echo -e "${CYAN}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        log_info "Detected: $PRETTY_NAME"
    else
        DISTRO="unknown"
    fi
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    case "$DISTRO" in
        debian|ubuntu|kali|parrot)
            apt-get update -qq
            apt-get install -y -qq \
                git curl wget unzip \
                build-essential \
                python3 python3-pip python3-venv \
                nmap wireshark-common tcpdump \
                john hashcat hydra \
                aircrack-ng \
                binwalk foremost \
                gdb radare2 \
                tor proxychains4 \
                2>/dev/null || true
            ;;
        fedora|rhel|centos)
            dnf install -y \
                git curl wget unzip \
                gcc gcc-c++ make \
                python3 python3-pip \
                nmap wireshark tcpdump \
                john hashcat hydra \
                tor proxychains-ng \
                2>/dev/null || true
            ;;
        arch|manjaro)
            pacman -Sy --noconfirm \
                git curl wget unzip \
                base-devel \
                python python-pip \
                nmap wireshark-qt tcpdump \
                john hashcat hydra \
                aircrack-ng \
                binwalk foremost \
                gdb radare2 \
                tor proxychains-ng \
                2>/dev/null || true
            ;;
    esac
    
    log_success "Dependencies installed"
}

create_directories() {
    log_info "Creating directories..."
    
    mkdir -p "$NULLSEC_HOME"/{bin,lib,modules,configs,payloads,wordlists,scripts,docs}
    mkdir -p "$CONFIG_DIR"/{hardening,firewall,apparmor,seccomp,integrity}
    
    log_success "Directories created"
}

install_tools() {
    log_info "Installing NullSec tools..."
    
    cd "$NULLSEC_HOME"
    
    # Clone tool repositories
    TOOLS=(
        "nullsec-framework"
        "nullsec-injector"
        "nullsec-netprobe"
        "nullsec-memcorrupt"
        "nullsec-bingaze"
        "nullsec-kernspy"
        "nullsec-portscan"
        "nullsec-hashwitch"
        "nullsec-cryptwrap"
        "nullsec-stealth"
        "nullsec-cppsentry"
        "nullsec-flowtrace"
        "nullsec-clusterguard"
        "nullsec-reporaider"
        "nullsec-luashield"
        "nullsec-juliaprobe"
        "nullsec-perlscrub"
        "nullsec-vvault"
        "nullsec-nimhunter"
        "nullsec-zigscan"
        "nullsec-shelltrace"
        "nullsec-fsharpsignal"
        "nullsec-adashield"
        "nullsec-crystalrecon"
        "nullsec-kotlinguard"
        "nullsec-swiftsentinel"
        "nullsec-ocamlparse"
        "nullsec-dlangaudit"
        "nullkia"
    )
    
    for tool in "${TOOLS[@]}"; do
        if [[ -d "$NULLSEC_HOME/modules/$tool" ]]; then
            log_info "Updating $tool..."
            cd "$NULLSEC_HOME/modules/$tool" && git pull -q
        else
            log_info "Installing $tool..."
            git clone -q "https://github.com/bad-antics/$tool" "$NULLSEC_HOME/modules/$tool" 2>/dev/null || true
        fi
    done
    
    log_success "Tools installed"
}

create_commands() {
    log_info "Creating commands..."
    
    # nullsec-update
    cat > "$BIN_DIR/nullsec-update" << 'CMD'
#!/bin/bash
echo "[*] Updating NullSec tools..."
cd /opt/nullsec/modules
for tool in */; do
    echo "  Updating $tool..."
    cd "$tool" && git pull -q 2>/dev/null
    cd ..
done
echo "[✓] Update complete"
CMD

    # nullsec-fetch
    cat > "$BIN_DIR/nullsec-fetch" << 'CMD'
#!/bin/bash
echo "[*] Fetching latest tools from bad-antics..."
cd /opt/nullsec/modules
gh repo list bad-antics --limit 100 | grep nullsec | while read repo rest; do
    name=$(basename "$repo")
    if [[ ! -d "$name" ]]; then
        echo "  Cloning $name..."
        git clone -q "https://github.com/$repo" 2>/dev/null
    fi
done
echo "[✓] Fetch complete"
CMD

    # nullsec-harden
    cat > "$BIN_DIR/nullsec-harden" << 'CMD'
#!/bin/bash
echo "[*] NullSec Hardening Tool"
case "$1" in
    --profile)
        echo "Applying profile: $2"
        case "$2" in
            maximum)
                sysctl -w kernel.kptr_restrict=2
                sysctl -w kernel.dmesg_restrict=1
                sysctl -w kernel.perf_event_paranoid=3
                sysctl -w net.ipv4.tcp_syncookies=1
                echo "[✓] Maximum hardening applied"
                ;;
            moderate)
                sysctl -w kernel.kptr_restrict=1
                sysctl -w kernel.dmesg_restrict=1
                echo "[✓] Moderate hardening applied"
                ;;
        esac
        ;;
    *)
        echo "Usage: nullsec-harden --profile <maximum|moderate|minimal>"
        ;;
esac
CMD

    # nullsec-anon
    cat > "$BIN_DIR/nullsec-anon" << 'CMD'
#!/bin/bash
echo "[*] NullSec Anonymity Tool"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tor)
            systemctl start tor
            echo "[✓] Tor started"
            ;;
        --mac-spoof)
            for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
                ip link set "$iface" down
                macchanger -r "$iface" 2>/dev/null
                ip link set "$iface" up
            done
            echo "[✓] MAC addresses randomized"
            ;;
        --dns)
            echo "nameserver 9.9.9.9" > /etc/resolv.conf
            echo "nameserver 149.112.112.112" >> /etc/resolv.conf
            echo "[✓] DNS set to Quad9"
            ;;
    esac
    shift
done
CMD

    # nullsec (main command)
    cat > "$BIN_DIR/nullsec" << 'CMD'
#!/bin/bash
NULLSEC_HOME="/opt/nullsec"

show_banner() {
    echo -e "\033[35m"
    echo '    _   __      ____  _____              '
    echo '   / | / /_  __/ / / / ___/___  _____    '
    echo '  /  |/ / / / / / /  \__ \/ _ \/ ___/    '
    echo ' / /|  / /_/ / / /  ___/ /  __/ /__      '
    echo '/_/ |_/\__,_/_/_/  /____/\___/\___/      '
    echo -e "\033[0m"
    echo "  NullSec Linux v4.0 | bad-antics"
    echo
}

case "$1" in
    list|ls)
        echo "[Tools in $NULLSEC_HOME/modules]"
        ls -1 "$NULLSEC_HOME/modules"
        ;;
    run)
        shift
        "$NULLSEC_HOME/modules/$1/bin/$1" "${@:2}" 2>/dev/null || \
        "$NULLSEC_HOME/modules/$1/$1" "${@:2}" 2>/dev/null || \
        echo "Tool not found: $1"
        ;;
    update)
        nullsec-update
        ;;
    fetch)
        nullsec-fetch
        ;;
    harden)
        shift
        nullsec-harden "$@"
        ;;
    anon)
        shift
        nullsec-anon "$@"
        ;;
    version|-v)
        echo "NullSec Linux v4.0.0"
        ;;
    help|-h|"")
        show_banner
        echo "Usage: nullsec <command>"
        echo
        echo "Commands:"
        echo "  list      List installed tools"
        echo "  run       Run a tool"
        echo "  update    Update all tools"
        echo "  fetch     Fetch new tools"
        echo "  harden    Apply hardening"
        echo "  anon      Anonymity tools"
        echo "  version   Show version"
        echo
        echo "Join discord.gg/killers for support!"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'nullsec help' for usage"
        ;;
esac
CMD

    chmod +x "$BIN_DIR"/nullsec*
    
    log_success "Commands created"
}

setup_hardening() {
    log_info "Setting up hardening profiles..."
    
    # Sysctl hardening
    cat > "$CONFIG_DIR/hardening/sysctl.conf" << 'SYSCTL'
# NullSec Linux Kernel Hardening
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.perf_event_paranoid=3
kernel.unprivileged_bpf_disabled=1
kernel.yama.ptrace_scope=2
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv6.conf.all.accept_redirects=0
SYSCTL

    log_success "Hardening profiles created"
}

print_success() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     NullSec Linux Toolkit installed successfully!            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Quick start:${NC}"
    echo "    nullsec list          # List tools"
    echo "    nullsec update        # Update tools"
    echo "    nullsec harden --profile maximum"
    echo "    nullsec anon --tor --mac-spoof"
    echo
    echo -e "${YELLOW}Join discord.gg/killers for premium tools!${NC}"
    echo
}

# Main
main() {
    banner
    check_root
    detect_distro
    
    log_info "Installing NullSec Linux Toolkit v${VERSION}..."
    echo
    
    install_dependencies
    create_directories
    install_tools
    create_commands
    setup_hardening
    
    print_success
}

main "$@"

#!/bin/bash
#============================================
# NullSec Linux Installer
# Security-focused Linux distribution
# https://github.com/bad-antics/nullsec-linux
#============================================

set -e
NULLSEC_VERSION="1.0-void"
INSTALL_DIR="/opt/nullsec"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    cat << 'BANNER'
    _   __      ____  _____           
   / | / /_  __/ / / / ___/___  _____
  /  |/ / / / / / /  \__ \/ _ \/ ___/
 / /|  / /_/ / / /  ___/ /  __/ /__  
/_/ |_/\__,_/_/_/  /____/\___/\___/  
         Linux Security Distribution
BANNER
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] This script must be run as root${NC}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${GREEN}[*] Installing dependencies...${NC}"
    apt-get update -qq
    apt-get install -y -qq \
        git curl wget nmap masscan \
        python3 python3-pip \
        golang-go rustc cargo \
        build-essential libssl-dev \
        aircrack-ng hashcat john \
        wireshark-qt burpsuite \
        metasploit-framework \
        sqlmap nikto dirb gobuster
}

install_nullsec_tools() {
    echo -e "${GREEN}[*] Installing NullSec tools...${NC}"
    mkdir -p $INSTALL_DIR
    
    # Clone tools repo
    git clone https://github.com/bad-antics/nullsec-tools.git $INSTALL_DIR/tools
    
    # Install Python tools
    pip3 install -r $INSTALL_DIR/tools/requirements.txt 2>/dev/null || true
    
    # Build Go tools
    cd $INSTALL_DIR/tools/go
    for f in *.go; do
        go build -o /usr/local/bin/nullsec-${f%.go} $f 2>/dev/null || true
    done
    
    # Build Rust tools
    cd $INSTALL_DIR/tools/rust
    cargo build --release 2>/dev/null || true
    
    # Build C tools
    cd $INSTALL_DIR/tools/c
    for f in *.c; do
        gcc -o /usr/local/bin/nullsec-${f%.c} $f -lpthread 2>/dev/null || true
    done
}

configure_system() {
    echo -e "${GREEN}[*] Configuring system...${NC}"
    
    # Enable IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    
    # Configure firewall
    ufw default deny incoming
    ufw default allow outgoing
    ufw enable
    
    # Install NullSec configs
    git clone https://github.com/bad-antics/nullsec-configs.git /tmp/configs
    cp -r /tmp/configs/.bashrc /etc/skel/
    cp -r /tmp/configs/.vimrc /etc/skel/
}

main() {
    banner
    check_root
    
    echo -e "${GREEN}[*] NullSec Linux Installer v${NULLSEC_VERSION}${NC}"
    echo ""
    
    install_dependencies
    install_nullsec_tools
    configure_system
    
    echo ""
    echo -e "${GREEN}[✓] NullSec Linux installation complete!${NC}"
    echo -e "${CYAN}[*] Reboot recommended${NC}"
}

main "$@"

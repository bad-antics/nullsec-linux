#!/bin/bash
# SourceForge Mirror Setup for NullSec Linux
# 
# Prerequisites:
# 1. Create SourceForge account
# 2. Register project at: https://sourceforge.net/projects/new/
# 3. Set up SSH keys for file uploads

PROJECT="nullsec-linux"
SF_USER="bad-antics"  # Your SourceForge username
SF_HOST="frs.sourceforge.net"
RELEASE_DIR="/home/frs/project/${PROJECT}"

# Create directory structure
# ssh ${SF_USER}@${SF_HOST} "mkdir -p ${RELEASE_DIR}/5.0.0/{amd64,arm64,riscv64}"

# Upload function
upload_iso() {
    local ISO_FILE=$1
    local ARCH=$2
    local VERSION="5.0.0"
    
    echo "Uploading ${ISO_FILE} to SourceForge..."
    rsync -avP -e ssh "${ISO_FILE}" \
        "${SF_USER}@${SF_HOST}:${RELEASE_DIR}/${VERSION}/${ARCH}/"
}

# Upload checksums
upload_checksums() {
    local VERSION="5.0.0"
    
    rsync -avP -e ssh ../checksums/SHA256SUMS ../checksums/MD5SUMS \
        "${SF_USER}@${SF_HOST}:${RELEASE_DIR}/${VERSION}/"
}

# Example usage:
# ./setup-sourceforge.sh upload nullsec-5.0.0-standard-amd64.iso amd64

case "$1" in
    upload)
        upload_iso "$2" "$3"
        ;;
    checksums)
        upload_checksums
        ;;
    *)
        echo "Usage: $0 {upload <iso> <arch>|checksums}"
        exit 1
        ;;
esac

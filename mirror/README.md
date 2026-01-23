# NullSec Linux Mirror Setup Guide

## Mirror Options (Ranked by Ease)

### Option 1: SourceForge (FREE - Recommended) ⭐
**Best for:** Unlimited storage, global CDN, established trust

1. **Create Account**: https://sourceforge.net/user/registration
2. **Create Project**: https://sourceforge.net/projects/new/
   - Name: `nullsec-linux`
   - Category: Operating Systems > Linux Distributions
3. **Set up SSH Keys**:
   ```bash
   ssh-keygen -t ed25519 -C "nullsec-sf"
   # Add public key to SF account settings
   ```
4. **Upload ISOs**:
   ```bash
   ./setup-sourceforge.sh upload nullsec-5.0.0-standard-amd64.iso amd64
   ```

**Download URL**: `https://sourceforge.net/projects/nullsec-linux/files/`

---

### Option 2: OSDN (FREE - Asia Mirror)
**Best for:** Asian users, backup mirror

1. Create account: https://osdn.net/account/register.php
2. Create project: https://osdn.net/projects/new/
3. Upload via SFTP

---

### Option 3: Self-Hosted VPS ($5-20/month)
**Best for:** Full control, custom domain

#### Recommended Providers:
| Provider | Cost | Storage | Bandwidth |
|----------|------|---------|-----------|
| Vultr | $5/mo | 25GB SSD | 1TB |
| DigitalOcean | $6/mo | 25GB SSD | 1TB |
| Linode | $5/mo | 25GB SSD | 1TB |
| Hetzner | €4/mo | 20GB SSD | 20TB |

#### Quick Setup:
```bash
# On VPS
apt update && apt install -y nginx certbot python3-certbot-nginx

# Copy nginx config
cp nginx-mirror.conf /etc/nginx/sites-available/mirror.nullsec.io
ln -s /etc/nginx/sites-available/mirror.nullsec.io /etc/nginx/sites-enabled/

# Get SSL cert
certbot --nginx -d mirror.nullsec.io

# Create directories
mkdir -p /var/www/mirror/nullsec-linux/{releases,checksums,keys}

# Upload ISOs via rsync
rsync -avP *.iso user@mirror.nullsec.io:/var/www/mirror/nullsec-linux/releases/
```

---

### Option 4: Cloudflare R2 + Workers (Pay-per-use)
**Best for:** Scalable, global CDN, cheap egress

```bash
# Install wrangler
npm install -g wrangler

# Create R2 bucket
wrangler r2 bucket create nullsec-linux

# Upload
wrangler r2 object put nullsec-linux/releases/5.0.0/nullsec-5.0.0-standard-amd64.iso \
  --file=nullsec-5.0.0-standard-amd64.iso
```

**Cost**: ~$0.015/GB egress (much cheaper than S3)

---

### Option 5: Internet Archive (FREE - Archival)
**Best for:** Permanent archival, backup

1. Create account: https://archive.org/account/signup
2. Upload via web or CLI:
   ```bash
   ia upload nullsec-linux-5.0.0 *.iso --metadata="collection:open_source_software"
   ```

**Download URL**: `https://archive.org/download/nullsec-linux-5.0.0/`

---

## Directory Structure

```
/releases/
├── 5.0.0/
│   ├── amd64/
│   │   ├── nullsec-5.0.0-standard-amd64.iso
│   │   ├── nullsec-5.0.0-minimal-amd64.iso
│   │   └── ...
│   ├── arm64/
│   │   └── ...
│   ├── SHA256SUMS
│   ├── MD5SUMS
│   └── SHA256SUMS.gpg
└── latest -> 5.0.0
```

## Bandwidth Estimates

| Downloads/day | Monthly BW | Recommended |
|---------------|------------|-------------|
| 10 | ~100GB | SourceForge |
| 50 | ~500GB | SourceForge/Self-hosted |
| 100+ | ~1TB+ | Self-hosted + CDN |

---

## Quick Start: SourceForge Setup

```bash
# 1. Register project at sourceforge.net/projects/new/

# 2. Add SSH key to your SF account

# 3. Test connection
ssh bad-antics@shell.sourceforge.net

# 4. Create release directories
ssh bad-antics@frs.sourceforge.net "mkdir -p /home/frs/project/nullsec-linux/5.0.0"

# 5. Upload ISOs
rsync -avP --progress nullsec-5.0.0-*.iso \
  bad-antics@frs.sourceforge.net:/home/frs/project/nullsec-linux/5.0.0/

# 6. Upload checksums
rsync -avP SHA256SUMS MD5SUMS \
  bad-antics@frs.sourceforge.net:/home/frs/project/nullsec-linux/5.0.0/
```

Done! ISOs available at: https://sourceforge.net/projects/nullsec-linux/files/

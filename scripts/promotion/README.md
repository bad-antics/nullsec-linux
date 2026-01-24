# NullSec Promotion Automation

Automated tools to build GitHub stars and visibility for NullSec projects.

## Quick Start

```bash
# Check your setup
./star_getter.sh check

# Track current star counts
./star_getter.sh track

# Generate promotional content
./star_getter.sh content nullsec-linux

# Open social media submit pages
./star_getter.sh open nullsec-webfuzz
```

## Tools

### star_getter.sh
Quick CLI tool for common promotion tasks:

| Command | Description |
|---------|-------------|
| `track` | Show star progress across all repos |
| `links` | Generate shareable links |
| `content [repo]` | Generate promotional content |
| `open [repo]` | Open social submit pages in browser |
| `watch` | Real-time star monitoring |
| `update` | Update repo topics/metadata |
| `check` | Verify setup status |

### promote.py
Full automation suite for scheduled posting:

```bash
# Dry run - see what would be posted
python3 promote.py dry-run --repo nullsec-linux

# Track stars
python3 promote.py track

# Run Reddit campaign
python3 promote.py reddit --repo nullsec-webfuzz

# Run Twitter campaign
python3 promote.py twitter --repo nullsec-linux
```

## Setup

### 1. Install Dependencies

```bash
pip install praw tweepy requests pyyaml
```

### 2. Configure API Credentials

Copy and edit the config:
```bash
cp config.yaml.example config.yaml
nano config.yaml
```

### 3. Get API Credentials

#### Reddit API
1. Go to https://www.reddit.com/prefs/apps
2. Create an app (script type)
3. Copy client_id and client_secret

#### Twitter API
1. Go to https://developer.twitter.com/
2. Create a project and app
3. Generate API keys and access tokens

#### Hacker News
- Just use your regular HN username/password
- Note: HN has CAPTCHA, may require manual submission

## Promotion Strategy

### Timing
Best times to post (UTC):
- **Reddit**: 14:00-15:00, 18:00-19:00
- **Twitter**: 12:00-13:00, 17:00-18:00
- **HN**: 14:00-16:00 (US morning)

### Subreddits
Target these communities:
- r/netsec (main infosec)
- r/cybersecurity
- r/hacking
- r/AskNetsec
- r/ReverseEngineering
- r/linuxadmin
- r/linux (for distro)
- r/rust (for Rust projects)
- r/golang (for Go projects)

### Content Tips
1. **Be genuine** - Share what problem it solves
2. **Show don't tell** - Include demos/screenshots
3. **Engage** - Reply to comments
4. **Don't spam** - Space out posts (1-2 per week per platform)
5. **Cross-promote** - Link between your projects

## Goal Tracking

Target: **50 stars** per repo for awesome-list eligibility

```
nullsec-linux     [██░░░░░░░░░░░░░░░░░░]  5/50 ⭐
nullsec-webfuzz   [░░░░░░░░░░░░░░░░░░░░]  0/50 ⭐
blackflag-ecu     [░░░░░░░░░░░░░░░░░░░░]  0/50 ⭐
```

## Files

```
promotion/
├── README.md           # This file
├── config.yaml         # Your API credentials (gitignored)
├── promote.py          # Full automation suite
├── star_getter.sh      # Quick CLI tool
└── star_history.json   # Star tracking data (auto-generated)
```

## Safety Notes

⚠️ **Don't spam** - Respect rate limits and community rules
⚠️ **Don't vote manipulate** - Only organic engagement
⚠️ **Be patient** - Building stars takes time (weeks/months)
⚠️ **Quality first** - Good code attracts stars naturally

# Distribution Submission Targets

## Primary Targets (High Priority)

### 1. DistroWatch
- **URL:** https://distrowatch.com/dwres.php?resource=submit
- **Status:** ✅ Submitted
- **Requirements:**
  - [x] Publicly available ISO
  - [x] Website/homepage
  - [x] Active development
  - [x] Documentation
  - [ ] Submit form completed
- **Notes:** Most important listing for visibility. Submit after ISO release.

### 2. Wikipedia - Linux Distributions
- **URL:** https://en.wikipedia.org/wiki/Comparison_of_Linux_distributions
- **Status:** ✅ Submitted  
- **Requirements:**
  - [ ] Notable coverage (DistroWatch listing helps)
  - [ ] Third-party references
  - [x] Active development
- **Notes:** Need DistroWatch listing first for notability.

### 3. LinuxTracker
- **URL:** https://linuxtracker.org
- **Status:** ✅ Submitted
- **Requirements:**
  - [x] Torrent file for ISO
  - [x] Checksums
  - [x] Description
- **Notes:** Good for torrent distribution of ISOs.

### 4. OSDN (Open Source Distribution Network)
- **URL:** https://osdn.net
- **Status:** �� Pending
- **Requirements:**
  - [x] Open source project
  - [x] Active development
- **Notes:** Alternative hosting for downloads.

## Secondary Targets

### 5. AlternativeTo
- **URL:** https://alternativeto.net
- **Status:** ✅ Submitted
- **Notes:** List as alternative to Kali Linux, Parrot OS.

### 6. GitHub Topics
- **URL:** https://github.com/topics/linux-distribution
- **Status:** ✅ Done (via repo topics)
- **Notes:** Add relevant topics to repo.

### 7. Awesome Lists (GitHub)
Target lists for PR submissions:

| List | URL | Status |
|------|-----|--------|
| awesome-security | github.com/sbilly/awesome-security | ✅ Submitted |
| awesome-hacking | github.com/carpedm20/awesome-hacking | ✅ Submitted |
| awesome-pentest | github.com/enaqx/awesome-pentest | ✅ Submitted |
| awesome-linux | github.com/inputsh/awesome-linux | ✅ Submitted |
| Awesome-Linux-Software | github.com/luong-komorebi/Awesome-Linux-Software | ✅ Submitted |
| awesome-selfhosted | github.com/awesome-selfhosted/awesome-selfhosted | ✅ Submitted |

### 8. Reddit Communities
- r/linux - Release announcement
- r/netsec - Security tools announcement
- r/hacking - Pentest distro announcement
- r/AskNetsec - Introduction post
- r/cybersecurity - Tool showcase

### 9. Hacker News
- **URL:** https://news.ycombinator.com
- **Notes:** Submit as "Show HN: NullSec Linux - Security distro with 135+ tools"

### 10. Security Forums
- Offensive Security forums
- HackTheBox forums
- TryHackMe community
- SecurityTube
- Null Byte (WonderHowTo)

## Specialized Directories

### 11. Security Tool Directories
- **SecTools.org** - Top 100 security tools
- **BlackArch packages** - Submit tools for inclusion
- **Kali Tool Proposals** - Community tools
- **OSINT Framework** - OSINT tool listing

### 12. Package Repositories
- **AUR (Arch)** - Create nullsec-linux-tools package
- **Homebrew** - macOS tool formulas
- **nixpkgs** - NixOS packages

## Submission Timeline

### Week 1 (Current)
1. ✅ Create ISO build system
2. ✅ Create release documentation
3. 🔄 Build first official ISO
4. 🔄 Create GitHub release with assets

### Week 2
1. Submit to DistroWatch
2. Create LinuxTracker torrent
3. Submit to OSDN

### Week 3
1. Reddit announcements
2. Hacker News submission
3. Security forum posts

### Week 4
1. Awesome list PRs
2. AlternativeTo listing
3. Package repository submissions

## PR Templates

### Awesome Lists PR Title
```
Add NullSec Linux - Security distribution with 135+ tools
```

### Awesome Lists PR Body
```markdown
## What is NullSec Linux?

NullSec Linux is a Debian-based security distribution featuring:

- 135+ pre-installed security tools
- 9 specialized editions (Cloud, AI/ML, Hardware, Automotive, Mobile, etc.)
- 4 architecture support (AMD64, ARM64, RISC-V, Apple Silicon)
- Calamares graphical installer
- Custom security-hardened kernel

## Links

- Website: https://bad-antics.github.io
- GitHub: https://github.com/bad-antics/nullsec-linux
- Download: https://github.com/bad-antics/nullsec-linux/releases
- Documentation: https://github.com/bad-antics/nullsec-wiki

## Category

This belongs in the [Penetration Testing Distributions / Security Tools] section.
```

---

## Notes

- Always include direct download links
- Provide checksums and GPG signatures
- Link to documentation
- Mention unique features (AI/ML, automotive, hardware)
- Be responsive to feedback in PRs

# Customization

## Themes

NullSec Linux ships with custom dark themes optimized for long hacking sessions.

### GTK Theme
```bash
# Switch GTK theme
nullsec-theme set dark-matrix
nullsec-theme set dark-cyber
nullsec-theme set dark-blood
```

### Terminal
```bash
# Custom terminal profiles
nullsec-terminal set hacker    # Green on black
nullsec-terminal set stealth   # Gray minimal
nullsec-terminal set fire      # Red/orange gradient
```

### Wallpapers
Custom NullSec wallpapers in `/usr/share/backgrounds/nullsec/`

## Shell Configuration

### ZSH (Default)
NullSec Linux uses ZSH with Oh My Zsh and custom NullSec plugins:
- `nullsec` — NullSec Framework shortcuts
- `pentest` — Quick pentest commands
- `recon` — Reconnaissance aliases

### Prompt
Custom Powerlevel10k configuration with:
- IP address display
- VPN status indicator
- Target machine indicator
- Git branch for development

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Super+T` | Open terminal |
| `Super+F` | File manager |
| `Super+B` | Browser |
| `Super+L` | Lock screen |
| `Ctrl+Alt+T` | Root terminal |

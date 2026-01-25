# Linux Security Hardening Guide

## Overview
Comprehensive Linux security hardening procedures.

## Kernel Hardening

### Sysctl Settings
- ASLR configuration
- Core dump restrictions
- Exec shield
- Panic settings

### Module Security
- Module loading restrictions
- Signing requirements
- Blacklisting

### Syscall Filtering
- seccomp profiles
- Audit subsystem
- SELinux/AppArmor

## Filesystem Security

### Permissions
- umask settings
- Sticky bits
- SUID/SGID auditing
- ACL implementation

### Mount Options
- noexec
- nosuid
- nodev
- read-only mounts

### Encryption
- LUKS configuration
- dm-crypt
- ecryptfs
- fscrypt

## Network Security

### Firewall
- iptables/nftables
- Default deny
- Logging
- Rate limiting

### Service Hardening
- SSH configuration
- Network services
- Listening ports

## Authentication

### PAM Configuration
- Password policies
- Account lockout
- Two-factor auth

### SSH Hardening
- Key-based auth
- Allowed users
- Protocol settings

## Monitoring
- auditd rules
- Log management
- AIDE/Tripwire

## Legal Notice
For authorized system administration.

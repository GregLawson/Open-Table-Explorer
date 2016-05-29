###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/host.rb'
require_relative '../../app/models/file_tree.rb'
class Network # < ActiveRecord::Base
  include NoDB
  extend NoDB::ClassMethods
  # include Generic_Table
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		include FileTree::Example
    # Hosts = Host.new
    Quad_Pattern = /[0-2]?[0-9]?[0-9]/
    Private_A = /10\./.capture(:network) * (Quad_Pattern * Quad_Pattern * Quad_Pattern).capture(:host)
    B_Quad2 = /16/ | /17/ | /18/ | /19/ | /20/ | /21/ | /22/ | /23/ | /24/ | /25/ | /26/ | /27/ | /28/ | /29/ | /30/ | /31/
    Private_B = (/172\./ * B_Quad2).capture(:network) * (Quad_Pattern * Quad_Pattern).capture(:host)
    Private_C = /192\.168\./.capture(:network) * (Quad_Pattern * /\./ * Quad_Pattern).capture(:host)
    Zero_Config_Pattern = /169\.254./.capture(:network)
    Private_Network_Pattern = Private_A | Private_B | Private_C | Zero_Config_Pattern

    Device_separator_regexp = /\n\n/
    Device_name_regexp = /lo|[a-z]+[0-9]+/.capture(:device_name)
    IP_Pattern = (Quad_Pattern * /\./).group * 3 * Quad_Pattern
    Netmask_Pattern = /.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze
    MyContext = /\s*inet addr:/,/[0-9]*\.[0-9]*\./.capture(:myContext).freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze
    MyNetwork = /[0-9]+/.capture(:myNode)
    MyNetmask = /.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze.freeze
    IFCONFIG = ShellCommands.new('/sbin/ifconfig')
    IFCONFIG_output = IFCONFIG.output.split(Device_separator_regexp)
    Leading_whitespace = /^\s+/
    Inet_addr_regexp = Leading_whitespace * /inet / * IP_Pattern.capture(:ipv4) * /  netmask / * IP_Pattern.capture(:netmask) * /  broadcast / * IP_Pattern.capture(:broadcast) * // * /\n/
    Ifconfig_pattern = Inet_addr_regexp
    IFCONFIG_capture = IFCONFIG_output[0].capture?(Ifconfig_pattern)
  end # DefinitionalConstants
  include DefinitionalConstants
  module ClassMethods
    include DefinitionalConstants
    def ifconfig
      ret = {}
      IFCONFIG_output.each do |device_description|
        device_name = device_description.parse(Device_name_regexp)[:device_name]
        ret = ret.merge(device_name.to_sym => device_description.parse(Ifconfig_pattern))
      end # each
      ret
    end # ifconfig

    def all
      @@all = ['192.168.0.1-254'].map do |nmapScan| # map
        Network.new(nmapScan)
      end # map
    end # all

    def find_or_initialize_by_nmap_addresses(nmapScan)
      Network.new(nmapScan)
    end # find_or_initialize_by_nmap_addresses

    def whereAmI
      ifconfig = `/sbin/ifconfig|grep "inet addr" `
      # puts ifconfig
      @myContext = ifconfig.parse([/\s*inet addr:/, /[0-9]*\.[0-9]*\./.capture(:myContext)])
      @myNetwork = ifconfig.scan(/[0-9]+\./.capture(:myNetwork))
      @myNode = ifconfig.scan(/[0-9]+/.capture(:myNode))
      # puts "@myContext=#{@myContext}"
      # puts "@myNetwork=#{@myNetwork}"
      # puts "@myNode=#{@myNode}"
      @myIP = "#{@myContext}#{@myNetwork}#{@myNode}"
      # puts "@myIP=#{@myIP}"
      # ip=IPAddr.new(@myIP)
      # puts "ip=#{ip}"
      # puts "@myNetmask=#{@myNetmask}"
      # ip=ip.mask(@myNetmask)
      # puts "ip=#{ip}"
      # puts "masklen(\"cidr #{@myNetmask}\")"
      # @hosts=Host.new
      #	Host.recordDetection(@myIP)
      @nmapScan = "#{@myContext}#{@myNetwork}1-254"
      network = find_or_initialize_by_nmap_addresses(@nmapScan)
      #	network.update_attribute('nmap_addresses',@nmapScan)
      network.dumpAcquisitions if $DEBUG
      #	network.save
    end # whereAmI

    def acquire
      whereAmI
      # now do incremental ping and nmapScan
      Global.log.debug("networks before find @row=#{@row}")
      network = Networks.first(order: 'last_scan ASC')
      puts "nmap_addresses=#{network.nmap_addresses}" if $VERBOSE
      Networks.ping(network.nmap_addresses)
      host = Host.first(order: 'last_detection ASC')
      Host.nmapScan(host.ip)
    end

    def ping(nmapScan)
      network = Networks.find_or_initialize_by_nmap_addresses(nmapScan)
      puts "nmap -sP #{nmapScan}" # if $VERBOSE
      @pingNmap = `nmap -sP #{nmapScan}`
      Global.log.debug("@pingNmap=#{@pingNmap}")
      network.update_attribute('last_scan', Time.new)
      network.save
      @pingNmap.each_line do |r|
        Global.log.debug("Line: '#{r}'")
        s = VerboseStringScanner.new(r)
        if s.scan(/Host /)
          matchData = /[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}/.match(r)
          candidateIP = matchData[0]
          Host.recordDetection(candidateIP)
          Global.log.debug("candidateIP=#{candidateIP}")
        elsif s.scan(/Nmap done:/)
          up, nmap_execution_time = Host.scanNmapSummary(s)
          network.update_attribute('nmap_execution_time', nmap_execution_time)
          puts "nmap_execution_time=#{nmap_execution_time}" # if $VERBOSE
        elsif s.scan(/^\s*$|Starting Nmap/)
          # ignore line
        else
          puts "Line not decoded: '#{r}'"
        end
      end
      # network.dumpAcquisitions if $VERBOSE
      network.inspect if $VERBOSE
      network.save
    end
  end # ClassMethods
  extend ClassMethods
  module Constants # constant objects of the type (e.g. default_objects)
    My_IP = Network.ifconfig[:eth0][:ipv4]
    Arp_IP_file = IO.read('/proc/net/arp')
    Arp_IP_lines = IO.read('/proc/net/arp').split("\n")
  end # Constants
  include Constants
  attr_reader :ip_range
  def initialize(ip_range) # can this be a Range?
    @ip_range = ip_range
  end # initialize

  def ==(other)
    ip_range == other.ip_range
  end # equals

  def nmap(options = '-sP')
    #	@nmap=ShellCommands.new('nmap ' + options + ' ' + @ip_range)
  end # nmap

  def update_attribute(name, value)
    instance_variable_set(name, value)
  end # update_attribute
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include Constants
  end # Examples
end # Network

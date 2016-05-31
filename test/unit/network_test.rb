###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/network.rb'
class NetworkTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  include Network::Examples
  include Network::DefinitionalConstants

  def test_DefinitionalConstants
    example_nmap_line = 'Nmap scan report for 192.168.0.5'
    private_C_network = /192\.168\./.capture(:network)
    assert_match(private_C_network * Quad_Pattern, example_nmap_line)
    assert_match(private_C_network * Quad_Pattern.capture(:host), example_nmap_line)
    assert_match(Quad_Pattern * /\./, example_nmap_line)
    assert_match(Quad_Pattern * /\.[0-9]?/, example_nmap_line)
    assert_match(Quad_Pattern * /\.[0-9]?[0-9]/, example_nmap_line)
    assert_match(Quad_Pattern * /\.[0-2]?[0-9]?[0-9]/, example_nmap_line)
    assert_match(Quad_Pattern * /\./ * Quad_Pattern, example_nmap_line)
    assert_match((Quad_Pattern * /\./ * Quad_Pattern).capture(:host), example_nmap_line)
    assert_match(private_C_network * (Quad_Pattern * /\./ * Quad_Pattern).capture(:host), example_nmap_line)
    assert_match(Private_C, example_nmap_line)
    ip_regexp = Private_Network_Pattern
    assert_match(ip_regexp, example_nmap_line)
    assert_equal({ lo: '../../devices/virtual/net/lo', eth0: '../../devices/pci0000:00/0000:00:1c.2/0000:03:00.0/net/eth0', wlan0: '../../devices/pci0000:00/0000:00:1c.0/0000:01:00.0/net/wlan0' }, Net_file_tree_hash)
    #    assert_match(IP_Pattern, IFCONFIG_capture.output[:ipv4], IFCONFIG_capture.inspect)
    #    assert_match(IP_Pattern, IFCONFIG_capture.output[:netmask], IFCONFIG_capture.inspect)
    #    assert_match(IP_Pattern, IFCONFIG_capture.output[:broadcast], IFCONFIG_capture.inspect)
  end # Constants

  def test_ifconfig
    assert_match(Device_separator_regexp, IFCONFIG.output)
    assert_match(Device_name_regexp, IFCONFIG.output)
    hex_digit_lc = /[0-9a-f]/
    assert_match(hex_digit_lc, IFCONFIG.output)
    hex_byte_lc = hex_digit_lc * hex_digit_lc
    assert_match(hex_byte_lc, IFCONFIG.output)
    hw_address = ((hex_byte_lc * /:/).group * 5 * hex_byte_lc).capture(:hw_address)
    assert_match(hw_address, IFCONFIG.output)
    assert_match(Leading_whitespace, IFCONFIG.output)
    inet_addr_regexp = Leading_whitespace * /inet / * IP_Pattern.capture(:ipv4) * /  netmask / * IP_Pattern.capture(:netmask) * /  broadcast / * IP_Pattern.capture(:broadcast) * // * /\n/
    assert_match(Leading_whitespace * /inet /, IFCONFIG.output)
    assert_match(Leading_whitespace * /inet / * IP_Pattern, IFCONFIG.output)
    assert_match(/  netmask /, IFCONFIG.output)
    assert_match(Leading_whitespace * /inet / * IP_Pattern * / /, IFCONFIG.output)
    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  /, IFCONFIG.output)
    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  netmask/, IFCONFIG.output)
    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  netmask /, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  netmask / * IP_Pattern, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  netmask / * IP_Pattern * /  broadcast /, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet / * IP_Pattern * /  netmask / * IP_Pattern * /  broadcast / * IP_Pattern * // * /\n/, IFCONFIG.output)
    #    assert_match(inet_addr_regexp, IFCONFIG.output)
    hex4_lc = hex_digit_lc * (1..4)
    assert_match(hex4_lc, IFCONFIG.output)
    ip6_address = (hex4_lc * /:/).group * (0..7) * hex_digit_lc * hex_digit_lc
    assert_match(ip6_address, IFCONFIG.output)
    ipv6_bit_length_regexp = /1?[0-9]?[0-9]/
    assert_match(ipv6_bit_length_regexp, IFCONFIG.output)
    ipv6_CIDR_regexp = ip6_address * /\// * ipv6_bit_length_regexp

    ret = {}
    IFCONFIG_output.each do |device_description|
      device_name = device_description.parse(Device_name_regexp)[:device_name]
      message = 'device_description = ' + device_description.inspect
      message += "\n" + IFCONFIG_output.inspect
      assert_match(/eth0|lo|wlan0/, device_name.to_s, message)
      ret = ret.merge(device_name.to_sym => device_description.parse(Ifconfig_pattern))
    end # each
    Network.ifconfig.each_pair do |device, _description|
      message = Network.ifconfig.inspect
      message += "\n" + IFCONFIG_output.inspect
      assert_match(/eth0|lo|wlan0/, device.to_s, message)
    end # each_pair

    #	assert_match(ipv6_CIDR_regexp, IFCONFIG.output)
    inet6_addr_regexp = Leading_whitespace * /inet6 / * ipv6_CIDR_regexp * / Scope:/ * /Link|Global|Host/.capture(:scope) * /\n/
    #	assert_match(inet6_addr_regexp, IFCONFIG.output)
    status_regexp = Leading_whitespace * /UP LOOPBACK RUNNING  MTU:65536  Metric:1/ * /\n/
    #	assert_match(status_regexp, IFCONFIG.output)
    rx_packets_regexp = Leading_whitespace * /RX packets:/ * /[0-9]+/ * / errors:/ * /[0-9]+/ * / dropped:/ * /[0-9]+/ * / overruns:/ * /[0-9]+/ * / frame:/ * /[0-9]+/ * /\n/
    #	assert_match(rx_packets_regexp, IFCONFIG.output)
    tx_regexp = Leading_whitespace * /TX packets:/ * /[0-9]+/ * / errors:/ * /[0-9]+/ * / dropped:/ * /[0-9]+/ * / overruns:/ * /[0-9]+/ * / carrier:/ * /[0-9]+/ * /\n/
    #	assert_match(tx_regexp, IFCONFIG.output)
    congestion_regexp = Leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / / * /\n/
    #	assert_match(congestion_regexp, IFCONFIG.output)
    rx_bytes_regexp = Leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/ * /[0-9]+/ * / \(4.7 GiB\)/ * /\n/
    #	assert_match(rx_bytes_regexp, IFCONFIG.output)
    #	line1_regexp = Leading_whitespace * device_name * /\s+/ * /Link encap:/ * /Ethernet  HWaddr / * hw_address * /  / * /\n/
    #	assert_match(line1_regexp, IFCONFIG.output)
    #	assert_match(line1_regexp * Context_Pattern, IFCONFIG.output)
    #	assert_match(line1_regexp * Context_Pattern * Network_Pattern, IFCONFIG.output)
    #	assert_match(line1_regexp * Context_Pattern * Network_Pattern * Node_Pattern, IFCONFIG.output)

    assert_match(IP_Pattern, IFCONFIG.output)
    #    assert_match(inet_addr_regexp, IFCONFIG.output)

    assert_match(Leading_whitespace * /inet6 /, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet6 / * hex_digit_lc, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet6 / * hex4_lc, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /inet6 / * ip6_address, IFCONFIG.output)
    #    ip6_regexp = Leading_whitespace * /inet6 / * ip6_address
    #    matchData = IFCONFIG.output.match(ip6_regexp)
    #	assert_equal('/64', matchData.post_match[0,3], matchData.inspect)
    #	assert_match(Leading_whitespace * /inet6 / * ipv6_CIDR_regexp * / Scope/, IFCONFIG.output)
    #	assert_match(Leading_whitespace * /inet6 / * ipv6_CIDR_regexp * / Scope:/, IFCONFIG.output)
    #	assert_match(Leading_whitespace * /inet6 / * ipv6_CIDR_regexp * / Scope:/ * (/Link|Global|Host/).capture(:scope), IFCONFIG.output)
    #	assert_match(Leading_whitespace * /inet6 / * ipv6_CIDR_regexp * / Scope:/ * (/Link|Global|Host/).capture(:scope) */\n/, IFCONFIG.output)
    #    assert_match(inet6_addr_regexp, IFCONFIG.output)
    #    assert_match(status_regexp, IFCONFIG.output)
    #    assert_match(rx_packets_regexp, IFCONFIG.output)
    #    assert_match(tx_regexp, IFCONFIG.output)

    ifconfig_regexp = inet6_addr_regexp
    #    assert_match(ifconfig_regexp, IFCONFIG.output)
    ifconfig_regexp *= status_regexp
    #    assert_match(ifconfig_regexp, IFCONFIG.output)

    #    assert_match(Leading_whitespace * /collisions:/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /collisions:/ * /[0-9]+/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / /, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / / * /\n/, IFCONFIG.output)
    #    assert_match(congestion_regexp, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/ * /[0-9]+/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/, IFCONFIG.output)
    #    assert_match(Leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/ * /[0-9]+/, IFCONFIG.output)
    #    assert_match(rx_bytes_regexp, IFCONFIG.output)

    #    assert_match(inet6_addr_regexp * status_regexp, IFCONFIG.output)
    ifconfig_regexp *= rx_packets_regexp * tx_regexp
    #    assert_match(ifconfig_regexp, IFCONFIG.output)
    ifconfig_regexp *= congestion_regexp * rx_bytes_regexp

    #    assert_match(ifconfig_regexp, IFCONFIG.output)
    #    lines = IFCONFIG.output.parse(Capture::Examples::LINE)
    double_lines = IFCONFIG.output.split("\n\n")
    assert_instance_of(Array, double_lines)
    assert_operator(2, :<=, double_lines.size)
    #    assert_equal('eth0', double_lines[0].split(' ')[0])
    words = double_lines[0].parse(Capture::Examples::WORD)
    #    assert_equal({ word: 'eth0' }, words, words.inspect)
    #	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
    puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
    words = double_lines.map do |row|
      words = row.parse(Capture::Examples::WORD)
      puts "words=#{words.inspect}, row=#{row.inspect}"
      assert_match(/eth0|lo|wlan0/, words[:word], "row=#{row.inspect}, words=#{words.inspect}")
    end # map
    #	IFCONFIG.output.enumerate(:map) parse(Capture::Examples::LINE).map  do |row|
    #		row.parse(row, Capture::Examples::WORD)
    #	end #map
    #	assert_equal('', IFCONFIG.rows_and_columns)
    #	assert_equal('eth0,', IFCONFIG.inspect)
    #	assert_equal('', IFCONFIG.output)
  end # ifconfig

  def test_all
    all = ['192.168.0.1-254'].map do |nmapScan| # map
      Network.new(nmapScan)
    end # map
    assert_equal(all, Network.all)
  end # all

  def test_whereAmI
    ifconfig = ShellCommands.new('/sbin/ifconfig|grep "inet addr" ').output
    private_C = ifconfig.parse(Private_C)
    private_network = ifconfig.parse(Private_Network_Pattern)
    #	context = ifconfig.parse(Context_Pattern)
    captures = ifconfig.capture?(IP_Pattern)
    ip = ifconfig.parse(IP_Pattern)
    netmask = ifconfig.parse(Netmask_Pattern)
    #	acquire=StreamPattern.find_by_name('Acquisition')
    #	refute_nil(acquire, "StreamPattern=#{StreamPattern.all.map{|p| p.name}.inspect}")
    #	ifconfig=StreamMethod.find_by_name('Shell')
    #	refute_nil(ifconfig, "StreamMethod=#{StreamMethod.all.inspect}")
    #	explain_assert_respond_to(ifconfig, :compile_code)
    #	explain_assert_respond_to(ifconfig, :fire)
    Network.whereAmI
  end # whereAmI

  def test_Constants
    assert_instance_of(Hash, Network.ifconfig)
    assert_instance_of(Hash, Network.ifconfig[:eth0])
    #    refute_nil(Network.ifconfig[:eth0][:ipv4], Network.ifconfig)
    #    assert_instance_of(String, Network.ifconfig[:eth0][:ipv4])
    #    assert_match(IP_Pattern, My_IP)
    arp_IP_file = IO.read('/proc/net/arp')
    arp_IP_lines = IO.read('/proc/net/arp').split("\n")
    assert_instance_of(Array, arp_IP_lines)
    assert_operator(1, :<=, arp_IP_lines.size, arp_IP_lines.inspect)
    if 2 <= arp_IP_lines.size
      arp_IP = IO.read('/proc/net/arp').split("\n")[1].split(' ')
    end # if
  end # Constants

  def test_initialize
  end # initialize

  def test_equals
  end # equals

  def test_update_attribute
    #	assert_equal update_attribute(name, value)
    #	refute_empty()
  end # update_attribute
end # Network

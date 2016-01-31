###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/network.rb'
class NetworkTest < TestCase
#include DefaultTests
include RailsishRubyUnit::Executable.model_class?::Examples
def test_Constants
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
end #Constants
def test_ifconfig
	device_separator = /\n\n/
	device_name = /[a-z]+[0-9]+/.capture(:device_name)
	hex_digit_lc = /[0-9a-f]/
	hex_byte_lc = hex_digit_lc * hex_digit_lc
	hw_address = ((hex_byte_lc * /:/).group * 5 * hex_byte_lc).capture(:hw_address)
	leading_whitespace = /^\s+/
	line1_regexp = leading_whitespace * device_name * /\s+/ * /Link encap:/ * /Ethernet  HWaddr / * hw_address * /  / * /\n/
	inet_addr_regexp = leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern * /  Mask:/ * IP_Pattern * // */\n/
	hex4_lc = hex_digit_lc * (1..4)
	ip6_address = (hex4_lc * /:/).group * (0..7) * hex_digit_lc * hex_digit_lc
	ipv6_bit_length_regexp = /1?[0-9]?[0-9]/
	ipv6_CIDR_regexp = ip6_address * /\// * ipv6_bit_length_regexp
	inet6_addr_regexp = leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / Scope:/ * (/Link|Global|Host/).capture(:scope) */\n/
	status_regexp = leading_whitespace * /UP LOOPBACK RUNNING  MTU:65536  Metric:1/ */\n/
	rx_packets_regexp = leading_whitespace * /RX packets:/ * /[0-9]+/ * / errors:/ * /[0-9]+/ * / dropped:/ * /[0-9]+/ * / overruns:/ * /[0-9]+/ * / frame:/ * /[0-9]+/ */\n/
	tx_regexp = leading_whitespace * /TX packets:/ * /[0-9]+/ * / errors:/ * /[0-9]+/ * / dropped:/ * /[0-9]+/ * / overruns:/ * /[0-9]+/ * / carrier:/ * /[0-9]+/ */\n/
	congestion_regexp = leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / / */\n/
	rx_bytes_regexp = leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/ * /[0-9]+/ * / \(4.7 GiB\)/ */\n/
	assert_match(device_separator, IFCONFIG.output)
	assert_match(device_name, IFCONFIG.output)
	assert_match(hex_digit_lc, IFCONFIG.output)
	assert_match(hex_byte_lc, IFCONFIG.output)
	assert_match(hw_address, IFCONFIG.output)
	assert_match(line1_regexp, IFCONFIG.output)
#	assert_match(line1_regexp * Context_Pattern, IFCONFIG.output)
#	assert_match(line1_regexp * Context_Pattern * Network_Pattern, IFCONFIG.output)
#	assert_match(line1_regexp * Context_Pattern * Network_Pattern * Node_Pattern, IFCONFIG.output)
	
	assert_match(leading_whitespace * /inet addr:/, IFCONFIG.output)
	assert_match(IP_Pattern, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern * /  Mask:/, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern * /  Mask:/ * IP_Pattern, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern * /  Mask:/ * IP_Pattern, IFCONFIG.output)
	assert_match(leading_whitespace * /inet addr:/ * IP_Pattern * /  Bcast:/ * IP_Pattern * /  Mask:/ * IP_Pattern * /\n/, IFCONFIG.output)
	assert_match(inet_addr_regexp, IFCONFIG.output)

	ifconfig_regexp = line1_regexp * inet_addr_regexp
	assert_match(ifconfig_regexp, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: /, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * hex_digit_lc, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * hex4_lc, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ip6_address, IFCONFIG.output)
	ip6_regexp = leading_whitespace * /inet6 addr: / * ip6_address
	matchData = IFCONFIG.output.match(ip6_regexp)
#	assert_equal('/64', matchData.post_match[0,3], matchData.inspect)
	assert_match(leading_whitespace * /inet6 addr: / * ip6_address * /\//, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ip6_address * /\/64 /, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / /, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / Scope/, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / Scope:/, IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / Scope:/ * (/Link|Global|Host/).capture(:scope), IFCONFIG.output)
	assert_match(leading_whitespace * /inet6 addr: / * ipv6_CIDR_regexp * / Scope:/ * (/Link|Global|Host/).capture(:scope) */\n/, IFCONFIG.output)
	assert_match(inet6_addr_regexp, IFCONFIG.output)
	assert_match(status_regexp, IFCONFIG.output)
	assert_match(rx_packets_regexp, IFCONFIG.output)
	assert_match(tx_regexp, IFCONFIG.output)

	ifconfig_regexp = inet6_addr_regexp
	assert_match(ifconfig_regexp, IFCONFIG.output)
	ifconfig_regexp *= status_regexp
	assert_match(ifconfig_regexp, IFCONFIG.output)

	assert_match(leading_whitespace * /collisions:/, IFCONFIG.output)
	assert_match(leading_whitespace * /collisions:/ * /[0-9]+/, IFCONFIG.output)
	assert_match(leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/, IFCONFIG.output)
	assert_match(leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/, IFCONFIG.output)
	assert_match(leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / /, IFCONFIG.output)
	assert_match(leading_whitespace * /collisions:/ * /[0-9]+/ * / txqueuelen:/ * /[0-9]+/ * / / */\n/, IFCONFIG.output)
	assert_match(congestion_regexp, IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/, IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/ * /[0-9]+/, IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ , IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/, IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/, IFCONFIG.output)
	assert_match(leading_whitespace * /RX bytes:/ * /[0-9]+/ * / \(/ * /[0-9]+\.[0-9]/ * / GiB\)  TX bytes:/ * /[0-9]+/, IFCONFIG.output)
	assert_match(rx_bytes_regexp, IFCONFIG.output)

	assert_match(inet6_addr_regexp * status_regexp, IFCONFIG.output)
	ifconfig_regexp *= rx_packets_regexp * tx_regexp
	assert_match(ifconfig_regexp, IFCONFIG.output)
	ifconfig_regexp *= congestion_regexp * rx_bytes_regexp


	assert_match(ifconfig_regexp, IFCONFIG.output)
	lines = IFCONFIG.output.parse(Capture::Examples::LINE)
	double_lines = IFCONFIG.output.split("\n\n")
	assert_instance_of(Array, double_lines)
	assert_operator(2, :<=, double_lines.size)
	assert_equal('eth0', double_lines[0].split(' ')[0])
	words=double_lines[0].parse(Capture::Examples::WORD)
	assert_equal({:word=>"eth0"}, words, words.inspect)
#	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
	puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
	words=double_lines.map do |row|
		words = row.parse(Capture::Examples::WORD)
		puts "words=#{words.inspect}, row=#{row.inspect}"
		assert_match(/eth0|lo|wlan0/, words[:word], "row=#{row.inspect}, words=#{words.inspect}")
	end #map
#	IFCONFIG.output.enumerate(:map) parse(Capture::Examples::LINE).map  do |row| 
#		row.parse(row, Capture::Examples::WORD)
#	end #map
#	assert_equal('', IFCONFIG.rows_and_columns)
#	assert_equal('eth0,', IFCONFIG.inspect)
#	assert_equal('', IFCONFIG.output)
end # ifconfig
def test_all
	all = ['192.168.0.1-254'].map do |nmapScan| #map
		Network.new(nmapScan)	
	end #map
	assert_equal(all, Network.all)
end #all
def test_whereAmI
	ifconfig= ShellCommands.new('/sbin/ifconfig|grep "inet addr" ').assert_post_conditions.output
	private_C = ifconfig.parse(Private_C)
	private_network = ifconfig.parse(Private_Network_Pattern)
	context = ifconfig.parse(Context_Pattern)
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
def test_initialize
end #initialize
def test_equals
end # equals
def test_nmap
	ip_regexp = /Nmap scan report for / * Private_Network_Pattern.capture(:ip) * /\n/
	latency_regexp = /[0-9]+\.[0-9]+/.capture(:latency)
	Network.all.map do |network|
		nmap = network.nmap('-sP')
		assert_match(ip_regexp, nmap.output)
		host_regexp = /Host is up \(/ 
		assert_match(host_regexp, nmap.output)
		host_regexp *= latency_regexp
		assert_match(host_regexp, nmap.output)
		host_regexp *= /s latency\)./
		assert_match(host_regexp, nmap.output)
		host_regexp *= /\n/
		assert_match(host_regexp, nmap.output)
		sp_regexp = ip_regexp * host_regexp
		assert_match(sp_regexp, nmap.output)
		parse = nmap.output.parse(sp_regexp)
		refute_nil(parse)
		refute_nil(parse[:ip])
		refute_nil(parse[:latency])
		assert_operator(parse[:latency].to_f, :>, 0.0)
	end # map
end # nmap
def test_update_attribute
#	assert_equal
	refute_empty()
end # update_attribute
end #Network

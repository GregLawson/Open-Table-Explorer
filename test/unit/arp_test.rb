require_relative 'test_environment'
require_relative '../../app/models/dhcp.rb'
class ArpTest < TestCase
def test_inialize
	command_string='cat /proc/net/arp'
	arp=ShellCommands.new(command_string)
	puts arp.inspect
	puts arp.errors
	assert_match(/DHCPACK/, arp.errors, "arp.errors=#{arp.errors}")
	assert_match(/DHCPACK from /, arp.errors)
	assert_match(/DHCPACK from ([0-9.]+)/, arp.errors)
	assert_match(/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, arp.errors)
	assert_match(/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, arp.errors)
	matchData=/Bound to ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(arp.errors)
	matchData=/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(arp.errors)
	if matchData.nil? then
		matchData=/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(arp.errors)
	end #if
	ip=matchData[1]
	assert_not_nil(ip)
end #initialize
def test_MAC(ip)
end #MACs
end #Arp

require_relative 'test_environment'
require_relative '../../app/models/router.rb'
class RouterTest < TestCase
require_relative '../../app/models/router.rb'
def test_dhclient
	command_string='/sbin/dhclient -v eth0'
	dhclient=ShellCommands.new(command_string)
	puts dhclient.inspect
	puts dhclient.errors
	assert_match(/DHCPACK/, dhclient.errors, "dhclient.errors=#{dhclient.errors}")
	assert_match(/DHCPACK from /, dhclient.errors)
	assert_match(/DHCPACK from ([0-9.]+)/, dhclient.errors)
	assert_match(/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, dhclient.errors)
	assert_match(/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, dhclient.errors)
	matchData=/Bound to ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(dhclient.errors)
	matchData=/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(dhclient.errors)
	if matchData.nil? then
		matchData=/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.match(dhclient.errors)
	end #if
	ip=matchData[1]
	assert_not_nil(ip)
end #dhclient
end #RouterTest

require_relative 'no_db.rb'
require_relative '../../app/models/shell_command.rb'
class DHCP <ShellCommands
def initialize
	super('/sbin/dhclient -v eth0')
end #initialize
def parse(regexp, acquisition=@output)
	matchData=regexp.match(acquisition)
	if matchData.nil? then
		nil
	else
		matchData[0]
	end #if
end #parse
def offer
	parse(/Bound to ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, @errors)
end #offer
def router
	parse(/DHCPACK from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/, @errors)
end #router
end #DHCP
class Arp < ShellCommands
def initialize
	super('cat /proc/net/arp')
end #initialize
def MAC(ip)
	parse(/#{ip} ([0-9A-F]+\:[0-9A-F]+\:[0-9A-F]+\:[0-9A-F]+)/, @errors)
end #MACs
end #Arp
class Router < ActiveRecord::Base
belongs_to :hosts
end

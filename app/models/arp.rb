require_relative 'no_db.rb'
require_relative '../../app/models/shell_command.rb'
class Arp < ShellCommands
module Constants
HEADER_Pattern=//
Data_Pattern=//
end #Constants
def initialize
	super('cat /proc/net/arp')
end #initialize
def MAC(ip)
	parse(/#{ip} ([0-9A-F]+\:[0-9A-F]+\:[0-9A-F]+\:[0-9A-F]+)/, @errors)
end #MACs
end #Arp

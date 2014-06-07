###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
class Network < ActiveRecord::Base
#include Generic_Table
module Constants
IFCONFIG=ShellCommands.new('/sbin/ifconfig')

Quad_Pattern = /[0-2]?[0-9]?[09]/
Private_A = /10\./.capture(:network) * (Quad_Pattern * Quad_Pattern * Quad_Pattern).capture(:host)
B_Quad2 = /16/ | /17/ | /18/ | /19/ | /20/ | /21/ | /22/ | /23/ | /24/ | /25/ | /26/ | /27/ | /28/ | /29/ | /30/ | /31/
Private_B = (/172\./ * B_Quad2).capture(:network) * (Quad_Pattern * Quad_Pattern).capture(:host)
Private_C = /192\.168\./.capture(:network) * (Quad_Pattern * Quad_Pattern).capture(:host)
Zero_Config_Pattern = /169\.254./.capture(:network)
Private_Network_Pattern = Private_A | Private_B | Private_C | Zero_Config_Pattern

Context_Pattern = [/\s*inet addr:/,/[0-9]*\.[0-9]*\./]
Network_Pattern =/[0-9]+\./
Node_Pattern = /[0-9]+/
IP_Pattern = [Context_Pattern, Network_Pattern, Node_Pattern]
Netmask_Pattern = /.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/
end #Constants
include Constants
module ClassMethods
def whereAmI
	ifconfig=`/sbin/ifconfig|grep "inet addr" `
	#puts ifconfig
	s = StringScanner.new(ifconfig)
	@myContext=s.after(/\s*inet addr:/,/[0-9]*\.[0-9]*\./)
	@myNetwork=s.scan(/[0-9]+\./)
	@myNode=s.scan(/[0-9]+/)
	#puts "@myContext=#{@myContext}"
	#puts "@myNetwork=#{@myNetwork}"
	#puts "@myNode=#{@myNode}"
	@myIP="#{@myContext}#{@myNetwork}#{@myNode}"
	#puts "@myIP=#{@myIP}"
	#ip=IPAddr.new(@myIP)
	#puts "ip=#{ip}"
	@myNetmask=s.after(/.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
	#puts "@myNetmask=#{@myNetmask}"
	#ip=ip.mask(@myNetmask)
	#puts "ip=#{ip}"
	#puts "masklen(\"cidr #{@myNetmask}\")"
	#@hosts=Hosts.new
	Hosts.recordDetection(@myIP)
	@nmapScan="#{@myContext}#{@myNetwork}1-254"
	network=find_or_initialize_by_nmap_addresses(@nmapScan)
	network.update_attribute('nmap_addresses',@nmapScan)
	network.dumpAcquisitions if $DEBUG
	network.save
end #whereAmI
def acquire
	whereAmI
# now do incremental ping and nmapScan
	Global::log.debug("networks before find @row=#{@row}")
	network=Networks.first(:order => 'last_scan ASC')
	puts "nmap_addresses=#{network.nmap_addresses}"  if $VERBOSE
	Networks.ping(network.nmap_addresses)
	host=Hosts.first(:order => 'last_detection ASC')
	Hosts.nmapScan(host.ip)
end
def ping(nmapScan)
	network=Networks.find_or_initialize_by_nmap_addresses(nmapScan)
	puts "nmap -sP #{nmapScan}"     #if $VERBOSE
	@pingNmap=`nmap -sP #{nmapScan}`
	Global::log.debug("@pingNmap=#{@pingNmap}")
	network.update_attribute('last_scan',Time.new)
	network.save
	@pingNmap.each_line do |r|
		Global::log.debug("Line: '#{r}'")
		s = VerboseStringScanner.new(r)
		if s.scan(/Host /) then
			matchData=/[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}\.[0-9.]{1,3}/.match(r)
			candidateIP= matchData[0]
			Hosts.recordDetection(candidateIP)
			Global::log.debug("candidateIP=#{candidateIP}")
		elsif  s.scan(/Nmap done:/)
			up,nmap_execution_time=Hosts.scanNmapSummary(s)
			network.update_attribute('nmap_execution_time', nmap_execution_time)
			puts "nmap_execution_time=#{nmap_execution_time}" #if $VERBOSE
		elsif s.scan(/^\s*$|Starting Nmap/)   then
			# ignore line
		else
			puts "Line not decoded: '#{r}'"
		end
	end
	#network.dumpAcquisitions if $VERBOSE
	network.inspect if $VERBOSE
	network.save
end
end #ClassMethods
extend ClassMethods
include Constants
# attr_reader
def initialize
	super('Networks')
end #initialize
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #Network

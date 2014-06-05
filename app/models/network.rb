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
module ClassMethods
def whereAmI
	ifconfig=`/sbin/ifconfig|grep "inet addr" `
	#puts ifconfig
	s = StringScanner.new(ifconfig)
	@myContext=s.rest(/\s*inet addr:/,/[0-9]*\.[0-9]*\./)
	@myNetwork=s.scan(/[0-9]+\./)
	@myNode=s.scan(/[0-9]+/)
	#puts "@myContext=#{@myContext}"
	#puts "@myNetwork=#{@myNetwork}"
	#puts "@myNode=#{@myNode}"
	@myIP="#{@myContext}#{@myNetwork}#{@myNode}"
	#puts "@myIP=#{@myIP}"
	#ip=IPAddr.new(@myIP)
	#puts "ip=#{ip}"
	@myNetmask=s.rest(/.*\sMask:/,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
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
module Constants
IFCONFIG=ShellCommands.new('/sbin/ifconfig')
end #Constants
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

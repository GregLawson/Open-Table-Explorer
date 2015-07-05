###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
#require_relative '../../app/models/generic_table.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require 'multi_xml'
class Host # < ActiveRecord::Base
include Virtus.model
  attribute :ip, String, :default => nil
  attribute :nmap, String, :default => ''
  attribute :otherPorts, Fixnum, :default => nil
  attribute :otherState, String, :default => nil
  attribute :mac, String, :default => nil # 
  attribute :nicVendor, String, :default => nil
  attribute :name, String, :default => nil
  attribute :last_detection, Time, :default => Time.now
  attribute :nmap_execution_time, Time, :default => nil
module Constants # first of two
Start_line = /Starting Nmap|Interesting ports|PORT|^$|Note: Host seems down/
Nmap_xml_pathname = Unit.new_from_path?($0).data_sources_directory? + '/nmap.xml'
end # Constants
include Constants
#has_many :ports
#has_many :routers
module ClassMethods
include Constants
def nmap(ip_range, options = '-oX ' + Nmap_xml_pathname)
	ShellCommands.new(nmap_command_string(ip_range, options))
end # nmap
def nmap_command_string(ip_range, options = '-oX ' + Nmap_xml_pathname)
	'nmap ' + options + ' ' + ip_range
end # nmap_command_string
def nmap_xml_command_string(ip_range, xml_pathname = Nmap_xml_pathname)
	nmap_command_string(ip_range, '-oX ' + Nmap_xml_pathname)
end # nmap_xml_command_string
def nmap_xml(ip_range, xml_pathname = Nmap_xml_pathname, parser = :nokogiri)
	nmap(ip_range, options = '-oX ' + xml_pathname)
	parse_xml_file(filename = xml_pathname, parser = :nokogiri)
end # nmap_xml
def parse_xml(string = '<tag>This is the contents</tag>', parser)
	MultiXml.parser = parser
	MultiXml.parser = eval('MultiXml::Parsers::' + parser[0..0].upcase + parser[1..-1])  # Same as above
	MultiXml.parse(string)
end # parse_xml_file
def parse_xml_file(filename = Nmap_xml_pathname, parser = :nokogiri)
	parse_xml(IO.read(filename), parser)
end # parse_xml_file
def logical_primary_key
	return [:name]
end #logical_primary_key
def Column_Definitions
	return [['ip','inet'],
	['nmap','text'],
	['otherPorts','integer'], 
	['otherState','VARCHAR(255)'], 
	['mac','text'], 
	['nicVendor','text'], 
	['name','VARCHAR(255)'], 
	['last_detection','timestamp with time zone'], 
	['nmap_execution_time','real']
	]
end # Column_Definitions
def recordDetection(ip,timestamp=Time.new)
	host=find_or_initialize_by_ip(ip)
	host.last_detection=timestamp
	host.save
end
def smbs
	
end # smbs
end # ClassMethods
extend ClassMethods
module Constants
Eth0_ip = '192.168.5.100'
My_host_nmap_parsed_xml = Host.nmap_xml(Eth0_ip)
My_host_nmap_simplified_xml = My_host_nmap_parsed_xml["nmaprun"]
Eth0_network = '192.168.5.1-254'
#Eth0_network_nmap_xml = Host.nmap_xml(Eth0_network)
end # Constants
include Constants
def save
	to_json
end # save
def nmapScan(candidateIP)
	host=find_or_initialize_by_ip(candidateIP)
	cmd= "nmap  #{candidateIP}"
	puts cmd if $VERBOSE
	nmap=`#{cmd}`
	puts "nmap=#{nmap}" if $DEBUG
	nmap.strip!
	nmap.each_line do |l|
		s = VerboseStringScanner.new(l)
		if s.scan(/Starting Nmap|Interesting ports|PORT|^$|Note: Host seems down/) then
			puts "skipping line=#{l}"    if $DEBUG
		elsif s.scan(/Not shown: /) then
			host.update_attribute('otherPorts', s.scan(/[0-9]+/))
			s.scan(/\s/)
			host.update_attribute('otherState', s.scan(/[a-z]+/))
		elsif s.scan(/MAC Address:\s*/) then
			puts "l=#{l}" if $VERBOSE
			mac= s.scan(/[0-9a-fA-F:]{17}/)
			host.update_attribute('mac', s.scan(/[0-9a-fA-F:]{17}/))
			puts "no spaces after MAC address in #{l}" if s.scan(/\s*/)
			nicVendor=s.scan(/\([a-zA-Z \-0-9]+\)/)
			#puts "nicVendor=#{nicVendor}"
			#puts "nicVendor[1,nicVendor.length-2]=#{nicVendor[1,nicVendor.length-2]}"
			host.update_attribute('nicVendor',  nicVendor[1,nicVendor.length-2])
		elsif s.scan(/All /) then
			host.update_attribute('otherPorts', s.scan(/[0-9]+/))
			s.scan(/\s/)
			host.update_attribute('otherState', s.scan(/[a-z]+/))
		elsif port= s.scan(/[0-9]+/) then
			@ports=find_or_initialize_by_ip_and_port(candidateIP,port)
			@ports.update_attribute('ip', candidateIP)
			@ports.update_attribute('port', port)
			s.scan(/\//)
			@ports.update_attribute('protocol', s.scan(/[tu][cd]p/))
			s.scan(/\s+open\s+/)
			@ports.update_attribute('portName', s.scan(/[a-zA-Z]+/))
			#@ports.sqlValues=@ports.hash2values(@data)
			@ports.save
		elsif s.scan(/Nmap done:/)
			up,nmap_execution_time=scanNmapSummary(s)
			if up>'0'
				puts "after if up=#{up}" if $VERBOSE
				host.update_attribute('last_detection', Time.new)
			end
			host.update_attribute('nmap_execution_time', nmap_execution_time)			
		else
			puts "Line not decoded: '#{l}'"
		end
	end
	host.update_attribute('nmap', nmap)
#	update_attribute('last_detection', Time.new)
	host.save
	#@ports.dumpAcquisitions
	#sqlValues=hash2values(@data)
	#dumpHash
	#dumpAcquisitions
end # nmapScan
def scanNmapSummary(s)
	puts "s.rest=#{s.rest}" if $VERBOSE
	plural=  s.rest(/.*IP address/,/e?s? /)
	up=s.rest(/\(/,/[0-9.]+/)
	puts "up=#{up}" if $VERBOSE
	nmap_execution_time= s.rest(/ hosts? up\) scanned in /,/[0-9.]+/)
	puts "nmap_execution_time=#{nmap_execution_time}" if $DEBUG
	return [up,nmap_execution_time]
end
# attr_reader
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
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end # Examples
end #Host

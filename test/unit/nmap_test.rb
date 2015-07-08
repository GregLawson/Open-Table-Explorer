###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nmap.rb'
# executed in alphabetical order. Longer names sort later.
class NmapTest < TestCase
#include DefaultTests
include TE.model_class?::Examples
def test_Constants

MultiXml.parser = :ox
MultiXml.parser = MultiXml::Parsers::Ox # Same as above
MultiXml.parse('<tag>This is the contents</tag>') # Parsed using Ox

MultiXml.parser = :libxml
MultiXml.parser = MultiXml::Parsers::Libxml # Same as above
MultiXml.parse('<tag>This is the contents</tag>') # Parsed using LibXML

MultiXml.parser = :nokogiri
MultiXml.parser = MultiXml::Parsers::Nokogiri # Same as above
MultiXml.parse('<tag>This is the contents</tag>') # Parsed using Nokogiri

MultiXml.parser = :rexml
MultiXml.parser = MultiXml::Parsers::Rexml # Same as above
MultiXml.parse('<tag>This is the contents</tag>') # Parsed using REXML

#MultiXml.parser = :oga
#MultiXml.parser = MultiXml::Parsers::Oga # Same as above
#MultiXml.parse('<tag>This is the contents</tag>') # Parsed using Oga
end # Constants
def test_nmap
	ip_range = Eth0_ip
	nmap_run = ShellCommands.new('nmap ' + ip_range).assert_post_conditions
	capture = nmap_run.output.capture?(Start_line)
	nmap_hash = nmap_run.output.parse(Start_line)
end # nmap
def test_nmap_xml
	xml_run = Nmap.nmap(Eth0_ip)
	xml_run.assert_post_conditions
end # nmap_xml
def test_parse_xml
	string = '<tag>This is the contents</tag>'
	parser = :nokogiri
end # parse_xml_file
def test_parse_xml_file
#	filename = 
	assert_instance_of(Hash, My_host_nmap_parsed_xml)
	assert_equal(["nmaprun"], My_host_nmap_parsed_xml.keys)
	assert_equal("1.04", My_host_nmap_simplified_xml["xmloutputversion"])
	assert_equal("6.00", My_host_nmap_simplified_xml["version"])
	assert_equal(Nmap.nmap_command_string(Eth0_ip), My_host_nmap_simplified_xml["args"])
end # parse_xml_file
def test_recordDetection
	ip = '192.168.0.'
	timestamp=Time.new
end
def test_smbs
	Nmap.assert_xml(My_host_nmap_parsed_xml)
	Nmap.assert_xml(Eth0_network_nmap_xml)
end # smbs
def test_save
	assert_equal("\"6.00\"", My_host_nmap_simplified_xml["version"].to_json)
#	assert_equal('\"' + Nmap.nmap_command_string(Eth0_ip) + '\"', My_host_nmap_simplified_xml["args"].to_json)
	assert_equal("\"1.04\"", My_host_nmap_simplified_xml["xmloutputversion"].to_json)
#	assert_equal('', My_host_nmap_parsed_xml.to_json)
end # save
def test_nmapScan
	candidateIP = Eth0_network
end # nmapScan
def test_assert_xml
	assert_equal(["scaninfo",  "verbose",  "debugging",  "host",  "runstats",  "scanner",  "args",
		"start",  "startstr",  "version",  "xmloutputversion"], My_host_nmap_parsed_xml["nmaprun"].keys)
	assert_equal(["type", "protocol", "numservices", "services"], My_host_nmap_simplified_xml["scaninfo"].keys)
	assert_equal(["scaninfo",  "verbose",  "debugging",  "host",  "runstats",  "scanner",  "args",
		"start",  "startstr",  "version",  "xmloutputversion"], My_host_nmap_parsed_xml["nmaprun"].keys)
	assert_equal(["scaninfo",  "verbose",  "debugging",  "runstats",  "scanner",  "args",
		"start",  "startstr",  "version",  "xmloutputversion"], Failed_nmap_xml["nmaprun"].keys, Failed_nmap_xml.inspect)
	Eth0_network_nmap_xml["nmaprun"]["host"].enumerate(:each) do |host|
		message = "host = " + host.inspect
		assert_equal(["status", "address", "hostnames", "ports", "times", "starttime", "endtime"], host.keys, message.inspect)
	end # enumerate
	assert_equal(["addr", "addrtype"], My_host_nmap_simplified_xml["host"]["address"].keys)
	assert_equal(["extraports", "port"], My_host_nmap_simplified_xml["host"]["ports"].keys)
	assert_equal([0, 1, 2, 3, 4], My_host_nmap_simplified_xml["host"]["ports"]["port"].keys)
	My_host_nmap_simplified_xml["host"]["ports"]["port"].each_with_index do |port, index|
		assert_instance_of(Fixnum, index)
		assert_instance_of(Hash, port)
		assert_equal(["state", "service", "protocol", "portid"], port.keys)
		assert_equal(["name", "method", "conf"], port["service"].keys)
#		assert_includes(["ssh", "rpcbind",  "netbios-ssn", "microsoft-ds", "samba-swat"], port["service"]["name"])
	end # each
	Nmap.assert_xml(My_host_nmap_parsed_xml)
	address = My_host_nmap_parsed_xml["nmaprun"]["host"]["address"]["addr"]
	assert_equal(Eth0_ip, address)
	addresses = Eth0_network_nmap_xml["nmaprun"]["host"]
	message = addresses.inspect
	message += "\n" + Eth0_network_nmap_xml["nmaprun"].inspect
	assert_includes(addresses, Eth0_ip)
	assert_operator(addresses.size, :==, 1, message)
	Nmap.assert_xml(My_host_nmap_parsed_xml)
	Nmap.assert_xml(Eth0_network_nmap_xml)
end # xml
end # Nmap

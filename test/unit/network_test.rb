###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/network.rb'
require_relative '../../app/models/parse.rb'
class NetworkTest < TestCase
#include DefaultTests
include TE.model_class?::Examples
def test_whereAmI
	ifconfig= ShellCommands.new('/sbin/ifconfig|grep "inet addr" ').assert_post_conditions.output
	private_C = ifconfig.parse(Private_C)
	private_network = ifconfig.parse(Private_Network_Pattern)
	context = ifconfig.parse(Context_Pattern)
	captures = ifconfig.capture?(IP_Pattern)
	ip = ifconfig.parse(IP_Pattern)
	netmask = ifconfig.parse(Netmask_Pattern)
#	acquire=StreamPattern.find_by_name('Acquisition')
#	assert_not_nil(acquire, "StreamPattern=#{StreamPattern.all.map{|p| p.name}.inspect}")
#	ifconfig=StreamMethod.find_by_name('Shell')
#	assert_not_nil(ifconfig, "StreamMethod=#{StreamMethod.all.inspect}")
#	explain_assert_respond_to(ifconfig, :compile_code)
#	explain_assert_respond_to(ifconfig, :fire)
	Network.whereAmI
end #whereAmI
def test_NetworkInterface
	lines=Parse.parse_into_array(IFCONFIG.output, Parse::Examples::LINE)
	double_lines=IFCONFIG.output.split("\n\n")
	assert_instance_of(Array, double_lines)
	assert_operator(2, :<=, double_lines.size)
	assert_equal('eth0', double_lines[0].split(' ')[0])
	words=Parse.parse_into_array(double_lines[0], Parse::Examples::WORD)
	assert_equal({:word=>"eth0"}, words[0])
#	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
	puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
	words=double_lines.map do |row|
		words=Parse.parse_into_array(row, Parse::Examples::WORD)
		puts "words=#{words.inspect}, row=#{row.inspect}"
		assert_match(words[0], /eth0|lo|wlan0/, "row=#{row.inspect}, words=#{words.inspect}")
	end #map
	Parse.parse_into_array(IFCONFIG.output, Parse::Examples::LINES).map  do |row| 
		Parse.parse_into_array(row, Parse::Examples::WORD)
	end #map
#	assert_equal('', IFCONFIG.rows_and_columns)
#	assert_equal('eth0,', IFCONFIG.inspect)
#	assert_equal('', IFCONFIG.output)
end #NetworkInterface
end #Network

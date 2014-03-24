###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/network.rb'
class NetworkTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_whereAmI
	acquire=StreamPattern.find_by_name('Acquisition')
	assert_not_nil(acquire, "StreamPattern=#{StreamPattern.all.map{|p| p.name}.inspect}")
	ifconfig=StreamMethod.find_by_name('Shell')
	assert_not_nil(ifconfig, "StreamMethod=#{StreamMethod.all.inspect}")
	explain_assert_respond_to(ifconfig, :compile_code)
	explain_assert_respond_to(ifconfig, :fire)
	Network.whereAmI
end #whereAmI
def test_NetworkInterface
	lines=parse(NetworkInterface::IFCONFIG.output, LINES)
	double_lines=NetworkInterface::IFCONFIG.output.split("\n\n")
	assert_instance_of(Array, double_lines)
	assert_operator(2, :<=, double_lines.size)
	assert_equal('eth0', double_lines[0].split(' ')[0])
	words=parse(double_lines[0], WORDS)
	assert_equal('eth0', words[0])
#	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
	puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
	words=double_lines.map do |row|
		words=parse(row, WORDS)
		puts "words=#{words.inspect}, row=#{row.inspect}"
		assert_match(words[0], /eth0|lo|wlan0/, "row=#{row.inspect}, words=#{words.inspect}")
	end #map
	parse(NetworkInterface::IFCONFIG.output, LINES).map  do |row| 
		parse(row, WORDS)
	end #map
#	assert_equal('', NetworkInterface::IFCONFIG.rows_and_columns)
#	assert_equal('eth0,', NetworkInterface::IFCONFIG.inspect)
#	assert_equal('', NetworkInterface::IFCONFIG.output)
end #NetworkInterface
end #Network

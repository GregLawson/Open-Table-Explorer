###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
require_relative '../../app/models/iwup.rb'
class IwTest < TestCase
include Iw::Examples
def test_scan
	refute_equal(0, Iw.scan.output.size)
end # scan
def test_Examples
	assert(Iw_list.success?, Iw_list.inspect)
	assert(Scan.success?, Scan.inspect)
	assert(Iwconfig.success?, Iwconfig.inspect)
	assert(Scan_dump.success?, Scan_dump.inspect)
	assert(Link_string.success?, Link_string.inspect)
end # Examples
#		puts ShellCommands.new("sudo /sbin/iwconfig wlan0 essid \"#{ESSID}").inspect
def test_authentication
 link_array = Link_string.output.split("\n")
 authentication=link_array[0]
 connection=link_array[1]
 puts "authentication=#{authentication}"
 authenicated_MAC=authentication.split(" ")[2]
 puts "authenicated_MAC=#{authenicated_MAC}"
 
 puts "connection=#{connection}"
if connection=='Not connected.' then
end #if
end # authentication
end # Iw

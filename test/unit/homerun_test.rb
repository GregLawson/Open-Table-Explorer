###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
require_relative '../../app/models/homerun.rb'
class HomeRunTest  < TestCase
include HomeRun::Examples
def test_initialize
	Default_hdhr.assert_post_conditions
end #initialize
def test_scan
	scan=Default_hdhr.scan
	assert_match(Scan_error|Scan_error_pass, scan.errors, "scan=#{scan.inspect}")
end
def test_Constants
	Discover.execute
	assert_operator(0, :<, Discover.output.size, "Discover=#{Discover.inspect}")
	assert_match(Discover_error|/^hdhomerun device /, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Id_pattern, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Ip_pattern0, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Ip_pattern1, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Ip_pattern2, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Ip_pattern3, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Ip_pattern, Discover.output, "Discover=#{Discover.inspect}")
	assert_match(Discover_error|Discover_parse, Discover.output, "Discover=#{Discover.inspect}")
end #Constants

end #HomeRun
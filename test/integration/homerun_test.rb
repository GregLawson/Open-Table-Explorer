###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
require_relative '../../app/models/homerun.rb'
class HomeRunIntegrationTest  < TestCase
include HomeRun::Examples
def test_integration
	Discover.execute
	assert_match(/^hdhomerun device /, Discover.output, "Discover=#{Discover.inspect}")
	assert_equal('hdhomerun device 10311E80 found at 172.31.42.101\n', Discover.output)
#special case	assert_not_empty(scan.output, "scan=#{scan.inspect}")
end #test_integration

end #HomeRun
###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/udev.rb'
class UdevTest < TestCase
include Udev::Examples
def test_Constants
	Lib_udev.execute.assert_post_conditions
	assert_equal('hdhomerun device 10311E80 found at 172.31.42.101', Lib_udev.output)
	Etc_udev.execute.assert_post_conditions
	assert_equal('hdhomerun device 10311E80 found at 172.31.42.101', Etc_udev.output)
end #Constants
end #Udev

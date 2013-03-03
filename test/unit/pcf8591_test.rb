###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/pcf8591.rb'
class PCF8591Test < DefaultTestCase2
include DefaultTests2
def test_initialize
	assert_not_nil(PCF8591.new)
end #initialize
def test_command_string
	assert_equal('', [].join(' '))
	assert_equal('', [].map{|a| a.to_s}.join(' '))
	assert_equal("sudo i2cget -y 1 0x48", PCF8591.new.command_string)
end #command_string
end #PCF8591

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
include PCF8591::Examples
include PCF8591::Constants
def test_initialize
	assert_not_nil(PCF8591.new)
end #initialize
def test_command_string
	assert_equal('', [].join(' '))
	assert_equal('', [].map{|a| a.to_s}.join(' '))
	assert_equal("sudo i2cget -y 1 0x48", PCF8591.new.command_string)
end #command_string
def test_select_channel_string
	assert_equal('sudo i2cset -y 1 0x48 0x44', YL_40.select_channel_string)
end #select_channel_string
def test_get_value_string
	assert_equal('sudo i2cget -y 1 0x48', YL_40.get_value_string)
end #get_value_string
def test_adc_read
	analog=1
	burst_length=512
	miniboard=PCF8591.new
	miniboard.assert_range(0+CB::Analog_output_enable, burst_length, 143, 227, 8)	
	miniboard.assert_range(1+CB::Analog_output_enable, burst_length, 216, 220, 2)
	miniboard.assert_disconnected(2+CB::Analog_output_enable, burst_length)	
	miniboard.assert_constant(3+CB::Analog_output_enable, burst_length)

	miniboard.assert_constant(3, burst_length)
	miniboard.assert_range(1, burst_length, 216, 219, 2)	
	miniboard.assert_range(0, burst_length, 143, 225, 8)	
	miniboard.assert_disconnected(2, burst_length)	
	miniboard.assert_constant(1, 7, 0)	
	miniboard.assert_constant(3, 7)	
	miniboard.assert_range(2, 64, 0, 81)	
end #adc_read
end #PCF8591

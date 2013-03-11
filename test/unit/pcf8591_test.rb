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
	miniboard=PCF8591.new
	miniboard.assert_range(1+CB::Analog_output_enable, BURST_LENGTH, 216, 220, 2)
	miniboard.assert_range(1, BURST_LENGTH, 216, 220, 2)	
end #adc_read
end #PCF8591
class YL_40_OnboardTest <TestCase
#include DefaultTests1
include PCF8591::Examples
include PCF8591::Constants
#include DefaultTests2
# disconnected not connected, no jumper for AIN0
def test_disconnected
	YL_40.assert_disconnected(2+CB::Analog_output_enable, BURST_LENGTH)	
	YL_40.assert_disconnected(2, BURST_LENGTH)	
end #test_disconnected
# thermistor R6 connected via jumper P4 to AIN1
def test_thermistor
	YL_40.assert_range(1+CB::Analog_output_enable, BURST_LENGTH, 216, 220, 2)
	YL_40.assert_range(1, BURST_LENGTH, 216, 220, 2)	
end #test_thermistor
# light sensor (CDS) R7 connected via jumper P5 to AIN2
def test_CDS
	YL_40.assert_range(0+CB::Analog_output_enable, BURST_LENGTH, 143, 227, 8)	
	YL_40.assert_range(0, BURST_LENGTH, 143, 227, 8)	
end #CDS
# potentiometer R3 connected via jumper P6 to ANI3
def test_potentiometer
	YL_40.assert_constant(3+CB::Analog_output_enable, BURST_LENGTH)
	YL_40.assert_constant(3, BURST_LENGTH)
end #test_potentiometer
end #YL_40_OnboardTest
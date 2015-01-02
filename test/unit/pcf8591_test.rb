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
def test_dac_set_value_string
	assert_equal('sudo i2cset -y 1 0x48 0x41 0x0', YL_40.dac_set_value_string)
end #dac_set_value_string

def test_adc_read
	analog=1
	miniboard=PCF8591.new
	miniboard.assert_range(1+CB::Analog_output_enable, BURST_LENGTH, 216, 220, 2)
	miniboard.assert_range(1, BURST_LENGTH, 216, 220, 2)	
	i=0
	3.times do
		i=i+1
		print i.to_s+" "+miniboard.adc_read(0+CB::Analog_output_enable,1).to_s
		print " "+miniboard.adc_read(1+CB::Analog_output_enable,1).to_s
		print " "+miniboard.adc_read(2+CB::Analog_output_enable,1).to_s
		puts " "+miniboard.adc_read(3+CB::Analog_output_enable,1).to_s
	puts miniboard.adc_read(Default_control_byte,4).join(' ')
	end #loop
end #adc_read
end #PCF8591

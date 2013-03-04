###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class PCF8591
module Constants
module CB
	# 0-3 analog channels
	Auto_increment=0x04
	# single ended or differntial 
	All_single_ended=0x00
	Differntial_from_3=0x10
	Single_single_diff=0x20
	Differential_pairs=0x30
	#
	Analog_output_enable=0x40 # stabilizes internal oscillator
end #CB
	CB_Mask=0x77 # zeros in reserved bits
	Default_control_byte=CB::Auto_increment|CB::All_single_ended|CB::Analog_output_enable
end #Constants
include Constants
def initialize(bus=1, address=0x48)
	@bus=bus.to_s
	@address='0x'+address.to_s(16)
	@last_value=[] # detect disconnected lines and power on
	@last_control_byte=nil
end #initialize
def command_string(command=:get, *args)
#	puts "in command_string, args="+args.inspect
	command_start="sudo i2c#{command.to_s} -y #{@bus} #{@address}"
	([command_start]+args).map{|a| a.to_s}.join(' ')
end #command_string
def select_channel_string(control_byte=Default_control_byte)
	command_string(:set, '0x'+control_byte.to_s(16)) # set control_byte
end #select_channel_string
def get_value_string
	command_string(:get)
end #get_value_string
def control_byte(channel, output_enable, differential)
end #control_byte
def adc_read(control_byte=Default_control_byte, burst_length=1)
	if @last_control_byte!=control_byte then
		sysout=`#{select_channel_string(control_byte)}` # set control_byte
		@last_control_byte=control_byte
	end #if
#	puts "select_channel_string="+select_channel_string(control_byte) # set control_byte
	@discard=`#{get_value_string}`.chomp.hex #clear latched value
#	puts "discard=", @discard
	ret=Array.new(burst_length) do |index| 
		sysout=`#{get_value_string}`
#		puts "get_value_string="+get_value_string
#		puts sysout
		sysout.chomp.hex
	end #Array.new
	sysout=`#{select_channel_string(control_byte&~CB::Analog_output_enable)}` # set control_byte
	@last_value[control_byte]=ret[-1]
	return ret
end #adc_read
require_relative '../../test/assertions/default_assertions.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
module Assertions
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include Constants
def assert_pre_conditions
	assert_instance_of(Class, self)
end #assert_pre_conditions
def assert_constant(control_byte=Default_control_byte, samples=64, expected_value=nil)
	scan=adc_read(control_byte, samples)
	if (control_byte&CB::Analog_output_enable)==CB::Analog_output_enable then
		scan=scan.drop_while {|e| e==@discard}
	end #if
	unique_values=scan.uniq
	assert_equal(1, unique_values.size,message)
	if !expected_value.nil? then
		assert_equal(expected_value, unique_values[0], message)
	end #if
end #assert_constant
def assert_range(control_byte=Default_control_byte, samples=64, min=0, max=255, max_range=nil)
	scan=adc_read(control_byte, samples)
	message="\ncontrol_byte=#{control_byte}\n#{self.inspect} #{scan.inspect}\ndecay=#{@discard.to_f/scan[0].to_f}\n#{caller_lines}"
	if (control_byte&CB::Analog_output_enable)==CB::Analog_output_enable then
		scan=scan.drop_while {|e| e==@discard}
	end #if
	assert_operator(min, :<=, scan.min, message)
	assert_operator(max, :>=, scan.max, message)
	if !max_range.nil? then
		assert_operator(max_range, :>=, scan.max-scan.min, message)
	end #if
end #assert_range
def assert_disconnected(control_byte=Default_control_byte, samples=64)
	scan=adc_read(control_byte, samples)
	message="\ncontrol_byte=#{control_byte}\n#{self.inspect} #{scan.inspect}\ndecay=#{@discard.to_f/scan[0].to_f}\n#{caller_lines}"
	if (control_byte&CB::Analog_output_enable)==CB::Analog_output_enable then
		scan=scan.drop_while {|e| e==@discard}
	end #if
	assert_operator(@discard/4.0, :<=, scan[0], "under "+message)
	assert_operator(@discard/2.0, :>=, scan[0], "over "+message)
	scan[1..-1].each do |value|
		assert_operator(value, :<=, 1, message)
	end #each
end #assert_disconnected
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
	YL_40=PCF8591.new(1, 0x48) # all address bits tied low
	BURST_LENGTH=64
end #Examples
end #PCF8591


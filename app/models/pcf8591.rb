###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class PCF8591
def initialize(bus=1, address=0x48)
	@bus=bus.to_s
	@address='0x'+address.to_s(16)
end #initialize
def command_string(command=:get, *args)
	puts "in command_string, args="+args.inspect
	command_start="sudo i2c#{command.to_s} -y #{@bus} #{@address}"
	([command_start]+args).map{|a| a.to_s}.join(' ')
end #command_string
def adc_start(analog=1)
	sysout=command_string(:get, analog)
end
module Assertions
def assert_pre_conditions
	assert_instance_of(Class, self)
end #assert_pre_conditions
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
end #PCF8591


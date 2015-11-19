###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
class Xrandr
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
Device_pattern = /[A-Z]+/.capture(:class) * /[0-9]+/.capture(:sequence)
Status_pattern = //
end #Constants
include Constants
attr_reader :display
def initialize(display)
	parameters = Parse.parse_string(display.to_s, Device_pattern)
	@display = parameters[:display]
	@sequence = parameters[:sequence]
end #initialize
def display
	@display.to_s + @sequence.to_s
end # display
def on
	ShellCommands.new('xrandr ' + display + ' on')
end # on
def status
	run = ShellCommands.new('xrandr ' + display)
	Parse.parse_string(run.output, Status_pattern)
end # status
#require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end # Xrandr

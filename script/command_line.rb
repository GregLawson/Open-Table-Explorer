#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/command_line.rb'
require_relative '../app/models/test_executable.rb'
scripting_executable = TestExecutable.new_from_path($0)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
script_class = Unit::Executing_Unit.model_class?
script = CommandLine.new($0)
puts 'ARGV = ' + ARGV.inspect if $VERBOSE
puts 'Sub_command = ' + CommandLine::Sub_command.inspect if $VERBOSE
if !CommandLine::Arguments.nil? then
	puts 'Arguments = ' + CommandLine::Constants::Arguments.inspect if $VERBOSE
	puts 'Argument_types = ' + CommandLine::Constants::Argument_types.inspect if $VERBOSE
end # if
run = script.run do
end # do run
puts "run returns "+ run.inspect
1 # successfully completed

#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/script_environment_no_assertions.rb'
require_relative '../app/models/unit.rb' # before command_line
# require_relative "../app/models/#{RailsishRubyUnit::Executable.model_basename}"
require_relative '../app/models/command_line_executable.rb'
script_command_line = CommandLineExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
executable_class = RailsishRubyUnit::Executable.model_class?
object_arguments = script_command_line.arguments[1]
sub_command = CommandLineExecutable::Script_command_line.sub_command
puts 'sub_command = ' + sub_command.inspect if $VERBOSE
executable_object = executable_class.new(TestExecutable.new_from_path(object_arguments))
sub_command_method = executable_object.method(sub_command)

ret = CommandLineExecutable::Script_command_line.run(sub_command_method) do
end # do run
puts 'ret = ' + ret.inspect unless $VERBOSE.nil?
1 # successfully completed

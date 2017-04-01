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
require_relative '../app/models/command_line_sub_executable.rb'
class CommandLine # < Command
end # CommandLine
script_command_line = CommandLineExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
executable_class = RailsishRubyUnit::Executable.model_class?
object_arguments = script_command_line.arguments[1]
sub_command = CommandLineExecutable::Script_command_line.sub_command
puts 'sub_command = ' + sub_command.inspect if $VERBOSE
sub_command_unit = RailsishRubyUnit.new(model_basename: sub_command.to_sym)
required_library_file = sub_command_unit.model_pathname?
if File.exist?(required_library_file)
  require File.expand_path(required_library_file).to_s # require ordering problem
elsif !Unit.all.include?(sub_command_unit)
  raise "\n\n" + sub_command_unit.model_basename.to_s + ' is not a unit. Please choose one of the following: ' + Unit.all_basenames.join(' ,')
else
  raise "required_library_file #{required_library_file} does not exist."
  end # if
# executable_object = executable_class.new(TestExecutable.new_from_path(object_arguments))
executable_object = executable_object(file_argument = nil)
if executable_object.methods.include?(sub_command)
  sub_command_method = executable_object.method(sub_command)
  ret = CommandLineExecutable::Script_command_line.run(sub_command_method) do
    sub_command_test_executable = TestExecutable.new_from_path(required_library_file)
    sub_command_commandline = CommandLineExecutable.new(test_executable: sub_command_test_executable, argv: ARGV[1..-1])
    sub_command_commandline.run do
      false # not done
    end # run
  end # do run
end # if
puts 'ret = ' + ret.inspect unless $VERBOSE.nil?
1 # successfully completed

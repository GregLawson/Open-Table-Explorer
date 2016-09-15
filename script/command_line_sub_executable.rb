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
#require_relative "../app/models/#{RailsishRubyUnit::Executable.model_basename}"
require_relative '../app/models/command_line.rb'
puts 'CommandLineExecutable::Script_command_line = ' + CommandLineExecutable::Script_command_line.inspect if $VERBOSE
CommandLineExecutable::Script_command_line.run do
    sub_command = CommandLineExecutable::Script_command_line.sub_command
    sub_command_unit = RailsishRubyUnit.new(model_basename: sub_command.to_sym)
    required_library_file = sub_command_unit.model_pathname?
    if File.exist?(required_library_file)
      require File.expand_path(required_library_file).to_s # require ordering problem
    elsif !Unit.all.include?(sub_command_unit)
      raise "\n\n" + sub_command_unit.model_basename.to_s + ' is not a unit. Please choose one of the following: ' + Unit.all_basenames.join(' ,')
    else
      raise "required_library_file #{required_library_file} does not exist."
      end # if
    puts 'sub_command = ' + sub_command.inspect + sub_command_unit.inspect if $VERBOSE
    sub_command_test_executable = TestExecutable.new_from_path(required_library_file)
		sub_command_commandline = CommandLineExecutable.new(test_executable: sub_command_test_executable, argv: ARGV[1..-1])
    sub_command_commandline.run do
      false # not done
    end # run
end # do run
1 # successfully completed

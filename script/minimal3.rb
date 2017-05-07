#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/unit.rb' # before command_line
require_relative "../app/models/#{Unit::Executable.model_basename}"
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_path($PROGRAM_NAME)
require_relative "../app/models/#{scripting_executable.unit.model_basename}.rb"
script_class = RailsishRubyUnit::Executable.model_class?

script = CommandLine.new(executable: $PROGRAM_NAME, unit_class: script_class)
pp ARGV if $VERBOSE

run = script.run do
		case script.sub_command
		else script.arguments.each do |f|
		end # each
		end # case
end # do run
puts 'run returns ' + run.inspect if CommandLine::Command_line_opts[:inspect]
1 # successfully completed

#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/minimal2.rb' # before command_line
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_path($0)
require_relative "../app/models/#{scripting_executable.unit.model_basename}.rb"
script_class = Unit::Executing_Unit.model_class?

script = CommandLine.new($0)
run = script.run do
end # do run
puts "run returns "+ run.inspect if CommandLine::Command_line_opts[:inspect]
1 # successfully completed

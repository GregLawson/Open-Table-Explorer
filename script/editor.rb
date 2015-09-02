#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/unit.rb' # before command_line
require_relative "../app/models/#{Unit::Executable.model_basename}"
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_path($0)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
script_class = Unit::Executable.model_class?

script = CommandLine.new($0, script_class)
pp ARGV if $VERBOSE
pp script.options if $VERBOSE

run = CommandLine::Script_command_line.run do
end # do run
1 # successfully completed

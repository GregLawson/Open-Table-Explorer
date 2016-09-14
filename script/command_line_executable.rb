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
end # do run
1 # successfully completed

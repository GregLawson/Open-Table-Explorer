#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require 'pp'
require_relative '../app/models/command_line.rb'
require_relative '../app/models/test_executable.rb'
scripting_executable = TestExecutable.new_from_pathname($0)
require_relative "../app/models/#{scripting_executable.unit.model_basename}"
script_class = Unit::Executing_Unit.model_class?
script = CommandLine.new($0)
pp script.commands if $VERBOSE
pp ARGV if $VERBOSE

script.run do
end # do run
1 # successfully completed

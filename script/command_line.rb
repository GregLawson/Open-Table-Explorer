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
run = CommandLine::Script_command_line.run do
	sub_command = CommandLine::Script_command_line.sub_command
	if sub_command == :help then
		puts Unit.all.inspect
	else
		unit = Unit.new(sub_command)
		require unit.model_pathname?
		puts 'sub_command = ' + sub_command.inspect + unit.inspect if $VERBOSE
		unit_commandline = CommandLine.new($0, unit.model_class?, ARGV[1..-1])
		unit_commandline.run do
		end # run
	end # if help
end # do run
1 # successfully completed

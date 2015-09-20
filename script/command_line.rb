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
	if CommandLine::Script_command_line.command_line_opts[:help] then
			puts 'command_line_opts[:help]'
			true # done
	else
		sub_command = CommandLine::Script_command_line.sub_command
			unit = Unit.new(sub_command.to_s.camelize.to_sym)
			required_library_file = unit.model_pathname?
			if File.exist?(required_library_file) then
				require required_library_file
			elsif !Unit.all.include?(unit) then
				fail unit.inspect + " is not a unit :" +Unit.all_basenames.join(' ,')
			else
				fail "required_library_file #{required_library_file} does not exist."
			end # if 
			puts 'sub_command = ' + sub_command.inspect + unit.inspect if $VERBOSE
			unit_commandline = CommandLine.new($0, unit.model_class?, ARGV[1..-1])
			unit_commandline.run do
			end # run
		end # if help
end # do run
1 # successfully completed

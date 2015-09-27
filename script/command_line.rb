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
class CommandLine  < Command
def command_line_parser
	command_line = self
	Trollop::Parser.new do
		banner 'Usage: ' + ' unit_basename subcommand  options args'
		banner 'Possible unit names:'
		banner Unit.all_basenames.join(' ,')
		banner ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
		banner ' candidate_commands with ' + command_line.number_of_arguments.to_s + ' or variable number of arguments:  '
		command_line.candidate_commands_strings.each do |candidate_commands_string|
			banner '   '  + candidate_commands_string
		end # each
		banner 'args may be paths, units, branches, etc.'
		banner 'options:'
		opt :inspect, 'Inspect ' + Command.to_s + ' object' 
		opt :test, "Test unit."       # string --name <s>, default nil
	  stop_on SUB_COMMANDS
	  end
end # command_line_parser
def command_line_opts
  p = command_line_parser
	Trollop::with_standard_exception_handling p do
  o = p.parse @argv
  raise Trollop::HelpNeeded if @argv.empty? # show help screen
  o
end
end # command_line_opts
end # CommandLine
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

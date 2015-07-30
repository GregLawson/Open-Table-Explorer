###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'trollop'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/command.rb'
require_relative '../../app/models/test_executable.rb'
class CommandLine  < Command
module Constants # constant parameters of the type
Arguments = ARGV[1..-1]
Number_of_arguments = if Arguments.nil? then
		0
	else
		Arguments.size # don't include Sub_command
	end # if
SUB_COMMANDS = %w(help inspect test)
Nonscriptable_methods = [:run, :executable, :executable=]
if ARGV.size > 0 then
	Sub_command = ARGV[0].to_sym # get the subcommand
	Argument_types = Arguments.map do |argument|
		if SUB_COMMANDS.include?(argument)
			CommandLine
		elsif Branch.branch_names?.include?(argument) then 
			Branch
		elsif !Dir[argument].empty? then
			Dir
		elsif File.exists?(argument) then
			File
		else 
			Unit
		end # if
	end # map
elsif ARGV[0].nil?
	Sub_command = :help # default subcommand
else
	Sub_command = ARGV[0].to_sym # get the subcommand
end # if
Command = Unit::Executing_Unit.model_basename
end # Constants
include Constants
attr_accessor :executable, :options
def initialize(executable) # , options = Command_line_opts)
	@executable = executable
#	@options = options
end # initialize
def dispatch_one_argument(argument)
	executable_object = Unit::Executing_Unit.model_class?.new(TestExecutable.new_from_path(argument))
	ret = if executable_object.respond_to?(Sub_command) then
		method = executable_object.method(Sub_command)
		case method.arity
		when -1 then
			method.call(argument)
		when 0 then
			method.call
		when 1 then
			method.call(argument)
		else
			message = 'In CommandLine#run, '
			message += "\nargument =  " + argument
			message += "\nSub_command =  " + Sub_command.to_s
			message += "\narity =  " + method.arity.to_s
			fail Exception.new(message)
		end # case
	else
		message = "#{Sub_command} is not an instance method of #{executable_object.class.inspect}"
		message = CommandLine.candidate_commands_strings.join("\n")
#		message += "\n candidate_commands = " + candidate_commands.inspect
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
		puts message
	end # if
	ret
end # dispatch_one_argument
def run(&non_default_actions)
	done = if block_given? then
		non_default_actions.call
	else
		false # non-default commands not done cause they don't exist
	end # if
	if !done then
		if Number_of_arguments == 0 then
			puts 'Number_of_arguments == 0 '
			puts 'Trollop Command_line_opts = ' + Command_line_opts.inspect
			CommandLine.candidate_commands
		elsif Number_of_arguments == 1 then
			dispatch_one_argument(Arguments[0])
			CommandLine.candidate_commands
		elsif Number_of_arguments >= 2 then # enough arguments to loop over
			Arguments.each do |argument|
				dispatch_one_argument(argument)
			end # each
		else
		end # if
	end # if
#	cleanup_ARGV
#		scripting_workflow.script_deserves_commit!(:passed)
end #run
def cleanup_ARGV
	ARGV.delete_at(0)
end # cleanup_ARGV
def test
	puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
end # test
module ClassMethods
include Constants
def candidate_commands
	script_class = Unit::Executing_Unit.model_class?
	if Number_of_arguments == 0 then
		file_argument = $0 # script file
	else
		file_argument = ARGV[1]
	end # if
	executable_object = script_class.new(TestExecutable.new_from_path(file_argument))
	script_class.instance_methods(false).map do |candidate_command_name|
		if Nonscriptable_methods.include?(candidate_command_name) then
			nil
		else
			method = executable_object.method(candidate_command_name)
			if Number_of_arguments == method.arity ||(Number_of_arguments == -1) then
				{candidate_command: candidate_command_name, arity: method.arity}
			else
				nil
			end # if
		end # if
	end.compact.sort {|x,y| x[:arity] <=>  y[:arity] && x[:candidate_command] <=>  y[:candidate_command]} # map
end # candidate_commands
def candidate_commands_strings
	candidate_commands.map do |c|
		c[:candidate_command].to_s + ' ' + case c[:arity]
		when -1 then 'args...'
		when 0 then ''
		when 1 then 'arg'
		when 2 then 'arg arg'
		end # case
	end # map
end # candidate_commands_strings
end # ClassMethods
extend ClassMethods
module Constants # constant objects of the type
Command_line_parser = Trollop::Parser.new do
	banner 'Usage: ' + ' subcommand  options args'
	banner ' subcommands:  ' + SUB_COMMANDS.join(', ')
	banner ' candidate_commands with ' + Number_of_arguments.to_s + ' or variable number of arguments:  '
	CommandLine.candidate_commands_strings.each do |candidate_commands_string|
		banner '   '  + candidate_commands_string
   end # each
	banner 'args may be paths, units, branches, etc.'
	banner 'options:'
	opt :inspect, 'Inspect ' + Command.to_s + ' object' 
   opt :test, "Test unit."       # string --name <s>, default nil
  stop_on SUB_COMMANDS
  end
  p = Command_line_parser
Command_line_opts = Trollop::with_standard_exception_handling p do
  o = p.parse ARGV
  raise Trollop::HelpNeeded if ARGV.empty? # show help screen
  o
end
Command_line_test_opts = Trollop::options do
	banner 'Usage: ' + Command.to_s + ' subcommand options  args' 
    opt :inspect, "Inspect file object"                    # flag --monkey, default false
    opt :test, "Test unit."       # 
    opt :help, "Commands" # 
    opt :individual_test, "Run only one individual test",  :short => "-n" # 
  end
end # Constants
include Constants
end # CommandLine

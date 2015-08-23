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
SUB_COMMANDS = %w(inspect test)
Nonscriptable_methods = [:run, :executable, :executable=]

end # Constants
include Constants
attr_reader :executable, :unit_class, :argv
def initialize(executable, unit_class = CommandLine, argv = ARGV)
	@executable = executable
	@unit_class = unit_class
	@argv = argv
end # initialize
def to_s
	ret = '@argv = ' + @argv.inspect if $VERBOSE
	ret += "\n sub_command = " + sub_command.inspect if $VERBOSE
	if number_of_arguments != 0 then
		ret += "\n arguments = " + arguments.inspect if $VERBOSE
		ret += "\n argument_types = " + argument_types.inspect if $VERBOSE
	end # if
	ret
end # to_s
# Deliberately raises exception if number_of_arguments == 0
def arguments
	@argv[1..-1]
end # arguments
def number_of_arguments
	if @argv.nil? || @argv.empty? then
		0
	else
		arguments.size # don't include sub_command
	end # if
end # number_of_arguments
def sub_command
	if @argv.nil? || @argv.empty? then
		:help # default subcommand
	else
		@argv[0].to_sym # get the subcommand
	end # if
end # sub_command
def argument_types
	arguments.map do |argument|
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
end # argument_types
def dispatch_one_argument(argument)
	executable_object = executable_object(argument)
	ret = if executable_object.respond_to?(sub_command) then
		method = executable_object.method(sub_command)
		case method.arity
		when -1 then
			method.call
		when 0 then
			method.call
		when 1 then
			method.call(argument)
		else
			message = 'In CommandLine#run, '
			message += "\nargument =  " + argument
			message += "\nsub_command =  " + sub_command.to_s
			message += "\narity =  " + method.arity.to_s
			fail Exception.new(message)
		end # case
	else
		message = "#{sub_command} is not an instance method of #{executable_object.class.inspect}"
		message = candidate_commands_strings.join("\n")
#		message += "\n candidate_commands = " + candidate_commands.inspect
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
		puts message
	end # if
	ret
end # dispatch_one_argument
def executable_object(file_argument = nil)
	script_class = Unit::Executable.model_class?
	if file_argument.nil? then # default
		if number_of_arguments == 0 then
			file_argument = $0 # script file
		else
			file_argument = @argv[1]
		end # if
	end # if file_argument.nil? default
	if @unit_class.included_modules.include?(Virtus::InstanceMethods) then
		@unit_class.new(executable: TestExecutable.new(executable_file: file_argument))
	else
		@unit_class.new(executable: TestExecutable.new_from_path(file_argument))
	end # if
end # executable_object
def candidate_commands
	script_class = Unit::Executable.model_class?
	script_class.instance_methods(false).map do |candidate_command_name|
		if Nonscriptable_methods.include?(candidate_command_name) then
			nil
		else
			method = executable_object.method(candidate_command_name)
			if number_of_arguments == method.arity ||(number_of_arguments == -1) then
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
def command_line_parser
	command_line = self
	Trollop::Parser.new do
		banner 'Usage: ' + ' subcommand  options args'
		banner ' subcommands:  ' + SUB_COMMANDS.join(', ')
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
def run(&non_default_actions)
	done = if block_given? then
		non_default_actions.call
	else
		false # non-default commands not done cause they don't exist
	end # if
	ret = if !done then
		if number_of_arguments == 0 then
			puts 'number_of_arguments == 0 '
			puts 'Trollop command_line_opts = ' + command_line_opts.inspect
			candidate_commands
		elsif number_of_arguments == 1 then
			dispatch_one_argument(arguments[0])
			candidate_commands
		elsif number_of_arguments >= 2 then # enough arguments to loop over
			arguments.each do |argument|
				dispatch_one_argument(argument)
			end # each
		else
			fail
		end # if
	end # if
#	cleanup_ARGV
#		scripting_workflow.script_deserves_commit!(:passed)
	puts "run returns "+ run.inspect if command_line_opts[:inspect]
	ret
end #run
def cleanup_ARGV
	ARGV.delete_at(0)
end # cleanup_ARGV
def test
	puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
end # test
module ClassMethods
include Constants
end # ClassMethods
extend ClassMethods
module Constants # constant objects of the type
Command = Unit::Executable.model_basename
Script_class = Unit::Executable.model_class?
Script_command_line = CommandLine.new($0, Script_class, ARGV)
# = Script_class.new(TestExecutable.new_from_path($0))


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

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

else
	Sub_command = :help # default subcommand
end # if
Command = Unit::Executing_Unit.model_basename
end # Constants
include Constants
attr_accessor :executable, :options
def initialize(executable, options = Command_line_opts)
	@executable = executable
	@options = options
end # initialize
def dispatch_one_argument(argument)
	argument = file_argument
				executable_object = Unit::Executing_Unit.model_class?.new(TestExecutable.new_from_path(file_argument))
				if executable_object.respond_to?(Sub_command) then
					method = executable_object.method(Sub_command)
					case method.arity
					when -1 then
						method.call(file_argument)
					when 0 then
						method.call
					when 1 then
						method.call(file_argument)
					else
						message = 'In CommandLine#run, '
						message += "\nfile_argument =  " + file_argument
						message += "\nSub_command =  " + Sub_command.to_s
						message += "\narity =  " + method.arity.to_s
						fail Exception.new(message)
					end # case
				else
					message = "#{Sub_command} is not an instance method of #{executable_object.class.inspect}"
					message = candidate_commands.map do |candidate_command|
						candidate_command[:candidate_command].to_s + ' ' + candidate_command[:arity].to_s
					end.join("\n") # map
	#				message += "\n candidate_commands = " + candidate_commands.inspect
	#				message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
					puts message
				end # if
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
			puts 'Trollop Command_line_test_opts = ' + Command_line_test_opts.inspect
			CommandLine.candidate_commands
		elsif Number_of_arguments == 1 then
			fail RuntimeError.new("Expect a subcommand and a file argument.")
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
		method = executable_object.method(candidate_command_name)
		{candidate_command: candidate_command_name, arity: method.arity}
	end.sort {|x,y| x[:arity] <=>  y[:arity] && x[:candidate_command] <=>  y[:candidate_command]} # map
end # candidate_commands

end # ClassMethods
extend ClassMethods
module Constants # constant objects of the type
SUB_COMMANDS = %w(help inspect test)
Command_line_parser = Trollop::Parser.new do
	banner 'Usage: ' + ' subcommand  path_patterns' 
	banner ' subcommands:  ' + SUB_COMMANDS.join(', ')
	banner ' candidate_commands:  ' + CommandLine.candidate_commands.inspect
   opt :inspect, "Inspect file object"                    # flag --monkey, default false
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
	banner 'Usage: ' + Command.to_s + ' subcommand  path_patterns' 
    opt :inspect, "Inspect file object"                    # flag --monkey, default false
    opt :test, "Test unit."       # 
    opt :help, "Commands" # 
    opt :individual_test, "Run only one individual test",  :short => "-n" # 
  end
end # Constants
include Constants
end # CommandLine

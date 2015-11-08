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
# Monkey patch Mehod to give more intelligible arity methods
class Method

def default_arguments?
	if arity < 0 then
		true
	else
		false
	end # if


end # default_arguments
def required_arguments

	if default_arguments? then
		-(arity+1)
	else
		arity
	end # if
end # required_arguments
end # Method

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
def ==(other)
	@executable == other.executable && @unit_class == other.unit_class && @argv == other.argv
end # ==
def to_s
	ret = '@argv = ' + @argv.inspect
	ret += "\n sub_command = " + sub_command.inspect
	if number_of_arguments != 0 then
		ret += "\n arguments = " + arguments.inspect
		ret += "\n argument_types = " + argument_types.inspect
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
		CommandLine.argument_type(argument)
	end # map
end # argument_types
def find_examples
	Example.find_by_class(@unit_class, @unit_class)
end # find_examples
def find_example?
	examples = Example.find_by_class(@unit_class, @unit_class)
	if examples.empty? then
		nil
	else
		examples.first
	end # if
end # find_example?
def make_executable_object(file_argument)
	if @unit_class.included_modules.include?(Virtus::InstanceMethods) then
		@unit_class.new(executable: TestExecutable.new(executable_file: file_argument))
	else
		@unit_class.new(TestExecutable.new_from_path(file_argument))
	end # if
end # make_executable_object
def executable_object(file_argument = nil)
	example = find_example?
	if file_argument.nil? then
		if example.nil? then # default
			if number_of_arguments == 0 then
				make_executable_object($0) # script file
			else
				make_executable_object(@argv[1])
			end # if
		else
			example.value
		end # if
	else
		make_executable_object(file_argument)
	end # if
	
end # executable_object
def executable_method?(method_name, argument = nil)
	executable_object = executable_object(argument)
	ret = if executable_object.respond_to?(method_name) then
		method = executable_object.method(method_name)
	else
		nil
	end # if
end # executable_method?
def method_exception_string(method_name)
		message = "#{method_name.to_s} is not an instance method of #{executable_object.class.inspect}"
		message += "\n candidate_commands = "
		message += candidate_commands_strings.join("\n")
#		message += "\n candidate_commands = " + candidate_commands.inspect
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
		fail Exception.new(message)
end # method_exception_string
def arity(method_name)
	executable_method = executable_method?(method_name)
	ret = if executable_method.nil? then
		message = "#{method_name} is not an instance method of #{executable_object.class.inspect}"
		message = candidate_commands_strings.join("\n")
#		message += "\n candidate_commands = " + candidate_commands.inspect
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
		fail Exception.new(message)
	else
		executable_method.arity
	end # if
end # arity
def default_arguments?(method_name)
	if arity(method_name) < 0 then
		true
	else
		false
	end # if


end # default_arguments
def required_arguments(method_name)

	method_arity = arity(method_name)
	if default_arguments?(method_name) then
		-(method_arity+1)
	else
		method_arity
	end # if
end # required_arguments
def dispatch_one_argument(argument)
	method = executable_method?(sub_command, argument)
	if method.nil? then
		message = method_exception_string(sub_command)
		fail Exception.new(message)
	else
		case required_arguments(sub_command)
		when 0 then
			method.call
		when 1 then
			method.call(argument)
		else
			message = "\nIn CommandLine#dispatch_one_argument, "
			message += "\nargument =  " + argument
			message += "\nsub_command =  " + sub_command.to_s
			message += "\narity =  " + required_arguments(sub_command).to_s
			fail Exception.new(message)
		end # case
	end # if nil?
end # dispatch_one_argument
def candidate_commands(number_arguments = nil)
	executable_object.methods(true).map do |candidate_command_name|
		if Nonscriptable_methods.include?(candidate_command_name) then
			nil
		else
			method = executable_object.class.instance_method(candidate_command_name)
			selected = number_arguments.nil?
			selected ||= number_arguments == required_arguments(method_name)
			selected ||= (default_arguments?(method_name) && number_arguments <= required_arguments(method_name))
			if selected then
				{candidate_command: candidate_command_name, required_arguments: method.required_arguments, default_arguments: method.default_arguments?, method_receiver: executable_object}
			else
				nil
			end # if
		end # if
	end.compact.sort {|x,y| x[:arity] <=>  y[:arity] && x[:candidate_command] <=>  y[:candidate_command]} # map
end # candidate_commands
def candidate_commands_strings
	candidate_commands.map do |c|
		c[:candidate_command].to_s + ' ' + ['arg'] * c[:required_arguments] * ' '
	end # map
end # candidate_commands_strings
def run(&non_default_actions)
	done = if block_given? then
		non_default_actions.call
	else
		false # non-default commands not done cause they don't exist
	end # if
	ret = if !done then
		method = executable_method?(sub_command)
		if method.nil? then
			message = method_exception_string(sub_command)
			fail Exception.new(message)
		elsif number_of_arguments == required_arguments(sub_command) then
			dispatch_one_argument(arguments)
		elsif number_of_arguments < required_arguments(sub_command) then
			puts 'number_of_arguments == 0 '
		elsif required_arguments(sub_command) == 0 ||
		(number_of_arguments % required_arguments(sub_command)) == 0 then
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
def argument_type(argument)
	if SUB_COMMANDS.include?(argument)
		CommandLine
	elsif Branch.branch_names?.include?(argument) then 
		Branch
	elsif File.exists?(argument) then
		File
	elsif !Dir[argument].empty? then
		Dir
	else 
		Unit
	end # if
end # argument_type
end # ClassMethods
extend ClassMethods
module Constants # constant objects of the type
Command = Unit::Executable.model_basename
Script_class = Unit::Executable.model_class?
Script_command_line = CommandLine.new($0, Script_class, ARGV)
# = Script_class.new(TestExecutable.new_from_path($0))



end # Constants
include Constants
end # CommandLine

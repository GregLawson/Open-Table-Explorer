###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'trollop'
require 'virtus'
require_relative '../../app/models/shell_command.rb'
#require_relative '../../app/models/command.rb'
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

class CommandLine  #< Command
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
SUB_COMMANDS = %w(inspect test)
Nonscriptable_methods = [:run, :executable, :executable=]

end # DefinitionalConstants
include DefinitionalConstants
module DefinitionalClassMethods # compute sub-objects such as default attribute values
include DefinitionalConstants
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
end # DefinitionalClassMethods
extend DefinitionalClassMethods
include Virtus.value_object
  values do
 	attribute :executable, Symbol # Symbol not RepositoryPathname or TestExecutable?
	attribute :unit_class, Class, :default => CommandLine
	attribute :argv, Array, :default => ARGV
#	attribute :command_line_opts, Hash, :default => lambda {|commandline, attribute| commandline.command_line_opts_initialize}
end # values

module ClassMethods # such as alternative new methods
include DefinitionalConstants
end # ClassMethods
extend ClassMethods
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
		@unit_class.new(test_executable: TestExecutable.new(argument_path: file_argument))
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
def candidate_commands(number_arguments = nil)
	executable_object.methods(true).map do |candidate_command_name|
		if Nonscriptable_methods.include?(candidate_command_name) then
			nil
		else
			method = executable_object.method(candidate_command_name)
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
		c[:candidate_command].to_s + ' ' + 
			(['arg'] * c[:required_arguments]).join(' ') + 
			(c[:default_arguments] ? '...' : '')
	end # map
end # candidate_commands_strings
# default help, override as needed
def help_banner_string
		ret = 'Usage: ' + ' unit_basename subcommand  options args'
		ret += 'Possible unit names:'
		ret += Unit.all_basenames.join(', ')
		ret += ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
		ret += ' candidate_commands with ' + command_line.number_of_arguments.to_s + ' or variable number of arguments:  '
		command_line.candidate_commands_strings.each do |candidate_commands_string|
			ret += '   '  + candidate_commands_string
		end # each
		ret += 'args may be paths, units, branches, etc.'
		ret += 'options:'
end # help_banner_string
def command_line_parser
	command_line = self
	Trollop::Parser.new do
		banner 'Usage: ' + ' unit_basename subcommand  options args'
#		banner ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
		if command_line.number_of_arguments < 1 then
			banner 'Possible unit names:'
			banner Unit.all_basenames.join(' ,')
		elsif command_line.number_of_arguments == 1 then
			banner ' all candidate_commands ' 
			command_line.candidate_commands_strings.each do |candidate_commands_string|
				banner '   '  + candidate_commands_string
			end # each
		else
			banner ' candidate_commands with ' + command_line.number_of_arguments.to_s + ' or variable number of arguments:  '
			command_line.candidate_commands_strings.each do |candidate_commands_string|
				banner '   '  + candidate_commands_string
			end # each
		end # if
		banner 'args may be paths, units, branches, etc.'
		banner 'options:'
#		opt :inspect, 'Inspect ' + Command.to_s + ' object' 
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
module Constants # constant objects of the type
include DefinitionalConstants
#Command = RailsishRubyUnit::Executable.model_basename
Script_class = RailsishRubyUnit::Executable.model_class?
Script_command_line = CommandLine.new(executable: $0, unit_class: Script_class, argv: ARGV)
# = Script_class.new(TestExecutable.new_from_path($0))



end # Constants
include Constants
def ==(other)
	if self.class == other.class then
		@executable == other.executable && @unit_class == other.unit_class && @argv == other.argv
	else
		false
	end # if
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
def sub_command
	if @argv.nil? || @argv.empty? then
		:help # default subcommand
	else
		@argv[0].to_sym # get the subcommand
	end # if
end # sub_command
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
#		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
end # method_exception_string
def dispatch_required_arguments(argument)
	method = executable_method?(sub_command, argument)
	if method.nil? then
		message = method_exception_string(sub_command)
		fail Exception.new(message)
	else
		case method.required_arguments
		when 0 then
			method.call
		when 1 then
			method.call(argument)
		else
			message = "\nIn CommandLine#dispatch_required_arguments, "
			message += "\nargument =  " + argument
			message += "\nsub_command =  " + sub_command.to_s
			message += "\nrequired_arguments =  " + method.required_arguments.to_s
			fail Exception.new(message)
		end # case
	end # if nil?
end # dispatch_required_arguments
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
		elsif number_of_arguments == 0 then
			method.call
		elsif number_of_arguments == method.required_arguments then
			dispatch_required_arguments(arguments)
		elsif number_of_arguments < method.required_arguments then
			puts 'number_of_arguments == 0 '
		elsif method.required_arguments == 0 ||
		(number_of_arguments % method.required_arguments) == 0 then
			arguments.each do |argument|
				dispatch_required_arguments(argument)
			end # each
		else
			fail
		end # if
	end # if
#	cleanup_ARGV
#		scripting_workflow.script_deserves_commit!(:passed)
	message = 'command_line  (' + inspect + ') '
	message += ' run returns ' + ret.inspect + command_line_opts.inspect + caller.join("\n")
	puts message if command_line_opts[:inspect]
	puts "run returns "+ ret.inspect if command_line_opts[:inspect]
	ret
end #run
def cleanup_ARGV
	ARGV.delete_at(0)
end # cleanup_ARGV
def test
	puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
end # test
end # CommandLine

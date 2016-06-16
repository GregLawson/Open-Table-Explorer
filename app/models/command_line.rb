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
# require_relative '../../app/models/command.rb'
require_relative '../../app/models/test_executable.rb'
require_relative '../../app/models/method_model.rb'

class CommandLine # < Command
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    SUB_COMMANDS = %w(inspect test).freeze
    Nonscriptable_methods = [:run, :executable, :executable=].freeze
    Command_line_opts_default = lambda do |commandline, _attribute|
      commandline.command_line_opts_initialize
    end # command_line_opts
    Executable_default = lambda do |commandline, _attribute|
      TestExecutable.new_from_path(commandline.argv)
    end # Executable_default
    end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods # compute sub-objects such as default attribute values
    include DefinitionalConstants
    def argument_type(argument)
      if SUB_COMMANDS.include?(argument)
        CommandLine
      elsif Branch.branch_names?.include?(argument)
        Branch
      elsif File.exist?(argument)
        File
      elsif !Dir[argument].empty?
        Dir
      else
        Unit
      end # if
    end # argument_type
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
    attribute :test_executable, TestExecutable 
    attribute :unit_class, Class, default: ->(command_line, _attribute) { command_line.test_executable.unit.model_class? }
    attribute :argv, Array, default: ARGV
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
    if @argv.nil? || @argv.empty?
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
    if examples.empty?
      nil
    else
      examples.first
    end # if
  end # find_example?

  def make_executable_object(file_argument)
    if @unit_class.included_modules.include?(Virtus::InstanceMethods)
      @unit_class.new(test_executable: TestExecutable.new(argument_path: file_argument))
    else
      @unit_class.new(TestExecutable.new_from_path(file_argument))
    end # if
  end # make_executable_object

  def executable_object(file_argument = nil)
    example = find_example?
    if file_argument.nil?
      if example.nil? # default
        if number_of_arguments == 0
          make_executable_object($PROGRAM_NAME) # script file
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

  def command_instance_methods
		command_class = @test_executable.unit.model_class?	
		MethodModel.instance_method_models(command_class)	
  end # command_instance_methods

	def sub_command_method
      ret = command_instance_methods.find do |method_model|
        method_model.method_name == sub_command
      end # find
			message = sub_command.to_s + ' is not in ' + command_instance_methods.inspect
			raise message if ret.nil?
			ret
	end # sub_command_method
  def candidate_commands_strings
      command_instance_methods.map do |method_model|
        method_model.prototype(ancestor_qualifier: true, argument_delimeter: '(')
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
      ret += '   ' + candidate_commands_string
    end # each
    ret += 'args may be paths, units, branches, etc.'
    ret += 'options:'
  end # help_banner_string

  def command_line_parser
    command_line = self
    Trollop::Parser.new do
      banner 'Usage: ' + ' unit_basename subcommand  options args'
      #		banner ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
      if command_line.number_of_arguments < 1
        banner 'Possible unit names:'
        banner Unit.all_basenames.join(' ,')
      elsif command_line.number_of_arguments == 1
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
      opt :test, 'Test unit.' # string --name <s>, default nil
      stop_on SUB_COMMANDS
    end
  end # command_line_parser

  def command_line_opts
    p = command_line_parser
    Trollop.with_standard_exception_handling p do
      o = p.parse @argv
      raise Trollop::HelpNeeded if @argv.empty? # show help screen
      o
    end
  end # command_line_opts
  module Constants # constant objects of the type
    include DefinitionalConstants
    # Command = RailsishRubyUnit::Executable.model_basename
    Script_class = RailsishRubyUnit::Executable.model_class?
    Script_command_line = CommandLine.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
      # = Script_class.new(TestExecutable.new_from_path($0))
    end # Constants
  include Constants
  def ==(other)
    if self.class == other.class
      @test_executable == other.test_executable && @unit_class == other.unit_class && @argv == other.argv
    else
      false
    end # if
  end # ==

  def to_s
    ret = '@argv = ' + @argv.inspect
    ret += "\n sub_command = " + sub_command.inspect
    if number_of_arguments != 0
      ret += "\n arguments = " + arguments.inspect
      ret += "\n argument_types = " + argument_types.inspect
    end # if
    ret
  end # to_s

  def sub_command
    if @argv.nil? || @argv.empty?
      :help # default subcommand
    else
      @argv[0].to_sym # get the subcommand
    end # if
  end # sub_command

  def executable_method?(method_name, argument = nil)
    executable_object = executable_object(argument)
    ret = if executable_object.respond_to?(method_name)
            method = executable_object.method(method_name)
          end # if
  end # executable_method?

  def method_exception_string(method_name)
    message = "#{method_name} is not an instance method of #{executable_object.class.inspect}"
    message += "\n candidate_commands = "
    message += candidate_commands_strings.join("\n")
    #		message += "\n\n executable_object.class.instance_methods = " + executable_object.class.instance_methods(false).inspect
  end # method_exception_string

  def dispatch_required_arguments(argument)
    method = executable_method?(sub_command, argument)
    if method.nil?
      message = method_exception_string(sub_command)
      raise Exception.new(message)
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
        raise Exception.new(message)
      end # case
    end # if nil?
  end # dispatch_required_arguments

  def run
    done = if block_given?
             yield
           else
             false # non-default commands not done cause they don't exist
    end # if
    ret = unless done
            method_model = sub_command_method
            if method_model.nil?
              message = method_exception_string(sub_command)
              raise Exception.new(message)
            elsif number_of_arguments == 0
              method_model.theMethod.call
            elsif number_of_arguments == method_model.theMethod.required_arguments
              dispatch_required_arguments(arguments)
            elsif number_of_arguments < method_model.theMethod.required_arguments
              puts 'number_of_arguments == 0 '
            elsif method_model.theMethod.required_arguments == 0 ||
                  (number_of_arguments % method_model.theMethod.required_arguments) == 0
              arguments.each do |argument|
                dispatch_required_arguments(argument)
              end # each
            else
              raise
            end # if
    end # if
    #	cleanup_ARGV
    #		scripting_workflow.script_deserves_commit!(:passed)
    message = 'command_line  (' + inspect + ') '
    message += ' run returns ' + ret.inspect + command_line_opts.inspect + caller.join("\n")
    puts message if command_line_opts[:inspect]
    puts 'run returns ' + ret.inspect if command_line_opts[:inspect]
    ret
  end # run

  def cleanup_ARGV
    ARGV.delete_at(0)
  end # cleanup_ARGV

  def test
    puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
  end # test
end # CommandLine

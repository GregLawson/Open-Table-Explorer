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
require_relative '../../app/models/command.rb'
require_relative '../../app/models/test_executable.rb'
require_relative '../../app/models/method_model.rb'
require_relative '../../app/models/branch.rb'

class SingleExecution
  include Virtus.value_object
  values do
		attribute :executable_method, Method
	#	attribute :executable_object, Object 
	#	attribute :method_name, Symbol
		attribute :method_arguments, Array
  end # values
	def run
		@executable_method.call(*method_arguments)
  end # run
end # SingleExecution

class CommandLineExecutable
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    SUB_COMMANDS = %w(help inspect test).freeze
    Nonscriptable_methods = [:run, :executable, :executable=].freeze
    Executable_default = lambda do |commandline, _attribute|
      TestExecutable.new_from_path(commandline.argv)
    end # Executable_default
		All_argument_types = [CommandLineExecutable, Branch, File, Dir, Unit]
    end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods # compute sub-objects such as default attribute values
    include DefinitionalConstants
    def argument_type(argument)
      if SUB_COMMANDS.include?(argument)
        CommandLineExecutable
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
#    attribute :unit_class, Class, default: ->(command_line, _attribute) { command_line.test_executable.unit.model_class? }
    attribute :argv, Array, default: ARGV
  end # values

  module ClassMethods # such as alternative new methods
    include DefinitionalConstants
  end # ClassMethods
  extend ClassMethods

  module Constants # constant objects of the type
    include DefinitionalConstants
    # Command = RailsishRubyUnit::Executable.model_basename
    Script_class = CommandLineExecutable
    Script_command_line = CommandLineExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
      # = Script_class.new(TestExecutable.new_from_path($0))
    end # Constants
  include Constants

  # Deliberately raises exception if number_of_arguments == 0
  def arguments
    @argv[0..-1]
  end # arguments

  def number_of_arguments
    if @argv.nil? || @argv.empty? || @argv == ['']
      0
    else
      arguments.size # don't include sub_command
    end # if
  end # number_of_arguments

  def sub_command
    if @argv.nil? || @argv.empty? || @argv == ['']
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

  def cleanup_ARGV
    ARGV.delete_at(0)
  end # cleanup_ARGV

  def test
    puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
  end # test

  def ==(other)
    if self.class == other.class
      @test_executable == other.test_executable && @test_executable.unit.model_class? == other.test_executable.unit.model_class? && @argv == other.argv
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

  def make_executable_object(file_argument)
    if @test_executable.unit.model_class?.included_modules.include?(Virtus::InstanceMethods)
      @test_executable.unit.model_class?.new(test_executable: TestExecutable.new(argument_path: file_argument))
    else
      @test_executable.unit.model_class?.new(TestExecutable.new_from_path(file_argument))
    end # if
  end # make_executable_object

  def executable_object(file_argument = nil)
    if file_argument.nil?
        if number_of_arguments == 0
          make_executable_object($PROGRAM_NAME) # script file
        else
          make_executable_object(@argv[1])
        end # if
    else
      make_executable_object(file_argument)
    end # if
  end # executable_object

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

	def sub_command_method
      ret = find_sub_command_instance_method(method_name = sub_command)
			if ret.nil? # no sub_command, default to help
				raise 'method_name not found = ' + method_name.to_s
			else
				ret
			end # if
	end # sub_command_method


	def execution_array(executable_method, number_of_execution_arguments = executable_method.required_arguments)
		if number_of_execution_arguments == 0
				[SingleExecution.new(
					executable_method: executable_method, 
					arguments: arguments
					)]
		else
			remainder = number_of_arguments % number_of_execution_arguments
			if remainder == 0
			array_size = number_of_arguments / number_of_execution_arguments
			array_size.times do i
				SingleExecution.new(
					executable_method: executable_method, 
					arguments: arguments[i * number_of_execution_arguments, number_of_execution_arguments]
					)
				
			end # times
			else
				message = argument_types.map do |argument_type|
					argument_type.inspect
				end.join(', ') # map
				raise message
			end # if
		end # if
	end # execution_array

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
    message += ' run returns ' + ret.inspect + caller.join("\n")
    ret
  end # run
end # CommandLineExecutable

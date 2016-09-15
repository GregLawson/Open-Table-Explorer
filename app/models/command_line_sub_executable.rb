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
require_relative '../../app/models/command_line_executable.rb'

class CommandLineSubExecutable < CommandLineExecutable
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    SUB_COMMANDS = %w(help inspect test).freeze
    Nonscriptable_methods = [:run, :executable, :executable=].freeze
    Executable_default = lambda do |commandline, _attribute|
      TestExecutable.new_from_path(commandline.argv)
    end # Executable_default
    end # DefinitionalConstants
  include DefinitionalConstants
	
  module Constants # constant objects of the type
    include DefinitionalConstants
    # Command = RailsishRubyUnit::Executable.model_basename
    Script_class = CommandLineSubExecutable
    Script_command_line = CommandLineSubExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
      # = Script_class.new(TestExecutable.new_from_path($0))
    end # Constants
  include Constants

	def sub_command_commandline
    sub_command_unit = RailsishRubyUnit.new(model_basename: sub_command.to_sym)
    required_library_file = sub_command_unit.model_pathname?
		sub_command_test_executable = TestExecutable.new_from_path(required_library_file)
		CommandLine.new(test_executable: sub_command_test_executable, argv: @argv[1..-1])
	end # sub_command_commandline


  def find_examples
    Example.find_by_class(@test_executable.unit.model_class?, @test_executable.unit.model_class?)
  end # find_examples

  def find_example?
    examples = Example.find_by_class(@test_executable.unit.model_class?, @test_executable.unit.model_class?)
    if examples.empty?
      nil
    else
      examples.first
    end # if
  end # find_example?

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

  def sub_command_instance_methods
		command_class = @test_executable.unit.model_class?	
		MethodModel.instance_method_models(command_class)	
  end # sub_command_instance_methods

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
	
	def find_sub_command_instance_method(method_name = sub_command)
      ret = sub_command_instance_methods.find do |method_model|
        method_model.method_name == sub_command
      end # find
	end # find_sub_command_instance_method
	
	def sub_command_method
      ret = find_sub_command_instance_method(method_name = sub_command)
			if ret.nil? # no sub_command, default to help
				raise 'method_name not found = ' + method_name.to_s
			else
				ret
			end # if
	end # sub_command_method

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
    message += ' run returns ' + ret.inspect + caller.join("\n")
    ret
  end # run

end # CommandLineSubExecutable

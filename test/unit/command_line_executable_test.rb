###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../assertions/command_line_assertions.rb'
#require_relative '../../app/models/merge.rb'

class CommandLineExecutableTest < TestCase
  include CommandLineExecutable::Constants
  module Examples
		Not_virtus_test_executable = TestExecutable.new_from_path('app/models/editor.rb')
		Not_virtus_unit_commandline = CommandLineExecutable.new(test_executable: Not_virtus_test_executable, argv: ['help', $PROGRAM_NAME])
		require File.expand_path(Not_virtus_test_executable.unit.model_pathname?)
#		No_side_effects_test_executable = TestExecutable.new_from_path('app/models/merge.rb')
#		No_side_effects_sub_command_line = CommandLineExecutable.new(test_executable: No_side_effects_test_executable, argv: ['state?'])
		No_side_effects_default_test_executable = TestExecutable.new_from_path('app/models/editor.rb')
		No_side_effects_default_line = CommandLineExecutable.new(test_executable: No_side_effects_default_test_executable, argv: ['version_comparison'])
		No_arg_run = CommandLineExecutable.new(argv: [])
	#        test_run = ShellCommands.new('ruby -W0 script/command_line.rb ' + args)
  end # Examples
  include Examples
  def test_ruby_assertions
    assert(self.class.included_modules.include?(AssertionsModule))
    refute_empty([1])
  end # ruby_assertions

	def test_SingleExecution
		executable_method = No_arg_run.method(:arguments)
		execution = SingleExecution.new(executable_method: executable_method, method_arguments: [])
		assert_equal(No_arg_run.arguments, execution.run)
		assert_equal([], execution.run)
	end # SingleExecution
	
  def test_DefinitionalConstants
    CommandLineExecutable # .assert_pre_conditions
    #	Test_unit_commandline.assert_pre_conditions
    Not_virtus_unit_commandline # .assert_pre_conditions
    #	assert_equal({:inspect=>false, :test=>false, :help=>false, :individual_test=>false}, Script_command_line)
    if Script_command_line.number_of_arguments > 0
      Script_command_line.arguments.each_with_index do |argument, i|
        puts argument.to_s + ' type of ' + Script_command_line.argument_types[i].name.to_s
      end # each
    else
      puts 'No arguments'
    end # if
    #	assert_equal(Command, :command_line)
    assert_equal(Script_class, CommandLineExecutable)
    assert_equal(Script_command_line.test_executable.unit.model_class?, Script_class)
  end # DefinitionalConstants

  def test_argument_type
    assert_equal(Dir, CommandLineExecutable.argument_type('/*'))
    assert_equal(File, CommandLineExecutable.argument_type('/'), CommandLineExecutable.inspect)
    #	assert(Branch.branch_names?.include?(:master), Branch.branch_names?.inspect)
    #	assert_equal(Branch, CommandLineExecutable.argument_type('master'))
    assert_equal(Unit, CommandLineExecutable.argument_type('command_line'))
    #	assert_equal(Method, CommandLineExecutable.argument_type('error_score?'))
		assert_includes(All_argument_types, CommandLineExecutable.argument_type('error_score?'))
  end # argument_type

  def test_initialize
#    refute_nil(No_arg_run.test_executable)
#    refute_nil(No_arg_run.test_executable.unit)
#    refute_nil(No_arg_run.test_executable.unit.model_class?)
    refute_nil(Script_command_line.test_executable.unit.model_class?)
  end # values

  def test_arguments
    assert_equal([], No_arg_run.arguments)
    assert_equal(['help', $PROGRAM_NAME], Not_virtus_unit_commandline.arguments)
    assert_equal(['version_comparison'], No_side_effects_default_line.arguments)
    #		assert_equal(['state?'], No_side_effects_sub_command_line.arguments)
  end # arguments

  def test_number_of_arguments
    #    assert_equal(0, No_side_effects_sub_command_line.number_of_arguments)
    assert_equal(2, Not_virtus_unit_commandline.number_of_arguments)
    assert_equal(1, No_side_effects_default_line.number_of_arguments)
    assert_equal(0, No_arg_run.number_of_arguments)
    #		assert_equal(1, No_side_effects_sub_command_line.number_of_arguments)
  end # number_of_arguments

  def test_sub_command
    #    assert_equal(:state?, No_side_effects_sub_command_line.sub_command)
    #		assert_equal(:help, Not_virtus_unit_commandline.sub_command)
    assert_equal(:version_comparison, No_side_effects_default_line.sub_command)
    assert_equal(:help, No_arg_run.sub_command, No_arg_run.inspect)
    assert_equal(:help, Script_command_line.sub_command, Script_command_line.inspect)
  end # sub_command

  def test_sub_command_commandline
  end # sub_command_commandline

  def test_argument_types
    Not_virtus_unit_commandline.arguments.map do |argument|
      assert_includes(All_argument_types, CommandLineExecutable.argument_type(argument), argument.inspect)
    end # map
    #	assert_equal([Method], No_side_effects_sub_command_line.argument_types)
    assert_equal([CommandLineExecutable, File], Not_virtus_unit_commandline.argument_types)
    assert_equal([], No_arg_run.argument_types)
    assert_equal([Method], No_side_effects_sub_command_line.argument_types)
    assert_equal([Method], No_side_effects_default_line.argument_types)
  end # argument_types

  def test_make_executable_object
    #    assert_includes(No_side_effects_sub_command_line.test_executable.unit.model_class?.included_modules, Virtus::InstanceMethods)
  end # make_executable_object

  def test_executable_object
    #    assert_includes(No_side_effects_sub_command_line.test_executable.unit.model_class?.included_modules, Virtus::InstanceMethods)
    #    test_run_object = TestRun.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME))
    #    assert_equal(test_run_object.methods, No_side_effects_sub_command_line.executable_object.methods)
    #	assert_equal(test_run_object, No_side_effects_sub_command_line.executable_object)
    #	assert_equal(test_run_object.test_executable, No_side_effects_sub_command_line.executable_object.test_executable)
    #    refute_nil(test_run_object.test_executable)
    #	assert_equal($0, test_run_object.test_executable.argument_path)
    #	assert_equal($0, No_side_effects_sub_command_line.test_executable_object.test_executable.argument_path.relative_pathname.to_s)

    assert_includes(CommandLineExecutable.included_modules, Virtus::InstanceMethods)
    refute_includes(Not_virtus_unit_commandline.test_executable.unit.model_class?.included_modules, Virtus::InstanceMethods)
    test_run_object = CommandLineExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME))
    #	assert_equal(test_run_object.methods, No_side_effects_sub_command_line.executable_object.methods)
    #	assert_equal(test_run_object, No_side_effects_sub_command_line.executable_object)
    #	assert_equal(test_run_object.test_executable, No_side_effects_sub_command_line.executable_object.test_executable)
    refute_nil(test_run_object.test_executable)
    assert_instance_of(TestExecutable, test_run_object.test_executable)
    #	assert_equal($0, test_run_object.test_executable.argument_path.relative_pathname.to_s)
    #	assert_equal($0, No_side_effects_sub_command_line.test_executable_object.test_test_executable.argument_path.relative_pathname.to_s)
  end # executable_object

  def test_command_line_parser
  end # command_line_parser

  def test_command_line_opts
  end # command_line_opts

  def test_equal
  end # ==

  def test_to_s
    #    refute_equal('', No_side_effects_sub_command_line.to_s)
    #    assert_match(/argv/, No_side_effects_sub_command_line.to_s)
  end # to_s

  def test_execution_array
    executable_method = No_arg_run.method(:arguments)
    execution = SingleExecution.new(executable_method: executable_method, method_arguments: [])
    execution_array = No_arg_run.execution_array(executable_method)
    assert_equal([execution], execution_array)
  end # execution_array

  def test_run
    executable_method = No_arg_run.method(:arguments)
    execution_array = No_arg_run.execution_array(executable_method)
    returns = execution_array.map do |execution|
      execution_run = execution.run
      assert_equal(No_arg_run.arguments, execution_run)
      assert_equal([], execution_run)
    end # map
    command_string = 'ruby -W1 script/command_line_executable.rb sub_command  app/models/editor.rb'
    editor_command_line = ShellCommands.new(command_string)
    text = editor_command_line.output.lines[-1, 1][0]
    assert_instance_of(String, text)
    assert_match(/ret = \[:sub_command\]/, text)
  end # run
end # CommandLineExecutable

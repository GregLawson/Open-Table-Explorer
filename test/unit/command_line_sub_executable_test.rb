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

class CommandLineSubExecutableTest < TestCase
  include CommandLineSubExecutable::Constants
  module Examples
		Not_virtus_test_executable = TestExecutable.new_from_path('app/models/editor.rb')
		Not_virtus_unit_commandline = CommandLineSubExecutable.new(test_executable: Not_virtus_test_executable, argv: ['help', $PROGRAM_NAME])
		require File.expand_path(Not_virtus_test_executable.unit.model_pathname?)
#		No_side_effects_test_executable = TestExecutable.new_from_path('app/models/merge.rb')
#		No_side_effects_sub_command_line = CommandLineSubExecutable.new(test_executable: No_side_effects_test_executable, argv: ['state?'])
		No_side_effects_default_test_executable = TestExecutable.new_from_path('app/models/editor.rb')
		No_side_effects_default_line = CommandLineSubExecutable.new(test_executable: No_side_effects_default_test_executable, argv: ['version_comparison'])
		No_arg_run = CommandLineSubExecutable.new(argv: '')
	#        test_run = ShellCommands.new('ruby -W0 script/command_line.rb ' + args)
  end # Examples
  include Examples
  def test_ruby_assertions
    assert(self.class.included_modules.include?(AssertionsModule))
    refute_empty([1])
  end # ruby_assertions

  def test_DefinitionalConstants
    CommandLineSubExecutable # .assert_pre_conditions
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
    assert_equal(Script_class, CommandLineSubExecutable)
    assert_equal(Script_command_line.test_executable.unit.model_class?, Script_class)
  end # DefinitionalConstants

  def test_argument_type
    assert_equal(Dir, CommandLineSubExecutable.argument_type('/*'))
    assert_equal(File, CommandLineSubExecutable.argument_type('/'), CommandLineSubExecutable.inspect)
    #	assert(Branch.branch_names?.include?(:master), Branch.branch_names?.inspect)
    #	assert_equal(Branch, CommandLineSubExecutable.argument_type('master'))
    assert_equal(Unit, CommandLineSubExecutable.argument_type('command_line'))
    #	assert_equal(Method, CommandLineSubExecutable.argument_type('error_score?'))
  end # argument_type

  def test_initialize
#    refute_nil(No_arg_run.test_executable.unit.model_class?)
    refute_nil(Script_command_line.test_executable.unit.model_class?)
  end # values

  def test_arguments
  end # arguments

  def test_number_of_arguments
#    assert_equal(0, No_side_effects_sub_command_line.number_of_arguments)
  end # number_of_arguments

  def test_sub_command
#    assert_equal(:state?, No_side_effects_sub_command_line.sub_command)
#		assert_equal(:help, Not_virtus_unit_commandline.sub_command)
		assert_equal(:version_comparison, No_side_effects_default_line.sub_command)
		assert_equal(:help, No_arg_run.sub_command, No_arg_run.inspect)
    assert_equal(:help, Script_command_line.sub_command, Script_command_line.inspect)
  end # sub_command

  def test_argument_types
    Not_virtus_unit_commandline.arguments.map do |argument|
      refute_empty(Dir[argument])
    end # map
    #	assert_equal([Method], No_side_effects_sub_command_line.argument_types)
  end # argument_types

  def test_find_examples
    constants = RailsishRubyUnit::Executable.model_class?.constants
#    assert(constants.include?(:Examples))
#    example_constants = RailsishRubyUnit::Executable.model_class?::Examples.constants
#    example_classes = RailsishRubyUnit::Executable.model_class?::Examples.constants.map do |example_name|
#      example_fully_qualified_name = RailsishRubyUnit::Executable.model_class_name.to_s + '::Examples::' + example_name.to_s
#      example_value = eval(example_fully_qualified_name)
#      example_class = example_value.class
#      Example.new(containing_class: CommandLineSubExecutable, example_constant_name: example_name)
#    end # map
#    assert_equal(example_classes, Example.find_all_in_class(CommandLineSubExecutable))
    refute_equal([], Example.find_all_in_class(TestRun))
    Example.find_all_in_class(TestRun).each do |example|
    end # each
#    refute_equal([], Example.find_by_class(CommandLineSubExecutable, CommandLineSubExecutable))
#    refute_equal([], Script_command_line.find_examples, Script_command_line.inspect)
#    refute_equal([], No_side_effects_sub_command_line.find_examples, No_side_effects_sub_command_line.inspect)
    #			assert_equal(example_class, RailsishRubyUnit::Executable.model_class?)
#    refute_equal([], No_side_effects_sub_command_line.find_examples)
    refute_equal([], Not_virtus_unit_commandline.find_examples)
#    refute_equal([], Script_command_line.find_examples)
  end # find_examples

  def test_find_example?
#    refute_equal([], No_side_effects_sub_command_line.find_examples)
    refute_equal([], Not_virtus_unit_commandline.find_examples)
#    refute_equal([], Script_command_line.find_examples)
#    refute_nil(No_side_effects_sub_command_line.find_example?)
    refute_nil(Not_virtus_unit_commandline.find_example?)
#    refute_nil(Script_command_line.find_example?)
    #	assert_equal(TestRun::Examples::Default_testRun, No_side_effects_sub_command_line.find_example?.value)
    #	assert_equal(CommandLineSubExecutable::Examples::Script_command_line, Not_virtus_unit_commandline.find_example?.value)
#    assert_equal(CommandLineSubExecutable::Examples::Script_command_line, Script_command_line.find_example?.value)
  end # find_example?

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

    assert_includes(CommandLineSubExecutable.included_modules, Virtus::InstanceMethods)
    refute_includes(Not_virtus_unit_commandline.test_executable.unit.model_class?.included_modules, Virtus::InstanceMethods)
    test_run_object = CommandLineSubExecutable.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME))
    #	assert_equal(test_run_object.methods, No_side_effects_sub_command_line.executable_object.methods)
    #	assert_equal(test_run_object, No_side_effects_sub_command_line.executable_object)
    #	assert_equal(test_run_object.test_executable, No_side_effects_sub_command_line.executable_object.test_executable)
    refute_nil(test_run_object.test_executable)
    assert_instance_of(TestExecutable, test_run_object.test_executable)
    #	assert_equal($0, test_run_object.test_executable.argument_path.relative_pathname.to_s)
    #	assert_equal($0, No_side_effects_sub_command_line.test_executable_object.test_test_executable.argument_path.relative_pathname.to_s)
  end # executable_object

	def test_find_sub_command_instance_method
#    assert_instance_of(MethodModel, No_side_effects_sub_command_line.find_sub_command_instance_method(:state?), No_side_effects_sub_command_line.sub_command_instance_methods)
#    assert_instance_of(NilClass, Not_virtus_unit_commandline.find_sub_command_instance_method(:help), Not_virtus_unit_commandline.sub_command_instance_methods)
		assert_instance_of(MethodModel, No_side_effects_default_line.find_sub_command_instance_method)

#    assert_instance_of(MethodModel, No_side_effects_sub_command_line.find_sub_command_instance_method)
    assert_instance_of(NilClass, Script_command_line.find_sub_command_instance_method, Script_command_line.sub_command_instance_methods)
#		assert_instance_of(NilClass, No_arg_run.find_sub_command_instance_method)

#    assert_equal("Merge#state? is a instance method of class Merge\n", No_side_effects_sub_command_line.find_sub_command_instance_method(:state?), No_side_effects_sub_command_line.sub_command_instance_methods)
#    assert_equal({}, Not_virtus_unit_commandline.find_sub_command_instance_method(:help), Not_virtus_unit_commandline.sub_command_instance_methods)

#    assert_equal({}, No_side_effects_sub_command_line.find_sub_command_instance_method)
#		assert_equal({}, No_side_effects_default_line.find_sub_command_instance_method)
#		assert_equal({}, No_arg_run.find_sub_command_instance_method)
#    assert_equal({}, Script_command_line.find_sub_command_instance_method, Script_command_line.sub_command_instance_methods)
	end # find_sub_command_instance_method

  def test_sub_command_instance_methods
    assert_equal(-1, Script_command_line.method(:initialize).arity)
    #	assert_equal(0, Script_command_line.method(:sub_command_instance_methods).arity)
    #	assert_equal(-2, No_arg_run.test_executable.unit.model_class?.method(:initialize).arity)
    #	assert_equal(-2, Script_command_line.test_executable.unit.model_class?.method(:initialize).arity)

    refute_equal([], Script_command_line.executable_object.methods(true))
#    refute_equal([], No_side_effects_sub_command_line.executable_object.methods(true))
    refute_equal([], Not_virtus_unit_commandline.executable_object.methods(true))

    refute_equal([], Script_command_line.executable_object.class.instance_methods(false), Script_command_line.executable_object.methods(true))
#    refute_equal([], No_side_effects_sub_command_line.executable_object.class.instance_methods(false), No_side_effects_sub_command_line.executable_object.methods(true))
    refute_equal([], Not_virtus_unit_commandline.executable_object.class.instance_methods(false), Not_virtus_unit_commandline.executable_object.methods(true))
    # refute_equal([], Script_command_line.sub_command_instance_methods)
    # refute_equal([], No_side_effects_sub_command_line.sub_command_instance_methods)
    # refute_equal([], Not_virtus_unit_commandline.sub_command_instance_methods)
#    refute_equal([], No_side_effects_sub_command_line.executable_object.methods(true))
#    executable_object = No_side_effects_sub_command_line.executable_object
#    puts executable_object.methods(true).map do |method_name|
#      ancestors = executable_object.class.ancestors.select do |ancestor|
#        ancestor.instance_methods(false).include?(method_name)
#      end # each
#      { method_name: method_name, ancestors: ancestors }
#    end.inspect # each
  end # sub_command_instance_methods
	
	def test_sub_command_method
#    assert_instance_of(Method, Script_command_line.sub_command_method, Script_command_line.sub_command_instance_methods)

#    assert_instance_of(Method, Script_command_line.sub_command_method, Script_command_line.sub_command_instance_methods)
#    assert_instance_of(Method, No_side_effects_sub_command_line.sub_command_method, No_side_effects_sub_command_line.sub_command_instance_methods)
#    assert_instance_of(Method, Not_virtus_unit_commandline.sub_command_method, Not_virtus_unit_commandline.sub_command_instance_methods)

#    assert_instance_of(Method, No_side_effects_sub_command_line.sub_command_method)
#		assert_instance_of(Method, No_side_effects_default_line.sub_command_method)
#		assert_instance_of(Method, No_arg_run.sub_command_method)
	end # sub_command_method
	
  def test_candidate_sub_commands_strings
  end # candidate_sub_commands_strings

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

  def test_executable_method?
    refute_nil(Script_command_line.executable_object)
    assert(Script_command_line.executable_object.respond_to?(:argument_types))

    refute_nil(Script_command_line.executable_method?(:argument_types))
    test_run = ShellCommands.new('ruby -W0 script/command_line.rb editor minimal test/unit/samba_test.rb')
    #	assert(test_run.success?, test_run.inspect)
  end # executable_method?

  def test_dispatch_required_arguments
    #	assert_equal(0, No_side_effects_sub_command_line.method(:error_score?).required_arguments, No_side_effects_sub_command_line.to_s)

    #	fail Exception.new('infinite loop follows')

    #	refute_nil(No_side_effects_sub_command_line.dispatch_required_arguments($0))
  end # dispatch_required_arguments

  def test_run
    CommandLineSubExecutable # .assert_pre_conditions
    refute_nil(ARGV)
    #		SELF.run do
    #		end # do run
    #    No_side_effects_sub_command_line.run
    #		No_side_effects_default_line.assert_pre_conditions
    #		No_side_effects_sub_command_line.assert_pre_conditions
    #		No_side_effects_default_line.run
    #		No_side_effects_sub_command_line.run
    assert_match(/-t /, No_side_effects_default_line.run, No_side_effects_default_line.inspect)
    #		assert_equal(:state?, No_side_effects_sub_command_line.sub_command, No_side_effects_sub_command_line.inspect)
    #		assert_equal([:dirty], No_side_effects_sub_command_line.run, No_side_effects_sub_command_line.inspect)
    editor_command_string = 'ruby -W1 script/command_line_sub_executable.rb editor test_files app/models/editor.rb'
    editor_command_line = ShellCommands.new(editor_command_string)
    text = editor_command_line.output.lines[-1, 1][0]
    assert_instance_of(String, text)
    assert_match(TestDiffuse.test_files(TestDiffuse.test_executable.unit.edit_files), text)
  end # run
end # CommandLineSubExecutable

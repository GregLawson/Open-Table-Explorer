###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
#require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../assertions/command_line_assertions.rb'
class CommandLineTest < TestCase
include CommandLine::Examples
Test_unit = Unit.new(:TestRun)
require Test_unit.model_pathname?
Test_unit_commandline = CommandLine.new(Test_unit.model_test_pathname?, Test_unit.model_class?, ['error_score?', $0])
Not_virtus_unit = Unit.new(:CommandLine)
Not_virtus_unit_commandline = CommandLine.new(Not_virtus_unit.model_test_pathname?, Not_virtus_unit.model_class?, ['help', $0])
def test_ruby_assertions
	assert(self.class.included_modules.include?(AssertionsModule))
	refute_empty([1])
end # ruby_assertions

def test_Constants
	CommandLine.assert_pre_conditions
	Test_unit_commandline.assert_pre_conditions
	Not_virtus_unit_commandline.assert_pre_conditions
	assert_equal({:inspect=>false, :test=>false, :help=>false, :individual_test=>false}, Script_command_line)
	if Script_command_line.number_of_arguments > 0 then
		Script_command_line.arguments.each_with_index do |argument, i|
			puts argument.to_s + ' type of ' + Script_command_line.argument_types[i]
		end # each
	else
		puts "No arguments"
	end # if
	assert_equal(Command, :command_line)
	assert_equal(Script_class, CommandLine)
	assert_equal(Script_command_line.unit_class, Script_class)
end # Constants

def test_initialize
	refute_nil(No_args.unit_class)
	refute_nil(Script_command_line.unit_class)
end #initialize
def test_to_s
	refute_equal('', Test_unit_commandline.to_s)
	assert_match('', Test_unit_commandline.to_s)
end # to_s
def test_arguments
end # arguments
def test_number_of_arguments
	assert_equal(1, Test_unit_commandline.number_of_arguments)
end # number_of_arguments
def test_sub_command
	assert_equal(:error_score?, Test_unit_commandline.sub_command)
end # sub_command
def test_argument_types
	Test_unit_commandline.arguments.map do |argument|
		refute_empty(Dir[argument])
	end # map
#	assert_equal([Method], Test_unit_commandline.argument_types)
end # argument_types
def test_find_examples
	assert(Unit::Executable.model_class?.constants.include?(:Examples), Unit::Executable.model_class?.constants.inspect)
	constants = Unit::Executable.model_class?.constants
	assert(constants.include?(:Examples))
	example_constants = Unit::Executable.model_class?::Examples.constants
	example_classes = Unit::Executable.model_class?::Examples.constants.map do |example_name|
			example_fully_qualified_name = Unit::Executable.model_class_name.to_s + '::Examples::' + example_name.to_s
			example_value = eval(example_fully_qualified_name)
			example_class = example_value.class
			Example.new(containing_class: CommandLine, example_constant_name: example_name)

			end # map
	assert_equal(example_classes, Example.find_all_in_class(CommandLine))
	refute_equal([], Example.find_all_in_class(TestRun))
	Example.find_all_in_class(TestRun).each do |example|
	end # each
	refute_equal([], Example.find_by_class(CommandLine, CommandLine))
	refute_equal([], Script_command_line.find_examples, Script_command_line.to_s)
	refute_equal([], Test_unit_commandline.find_examples, Test_unit_commandline.to_s)
#			assert_equal(example_class, Unit::Executable.model_class?)
	refute_equal([], Test_unit_commandline.find_examples)
	refute_equal([], Not_virtus_unit_commandline.find_examples)
	refute_equal([], Script_command_line.find_examples)
end # find_examples
def test_find_example?
	refute_equal([], Test_unit_commandline.find_examples)
	refute_equal([], Not_virtus_unit_commandline.find_examples)
	refute_equal([], Script_command_line.find_examples)
	refute_nil(Test_unit_commandline.find_example?)
	refute_nil(Not_virtus_unit_commandline.find_example?)
	refute_nil(Script_command_line.find_example?)
	assert_equal(TestRun::Examples::Default_testRun, Test_unit_commandline.find_example?.value)
	assert_equal(CommandLine::Examples::Script_command_line, Not_virtus_unit_commandline.find_example?.value)
	assert_equal(CommandLine::Examples::Script_command_line, Script_command_line.find_example?.value)
end # find_example?
def test_executable_object
	assert_includes(Test_unit_commandline.unit_class.included_modules, Virtus::InstanceMethods)
	test_run_object = TestRun.new(executable: TestExecutable.new(executable_file: $0))
	assert_equal(test_run_object.methods, Test_unit_commandline.executable_object.methods)
#	assert_equal(test_run_object, Test_unit_commandline.executable_object)
#	assert_equal(test_run_object.executable, Test_unit_commandline.executable_object.executable)
	refute_nil(test_run_object.executable)
	assert_equal($0, test_run_object.executable.executable_file)
	assert_equal($0, Test_unit_commandline.executable_object.executable.executable_file)

	refute_includes(CommandLine.included_modules, Virtus::InstanceMethods)
	refute_includes(Not_virtus_unit_commandline.unit_class.included_modules, Virtus::InstanceMethods)
	test_run_object = CommandLine.new(TestExecutable.new_from_path($0))
#	assert_equal(test_run_object.methods, Test_unit_commandline.executable_object.methods)
#	assert_equal(test_run_object, Test_unit_commandline.executable_object)
#	assert_equal(test_run_object.executable, Test_unit_commandline.executable_object.executable)
	refute_nil(test_run_object.executable)
	assert_instance_of(TestExecutable, test_run_object.executable)
	assert_equal($0, test_run_object.executable.executable_file)
	assert_equal($0, Test_unit_commandline.executable_object.executable.executable_file)
end # executable_object
def test_executable_method
	refute_nil(Script_command_line.executable_object)
	assert(Script_command_line.executable_object.respond_to?(:argument_types))

	refute_nil(Script_command_line.executable_method(:argument_types))
	refute_nil(Script_command_line.executable_method(:argument_types))
	refute_nil(Script_command_line.executable_method(:argument_types))
	assert(ShellCommand.new('ruby -W0 script/command_line.rb editor minimal test/unit/samba_test.rb').success?)
end # executable_method
def test_arity
	refute_nil(Script_command_line.executable_method(:argument_types))
	assert_equal(0, Script_command_line.arity(:argument_types), Script_command_line.to_s)
	assert_equal(-1, Script_command_line.arity(:executable_object), Script_command_line.to_s)
	assert_equal(1, Script_command_line.arity(:executable_method), Script_command_line.to_s)
	assert_equal(1, Script_command_line.arity(:arity), Script_command_line.to_s)
	assert_equal(-1, Test_unit_commandline.arity(:error_score?), Test_unit_commandline.to_s)
end # arity
def test_default_arguments?
	assert_equal(false, Script_command_line.default_arguments?(:argument_types), Script_command_line.to_s)
	assert_equal(true, Script_command_line.default_arguments?(:executable_object), Script_command_line.to_s)
	assert_equal(false, Script_command_line.default_arguments?(:executable_method), Script_command_line.to_s)
	assert_equal(false, Script_command_line.default_arguments?(:arity), Script_command_line.to_s)
end # default_arguments
def test_required_arguments
	executable_object = Test_unit_commandline.executable_object
	assert_equal(:error_score?, Test_unit_commandline.sub_command)
	assert_respond_to(executable_object, Test_unit_commandline.sub_command)
	method = executable_object.method(Test_unit_commandline.sub_command)
	assert_equal(-1, method.arity)
	assert_equal(0, Test_unit_commandline.required_arguments(:error_score?), Test_unit_commandline.to_s)
end # required_arguments
def test_dispatch_one_argument
	assert_equal(0, Test_unit_commandline.required_arguments(:error_score?), Test_unit_commandline.to_s)

	fail Exception.new('possible infinite loop here')

	refute_nil(Test_unit_commandline.dispatch_one_argument($0))
end # dispatch_one_argument
def test_candidate_commands
	assert_equal(0, Script_command_line.method(:candidate_commands).arity)
	assert_equal(-2, Script_command_line.method(:initialize).arity)
#	assert_equal(-2, No_args.unit_class.method(:initialize).arity)
#	assert_equal(-2, Script_command_line.unit_class.method(:initialize).arity)
end # candidate_commands
def test_candidate_commands_strings
end # candidate_commands_strings
def test_command_line_parser
end # command_line_parser
def test_command_line_opts
end # command_line_opts
def test_run
	CommandLine.assert_pre_conditions
	refute_nil(ARGV)
#		SELF.run do
#		end # do run
	Test_unit_commandline.run
end # run
def test_argument_type
	assert_equal(Dir, CommandLine.argument_type('/*'))
	assert_equal(File, CommandLine.argument_type('/'))
	assert(Branch.branch_names?.include?(:master), Branch.branch_names?.inspect) 
	assert(Branch.branch_names?.include?(:master)) 
	assert_equal(Branch, CommandLine.argument_type('master'))
	assert_equal(Unit, CommandLine.argument_type('command_line'))
	assert_equal(Method, CommandLine.argument_type('error_score?'))
end # argument_type
# ruby -W0 script/command_line.rb
# ruby -W0 script/command_line.rb --help
# ruby -W0 script/command_line.rb help
# ruby -W0 script/command_line.rb help test/unit/command_line_test.rb
def test_no_arg_command
	no_arg_run = CommandLine.assert_command_run('')

	assert_equal('', no_arg_run.errors)
	refute_equal('', no_arg_run.output)
end # no_arg_command
def test_help_command
	help_run = CommandLine.assert_command_run('--help')
	assert_match(/Usage/, help_run.output)
end # help_command
def test_test_command
	CommandLine.assert_command_run('test ' + $0)
end # test_command
def test_inspect_command
	CommandLine.assert_command_run('inspect ' + $0)
end # inspect_command
def test_readme_example
#	 ruby -W0 test/unit/command_line_test.rb -n test_executable_object
	CommandLine.assert_pre_conditions
	assert_instance_of(Hash, Readme_opts)
	help_run = ShellCommands.new('ruby -W0 script/command_line.rb --help ')
	assert_equal([], ARGV)

	assert_equal(false, Readme_opts[:monkey])   #=> 192.168.0.1
	assert_equal(nil, Readme_opts[:name])
	assert_equal(4, Readme_opts[:num_limbs])

	assert_equal({:monkey=>false, :name=>nil, :num_limbs=>4, :help=>false}, Readme_opts.to_hash)  #=> { host: "192.168.0.1", port: 80, verbose: true, quiet: false }end #Examples
	CommandLine.assert_pre_conditions
end #Examples
end #CommandLine

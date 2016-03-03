###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
#require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_executable.rb'
class FileArgumentTest < TestCase
include FileArgument::Examples
def test_unit_file_type
	assert_equal(:unit, TestSelf.unit_file_type)
	assert_equal(:unit, TestMinimal.unit_file_type)
	assert_equal(:non_unit, Not_unit.unit_file_type)
	assert_nil(Not_unit.pattern)
	refute_nil(Unit_non_executable.pattern, Unit_non_executable.inspect)
	assert_equal(:unit_log, Unit_non_executable.unit_file_type)
	assert_equal(:data_sources_dir, Not_unit_executable.unit_file_type)
end # unit_file_type
def test_unit_file?
	assert_equal(true, TestSelf.unit_file?)
	assert_equal(true, TestMinimal.unit_file?)
	assert_equal(true, Unit_non_executable.unit_file?)
	assert_equal(false, Not_unit.unit_file?)
	assert_equal(false, Not_unit_executable.unit_file?)
end # unit_file?
def generatable_unit_file?
	assert_equal(true, TestSelf.generatable_unit_file?)
	assert_equal(true, TestMinimal.generatable_unit_file?)
	assert_equal(false, Unit_non_executable.generatable_unit_file?)
	assert_equal(false, Not_unit.generatable_unit_file?)
	assert_equal(false, Not_unit_executable.generatable_unit_file?)
end # generatable_unit_file?
def test_regression_unit_test_file
	assert_equal(File.expand_path($PROGRAM_NAME), TestSelf.regression_unit_test_file)
	assert_equal(File.expand_path(TestMinimal.argument_path), TestMinimal.regression_unit_test_file)
	assert_equal(File.expand_path(Not_unit.argument_path), Not_unit.regression_unit_test_file)
	assert_equal(File.expand_path(Unit_non_executable.unit.pathname_pattern?(:unit)), Unit_non_executable.regression_unit_test_file)
	assert_equal(File.expand_path(Not_unit_executable.unit.pathname_pattern?(:unit)), Not_unit_executable.regression_unit_test_file)
end # regression_unit_test_file
def test_recursion_danger?
end # recursion_danger?
end # FileArgument

class TestExecutableTest < TestCase
include TestExecutable::Examples
include Repository::Constants
def test_TestExecutable_initialize
	assert_equal(nil, TestTestExecutable.test)
	assert_equal(:unit, TestTestExecutable.test_type, TestTestExecutable.inspect)
#	TestExecutable.column_names.each do |n|
#		assert_instance_of(String,n)
#	end #each
	
#	Singular_executable.assert_logical_primary_key_defined
#	Stream_pattern_executable.assert_logical_primary_key_defined()
#	Unit_executable.assert_logical_primary_key_defined()
	assert_equal(:unit, TestTestExecutable.test_type, TestTestExecutable.inspect)
	assert_equal(:unit, TestTestExecutable.test_type)
end # values
def test_new_from_path
	argument_path = $0
	unit = Unit.new_from_path(argument_path)
	repository = Repository::This_code_repository
	new_executable = TestExecutable.new(argument_path: argument_path, 
								unit: unit, repository: repository)
	new_from_path_executable = TestExecutable.new_from_path($0)
	assert_instance_of(TestExecutable, new_executable)
end # new_from_path
def test_testable?
	assert_equal(true, TestSelf.testable?)
	assert_equal(false, TestSelf.testable?(:recursion_danger))
	assert_equal(true, TestMinimal.testable?)
	assert_equal(true, TestMinimal.testable?(:recursion_danger))
	assert_equal(nil, Not_unit.testable?)
	assert_equal(true, Not_unit_executable.testable?, Unit_non_executable.inspect)
	assert_equal(true, Unit_non_executable.testable?, Unit_non_executable.inspect)
end # testable?
def test_regression_test
end # regression_test
def test_log_path?
	unit = Unit.new_from_path($0)
	refute_nil(unit)
	assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable.log', TestTestExecutable.log_path?)
end # log_path?
def test_ruby_test_string
	argument_path = $PROGRAM_NAME
	ruby_test_string = TestTestExecutable.ruby_test_string
	assert_match(argument_path, ruby_test_string)
end # ruby_test_string
def test_write_error_file
	recent_test = ShellCommands.new('pwd')
	TestTestExecutable.write_error_file(recent_test)

end # write_error_file
def test_write_commit_message
	recent_test = ShellCommands.new('pwd')
	TestTestExecutable.write_commit_message(recent_test, [$0])
end # write_commit_message
def test_Examples
	assert_equal(:unit, TestTestExecutable.test_type)
	assert_equal(:unit, TestSelf.test_type)
	assert_equal(:unit, TestMinimal.test_type)
	assert_equal(:unit, Not_unit.test_type)
	assert_equal(:unit, Unit_non_executable.test_type)
	assert_equal(:unit, Not_unit_executable.test_type)
end # Examples
end # TestExecutable

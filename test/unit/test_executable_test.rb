###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative 'test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_executable.rb'
class TestExecutableTest < TestCase
  include TestExecutable::Examples
  include Repository::DefinitionalConstants
  def test_TestExecutable_initialize
    #	assert_equal(nil, TestTestExecutable.test)
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
    argument_path = $PROGRAM_NAME
    unit = Unit.new_from_path(argument_path)
    repository = Repository::This_code_repository
    new_executable = TestExecutable.new(argument_path: argument_path,
                                        unit: unit, repository: repository)
    new_from_path_executable = TestExecutable.new_from_path($PROGRAM_NAME)
    assert_instance_of(TestExecutable, new_executable)
  end # new_from_path

  def test_regression_unit_test_file
    assert_equal(RepositoryPathname.new_from_path('test/unit/test_executable_test.rb').to_s, TestSelf.regression_unit_test_file.to_s)
    assert_equal(RepositoryPathname.new_from_path($PROGRAM_NAME).expand_path.to_s, TestSelf.regression_unit_test_file.to_s)
    assert_equal(Pathname.new(TestMinimal.argument_path).expand_path.to_s, TestMinimal.regression_unit_test_file.to_s)
    assert_equal(Pathname.new(Not_unit.argument_path).expand_path.to_s, Not_unit.regression_unit_test_file.to_s)
    assert_equal(Pathname.new(Not_unit_executable.argument_path).expand_path.to_s, Not_unit_executable.regression_unit_test_file.to_s)
    assert_equal(Pathname.new(Unit_non_executable.argument_path).expand_path.to_s, Unit_non_executable.regression_unit_test_file.to_s)
    assert_equal(true, Non_test.generatable_unit_file?)
    assert_equal('test/unit/test_executable_test.rb', Non_test.regression_unit_test_file.relative_pathname.to_s)
  end # regression_unit_test_file

  def test_recursion_message
    message = 'recursion_danger? since ' + TestSelf.regression_unit_test_file.expand_path.to_s + '==' + File.expand_path($PROGRAM_NAME)

    assert_equal(message, TestSelf.recursion_message)
    assert_equal('', TestMinimal.recursion_message)
    assert_equal('', Unit_non_executable.recursion_message)
    assert_equal('', Not_unit.recursion_message)
    assert_equal('', Not_unit_executable.recursion_message)
    assert_equal('test/unit/test_executable_test.rb', Non_test.regression_unit_test_file.relative_pathname.to_s)
    assert_equal(File.expand_path($PROGRAM_NAME), Non_test.regression_unit_test_file.expand_path.to_s)
    assert_equal(message, Non_test.recursion_message)
  end # recursion_message

  def test_recursion_danger?
    assert_equal(true, TestSelf.recursion_danger?)
    assert_equal(false, TestMinimal.recursion_danger?)
    assert_equal(false, Unit_non_executable.recursion_danger?)
    assert_equal(false, Not_unit.recursion_danger?)
    assert_equal(false, Not_unit_executable.recursion_danger?)
    assert_equal('test/unit/test_executable_test.rb', Non_test.regression_unit_test_file.relative_pathname.to_s)
    assert_equal(File.expand_path($PROGRAM_NAME), Non_test.regression_unit_test_file.expand_path.to_s)
    assert_equal(true, Non_test.recursion_danger?)
  end # recursion_danger?

  def test_testable?
    assert_equal(false, TestSelf.testable?)
    assert_equal(true, TestMinimal.testable?)
    assert_equal(nil, Not_unit.testable?)
    assert_equal(true, Not_unit_executable.testable?, Unit_non_executable.inspect)
    assert_equal(true, Unit_non_executable.testable?, Unit_non_executable.inspect)
    assert_equal(false, Ignored_data_source.generatable_unit_file?, Ignored_data_source.inspect)
    assert_equal(nil, Ignored_data_source.testable?, Ignored_data_source.inspect)
  end # testable?

  def test_regression_test
  end # regression_test

  def test_log_path?
    unit = Unit.new_from_path($PROGRAM_NAME)
    refute_nil(unit)
    assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable.log', TestTestExecutable.log_path?(nil))
    assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable/test_log_path?.log', TestTestExecutable.log_path?('test_log_path?'))
    assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable/test_log_path?.log', TestTestExecutable.log_path?(:'test_log_path?'))
    assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable/test_log_path?.log', TestTestExecutable.log_path?(:test_log_path?))
  end # log_path?

  def test_ruby_test_string
    assert_match($PROGRAM_NAME, TestTestExecutable.ruby_test_string(nil))
    assert_match(' --name test_Constants', TestMinimal.ruby_test_string(:test_Constants))
  end # ruby_test_string

  def test_all_test_names
    grep_run = ShellCommands.new('grep "^ *def test_" ' + TestTestExecutable.regression_unit_test_file.to_s)
    refute_empty(grep_run.output.split("\n"))
    test_names = grep_run.output.split("\n").map do |line|
      line[11..-1]
    end # map
    assert_equal(test_names, TestTestExecutable.all_test_names)
    refute_empty(test_names.compact, grep_run.output.inspect)
    refute_empty(test_names.compact, grep_run.inspect)
    assert_include(TestSelf.all_test_names, 'all_test_names')
    assert_include(TestMinimal.all_test_names, 'Minimal_Examples')
  end # all_test_names

  def test_all_library_method_names
    grep_run = ShellCommands.new('grep "^ *def " ' + RepositoryPathname.new_from_path(TestTestExecutable.unit.pathname_pattern?(:model)).to_s)
    refute_empty(grep_run.output.split("\n"))
    library_method_names = grep_run.output.split("\n").map do |line|
      line[6..-1]
    end # map
    assert_equal(library_method_names, TestTestExecutable.all_library_method_names)
    assert_include(TestSelf.all_library_method_names, 'all_test_names')
  end # all_library_method_names

  def test_Examples
    assert_equal(:unit, TestTestExecutable.test_type)
    assert_equal(:unit, TestSelf.test_type)
    assert_equal(:unit, TestMinimal.test_type)
    assert_equal(:unit, Not_unit.test_type)
    assert_equal(:unit, Unit_non_executable.test_type)
    assert_equal(:unit, Not_unit_executable.test_type)
  end # Examples
end # TestExecutable

###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_run.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
class TestRunTest < TestCase
  include TestExecutable::Examples
  include TestRun::Examples
  module Examples
    include TestRun::Constants
    Allways_timeout = 0.00001
    Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable)
    Default_subtestRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test: :test_compare)
    Forced_timeout_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test_run_timeout: Allways_timeout)
    TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path(__FILE__, :unit)) # avoid recursion
  end # Examples
  include Examples
  include Repository::Constants
  def test_TestRun_explain_elapsed_time
    assert_equal(TestRun::DefinitionalConstants.explain_elapsed_time(Default_testRun, Default_testRun.cached_recent_test[:recent_test]), Default_testRun.explain_exception)
    assert_equal(TestRun::DefinitionalConstants.explain_elapsed_time(Default_subtestRun, Default_subtestRun.cached_recent_test[:recent_test]), Default_subtestRun.explain_exception)
  end # explain_elapsed_time

  def test_report_timeout
  end # report_timeout

  def test_Recent_test_default
    assert_equal(true, TestSelf.test_executable.recursion_danger?)
    assert_equal(nil, Recent_test_default.call(TestSelf, nil))
    assert_equal(Default_testRun, ->(test_run, _attribute) { test_run }.call(Default_testRun, nil))
    assert_equal(true, ->(test_run, _attribute) { test_run.test_executable.recursion_danger? }.call(TestSelf, nil))
    assert_equal(false, Default_testRun.test_executable.recursion_danger?, Default_testRun.inspect)
    assert_equal(false, ->(test_run, _attribute) { test_run.test_executable.recursion_danger? }.call(Default_testRun, nil))

    recent_test_default = Recent_test_default.call(Default_testRun, nil)
    assert_instance_of(Hash, recent_test_default)
    assert_instance_of(ShellCommands, recent_test_default[:recent_test])
    assert_instance_of(Float, recent_test_default[:recent_test].elapsed_time)
    assert_equal(nil, recent_test_default[:test])
    assert_instance_of(ShellCommands, recent_test_default[:recent_test])
    assert_instance_of(Float, recent_test_default[:recent_test].elapsed_time)
    assert_equal(nil, recent_test_default[:test])
    assert_instance_of(String, recent_test_default[:recent_test].output)
    assert_equal([:test, :recent_test], recent_test_default.keys, recent_test_default.inspect)
    assert_includes(Forced_timeout_testRun.cached_recent_test.keys, :exception_object_raised, Forced_timeout_testRun.cached_recent_test.inspect)
    assert_equal([:test, :recent_test, :exception_object_raised], Forced_timeout_testRun.cached_recent_test.keys, Forced_timeout_testRun.cached_recent_test.inspect)
    refute_nil(Default_subtestRun.cached_recent_test[:recent_test])
    refute_nil(Default_testRun.cached_recent_test[:recent_test])
    assert_nil(Forced_timeout_testRun.cached_recent_test[:recent_test])
    assert_nil(TestSelf.cached_recent_test)
  end # Recent_test_default

  def test_Timeout_default
    assert_equal(Too_long_for_regression_test, Timeout_default.call(Default_testRun, nil))

    refute_nil(Default_subtestRun.cached_recent_test)
    refute_nil(Default_subtestRun[:test])
    refute_equal(Too_long_for_regression_test, Default_subtestRun.test_run_timeout)
    refute_equal(Too_long_for_regression_test, Timeout_default.call(Default_subtestRun, nil))

    assert_equal(Default_testRun.subtest_timeout, Timeout_default.call(Default_subtestRun, nil))
    refute_nil(Timeout_default.call(Default_subtestRun, nil))
    assert_equal(Default_testRun.subtest_timeout, Timeout_default.call(Default_subtestRun, nil))
    assert_equal(Default_subtestRun.test_run_timeout, Default_testRun.subtest_timeout)
  end # Timeout_default

  def test_All_test_names_default
    refute_nil(Default_testRun.cached_recent_test)
    #	assert_equal([:exception_object_raised], Default_testRun.cached_recent_test.keys)
    refute_nil(Default_testRun.cached_recent_test)
    refute_nil(All_test_names_default.call(Default_testRun, nil))
    refute_empty(All_test_names_default.call(Default_testRun, nil))
		assert_includes(TestSelf.test_executable.all_test_names, 'All_test_names_default')
		assert_includes(All_test_names_default.call(TestSelf, nil), 'All_test_names_default')
  end # All_test_names_default

  def test_TestRun_initialize
    assert_equal(TestExecutable::Examples::TestTestExecutable, Default_testRun.test_executable)
    assert_equal(TestExecutable::Examples::TestTestExecutable.argument_path, Default_testRun.test_executable.argument_path)
    assert_equal(RepositoryPathname.new_from_path($PROGRAM_NAME).relative_pathname.to_s, TestSelf.test_executable.regression_unit_test_file.relative_pathname.to_s)
    assert_equal(TestExecutable::Examples::TestTestExecutable.unit, Default_testRun.test_executable.unit)
  end # values

  def test_new_from_pathname
    argument_path = $PROGRAM_NAME
    unit = Unit.new_from_path(argument_path)
    new_executable = TestExecutable.new(argument_path: argument_path, unit: unit)
  end # new_from_pathname

  def test_explain_elapsed_time
    assert_match(/test_compare in test_executable took /, Default_subtestRun.explain_elapsed_time)
    assert_match(/all tests in test_executable took /, Default_testRun.explain_elapsed_time, Default_testRun.inspect)
    assert_match(/all tests in test_executable timed-out in /, Forced_timeout_testRun.explain_elapsed_time, Forced_timeout_testRun.inspect)
    assert_nil(TestSelf.cached_recent_test, TestSelf.cached_recent_test.inspect)
    assert_match(/recursion danger/, TestSelf.explain_elapsed_time, TestSelf.inspect)
  end # explain_elapsed_time

  def test_explain_exception
    assert_equal(Default_subtestRun.explain_elapsed_time, Default_subtestRun.explain_exception)
    assert_equal(Default_testRun.explain_elapsed_time, Default_testRun.explain_exception)
    assert_includes(Forced_timeout_testRun.cached_recent_test.keys, :exception_object_raised, Forced_timeout_testRun.cached_recent_test.inspect)
    assert_match(/Timeout::Error/, Forced_timeout_testRun.explain_exception, Forced_timeout_testRun.inspect)
    assert_match(/recursion danger/, TestSelf.explain_exception)
  end # explain_exception

  def test_shell
    refute_empty(TestRun.shell('pwd', &:inspect))
  end # shell

  def test_write_error_file
    Default_testRun.write_error_file(nil)
  end # write_error_file

  def test_write_commit_message
    Default_testRun.write_commit_message([$PROGRAM_NAME])
  end # write_commit_message

  def test_error_score?
    argument_path = '/etc/mtab' # force syntax error with non-ruby text
    test_executable = TestExecutable.new(argument_path: argument_path)
    ruby_test_string = test_executable.ruby_test_string(nil)
    recent_test = This_code_repository.shell_command(ruby_test_string)
    error_message = recent_test.process_status.inspect + "\n" + recent_test.inspect
    assert_equal(1, recent_test.process_status.exitstatus, error_message)
    assert_equal(false, recent_test.success?, error_message)
    assert(!recent_test.success?, error_message)
    syntax_test = This_code_repository.shell_command('ruby -c ' + argument_path)
    refute_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
    #	test_run = TestRun.new(test_executable: executable)
    test_run = TestRun.new(test_executable: TestExecutable.new(argument_path: argument_path))
    #	assert_equal(nil, Unit.new_from_path(argument_path))
    #	assert_equal(nil, test_run.executable.unit, test_run.inspect)
    assert_equal(10_000, test_run.error_score?, recent_test.inspect)
    #	Default_testRun.assert_deserving_branch(:edited, executable_file)

    argument_path = 'test/unit/minimal2_test.rb'
    test_executable = TestExecutable.new(argument_path: argument_path)
    log_path = test_executable.log_path?(nil)
    ShellCommands.new('grep "seed 0" ' + log_path) # .assert_post_conditions

    recent_test = This_code_repository.shell_command('ruby ' + argument_path)
    assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
    syntax_test = This_code_repository.shell_command('ruby -c ' + argument_path)
    assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
    assert_equal(0, TestRun.new(test_executable: test_executable).error_score?)
    #	Default_testRun.assert_deserving_branch(:passed, executable_file)
  end # error_score

  def test_subtest_timeout
    assert_instance_of(Float, Default_testRun.subtest_timeout)
  end # subtest_timeout

  def test_conditionally_run_individual_tests
  end # conditionally_run_individual_tests

  def run_individual_tests # moved to long_test
    puts Default_testRun.test_executable.all_test_names.inspect if $VERBOSE
    Default_testRun.run_individual_tests.each do |subtest|
      puts subtest.explain_exception
      assert_match(/ in test_executable took /, subtest.explain_elapsed_time)
      refute_match(/all tests in test_executable took /, subtest.explain_elapsed_time)
    end # each
  end # run_individual_tests

  def test_TestRun_Examples
    refute_includes(Default_testRun.cached_recent_test.keys, :exception_object_raised, Default_testRun.cached_recent_test.inspect)
    refute_includes(Default_subtestRun.cached_recent_test.keys, :exception_object_raised, Default_subtestRun.cached_recent_test.inspect)
    assert_includes(Forced_timeout_testRun.cached_recent_test.keys, :exception_object_raised, Forced_timeout_testRun.cached_recent_test.inspect)
    assert_nil(TestSelf.cached_recent_test, TestSelf.cached_recent_test.inspect)
  end # Examples
end # TestRun

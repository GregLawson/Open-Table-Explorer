###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative 'test_environment' # avoid recursive requires
require_relative '../../app/models/test_environment_test_unit.rb'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_run.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
class RecentRunTest < TestCase
  module Examples
    #    include Constants
    Self_executable = TestExecutable.new_from_path(__FILE__, :unit)
    No_side_effects = TestRun.new(test_executable: Self_executable, cached_recent_test: nil, cached_all_test_names: nil) # avoid recursion
    #    include RecentRun::Constants
    Allways_timeout = 0.00001
    Hello_world = RecentRun.new(command_string: 'echo "Hello World"')
    Example_output = "1 2;3 4\n".freeze
    COMMAND_STRING = 'echo "1 2;3 4"'.freeze
    EXAMPLE = RecentRun.new(command_string: COMMAND_STRING)
    Guaranteed_existing_directory = File.expand_path(File.dirname($PROGRAM_NAME))
    Cd_command_array = ['cd', Guaranteed_existing_directory].freeze
    Guaranteed_existing_basename = File.basename($PROGRAM_NAME)
    Relative_command = ['ls', Guaranteed_existing_basename].freeze
    Bad_status = RecentRun.new(command_string: '$?=1')
    Error_message_run = RecentRun.new(command_string: 'ls happyHappyFailFail.junk')
    Forced_timeout_recent_run = RecentRun.new(command_string: 'sleep 0.01', timeout: Allways_timeout)
    Soft_timeout_recent_run = RecentRun.new(command_string: 'sleep 0.01', timeout: 0.011)
  end # Examples
  include Examples
  def test_Recent_test_default
   end # Recent_test_default

  def test_RecentRun_virtus
    refute_nil(Hello_world.command_string, Hello_world.inspect)
    assert_equal(Example_output, EXAMPLE.output)
    assert_includes(Hello_world.cached_run.instance_variables, :@elapsed_time, Hello_world.inspect)
    end # values

  def test_timed_out?
    assert_equal(false, Hello_world.timed_out?, Hello_world.inspect)
    assert_equal(false, EXAMPLE.timed_out?)
    assert_equal(false, Error_message_run.timed_out?)
    assert_kind_of(Exception, Forced_timeout_recent_run.errors[:rescue_exception], Forced_timeout_recent_run.inspect)
    assert_equal(true, Forced_timeout_recent_run.timed_out?, Forced_timeout_recent_run.inspect)
  end # timed_out?

  def test_shell_elapsed_time?
    assert_equal(true, Hello_world.shell_elapsed_time?, Hello_world.inspect)
    assert_equal(false, Forced_timeout_recent_run.shell_elapsed_time?, Forced_timeout_recent_run.inspect)
    assert_equal(true, EXAMPLE.shell_elapsed_time?)
    assert_equal(true, Error_message_run.shell_elapsed_time?)
  end # shell_elapsed_time?

  def test_elapsed_time
    assert_instance_of(Float, Hello_world.elapsed_time, Hello_world.inspect)
    assert_instance_of(Float, Forced_timeout_recent_run.elapsed_time, Forced_timeout_recent_run.inspect)
    assert_instance_of(Float, EXAMPLE.elapsed_time)
    assert_instance_of(Float, Error_message_run.elapsed_time)
  end # elapsed_time

  def test_success?
    assert(Hello_world.success?, Hello_world.inspect)
    assert(EXAMPLE.success?, Hello_world.inspect)
    refute(Error_message_run.success?, Error_message_run.inspect)
    refute(Forced_timeout_recent_run.success?, Forced_timeout_recent_run.inspect)
  end # success?

  def test_RecentRun_explain_elapsed_time
    assert_match(/ with no timeout/, Hello_world.explain_elapsed_time, Hello_world.inspect)
    assert_match(/beyond timeout of /, Forced_timeout_recent_run.explain_elapsed_time, Forced_timeout_recent_run.inspect)
    #    assert_match(/within timeout/, Soft_timeout_recent_run.explain_elapsed_time, Forced_timeout_recent_run.inspect)
  end # explain_elapsed_time

  def test_TestRun_assert_pre_conditions
    end # assert_pre_conditions

  def test_TestRun_assert_post_conditions
    end # assert_post_conditions

  def test_assert_pre_conditions
    Hello_world.assert_pre_conditions
    EXAMPLE.assert_pre_conditions
    Error_message_run.assert_pre_conditions
    Forced_timeout_recent_run.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
    Hello_world.assert_post_conditions
    EXAMPLE.assert_post_conditions
    Error_message_run.assert_post_conditions
    Forced_timeout_recent_run.assert_post_conditions
  end # assert_post_conditions
end # RecentRun

class TestRunTest < TestCase
  include TestExecutable::Examples
  include RecentRunTest::Examples
  module Examples
    include TestRun::Constants
    #    Allways_timeout = 0.00001
    Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestMinimal)
    Default_subtestRun = TestRun.new(test_executable: TestExecutable::Examples::TestMinimal, test: :test_compare)
    Forced_timeout_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test_run_timeout: RecentRunTest::Allways_timeout)
    TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path(__FILE__, :unit)) # avoid recursion
  end # Examples
  include Examples
  include Repository::DefinitionalConstants

  def test_All_test_names_default
    refute_nil(Default_testRun.cached_recent_test)
    #	assert_equal([:rescue_exception], Default_testRun.cached_recent_test.instance_variables)
    refute_nil(Default_testRun.cached_recent_test)
    refute_nil(All_test_names_default.call(Default_testRun, nil))
    refute_empty(All_test_names_default.call(Default_testRun, nil))
    assert_includes(TestSelf.test_executable.all_test_names, 'All_test_names_default')
    assert_includes(All_test_names_default.call(TestSelf, nil), 'All_test_names_default')
  end # All_test_names_default

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

  def test_Recent_test_default
    assert_equal(true, TestSelf.test_executable.recursion_danger?)
    assert_equal(nil, Recent_test_default.call(TestSelf, nil))
    assert_equal(Default_testRun, ->(test_run, _attribute) { test_run }.call(Default_testRun, nil))
    assert_equal(true, ->(test_run, _attribute) { test_run.test_executable.recursion_danger? }.call(TestSelf, nil))
    assert_equal(false, Default_testRun.test_executable.recursion_danger?, Default_testRun.inspect)
    assert_equal(false, ->(test_run, _attribute) { test_run.test_executable.recursion_danger? }.call(Default_testRun, nil))

    recent_test_default = Recent_test_default.call(Default_testRun, nil)
    assert_instance_of(RecentRun, recent_test_default)
    assert_instance_of(ShellCommands, recent_test_default.cached_run)
    assert_instance_of(Float, recent_test_default.elapsed_time)
    assert_instance_of(String, recent_test_default.output)
    assert_includes(Forced_timeout_testRun.cached_recent_test.errors.keys, :rescue_exception, Forced_timeout_testRun.cached_recent_test.inspect)
    refute_nil(Default_subtestRun.cached_recent_test)
    refute_nil(Default_testRun.cached_recent_test)
    assert_nil(Forced_timeout_testRun.cached_recent_test.cached_run)
    assert_nil(TestSelf.cached_recent_test)
  end # Recent_test_default

  def test_TestRun_initialize
    assert_equal(TestExecutable::Examples::TestMinimal, Default_testRun.test_executable)
    assert_equal(TestExecutable::Examples::TestMinimal.argument_path, Default_testRun.test_executable.argument_path)
    assert_equal(RepositoryPathname.new_from_path($PROGRAM_NAME).relative_pathname.to_s, TestSelf.test_executable.regression_unit_test_file.relative_pathname.to_s)
    assert_equal(TestExecutable::Examples::TestMinimal.unit, Default_testRun.test_executable.unit)
  end # values

  def test_all_test_names
  end # all_test_names

  def test_run_style
    assert_equal(:recursion_danger, TestSelf.run_style, TestSelf.inspect)

    assert_instance_of(RecentRun, Forced_timeout_testRun.cached_recent_test)
    assert_equal(:timeout_exception, Forced_timeout_testRun.run_style)
    #		assert_includes(Default_testRun.cached_recent_test.instance_variables, :@elapsed_time, Default_testRun.inspect)
    #		assert_includes(Default_subtestRun.cached_recent_test.instance_variables, :@elapsed_time, Default_subtestRun.inspect)
  end # run_style

  def test_explain_elapsed_time
    assert_match(/test_compare in minimal2 took /, Default_subtestRun.explain_elapsed_time)
    assert_match(/all tests in minimal2 took /, Default_testRun.explain_elapsed_time, Default_testRun.inspect)
    assert_nil(TestSelf.cached_recent_test, TestSelf.cached_recent_test.inspect)
    assert_match(/recursion danger/, TestSelf.explain_elapsed_time, TestSelf.inspect)
    assert_match(/all tests in test_executable took /, Forced_timeout_testRun.explain_elapsed_time, Forced_timeout_testRun.inspect)
    assert_match(/beyond timeout of /, Forced_timeout_testRun.explain_elapsed_time)
  end # explain_elapsed_time

  def test_explain_exception
  end # explain_exception

  def test_shell
    refute_empty(TestRun.shell('pwd', &:inspect))
  end # shell

  def state
    assert_instance_of(String, Default_testRun.state[:current_branch_name])
    assert_instance_of(String, Default_testRun.state[:start_time])
    assert_instance_of(String, Default_testRun.state[:command_string])
    assert_instance_of(String, Default_testRun.state[:output])
    assert_instance_of(String, Default_testRun.state[:errors])
  end # state

  def test_write_error_file
    assert_instance_of(String, Default_testRun.state.ruby_lines_storage)

    #		assert_equal(Default_testRun.state[:current_branch_name].inspect, Default_testRun.state[:current_branch_name].ruby_lines_storage)

    time = Default_testRun.state[:start_time]
    eval_time = eval(time.ruby_lines_storage)
    round_off = time - eval_time
    assert_equal(time, eval_time, time.strftime('%Y-%m-%d %H:%M:%S.%9N %z') + time.ruby_lines_storage + round_off.to_f.to_s)
    #		assert_equal(Default_testRun.state[:command_string].inspect, Default_testRun.state[:command_string].ruby_lines_storage)
    #		assert_equal(Default_testRun.state[:output].inspect, Default_testRun.state[:output].ruby_lines_storage)
    #		assert_equal(Default_testRun.state[:errors].inspect, Default_testRun.state[:errors].ruby_lines_storage)

    #		assert_equal(Default_testRun.state.inspect, Default_testRun.state.ruby_lines_storage)
    Default_testRun.write_error_file(nil)
  end # write_error_file

  def test_write_commit_message
    Default_testRun.write_commit_message([$PROGRAM_NAME])
  end # write_commit_message

  def test_error_score?
    argument_path = '/etc/mtab' # force syntax error with non-ruby text
    test_executable = TestExecutable.new(argument_path: argument_path)
    ruby_test_string = test_executable.ruby_test_string(nil)
    recent_test = Repository::This_code_repository.shell_command(ruby_test_string)
    error_message = recent_test.process_status.inspect + "\n" + recent_test.inspect
    assert_equal(1, recent_test.process_status.exitstatus, error_message)
    assert_equal(false, recent_test.success?, error_message)
    assert(!recent_test.success?, error_message)
    syntax_test = Repository::This_code_repository.shell_command('ruby -c ' + argument_path)
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

    recent_test = Repository::This_code_repository.shell_command('ruby ' + argument_path)
    assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
    syntax_test = Repository::This_code_repository.shell_command('ruby -c ' + argument_path)
    assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
    assert_equal(0, TestRun.new(test_executable: test_executable).error_score?)
    #	Default_testRun.assert_deserving_branch(:passed, executable_file)
  end # error_score

  def test_subtest_timeout
    assert_instance_of(Float, Default_testRun.subtest_timeout)
  end # subtest_timeout

  def test_conditionally_run_individual_tests
  end # conditionally_run_individual_tests

  def test_run_individual_tests # moved to long_test
  end # run_individual_tests

  def test_TestRun_assert_pre_conditions
    end # assert_pre_conditions

  def test_TestRun_assert_post_conditions
    end # assert_post_conditions

  def test_assert_pre_conditions
    Default_testRun.assert_pre_conditions
    Default_subtestRun.assert_pre_conditions
    Forced_timeout_testRun.assert_pre_conditions
    TestSelf.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
    Default_testRun.assert_post_conditions
    Default_subtestRun.assert_post_conditions
    Forced_timeout_testRun.assert_post_conditions
    TestSelf.assert_post_conditions
  end # assert_post_conditions

  def test_TestRun_Examples
    refute_includes(Default_testRun.cached_recent_test.instance_variables, :rescue_exception, Default_testRun.cached_recent_test.inspect)
    refute_includes(Default_subtestRun.cached_recent_test.instance_variables, :rescue_exception, Default_subtestRun.cached_recent_test.inspect)
    Forced_timeout_testRun.assert_pre_conditions
    assert_includes(Forced_timeout_testRun.cached_recent_test.errors.keys, :rescue_exception, Forced_timeout_testRun.cached_recent_test.inspect)
    assert_nil(TestSelf.cached_recent_test, TestSelf.cached_recent_test.inspect)
end # Examples
end # TestRun

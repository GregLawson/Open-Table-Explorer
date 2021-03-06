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
class TestRunTest < TestCase
  include TestExecutable::Examples
  module Examples
    Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable)
    Default_subtestRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test: :test_compare)
  end # Examples
  include Examples
  include Repository::DefinitionalConstants
  def run_individual_tests
    puts Default_testRun.test_executable.all_test_names.inspect if $VERBOSE
    Default_testRun.run_individual_tests.each do |subtest|
      puts subtest.explain_exception
      assert_match(/ in test_executable took /, subtest.explain_elapsed_time)
      refute_match(/all tests in test_executable took /, subtest.explain_elapsed_time)
    end # each
  end # run_individual_tests
end # TestRun

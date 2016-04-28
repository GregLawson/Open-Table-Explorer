###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_run.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
class TestRunTest < TestCase
  include TestExecutable::Examples
  include TestRun::Examples
  include Repository::Constants
  def run_individual_tests
    puts Default_testRun.test_executable.all_test_names.inspect if $VERBOSE
    Default_testRun.run_individual_tests.each do |subtest|
      puts subtest.explain_exception
      assert_match(/ in test_executable took /, subtest.explain_elapsed_time)
      refute_match(/all tests in test_executable took /, subtest.explain_elapsed_time)
    end # each
  end # run_individual_tests

end # TestRun

###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_run.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
class TestRunTest < TestCase
include TestExecutable::Examples
include TestRun::Examples
include Repository::Constants
def test_TestRun_initialize
	assert_equal(TestExecutable::Examples::TestTestExecutable, Default_testRun.test_executable)
	assert_equal(TestExecutable::Examples::TestTestExecutable.argument_path, Default_testRun.test_executable.argument_path)
	assert_equal($PROGRAM_NAME, TestSelf.test_executable.argument_path.relative_pathname.to_s)
	assert_equal(TestExecutable::Examples::TestTestExecutable.unit, Default_testRun.test_executable.unit)
end # test_TestRun_initialize
def test_new_from_pathname
	argument_path = $PROGRAM_NAME
	unit = Unit.new_from_path(argument_path)
	new_executable = TestExecutable.new(argument_path: argument_path, unit: unit)
end # new_from_pathname
def test_shell
	refute_empty(TestRun.shell('pwd'){|run| run.inspect})
end #shell
def test_error_score?
	argument_path = '/etc/mtab' #force syntax error with non-ruby text
	test_executable = TestExecutable.new(argument_path: argument_path)
	ruby_test_string = test_executable.ruby_test_string(nil)
	recent_test = This_code_repository.shell_command(ruby_test_string)
	error_message = recent_test.process_status.inspect+"\n"+recent_test.inspect
	assert_equal(1, recent_test.process_status.exitstatus, error_message)
	assert_equal(false, recent_test.success?, error_message)
	assert(!recent_test.success?, error_message)
		syntax_test=This_code_repository.shell_command("ruby -c "+argument_path)
		refute_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
#	test_run = TestRun.new(test_executable: executable)
	test_run = TestRun.new(test_executable: TestExecutable.new(argument_path: argument_path))
#	assert_equal(nil, Unit.new_from_path(argument_path))
#	assert_equal(nil, test_run.executable.unit, test_run.inspect)
	assert_equal(10000, test_run.error_score?, recent_test.inspect)
#	Default_testRun.assert_deserving_branch(:edited, executable_file)

	argument_path ='test/unit/minimal2_test.rb'
	test_executable = TestExecutable.new(argument_path: argument_path)
	log_path = test_executable.log_path?(nil)
	ShellCommands.new('grep "seed 0" ' + log_path) #.assert_post_conditions

		recent_test=This_code_repository.shell_command("ruby "+argument_path)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+argument_path)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(0, TestRun.new(test_executable: test_executable).error_score?)
#	Default_testRun.assert_deserving_branch(:passed, executable_file)
end # error_score
end # TestRun

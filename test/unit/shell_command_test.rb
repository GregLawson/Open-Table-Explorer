###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/shell_command.rb'
require_relative 'default_test_case.rb'
class ShellCommandsTest < DefaultTestCase2
include ShellCommands::Examples
def test_initialize
	assert_equal(COMMAND_STRING, EXAMPLE.command_string)
	assert_equal("1 2;3 4\n", EXAMPLE.output)
	assert_equal("", EXAMPLE.errors)
	assert_equal(0, EXAMPLE.exit_status.exitstatus)
	assert_equal(EXAMPLE.exit_status.pid, EXAMPLE.pid)
	assert_equal("Hello World\n", Hello_world.output)
end #initialize
def test_system_output
	ret=[] #make method scope not block scope so it can be returned
	Open3.popen3(COMMAND_STRING) {|stdin, stdout, stderr, wait_thr|
		stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
		output=stdout.read
		stdout.close
		errors=stderr.read
		stderr.close
		exit_status = wait_thr.value  # Process::Status object returned.
		pid = wait_thr.pid # pid of the started process.
		exit_status = wait_thr.value # Process::Status object returned.
		ret=[output, errors, exit_status, pid]
	}
	ret
end #system_output
def test_success?
	assert(EXAMPLE.success?)
end #success
def test_puts
	assert_equal(Example_output, EXAMPLE.output)
	assert_equal(EXAMPLE, EXAMPLE.puts) #allow command chaining
end #puts
def test_assert_post_conditions
	message=''
end #assert_post_conditions
end #ShellCommands

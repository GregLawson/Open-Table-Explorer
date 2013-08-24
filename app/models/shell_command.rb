###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'open3'
class ShellCommands
attr_reader :command_string, :output, :errors, :exit_status, :pid
# execute same command again (also called by new.
def execute
	@output, @errors, @exit_status, @pid=system_output(command_string)
	self #allows command chaining
end #execute
def initialize(command_string, delay_execution=nil)
	@command_string=command_string
	if delay_execution.nil? then
		execute # do it first time, then execute
	end #if
end #initialize
def system_output(command_string)
	ret=[] #make method scope not block scope so it can be returned
	Open3.popen3(command_string) {|stdin, stdout, stderr, wait_thr|
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
def success?
	@exit_status==0
end #success
def puts_string
	ret='$ '+@command_string
	ret+="\n"+@output
	ret+="\n"+@errors
end #puts_string
def puts
	$stdout.puts puts_string
	self # return for comand chaining
end #puts
module Examples
Hello_world=ShellCommands.new('echo "Hello World"')
Example_output="1 2;3 4\n"
COMMAND_STRING='echo "1 2;3 4"'
EXAMPLE=ShellCommands.new(COMMAND_STRING)

end #Examples
include Examples
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions(message='')
	self # return for comand chaining
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+=puts_string
	assert_empty(@errors, message)
	assert_equal(0, @exit_status, message)
	self # return for comand chaining
end #assert_post_conditions
end #Assertions
include Assertions
end #ShellCommands
class NetworkInterface
IFCONFIG=ShellCommands.new('/sbin/ifconfig')
#puts IFCONFIG.inspect
end #NetworkInterface

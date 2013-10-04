###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'open3'
require 'shellwords.rb'
class ShellCommands
module ClassMethods
include Shellwords
end #ClassMethods
extend ClassMethods
attr_reader :command_string, :output, :errors, :exit_status, :pid
# execute same command again (also called by new.
def execute
	@output, @errors, @exit_status, @pid=system_output(@command_string)
	self #allows command chaining
end #execute
def initialize(command_string)
	@command_string=command_string
	execute # do it first time, then execute
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
	$stdout.puts inspect if $VERBOSE
	ret
end #system_output
def fork(cmd)
	start(cmd)
	self #allows command chaining
end #fork
def server(cmd)
	start
	self #allows command chaining
end #server
def start(cmd)
	@stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*cmd)
	self #allows command chaining
end #start
def wait
	@exit_status = @wait_thr.value # Process::Status object returned.
	close
	self #allows command chaining
end #wait
def close
	@pid = @wait_thr[:pid]  # pid of the started process
	@stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
	@output=@stdout.read
	@stdout.close
	@errors=@stderr.read
	@stderr.close
	@exit_status = @wait_thr.value  # Process::Status object returned.
	self #allows command chaining
end #close
def success?
	@exit_status==0
end #success
def inspect
	ret=''
	if @errors!='' || @exit_status!=0 then
		ret+="@command_string=#{@command_string.inspect}\n"
	end #if
	if @errors!='' then
		ret+="@errors=#{@errors.inspect}\n"
	end #if
	if @exit_status!=0 then
		ret+="@exit_status=#{@exit_status.inspect}\n"
		ret+="@pid=#{@pid.inspect}\n"
	end #if
	ret+@output.to_s
end #inspect
def puts
	$stdout.puts "$ "+@command_string
	$stdout.puts inspect
	shorter_callers=caller.grep(/^[^\/]/)
	$stdout.puts shorter_callers.join("\n") if $VERBOSE
	self # return for comand chaining
end #puts
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions(message='')
	self # return for comand chaining
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="self=#{inspect}"
	assert_empty(@errors, message+'expected errors to be empty\n'+inspect)
	assert_equal(0, @exit_status, message)
	assert_not_nil(@errors)
	assert_not_nil(@exit_status)
	assert_not_nil(@pid)
	self # return for comand chaining
end #assert_post_conditions
end #Assertions
include Assertions
module Examples
Hello_world=ShellCommands.new('echo "Hello World"')
Example_output="1 2;3 4\n"
COMMAND_STRING='echo "1 2;3 4"'
EXAMPLE=ShellCommands.new(COMMAND_STRING)

end #Examples
include Examples
end #ShellCommands
class NetworkInterface
IFCONFIG=ShellCommands.new('/sbin/ifconfig')
#puts IFCONFIG.inspect
end #NetworkInterface

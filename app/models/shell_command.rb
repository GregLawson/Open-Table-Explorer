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
attr_reader :command_string, :output, :errors, :process_status
# execute same command again (also called by new.
def execute
	@output, @errors, @process_status=system_output(@command_string)
	self #allows command chaining
end #execute
def initialize(command)
	if command.instance_of?(Array) then
		command.map do |e|
			if e.instance_of?(Array) then
				@command_string=Shellwords.join(e)
			elsif e.instance_of?(Hash) then
				command_array=[]
				e.each_pair do |key, word|
					case key
						when :command then command_array+=Shellwords.escape(word)
						when :in then 
							raise "Input file '#{word}' does not exist." if !File.exists?(word)
							command_array+=Shellwords.escape(word)
						when :out then command_array+=Shellwords.escape(word)
						when :inout then command_array+=Shellwords.escape(word)
						else
							word
					end #case
				end #each_pair
				@command_string=command_array.join(' ')
			else
				@command_string=e
			end #if
		end #map
	else
		@command_string=command
	end #if
	execute # do it first time, to repeat call execute
	if $VERBOSE.nil? then
	elsif $VERBOSE then
		$stdout.puts trace # -W2
	else 
		$stdout.puts inspect(:echo_command) # -W1
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
		process_status = wait_thr.value  # Process::Status object returned.
		process_status = wait_thr.value # Process::Status object returned.
		ret=[output, errors, process_status]
	}
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
	@process_status = @wait_thr.value # Process::Status object returned.
	close
	self #allows command chaining
end #wait
def close
	@stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
	@output=@stdout.read
	@stdout.close
	@errors=@stderr.read
	@stderr.close
	@process_status = @wait_thr.value  # Process::Status object returned.
	self #allows command chaining
end #close
def success?
	@process_status.success?
end #success
def inspect(echo_command=@errors!='' || !success?)
	ret=''
	if echo_command then
		ret+="$ #{@command_string}\n"
	end #if
	if @errors!='' then
		ret+="@errors=#{@errors.inspect}\n"
	end #if
	if !success? then
		ret+="@process_status=#{@process_status.inspect}\n"
	end #if
	ret+@output.to_s
end #inspect
def puts
	$stdout.puts inspect(:echo_command)
	self # return for comand chaining
end #puts
def trace
	$stdout.puts inspect(:echo_command)
	shorter_callers=caller.grep(/^[^\/]/)
	$stdout.puts shorter_callers.join("\n")
	self # return for comand chaining
end #trace
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions(message='')
	self # return for comand chaining
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="self=#{inspect}"
	puts unless success?&& @errors.empty?
	assert_empty(@errors, message+'expected errors to be empty\n')
	assert_equal(0, @process_status.exitstatus, message)
	assert_not_nil(@errors, "expect @errors to not be nil.")
	assert_not_nil(@process_status)
	assert_instance_of(Process::Status, @process_status)

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

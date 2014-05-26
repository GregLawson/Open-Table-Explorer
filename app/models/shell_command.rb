###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'open3'
require 'shellwords.rb'
require 'test/unit/assertions.rb'
class ShellCommands
module ClassMethods
include Shellwords
def assemble_hash_command(command)
	command_array=[]
	command.each_pair do |key, word|
		case key
		when :command then command_array << Shellwords.escape(word)
		when :in then 
			raise "Input file '#{word}' does not exist." if !File.exists?(word)
			command_array << Shellwords.escape(word)
		when :out then command_array << Shellwords.escape(word)
		when :inout then command_array << Shellwords.escape(word)
		when :glob then 
			raise "Input pathname glob '#{word}' does not exist." if !Dir(word)==[]
			command_array << Shellwords.escape(word)
		when :environment then command_array << word
		else
			command_array << word
		end #case
	end #each_pair
	command_array.join(' ')
end #assemble_hash_command
def assemble_array_command(command)
	command.map do |e|
		if e.instance_of?(Array) then
			assemble_array_command(e)
		elsif e.instance_of?(Hash) then
			assemble_hash_command(e)
		elsif e.instance_of?(Pathname) then
			e.to_s
		elsif /[ \/.]/.match(e) then # pathnames
			Shellwords.escape(e)
		elsif /[$;&|<>]/.match(e) then #shell special characters
			e
		else # don't know
			e
		end #if
	end.join(' ') #map
end #assemble_array_command
def assemble_command_string(command)
	if command.instance_of?(Array) then
		assemble_array_command(command)
	elsif command.instance_of?(Hash) then
		assemble_hash_command(command)
	else
		command
	end #if
end #assemble_command_string
end #ClassMethods
extend ClassMethods
attr_reader :command_string, :output, :errors, :process_status
# execute same command again (also called by new).
def execute
#	info "@command="+@command.inspect
#	info "@command_string="+@command_string.inspect
	Open3.popen3(@env, @command_string, @opts) {|stdin, stdout, stderr, wait_thr|
		stdin.close  # stdin, stdout and stderr should be closed explicitly in this form.
		@output=stdout.read
		stdout.close
		@errors=stderr.read
		stderr.close
		@process_status = wait_thr.value # Process::Status object returned.
	}
	self #allows command chaining
rescue StandardError => exception
	$stdout.puts "rescue exception "+exception.inspect
#	info "@command="+@command.inspect
#	info "@command_string="+@command_string.inspect
	if @errors.nil? then
		@errors=exception.inspect
	else
		@errors+=exception.inspect
	end #if
end #execute
# prefer command as array since each element is shell escaped.
# Most common need for shell excape is spaces in pathnames (a common GUI style)
def initialize(*command)
	parse_argument_array(command)
	execute # do it first time, to repeat call execute
	@accumulated_tolerance_bits = 0x00 # all errors reported (not tolerated)
	if $VERBOSE.nil? then
	elsif $VERBOSE then
		$stdout.puts trace # -W2
	else 
		$stdout.puts inspect(:echo_command) # -W1
	end #if
end #initialize
# Allow Process.spawn options and environment to be passed.
def parse_argument_array(argument_array)
	@argument_array=argument_array
	case argument_array.size
	when 3 then
		@env=argument_array[0]
		@command=argument_array[1]
		@opts=argument_array[2]
	when 2 then
		if argument_array[0].instance_of?(Hash) then
			if argument_array[1].instance_of?(Hash) then
				@env={}
				@command=argument_array[0]
				@opts=argument_array[1]
			else
				@env=argument_array[0]
				@command=argument_array[1]
				@opts={}
			end #if
		else # command is not a Hash
			@env={}
			@command=argument_array[0]
			@opts=argument_array[1]
		end #if
	when 1 then
		@env={}
		@command=argument_array[0]
		@opts={}
	end #case
	@command_string=ShellCommands.assemble_command_string(@command)
end #parse_argument_array
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
	if @process_status.nil? then
		false
	else
		@process_status.exitstatus & ~@accumulated_tolerance_bits # explicit toleration
	end #if
end #success
def clear_error_message!(tolerated_status)
	@errors = ''
	@accumulated_tolerance_bits = @accumulated_tolerance_bits | tolerated_status # accumulated_tolerance_bits
	self # for command chaining
end # clear_error_message!
def force_success(tolerated_status)
	warn(@errors) if $VERBOSE
	modified_self = self.clone
	modified_self.clear_error_message!(tolerated_status)
	modified_self # for command chaining
end # force_success
def tolerate_status(tolerated_status = 1)
	if @process_status.exitstatus == tolerated_status then
		force_success(tolerated_status)
	else
		self # for command chaining
	end # if
end # tolerate_status
def tolerate_error_pattern(tolerated_error_pattern = /^warning/)
	if tolerated_error_pattern.match(@errors) then
		force_success(0xFF) # tolerate all error codes
	else
		self # for command chaining
	end # if
end # tolerate_error_pattern
def tolerate_status_and_error_pattern(tolerated_status = 1, tolerated_error_pattern = /^warning/)
	if @process_status.exitstatus == tolerated_status && tolerated_error_pattern.match(@errors) then
		force_success(tolerated_status)
	else
		self # for command chaining
	end # if
end # tolerate_status_and_error_message
def inspect(echo_command=@errors!='' || !success?)
	ret=''
	if echo_command then
		ret+="$ #{@command_string}\n"
		ret+="@env=#{@env.inspect}\n" if $VERBOSE
		ret+="@command=#{@command.inspect}\n" if $VERBOSE
		ret+="@opts=#{@opts.inspect}\n" if $VERBOSE
	end #if
	if @errors!='' then
		ret+="Shellwords.split(@command_string).inspect=#{Shellwords.split(@command_string).inspect}\n" if $VERBOSE
		ret+="@errors=#{@errors.inspect}\n"
	end #if
	if !success? then
		ret+="@process_status=#{@process_status.inspect}\n"
	end #if
	if @output.nil? then
		ret
	else
		ret+@output.to_s
	end #if
end #inspect
def puts
	$stdout.puts inspect(:echo_command)
	self # return for command chaining
end #puts
def trace
	$stdout.puts inspect(:echo_command)
	shorter_callers=caller.grep(/^[^\/]/)
	$stdout.puts shorter_callers.join("\n")
	self # return for command chaining
end #trace
module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions(message='')
	self # return for command chaining
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="self=#{self.inspect(true)}"
	puts unless success?&& @errors.empty?
	assert_empty(@errors, message+'expected errors to be empty\n')
	assert_equal(0, @process_status.exitstatus & ~@accumulated_tolerance_bits, message)
	assert_not_nil(@errors, "expect @errors to not be nil.")
	assert_not_nil(@process_status)
	assert_instance_of(Process::Status, @process_status)

	self # return for command chaining
end #assert_post_conditions
end #Assertions
include Assertions
module Examples
Hello_world=ShellCommands.new('echo "Hello World"')
Example_output="1 2;3 4\n"
COMMAND_STRING='echo "1 2;3 4"'
EXAMPLE=ShellCommands.new(COMMAND_STRING)
Guaranteed_existing_directory=File.expand_path(File.dirname($0))
Cd_command_array=['cd', Guaranteed_existing_directory]
Cd_command_hash={:command => 'cd', :in => Guaranteed_existing_directory}
Guaranteed_existing_basename=File.basename($0)
Redirect_command=['ls', Guaranteed_existing_basename, '>', 'blank in filename.shell_command']
Redirect_command_string='ls '+ Shellwords.escape(Guaranteed_existing_basename)+' > '+Shellwords.escape('blank in filename.shell_command')
Relative_command=['ls', Guaranteed_existing_basename]
Bad_status = ShellCommands.new('$?=1')
Error_message_run = ShellCommands.new('ls happyHappyFailFail.junk')
end #Examples
include Examples
end #ShellCommands
class NetworkInterface
IFCONFIG=ShellCommands.new('/sbin/ifconfig')
#puts IFCONFIG.inspect
end #NetworkInterface

###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
require 'fileutils'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/ruby_interpreter.rb'
require_relative '../../app/models/bug.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/test_executable.rb'
class TestRun # < ActiveRecord::Base
include Virtus.model
  attribute :test_executable, TestExecutable
module Constants
#include Version::Constants
end # Constants
include Constants
#include Generic_Table
#has_many :bugs
module ClassMethods
def shell(command, &proc)
#	puts "command='#{command}'"
	run =ShellCommands.new(command)
	if block_given? then
		proc.call(run)
	else
		run.assert_post_conditions
	end # if
end #shell
# Run rubyinterpreter passing arguments
def ruby(args, &proc)
	shell("ruby #{args}",&proc)
end #ruby
end # ClassMethods
extend ClassMethods
# attr_reader
def <=>(other)
	error_score? <=> other.error_score?
end # <=>
# returns nil if recursion danger
def error_score?
	if test_executable.recursion_danger? then
		nil
	else
		executable_file = @test_executable.regression_unit_test_file
		fail Exception.new('Executable file '+ executable_file + ' does not exist.') if !File.exists?(executable_file)
		@ruby_test_string = @test_executable.ruby_test_string
		@recent_test = ShellCommands.new({'SEED' => '0'}, @ruby_test_string, :chdir=> @test_executable.repository.path)
		log_path = @test_executable.log_path?
		if !log_path.empty? then
		end # if
		@test_executable.write_error_file(@recent_test)
		@test_executable.write_commit_message(@recent_test, [executable_file])
	#	@recent_test.puts if $VERBOSE
		@error_score = if @recent_test.success? then
			0
		elsif @recent_test.process_status.nil? then
			100000 # really bad
		elsif @recent_test.process_status.exitstatus==1 then # 1 error or syntax error
			syntax_test = @test_executable.repository.shell_command("ruby -c "+executable_file.to_s)
			if syntax_test.output=="Syntax OK\n" then
				initialize_test = @test_executable.repository.shell_command("ruby "+executable_file.to_s + ' --name test_initialize')
				if initialize_test.success? then
					1
				else # initialization  failure or test_initialize failure
					100 # may prevent other tests from running
				end #if
			else
				10000 # syntax error can hide many sins
			end #if
		else
			@recent_test.process_status.exitstatus # num_errors>1
		end #if
		@error_score
	end # if
end # error_score
#require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable)
end # Examples
end # TestRun

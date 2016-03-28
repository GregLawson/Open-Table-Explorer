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
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Recent_test_default = lambda do |test_run, attribute|
	test = test_run.test
	start_time = Time.now
	if test_run.test_executable.recursion_danger? then
		nil
	else
		recent_test = ShellCommands.new({'SEED' => '0'}, test_run.test_executable.ruby_test_string(test_run.test), :chdir=> test_run.test_executable.repository.path.to_s)
		{test: test_run.test, recent_test: recent_test, elapsed_time: Time.now - start_time}
	end # if
end # Recent_test_default
end # DefinitionalConstants
include DefinitionalConstants
include Virtus.value_object
  values do
  attribute :test_executable, TestExecutable
end # values
module Constants
include DefinitionalConstants
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
def error_score?(test = nil)
	if @test_executable.recursion_danger? then
		nil
	else
		executable_file = @test_executable.regression_unit_test_file
#		fail Exception.new('Executable file '+ executable_file + ' does not exist.') if !executable_file.exist?
		@ruby_test_string = @test_executable.ruby_test_string(test)
		@start_time = Time.now
		@recent_test = ShellCommands.new({'SEED' => '0'}, @ruby_test_string, :chdir=> @test_executable.repository.path)
		@elapsed_time = Time.now - @start_time
		log_path = @test_executable.log_path?(test)
		if !log_path.empty? then
		end # if
		@test_executable.write_error_file(@recent_test, test)
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
		if @elapsed_time > 0 then
			puts "@start_time = " + @start_time.to_s if $VERBOSE
			puts "\n@elapsed_time = " + @elapsed_time.to_s
			puts "\nTime.now = " + Time.now.to_s if $VERBOSE
			puts @test_executable.all_test_names.inspect if $VERBOSE
			@test_executable.all_test_names.each do |test_name|
				puts  test_name.to_s if $VERBOSE
			end # each
		end # if
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
TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path($0))
Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable)
end # Examples
end # TestRun

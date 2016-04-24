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
		begin	
			recent_test =
			Timeout::timeout(test_run.test_run_timeout) do
				ShellCommands.new({'SEED' => '0'}, test_run.test_executable.ruby_test_string(test_run.test), :chdir=> test_run.test_executable.repository.path.to_s)
			end # Timeout
			{test: test_run.test, recent_test: recent_test, elapsed_time: Time.now - start_time}
		rescue Timeout::Error  => exception_object_raised
			elapsed_time = Time.now - start_time
			puts "timeout"
			puts exception_object_raised.inspect
			puts "start_time = " + start_time.to_s if $VERBOSE
			puts "\nelapsed_time = " + elapsed_time.to_s
			puts "\nTime.now = " + Time.now.to_s if $VERBOSE
			{test: test_run.test, exception_object_raised: exception_object_raised, elapsed_time: elapsed_time}
		end # begin/rescue block
	end # if
end # Recent_test_default
Timeout_default = lambda do |test_run, attribute|
	if test_run[:test].nil? then
		Too_long_for_regression_test
	else
		test_run.subtest_timeout
	end # if
end # Timeout_default
All_test_names_default = lambda do |test_run, attribute|
#	if test_run.cached_recent_test[:exception_object_raised].nil? then
#		nil # not needed yet
#	else
		test_run.test_executable.all_test_names
#	end # if
end # All_test_names_default
Too_long_for_regression_test = 30.0 # zero means infinite timeout
Subtest_timeout_margin = 3.0
end # DefinitionalConstants
include DefinitionalConstants
include Virtus.value_object
  values do
  attribute :test_executable, TestExecutable
  attribute :test, Symbol, :default => nil
  attribute :cached_recent_test, Hash, :default => TestRun::Recent_test_default
  attribute :cached_all_test_names, Array, :default => TestRun::All_test_names_default
  attribute :test_run_timeout, Float, :default => Timeout_default
end # values
def all_test_names
	@test_executable.all_test_names
end # elapsed_time
def elapsed_time
	@cached_recent_test[:elapsed_time]
end # elapsed_time
module Constants
include DefinitionalConstants
TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path(__FILE__)) # avoid recursion
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
def error_file
	ret = @test_executable.repository.current_branch_name?.to_s
	ret += "\n" + Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
	ret += "\n" + @cached_recent_test[:recent_test].command_string
	ret += "\n" + @cached_recent_test[:recent_test].output.to_s
	ret += "\n" + @cached_recent_test[:recent_test].errors
end # error_file
def write_error_file(test)
	IO.write(@test_executable.log_path?(test), error_file)
end # write_error_file
def commit_message(files)
	commit_message= 'fixup! ' + Unit.unit_names?(files).uniq.join(', ')
	if !@cached_recent_test[:recent_test].nil? then
		commit_message += "\n" + @test_executable.repository.current_branch_name?.to_s + "\n"
		commit_message += "\n" + @cached_recent_test[:recent_test].command_string
		commit_message += "\n" + @cached_recent_test[:recent_test].output.to_s
		commit_message += @cached_recent_test[:recent_test].errors
	end #if
end # commit_message
def write_commit_message(files)
	IO.binwrite('.git/GIT_COLA_MSG', commit_message(files))	
end # write_commit_message
def error_score?(test = nil)
	if @cached_recent_test.nil? || @cached_recent_test[:recent_test].nil? then
		nil
	else
		write_error_file(test)
		write_commit_message([@test_executable.regression_unit_test_file])
		#	@cached_recent_test[:recent_test].puts if $VERBOSE
			@error_score = if @cached_recent_test[:recent_test].success? then
				0
			elsif @cached_recent_test[:recent_test].process_status.nil? then
				100000 # really bad
			elsif @cached_recent_test[:recent_test].process_status.exitstatus==1 then # 1 error or syntax error
				syntax_test = @test_executable.repository.shell_command("ruby -c "+@test_executable.regression_unit_test_file.to_s)
				if syntax_test.output=="Syntax OK\n" then
					initialize_test = @test_executable.repository.shell_command("ruby "+@test_executable.regression_unit_test_file.to_s + ' --name test_initialize')
					if initialize_test.success? then
						1
					else # initialization  failure or test_initialize failure
						100 # may prevent other tests from running
					end #if
				else
					10000 # syntax error can hide many sins
				end #if
			else
				@cached_recent_test[:recent_test].process_status.exitstatus # num_errors>1
			end #if
		@error_score
	end # if
end # error_score
def subtest_timeout
#	if test.nil? then
		Subtest_timeout_margin * Too_long_for_regression_test / @cached_all_test_names.size
#	else
#		nil
#	end # if
end # subtest_timeout
def run_individual_tests
	puts @test_executable.all_test_names.inspect if $VERBOSE
	if test.nil? && @test_executable.regression_unit_test_file != TestSelf.test_executable.regression_unit_test_file then
		puts '@test_executable = ' + @test_executable.inspect  if $VERBOSE
		puts '   TestSelf.test_executable = ' + TestSelf.test_executable.inspect if $VERBOSE
		@test_executable.all_test_names.each do |test_name|
			error_score_run = TestRun.new(test_executable: @test_executable, test_name: test_name, test_run_timeout: subtest_timeout)
			puts  test_name.to_s + ' ' + @elapsed_time.to_s
			puts error_score_run.inspect if $VERBOSE
		end # each
	else
		raise "Only one level of subtests."
	end # if
end # run_individual_tests
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
Allways_timeout = 0.00001
Default_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable)
Default_subtestRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test: :test_compare)
Forced_timeout_testRun = TestRun.new(test_executable: TestExecutable::Examples::TestTestExecutable, test_run_timeout: Allways_timeout)
end # Examples
end # TestRun

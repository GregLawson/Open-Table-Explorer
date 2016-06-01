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
    def self.explain_elapsed_time(_test_run, recent_test)
      ret = if _test_run.test.nil?
              'all tests'
            else
              _test_run.test.to_s
            end # if
      ret += ' in ' + _test_run.test_executable.unit.model_basename.to_s
      #      raise ret + ' recent_test is not a ShellCommands but a ' + recent_test.class.name unless recent_test.instance_of?(ShellCommands)
      if recent_test.nil?
        ret += 'recursion danger'
      elsif recent_test.keys.include?(:exception_object_raised)
        if  recent_test[:exception_object_raised].instance_of?(Timeout::Error)
          ret += ' timed-out in ' + recent_test[:elapsed_time].inspect +
                 ret += ' beyond timeout of ' + _test_run.test_run_timeout.to_s
        else
          #					ret += recent_test[:exception_object_raised].inspect + ' raised in '
          ret += recent_test.elapsed_time.inspect + ' with timeout ' + _test_run.test_run_timeout.to_s
        end # if
      else
        ret += ' took ' + recent_test.elapsed_time.inspect
        ret += ' within timeout of ' + _test_run.test_run_timeout.to_s
      end # if
      #	ret += ' with timeout ' + _test_run.test_run_timeout.to_s
      #    ret += ' at ' + Time.now.to_s
      ret
    end # explain_elapsed_time

    def self.report_timeout(_test_run, recent_test)
      _test_run.errors[:timeout] = 'timeout ' + _test_run.test.to_s + ' of ' + _test_run.test_executable.regression_unit_test_file.relative_pathname.to_s +
                                   ' exception ' + ' with timeout of ' + _test_run.test_run_timeout.to_s +
                                   TestRun::DefinitionalConstants.explain_elapsed_time(_test_run, recent_test)
      puts _test_run.errors[:timeout]
    end # report_timeout
    Recent_test_default = lambda do |test_run, _attribute|
      if test_run.test_executable.recursion_danger?
        nil
      else
        begin
          test_run.test_executable.lint_unit
          recent_test =
            Timeout.timeout(test_run.test_run_timeout) do
              ShellCommands.new({ 'SEED' => '0' }, '/usr/bin/time --verbose ' +
                test_run.test_executable.ruby_test_string(test_run.test),
                                chdir: test_run.test_executable.repository.path.to_s)
            end # Timeout
          if recent_test.elapsed_time > test_run.test_run_timeout
            TestRun::DefinitionalConstants.report_timeout(test_run, recent_test)
          end # if
          { test: test_run.test, recent_test: recent_test }
        rescue Timeout::Error => exception_object_raised
          TestRun::DefinitionalConstants.report_timeout(test_run, recent_test)
          { test: test_run.test, recent_test: recent_test,
            exception_object_raised: exception_object_raised }
        end # begin/rescue block
      end # if
    end # Recent_test_default
    Timeout_default = lambda do |test_run, _attribute|
      if test_run[:test].nil?
        Too_long_for_regression_test
      else
        test_run.subtest_timeout
      end # if
    end # Timeout_default
    All_test_names_default = lambda do |test_run, _attribute|
      #	if test_run.cached_recent_test[:exception_object_raised].nil? then
      #		nil # not needed yet
      #	else
      test_run.test_executable.all_test_names
      #	end # if
    end # All_test_names_default
    Too_long_for_regression_test = 30.0 # zero means infinite timeout
    Subtest_timeout_margin = 3.0 # allow some variation in test runtimes
  end # DefinitionalConstants
  include DefinitionalConstants
  include Virtus.value_object
  values do
    attribute :test_executable, TestExecutable
    attribute :test, Symbol, default: nil
    attribute :cached_all_test_names, Array, default: TestRun::All_test_names_default
    attribute :test_run_timeout, Float, default: Timeout_default
    attribute :errors, Hash, default: {}
    attribute :cached_recent_test, Hash, default: TestRun::Recent_test_default
  end # values
  def all_test_names
    @test_executable.all_test_names
  end # all_test_names

  def elapsed_time
    @cached_recent_test[:elapsed_time]
  end # elapsed_time

  def explain_elapsed_time
    ret = if @test.nil?
            'all tests'
          else
            @test.to_s
          end # if
    ret += ' in ' + @test_executable.unit.model_basename.to_s
    if cached_recent_test.nil?
      ret += 'recursion danger'
    elsif @cached_recent_test.keys.include?(:exception_object_raised)
      if  @cached_recent_test[:exception_object_raised].instance_of?(Timeout::Error)
        ret += ' timed-out in ' + @cached_recent_test[:elapsed_time].inspect +
               ret += ' beyond timeout of ' + @test_run_timeout.to_s
      else
        ret += @cached_recent_test[:exception_object_raised].inspect + ' raised in '
        ret += @cached_recent_test.elapsed_time.inspect + ' with timeout ' + @test_run_timeout.to_s
      end # if
    else
      ret += ' took ' + @cached_recent_test[:recent_test].elapsed_time.inspect
      ret += ' within timeout of ' + @test_run_timeout.to_s
    end # if
    #	ret += ' with timeout ' + @test_run_timeout.to_s
    #    ret += ' at ' + Time.now.to_s
    ret
  end # explain_elapsed_time

  def explain_exception
    if @cached_recent_test.nil?
      ret = 'recursion danger'
    elsif @cached_recent_test.keys.include?(:exception_object_raised)
      ret = 'explain timeout '
      ret += 'exception_object_raised = ' + @cached_recent_test[:exception_object_raised].inspect
      ret += explain_elapsed_time
    else
      ret = explain_elapsed_time
    end # if
  end # explain_exception
  module Constants
    include DefinitionalConstants
    TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path(__FILE__)) # avoid recursion
  end # Constants
  include Constants
  # include Generic_Table
  # has_many :bugs
  module ClassMethods
    def shell(command)
      #	puts "command='#{command}'"
      run = ShellCommands.new(command)
      if block_given?
        yield(run)
      else
        run.assert_post_conditions
      end # if
    end # shell

    # Run rubyinterpreter passing arguments
    def ruby(args, &proc)
      shell("ruby #{args}", &proc)
    end # ruby
  end # ClassMethods
  extend ClassMethods
  # attr_reader
  def <=>(other)
    error_score? <=> other.error_score?
  end # <=>

  # returns nil if recursion danger
  def error_file
    ret = @test_executable.repository.current_branch_name?.to_s
    ret += "\n" + Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
    ret += "\n" + @cached_recent_test[:recent_test].command_string
    ret += "\n" + @cached_recent_test[:recent_test].output.to_s
    ret += "\n" + @cached_recent_test[:recent_test].errors
  end # error_file

  def write_error_file(test)
    IO.write(@test_executable.log_path?(test), error_file)
  end # write_error_file

  def commit_message(files)
    commit_message = 'fixup! ' + Unit.unit_names?(files).uniq.join(', ')
    unless @cached_recent_test[:recent_test].nil?
      commit_message += "\n" + @test_executable.repository.current_branch_name?.to_s + "\n"
      commit_message += "\n" + @cached_recent_test[:recent_test].command_string
      commit_message += "\n" + @cached_recent_test[:recent_test].output.to_s
      commit_message += @cached_recent_test[:recent_test].errors
    end # if
    commit_message
  end # commit_message

  def write_commit_message(files)
    IO.binwrite('.git/GIT_COLA_MSG', commit_message(files))
  end # write_commit_message

  def error_score?(test = nil)
    if @cached_recent_test.nil? || @cached_recent_test[:recent_test].nil?
      nil
    else
      write_error_file(test)
      write_commit_message([@test_executable.regression_unit_test_file])
      #	@cached_recent_test[:recent_test].puts if $VERBOSE
      @error_score = if @cached_recent_test[:recent_test].success?
                       0
                     elsif @cached_recent_test[:recent_test].process_status.nil?
                       100_000 # really bad
                     elsif @cached_recent_test[:recent_test].process_status.exitstatus == 1 # 1 error or syntax error
                       syntax_test = @test_executable.repository.shell_command('ruby -c ' + @test_executable.regression_unit_test_file.to_s)
                       if syntax_test.output == "Syntax OK\n"
                         initialize_test = @test_executable.repository.shell_command('ruby ' + @test_executable.regression_unit_test_file.to_s + ' --name test_initialize')
                         if initialize_test.success?
                           1
                         else # initialization  failure or test_initialize failure
                           100 # may prevent other tests from running
                         end # if
                       else
                         10_000 # syntax error can hide many sins
                       end # if
                     else
                       @cached_recent_test[:recent_test].process_status.exitstatus # num_errors>1
        end # if
      conditionally_run_individual_tests
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

  def conditionally_run_individual_tests
    if @cached_recent_test[:recent_test].elapsed_time > @test_run_timeout

      run_individual_tests
    else
      puts 'not timed out: ' + explain_elapsed_time
    end # if
  end # conditionally_run_individual_tests

  def run_individual_tests
    puts @test_executable.all_test_names.inspect if $VERBOSE
    if test.nil? && @test_executable.regression_unit_test_file != TestSelf.test_executable.regression_unit_test_file
      puts '@test_executable = ' + @test_executable.inspect if $VERBOSE
      puts '   TestSelf.test_executable = ' + TestSelf.test_executable.inspect if $VERBOSE
      @test_executable.all_test_names.map do |test_name|
        subtest_run = TestRun.new(test_executable: @test_executable, test: test_name, test_run_timeout: subtest_timeout)
        puts test_name.to_s + ' ' + subtest_run.explain_elapsed_time
      end # each
    else
      raise 'Only one level of subtests.'
    end # if
  end # run_individual_tests
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include Constants
  end # Examples
end # TestRun

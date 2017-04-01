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
require_relative '../../app/models/ruby_lines_storage.rb'
class RecentRun
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Cached_run_default = lambda do |recent_run, _attribute|
      begin
        recent_run.start_time = Time.now
        cached_run =
          Timeout.timeout(recent_run.timeout) do
            ShellCommands.new(recent_run.env, recent_run.command_string, recent_run.opts)
          end # Timeout
        recent_run.output = cached_run.output
        recent_run.elapsed_time = Time.now - recent_run.start_time
        recent_run.errors[:syserr] = cached_run.errors
      rescue Timeout::Error => exception_object_raised
        recent_run.errors[:rescue_exception] = exception_object_raised
        recent_run.elapsed_time = Time.now - recent_run.start_time
      end # begin/rescue block
      cached_run
    end # Recent_test_default
  end # DefinitionalConstants
  include DefinitionalConstants

  include Virtus.model
  attribute :command_string, String
  attribute :env, Hash, default: {}
  attribute :opts, Hash, default: {}
  attribute :errors, Hash, default: {}
  attribute :start_time, Time, default: nil
  attribute :cached_run, Object, default: Cached_run_default
  attribute :elapsed_time, Float
  attribute :timeout, Float, default: 0.0 # no timeout
  attribute :stdin, File, default: nil
  attribute :stdout, File, default: nil
  attribute :stderr, File, default: nil
  attribute :wait_thr, Object, default: nil
  attribute :output, String, default: nil
  def timed_out?
    @errors[:rescue_exception].is_a?(Exception)
  end # timed_out?

  def shell_elapsed_time?
    if timed_out?
      false
    elsif @cached_run.nil?
      nil
    elsif @cached_run.instance_of?(ShellCommands)
      if @cached_run.instance_variables.include?(:@elapsed_time)
        if @cached_run.elapsed_time.nil?
          :timeout_elapsed_time_nil
        else
          true
        end # if
      elsif @errors[:rescue_exception].instance_of?(ShellCommands)
        :timeout_exception
      else
        :unknown_ShellCommands
      end # if
    else
      :unknown
    end # if
  end # shell_elapsed_time?

  def elapsed_time
    if shell_elapsed_time?
      @cached_run.elapsed_time
    elsif @cached_run.nil?
      if @elapsed_time.nil?
        nil
      else
        @elapsed_time # timeout
      end # if
    elsif @cached_run.instance_of?(ShellCommands)
      if @cached_run.instance_variables.include?(:@elapsed_time)
        if @cached_run.elapsed_time.nil?
          :timeout_elapsed_time_nil
        else
          @cached_run.elapsed_time
        end # if
      elsif @errors[:rescue_exception].instance_of?(ShellCommands)
        :timeout_exception
      else
        :unknown_ShellCommands
      end # if
    else
      :unknown
    end # if
  end # elapsed_time

  def success?
    if @cached_run.nil?
      false
    else
      @cached_run.success?
    end # if
  end # success?

  def process_status
    if @cached_run.nil?
      nil
    else
      @cached_run.process_status
    end # if
  end # process_status

  def soft_timeout
    0.05 + (0.5 * @timeout)
  end # soft_timeout

  def explain_elapsed_time
    ret = 'took ' + elapsed_time.inspect + 's '
    ret += if @timeout == 0.0
             'with no timeout'
           elsif timed_out?
             'beyond timeout of ' + @timeout.to_s + 's'
           elsif elapsed_time > @timeout
             'timedout within timeout of ' + @timeout.to_s + 's'
           else
             'unknown with timeout of ' + @timeout.to_s + 's'
           end # if
    ret
  end # explain_elapsed_time

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

    def assert_pre_conditions(_message = '')
      assert_includes(instance_variables, :@errors, inspect)
      self # for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(_message = '')
      unless @errors.nil?
        if @errors.keys.include?(:rescue_exception)
          assert_includes(@errors.keys, :rescue_exception, @cached_run.inspect)
          assert_instance_of(Timeout::Error, @errors[:rescue_exception], inspect)
        end # if
      end # unless
      self # for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end # RecentRun

class TestRun # < ActiveRecord::Base
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    All_test_names_default = lambda do |test_run, _attribute|
      #	if test_run.cached_recent_test[:rescue_exception].nil? then
      #		nil # not needed yet
      #	else
      test_run.test_executable.all_test_names
      #	end # if
    end # All_test_names_default

    Too_long_for_regression_test = 15.0 # zero means infinite timeout
    Subtest_timeout_margin = 3.0 # allow some variation in test runtimes

    Timeout_default = lambda do |test_run, _attribute|
      if test_run[:test].nil?
        Too_long_for_regression_test
      else
        test_run.subtest_timeout
      end # if
    end # Timeout_default

    Recent_test_default = lambda do |test_run, _attribute|
      unless test_run.test_executable.test_type == :unit
        test_run.test_executable.lint_unit
        # tested raise 'unexpected lint run.'
      end # if
      if test_run.test_executable.recursion_danger?
        nil
      else
        unless test_run.test_executable.test_type == :unit
          test_run.test_executable.lint_unit
            # tested raise 'unexpected lint run.'
          end # if
        recent_test =
          RecentRun.new(env: { 'SEED' => '0' }, command_string: '/usr/bin/time --verbose ' +
              test_run.test_executable.ruby_test_string(test_run.test),
                        opts: { chdir: test_run.test_executable.repository.path.to_s },
                        timeout: test_run.test_run_timeout)
      end # if
    end # Recent_test_default
  end # DefinitionalConstants
  include DefinitionalConstants

  include Virtus.value_object
  values do
    attribute :test_executable, TestExecutable
    attribute :test, Symbol, default: nil
    attribute :cached_all_test_names, Array, default: TestRun::All_test_names_default
    attribute :test_run_timeout, Float, default: Timeout_default
    attribute :errors, Hash, default: {}
    attribute :cached_recent_test, RecentRun, default: TestRun::Recent_test_default
  end # values
  def all_test_names
    @test_executable.all_test_names
  end # all_test_names

  def run_style(recent_test = @cached_recent_test)
    if @test_executable.recursion_danger?
      :recursion_danger
    elsif recent_test.nil?
      :cached_recent_test_nil
    elsif recent_test.timed_out?
      :timeout_exception
    elsif recent_test.cached_run.instance_of?(ShellCommands)
      :recent_test_as_shell_command

    else
      :unknown
    end # if
  end # run_style

  def explain_elapsed_time
    ret = if @test.nil?
            'all tests'
          else
            @test.to_s
          end # if
    ret += ' in ' + @test_executable.unit.model_basename.to_s
    ret += if cached_recent_test.nil?
             'recursion danger'
           else
             ' ' + @cached_recent_test.explain_elapsed_time
           end # if
    ret
  end # explain_elapsed_time
  module Constants
    include DefinitionalConstants
    TestSelf = TestRun.new(test_executable: TestExecutable.new_from_path(__FILE__, :unit)) # avoid recursion
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

  def command_string
  end # command_string

  def <=>(other)
    error_score? <=> other.error_score?
  end # <=>

  def state
    { current_branch_name: Branch.current_branch(@test_executable.repository),
      start_time: Time.now,
      command_string: @cached_recent_test.command_string,
      output: @cached_recent_test.output.to_s,
      errors: @cached_recent_test.errors }
  end # state

  def write_error_file(test)
    IO.write(@test_executable.log_path?(test), state.ruby_lines_storage)
  end # write_error_file

  def commit_message(files)
    commit_message = 'fixup! ' + Unit.unit_names?(files).uniq.join(', ')
    unless @cached_recent_test.nil?
      commit_message += "\n" + state[:current_branch_name].to_s + "\n"
      commit_message += "\n" + @cached_recent_test.command_string
      commit_message += "\n" + @cached_recent_test.output.to_s
      commit_message += @cached_recent_test.errors.inspect
    end # if
    commit_message
  end # commit_message

  def write_commit_message(files)
    IO.binwrite('.git/GIT_COLA_MSG', commit_message(files))
  end # write_commit_message

  def error_score?(test = nil)
    if @cached_recent_test.nil? || @cached_recent_test.nil?
      nil
    else
      write_error_file(test)
      write_commit_message([@test_executable.regression_unit_test_file])
      #	@cached_recent_test.puts if $VERBOSE
      @error_score = if @cached_recent_test.success?
                       0
                     elsif @cached_recent_test.process_status.nil?
                       100_000 # really bad
                     elsif @cached_recent_test.process_status.exitstatus == 1 # 1 error or syntax error
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
                       @cached_recent_test.process_status.exitstatus # num_errors>1
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
    if @cached_recent_test.elapsed_time > @test_run_timeout

      run_individual_tests
    else
      puts 'not timed out: ' + explain_elapsed_time
    end # if
  end # conditionally_run_individual_tests

  def run_individual_tests
    puts @test_executable.all_test_names.inspect if $VERBOSE
    if !test.nil?
      message = 'test = ' + test.inspect + '@test_executable = ' + @test_executable.inspect + "\n\n"
      message += '@test_executable.regression_unit_test_file = ' + @test_executable.regression_unit_test_file.inspect + "\n\n"
      message += 'TestSelf.test_executable.regression_unit_test_file = ' + TestSelf.test_executable.regression_unit_test_file.inspect + "\n\n"
      message += 'Only one level of subtests.' + "\n\n"
      raise message
    elsif @test_executable.regression_unit_test_file == TestSelf.test_executable.regression_unit_test_file
      puts '@test_executable = ' + @test_executable.inspect if $VERBOSE
      puts '   TestSelf.test_executable = ' + TestSelf.test_executable.inspect if $VERBOSE
      @test_executable.all_test_names.map do |test_name|
        unless test_name == 'test_run_individual_tests' # recursion again
          subtest_run = TestRun.new(test_executable: @test_executable, test: 'test_' + test_name.to_s, test_run_timeout: subtest_timeout)
          puts subtest_run.explain_elapsed_time
        end # unless
      end # each
    else
      puts '@test_executable = ' + @test_executable.inspect if $VERBOSE
      puts '   TestSelf.test_executable = ' + TestSelf.test_executable.inspect if $VERBOSE
      @test_executable.all_test_names.map do |test_name|
        subtest_run = TestRun.new(test_executable: @test_executable, test: 'test_' + test_name.to_s, test_run_timeout: subtest_timeout)
        puts test_name.to_s + ' ' + subtest_run.explain_elapsed_time
      end # each
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
    def assert_pre_conditions(_message = '')
      unless @cached_recent_test.nil?
        assert_instance_of(RecentRun, @cached_recent_test, inspect)
        @cached_recent_test.assert_pre_conditions
      end # if
      self # for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(_message = '')
      unless @recent_test_default.nil?
        @cached_recent_test.assert_post_conditions
      end # if
      self # for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
end # TestRun

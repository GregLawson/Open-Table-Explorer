###########################################################################
#    Copyright (C) 2013-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
# assert_global_name(:Repository)
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/test_run.rb'
require_relative '../../app/models/ruby_lines_storage.rb'
# abstracts TestRun and git commits for comparison
class TestMaturity
	module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
    # Error score is a SWAG at order of magnitude of errors
    Error_classification = { 0 => :success,
                             1 => :single_test_fail,
                             100 => :initialization_fail,
                             10_000 => :syntax_error }.freeze
    Push_branch = { success:             :passed,
                    single_test_fail:    :tested,
                    multiple_tests_fail: :tested, # visibility boundary
                    initialization_fail: :edited,
                    syntax_error:        :edited
        }.freeze
    Pull_branch = { success:             :passed,
                    single_test_fail:    :passed,
                    multiple_tests_fail: :tested, # visibility boundary
                    initialization_fail: :tested,
                    syntax_error:        :edited
        }.freeze
		Error_classification_keys = Push_branch.keys
		
    Error_score_directory = Unit.data_source_directories + 'test_maturity/'
		
#		raise RubyLinesStorage.instance_methods(false).inspect unless RubyLinesStorage.instance_methods.include?(:read) 
		Fixed_regexp = /[0-9]+\.[0-9]+/
		Finished_regexp = /Finished in / * Fixed_regexp.capture(:test_finished)
    User_time_regexp = /User time \(seconds\): / * Fixed_regexp.capture(:user_time)
    Tests_pattern = /[0-9]+/.capture(:tests) * / / * (/tests/ | /runs/) * /, /
    Assertions_pattern = /[0-9]+/.capture(:assertions) * / / * /assertions/ * /, /
    Failures_pattern = /[0-9]+/.capture(:failures) * / / * /failures/ * /, /
    Errors_pattern = /[0-9]+/.capture(:errors) * / / * /errors/ * /, /
    Pendings_pattern = /[0-9]+/.capture(:pendings) * / / * /pendings/ * /, /
    Omissions_pattern = /[0-9]+/.capture(:omissions) * / / * /omissions/ * /, /
    Notifications_pattern = /[0-9]+/.capture(:notifications) * / / * /notifications/ * /\n/
    Common_summary_regexp = Tests_pattern * Assertions_pattern * Failures_pattern * Errors_pattern
    end # DefinitionalConstants
  include DefinitionalConstants
	
  module ClassMethods
    include DefinitionalConstants
    def example_files
      ret = {} # accumulate a hash
      Error_classification_keys.each do |classification|
        argument_path = Error_score_directory + classification.to_s + '.rb'
        ret = ret.merge(classification => argument_path)
      end # each_pair
      ret
    end # example_files

    def file_bug_reports(ruby_source, log_file, _test = nil)
      table, test_type = CodeBase.test_type_from_source(ruby_source)
      header, errors, summary = parse_log_file(log_file)
      if summary.nil?
        puts 'summary is nil. probable rake failure.'
        stop = true
      else
        sysout, run_time = TestRun.parse_header(header)
        puts "sysout='#{sysout.inspect}'"
        puts "run_time='#{run_time}'"
        tests, assertions, failures, tests_stop_on_error = TestRun.parse_summary(summary)
        # ~ puts "failures+tests_stop_on_error=#{failures+tests_stop_on_error}"
        stop = if (failures + tests_stop_on_error) == 0
                 false
               else
                 true
               end # if
        open('db/tests.sql', 'a') { |f| f.write("insert into test_runs(model,test,test_type,environment,tests,assertions,failures,tests_stop_on_error,created_at,updated_at) values('#{table}','#{ENV['TEST']}','#{test_type}','#{ENV['RAILS_ENV']}',#{tests},#{assertions},#{failures},#{tests_stop_on_error},'#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
      end # if
      unless errors.nil?
        errors.each do |error|
          Bug.new(test_type, table, error)
          #			puts "error='#{error}'"
        end # each
      end # if
      #	puts "ARGF.argv.inspect=#{ARGF.argv.inspect}"
      puts "file_bug_reports stop=#{stop}"
      puts "summary='#{summary}'"
      stop
    end # file_bug_reports

    def parse_log_file(log_file)
      blocks = IO.read(log_file).split("\n\n") # delimited by multiple successive newlines
      #	puts "blocks=#{blocks.inspect}"
      header = blocks[0]
      errors = blocks[1..-2]
      summary = blocks[-1]
      [header, errors, summary]
    end # parse_log_file

    def log_passed?(log_file)
      unless File.size?(log_file)
        return false # no file or empty file, no evidence of passing
      end # if
      header, errors, summary = TestRun.parse_log_file(log_file)
      if summary.nil?
        return false
      else
        tests, assertions, failures, tests_stop_on_error = TestRun.parse_summary(summary)
        if (failures + tests_stop_on_error) == 0
          return true
        else
          return false
        end # if
      end # if
    end # log_passed?

    def summarize
      sh %(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/empty_tests.tmp)
      #	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >log/error_tests.tmp}
      #	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >log/failure_tests.tmp}
      sh %(cat log/empty_tests.tmp log/error_tests.tmp log/failure_tests.tmp|sort|uniq >log/failed_tests.log)
    end # summarize

    def parse_summary(summary)
      summary = summary.split(' ')
      tests = summary[0].to_i
      assertions = summary[2].to_i
      failures = summary[4].to_i
      tests_stop_on_error = summary[6].to_i
      [tests, assertions, failures, tests_stop_on_error]
    end # parse_summary

    def parse_header(header)
      headerArray = header.split("\n")
      sysout = headerArray[0..-2]
      run_time = headerArray[-1].split(' ')[2].to_f
      [sysout, run_time]
    end # parse_header
  end # ClassMethods
  extend ClassMethods

  include Virtus.value_object
  values do
    attribute :version, BranchReference, default: nil # working_directory
    attribute :test_executable, TestExecutable
    #	attribute :age, Fixnum, :default => 789
    #	attribute :timestamp, Time, :default => Time.now
  end # values

  module Constructors # such as alternative new methods
    include DefinitionalConstants
		def all
	    Dir['log/unit/2.2/2.2.3p173/silence/*.log']
		end # all
  end # Constructors
  extend Constructors

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
#    ExecutableMaturity = TestMaturity.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME))
		Self_test_executable = TestExecutable.new(argument_path: $PROGRAM_NAME)
		Working_maturity = TestMaturity.new(version: nil, test_executable: Self_test_executable)
  end # ReferenceObjects
  include ReferenceObjects

	def read_state(commit, test = nil)
		if commit.nil?
			file_contents = RubyLinesStorage.read(@test_executable.log_path?(test))
		else
			git_command = 'git cat-file blob ' + commit.to_s + ':' + @test_executable.log_path?(test)
			file_contents = @repository.git_command(git_command)
			eval(file_contents)
		end # if
	end # read_state
	


  def get_error_score!
    if @test_executable.recursion_danger?
      nil # avoid recursion
    elsif @cached_error_score.nil?
      @cached_error_score = TestRun.new(test_executable: @test_executable).error_score?
    else
      @cached_error_score
    end # if
  end # get_error_score!

  def deserving_branch
    if File.exist?(@test_executable.argument_path)
      deserving_commit_to_branch!
    else
      :edited
    end # if
  end # deserving_branch

  def <=>(other)
    if @test_executable.testable?
      if other.test_executable.testable?
        get_error_score! <=> other.get_error_score!
      else
        +1
      end # if

    else
      if other.test_executable.testable?
        -1
      else
        @test_executable <=> other.test_executable
      end # if
    end # if
  end # <=>

  def error_classification!
    Error_classification.fetch(get_error_score!, :multiple_tests_fail)
  end # error_classification!

  def deserving_commit_to_branch!
    TestMaturity::Push_branch[error_classification!]
  end # deserving_commit_to_branch!

  def expected_next_commit_branch!
    TestMaturity::Pull_branch[error_classification!]
  end # expected_next_commit_branch!

  def branch_enhancement!
    Branch::Branch_enhancement[deserving_commit_to_branch!]
  end # branch_enhancement!

	require_relative '../../app/models/assertions.rb'
	
  module Assertions
    module ClassMethods
    end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
				self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
				if hash[:context].keys.include?(:command_string)
				else
					# puts hash.ruby_lines_storage
					puts hash.keys
				end # if
				self # return for command chaining
    end # assert_post_conditions
    def assert_deserving_branch(branch_expected, executable, message = '')
      deserving_branch = TestMaturity.deserving_branch
      recent_test = shell_command('ruby ' + executable)
      message += "\nrecent_test=" + recent_test.inspect
      message += "\nrecent_test.process_status=" + recent_test.process_status.inspect
      syntax_test = shell_command('ruby -c ' + executable)
      message += "\nsyntax_test=" + syntax_test.inspect
      message += "\nsyntax_test.process_status=" + syntax_test.process_status.inspect
      message += "\nbranch_expected=#{branch_expected.inspect}"
      message += "\ndeserving_branch=#{deserving_branch.inspect}"
      case deserving_branch
      when :edited then
        assert_equal(1, recent_test.process_status.exitstatus, message)
        refute_equal("Syntax OK\n", syntax_test.output, message)
        assert_equal(1, syntax_test.process_status.exitstatus, message)
      when :tested then
        assert_operator(1, :<=, recent_test.process_status.exitstatus, message)
        assert_equal("Syntax OK\n", syntax_test.output, message)
      when :passed then
        assert_equal(0, recent_test.process_status.exitstatus, message)
        assert_equal("Syntax OK\n", syntax_test.output, message)
      end # case
      assert_equal(deserving_branch, branch_expected, message)
    end # deserving_branch
  end # Assertions
end # TestMaturity

class UnitMaturity
  # include Repository::Constants
  module Constants
    # define branch maturity partial order
    # use for merge-down and maturity promotion
  end # Constants
  include Constants
  module ClassMethods
    # include Repository::Constants
    include Constants
  end # ClassMethods
  extend ClassMethods
  attr_reader :repository, :unit
  def initialize(repository, unit)
    raise 'UnitMaturity.new first argument must be of type Repository' unless repository.instance_of?(Repository)
    #	fail "@repository must respond to :remotes?\n"+
    #		"repository.inspect=#{repository.inspect}\n" +
    #		"repository.methods(false)=#{repository.methods(false).inspect}" unless repository.respond_to?(:remotes?)
    @repository = repository
    @unit = unit
  end # initialize

  def diff_command?(filename, branch_index)
    raise filename + ' does not exist.' unless File.exist?(filename)
    branch_string = Branch.branch_symbol?(branch_index).to_s
    git_command = "diff --summary --shortstat #{branch_string} -- " + filename.to_s
    diff_run = @repository.git_command(git_command)
  end # diff_command?

  # What happens to non-existant versions? returns nil Are they different?
  # What do I want?
  def working_different_from?(filename, branch_index)
    diff_run = diff_command?(filename, branch_index)
    if diff_run.output == ''
      false # no difference
    elsif diff_run.output.split("\n").size == 2
      nil # missing version
    else
      true # real difference
    end # if
  end # working_different_from?

  def differences?(filename, range)
    differences = range.map do |branch_index|
      working_different_from?(filename, branch_index)
    end # map
  end # differences?

  def scan_verions?(filename, range, direction)
    differences = differences?(filename, range)
    different_indices = []
    existing_indices = []
    range.zip(differences) do |index, s|
      case s
      when true then
        different_indices << index
        existing_indices << index
      when nil then
      when false then
        existing_indices << index
      else
        raise 'else ' + local_variables.map { |v| eval(v).inspect }.join("\n")
      end # case
    end # zip
    case direction
    when :first then
      (different_indices + [existing_indices[-1]]).min
    when :last then
      ([existing_indices[0]] + different_indices).max
    else
      raise
    end # case
  end # scan_verions?

  def bracketing_versions?(filename, current_index)
    left_index = scan_verions?(filename, Branch::First_slot_index..current_index, :last)
    right_index = scan_verions?(filename, current_index + 1..Branch::Last_slot_index, :first)
    [left_index, right_index]
  end # bracketing_versions?
end # UnitMaturity

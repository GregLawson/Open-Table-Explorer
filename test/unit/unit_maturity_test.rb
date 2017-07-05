###########################################################################
#    Copyright (C) 2013-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/unit_maturity.rb'
class TestMaturityTest < TestCase
  module Examples
    include TestMaturity::DefinitionalConstants
    include TestMaturity::ReferenceObjects
    #    ExecutableMaturity = TestMaturity.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME))
    MinimalMaturity = TestMaturity.new(test_executable: TestExecutable.new(argument_path: 'test/unit/minimal2_test.rb'))
    MinimalMaturity3 = TestMaturity.new(test_executable: TestExecutable.new(argument_path: 'test/unit/minimal3_test.rb'))
		require_relative '../examples/ruby_lines_storage.rb'
  end # Examples
  include Examples

  def test_DefinitionalConstants
    Error_classification.each_pair do |expected_error_score, classification|
      assert_instance_of(Fixnum, expected_error_score)
      assert_instance_of(Symbol, classification)
    end # each_pair
    assert_equal(4, Error_classification.keys.size, Error_classification.inspect)
    assert_equal(4, Error_classification.values.size, Error_classification.inspect)
    example_minitest_log = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
    example_testunit_log = RubyLinesStorage.read('./log/unit/2.2/2.2.3p173/silence/initialization_fail.rb.log')
    example_minitest_log = IO.read('./log/unit/2.2/2.2.3p173/silence/single_test_fail.rb.log')
    example_testunit_log = IO.read('./log/unit/2.2/2.2.3p173/silence/initialization_fail.rb.log')
    #	assert_match(Tests_pattern, example_minitest_log)
    #	assert_match(Assertions_pattern, example_minitest_log)
    #	assert_match(Failures_pattern, example_minitest_log)
    #	assert_match(Errors_pattern, example_minitest_log)
    #	assert_match(Tests_pattern, example_testunit_log)
    #	assert_match(Pendings_pattern, example_testunit_log)
    assert_match(Fixed_regexp, example_testunit_log)
    assert_match(/Finished in / * Fixed_regexp.capture(:test_finished), example_testunit_log)
    assert_match(/Finished in / * Fixed_regexp.capture(:test_finished), example_testunit_log)
    #    assert_match(/Finished in / * Fixed_regexp.capture(:test_finished) * /s, / * Fixed_regexp, example_testunit_log)
    #    assert_match(/Finished in / * Fixed_regexp.capture(:test_finished) * /s, / * Fixed_regexp * / runs\/s, /, example_testunit_log)
    #    assert_match(/Finished in / * Fixed_regexp.capture(:test_finished) * /s, / * Fixed_regexp * / runs\/s, / * Fixed_regexp, example_testunit_log)
    assert_match(Finished_regexp, example_testunit_log)
    assert_match(User_time_regexp, example_testunit_log)

    assert_match(Fixed_regexp, example_minitest_log)
    #    assert_match(Finished_regexp, example_minitest_log)
    assert_match(User_time_regexp, example_minitest_log)

    #    assert_match(Tests_pattern, example_minitest_log)
    #    assert_match(Assertions_pattern, example_minitest_log)
    #    assert_match(Failures_pattern, example_minitest_log)
    #    assert_match(Errors_pattern, example_minitest_log)
    assert_match(Tests_pattern, example_testunit_log)
    assert_match(Pendings_pattern, example_testunit_log)
    assert_match(Omissions_pattern, example_testunit_log)
    assert_match(Notifications_pattern, example_testunit_log)
    minitest_summary_regexp = Tests_pattern * Assertions_pattern * Failures_pattern * Errors_pattern
    #    assert_match(Common_summary_regexp, example_minitest_log)
    testunit_summary_regexp = Common_summary_regexp * Pendings_pattern * Omissions_pattern * Notifications_pattern
    assert_match(testunit_summary_regexp, example_testunit_log)
  end # DefinitionalConstants

  def test_example_files
    ret = {} # accumulate a hash
    Error_classification_keys.each do |classification|
      argument_path = Error_score_directory + classification.to_s + '.rb'
      message = 'argument_path = ' + argument_path
      assert(File.exist?(argument_path), message)
      ret = ret.merge(classification => argument_path)
    end # each_pair
    refute_empty(TestMaturity.example_files)
    assert_equal(5, TestMaturity.example_files.keys.size, TestMaturity.example_files.inspect)
    assert_equal(5, TestMaturity.example_files.values.size, TestMaturity.example_files.inspect)
    assert_equal(ret, TestMaturity.example_files)
    assert_equal(Dir[Error_score_directory + '*'].sort, TestMaturity.example_files.values.sort)
  end # example_files

  def test_log_path?
    argument_path = $PROGRAM_NAME
    assert_equal('log/unit/1.9/1.9.3p194/quiet/argument_path.log', MinimalMaturity.log_path?(executable_file))
    assert_equal('log/unit/1.9/1.9.3p194/quiet/unit_maturity.log', MinimalMaturity.log_path?(argument_path))
    #	assert_equal('log/unit/1.9/1.9.3p194/quiet/repository.log', MinimalMaturity.log_path?)
  end # log_path?

  def test_file_bug_reports
    header, errors, summary = TestMaturity.parse_log_file(MinimalMaturity.test_executable.log_path?(nil))
    headerArray = header.split("\n")
    assert_instance_of(Array, headerArray)
    sysout = headerArray[0..-2]
    assert_instance_of(Array, sysout)
    assert_equal(headerArray.size, sysout.size + 1)
    run_time = headerArray[-1].split(' ')[2]
    #	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray='#{headerArray.inspect}', header='#{header.inspect}'")
    #	assert_equal('in',headerArray[-1].split(' ')[1])
    #	assert_equal('seconds.',headerArray[-1].split(' ')[3])
    sysout, run_time = TestMaturity.parse_header(header)
    assert_instance_of(Array, sysout)
    refute_nil(run_time)
    assert_operator(run_time, :>=, 0)
    sysout, run_time = TestMaturity.parse_header(header)
    refute_nil(run_time)
    assert_operator(run_time, :>=, 0)
  end # file_bug_reports

  def test_parse_log_file
    log_file = MinimalMaturity.test_executable.log_path?(nil)
    blocks = IO.read(log_file).split("\n\n") # delimited by multiple successive newlines
    #	puts "blocks='#{blocks.inspect}'"
    header = blocks[0]
    errors = blocks[1..-2]
    summary = blocks[-1]
    headerArray = header.split("\n")
    assert_instance_of(Array, headerArray)
    assert_operator(headerArray.size, :>, 1)
    sysout = headerArray[0..-2]
    assert_instance_of(Array, sysout)
    assert_equal(headerArray.size, sysout.size + 1)
    run_time = headerArray[-1].split(' ')[2]
    #	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray[-1]='#{headerArray[-1].inspect}'")
    #	assert_equal('in',headerArray[-1].split(' ')[1])
    #	assert_equal('seconds.',headerArray[-1].split(' ')[3])
    sysout, run_time = TestMaturity.parse_header(header)
    assert_instance_of(Array, sysout)
    refute_nil(run_time)
    assert_operator(run_time, :>=, 0)
    sysout, run_time = TestMaturity.parse_header(header)
    refute_nil(run_time)
    assert_operator(run_time, :>=, 0)
    #	header,errors,summary=TestMaturity.parse_log_file(testRun.test_executable.log_path?)
    #	refute_nil(header)
    #	refute_nil(summary)
  end # parse_log_file

  def test_log_passed?
  end # log_passed?

  def test_summarize
  end # summarize

  def test_parse_summary
  end # parse_summary

  def test_parse_header
    header, errors, summary = TestMaturity.parse_log_file(MinimalMaturity.test_executable.log_path?(nil))
    assert_operator(header.size, :>, 0)
    headerArray = header.split("\n")
    assert_instance_of(Array, headerArray)
    sysout = headerArray[0..-2]
    assert_instance_of(Array, sysout)
    assert_equal(headerArray.size, sysout.size + 1)
    run_time = headerArray[-1].split(' ')[2]
    #	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray[-1]='#{headerArray[-1].inspect}'")
    #	assert_equal('in',headerArray[-1].split(' ')[1])
    #	assert_equal('seconds.',headerArray[-1].split(' ')[3])
    sysout, run_time = TestMaturity.parse_header(header)
    assert_instance_of(Array, sysout)
    refute_nil(run_time)
    assert_operator(run_time, :>=, 0)
  end # parse_header

  def test_Constructors # such as alternative new methods
  end # Constructors

  def test_ReferenceObjects
    assert_equal(true, Working_maturity.test_executable.recursion_danger?)
    #    assert_equal(Working_maturity, ExecutableMaturity)

    working_log = RubyLinesStorage.read(TestMaturity::Self_test_executable.log_path?(nil))
    assert_equal(working_log, TestMaturity::Working_maturity.read_state)
    TestMaturity::Working_maturity.assert_pre_conditions
    TestMaturity::Working_maturity.assert_post_conditions
  end # ReferenceObjects

  def test_read_state
    log_files = TestMaturity.all
    file_times = log_files.map do |path|
      file_contents = IO.read(path)
      read_return = RubyLinesStorage.read(path)
      assert_instance_of(Hash, read_return)
      if RubyLinesStorage.read_success?(read_return)
				assert(RubyLinesStorage.read_success?(read_return), read_return.ruby_lines_storage)
				refute_includes(read_return.keys, :exception_hash, read_return.ruby_lines_storage)
				assert_equal(Read_success_keys, read_return.keys)
				assert_equal(read_return, eval(file_contents))
				TestMaturity.assert_log_hash(eval(file_contents))
				TestMaturity.assert_log_hash(read_return)
				assert_equal(Branch.current_branch_name?(Repository::This_code_repository), read_return[:current_branch_name], read_return.inspect)
				um_hash = TestMaturity.new(version: nil, test_executable: TestExecutable.new(argument_path: path)).read_state
				assert_equal(um_hash, read_return)
				TestMaturity.assert_log_hash(um_hash)
			else
				refute(RubyLinesStorage.read_success?(read_return), read_return.ruby_lines_storage)
				assert_includes(read_return.keys, :exception_hash, read_return.ruby_lines_storage)
				assert_equal(RubyLinesStorage::Read_fail_keys, read_return.keys)
			end # if
    end # each
  end # read_state

  def test_times
    log_files = TestMaturity.all
    file_times = log_files.map do |path|
      file_contents = IO.read(path)
      read_return = RubyLinesStorage.read(path)
      if RubyLinesStorage.read_success?(read_return)
				assert_match(Finished_regexp, file_contents, path)
				assert_match(User_time_regexp, file_contents, path)
				finished_time = file_contents.parse(Finished_regexp)
				user_time = file_contents.parse(User_time_regexp)
				assert_operator(finished_time[:test_finished].to_f, :<, user_time[:user_time].to_f)
				read_return = RubyLinesStorage.read(path)
				finished_time.merge(user_time)
			else
			end # if
    end # each
    message = ruby_lines_storage(file_times)
    #		assert_equal
  end # times

  def test_recursion_danger?
    assert_equal(true, Working_maturity.test_executable.recursion_danger?)
    assert_equal(false, MinimalMaturity.test_executable.recursion_danger?)
    assert_equal(false, MinimalMaturity3.test_executable.recursion_danger?)
  end # recursion_danger?

  def test_run
    #	assert_equal("test/unit/test_run_test.rb\n", TestRun.new(test_command: 'echo', options: '').run.output)
    ruby_pattern = /ruby / * /2.1.2p95/
    parenthetical_date_pattern = / \(/ * /2014-05-08/.capture(:compile_date) * /\)/
    bracketed_os = / \[/ * /i386-linux-gnu/ * /\]/ * "\n"
    version_pattern = ruby_pattern * parenthetical_date_pattern * bracketed_os
    #	assert_match(ruby_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	assert_match(parenthetical_date_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	assert_match(bracketed_os, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	assert_match(ruby_pattern * parenthetical_date_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	assert_match(parenthetical_date_pattern * bracketed_os, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	assert_match(version_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
    #	output = TestRun.new(test_command: 'ruby', singular_table: 'unit').run.assert_post_conditions.output
    #	unit_run = TestRun.new(test_command: 'ruby', singular_table: 'unit')
    #	assert_equal(0, unit_run.process_status, unit_run.inspect)
    #	unit_run.assert_post_conditions
    #	output = unit_run.output
    tests_pattern = /[0-9]+/.capture(:tests) * / / * /tests/
    assertions_pattern = /[0-9]+/.capture(:assertions) * / / * /assertions/
    failures_pattern = /[0-9]+/.capture(:failures) * / / * /failures/
    errors_pattern = /[0-9]+/.capture(:errors) * / / * /errors/
    pendings_pattern = /[0-9]+/.capture(:pendings) * / / * /pendings/
    omissions_pattern = /[0-9]+/.capture(:omissions) * / / * /omissions/
    notifications_pattern = /[0-9]+/.capture(:notifications) * / / * /notifications/
    output_pattern = [tests_pattern, assertions_pattern, failures_pattern, errors_pattern, pendings_pattern]
    output_pattern += [omissions_pattern, notifications_pattern]
    #	test_results = output.parse(output_pattern)
    #	assert_instance_of(Array, test_results)
  end # run

  def test_get_error_score!
    assert_includes(TestMaturity.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME)).instance_variables, :@test_executable)
    refute_includes(TestMaturity.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME)).instance_variables, :@cached_error_score)
    assert_includes(Working_maturity.instance_variables, :@test_executable)
    assert_nil(Working_maturity.get_error_score!)
  end # error_score

  def test_deserving_branch
    error_classifications = []
    branch_compressions = []
    branch_enhancements = []
    TestMaturity.example_files.each_pair do |classification, argument_path|
      assert_instance_of(Symbol, classification, TestMaturity.example_files.inspect)
      assert(File.exist?(argument_path.to_s), TestMaturity.example_files.inspect)
      test_executable = TestExecutable.new(argument_path: argument_path)
      refute_nil(test_executable.unit) # nonstandard unit assignment
      assert_equal(:unit, test_executable.test_type) # nonstandard unit assignment
      test_run = TestRun.new(test_executable: test_executable)
      test_maturity = TestMaturity.new(test_executable: test_executable)
      deserving_branch = if File.exist?(test_executable.argument_path)
                           test_maturity.deserving_commit_to_branch!
                         else
                           :edited
      end # if
      #		assert_equal(expected_error_score, error_score, test_run.inspect)
      error_classifications << test_maturity.error_classification!
      branch_compressions << test_maturity.expected_next_commit_branch!
      #			branch_enhancements << test_maturity.branch_enhancement!
    end # each
    assert_equal(4, error_classifications.uniq.size, error_classifications.inspect)
    assert_equal(3, branch_compressions.uniq.size, branch_compressions.inspect)
    #    assert_equal(3, branch_enhancements.uniq.size, branch_enhancements.inspect)
    #    error_classification=Error_classification.fetch(error_score, :multiple_tests_fail)
    #    assert_equal(:passed, Branch_enhancement[Deserving_commit_to_branch[error_classification]])
  end # deserving_branch

  def test_compare
    assert_equal(0, MinimalMaturity3 <=> MinimalMaturity3)
    assert_equal(0, MinimalMaturity <=> MinimalMaturity)
    assert(MinimalMaturity.test_executable.testable?)
    assert(MinimalMaturity3.test_executable.testable?)
    refute_nil(MinimalMaturity.get_error_score!)
    refute_nil(MinimalMaturity3.get_error_score!)
    assert_equal(0, MinimalMaturity.get_error_score! <=> MinimalMaturity3.get_error_score!)
    assert_equal(0, MinimalMaturity <=> MinimalMaturity3)
    assert_equal(0, MinimalMaturity3 <=> MinimalMaturity) # symmetric
    assert_equal(false, Working_maturity.test_executable.testable?)
  end # <=>

  def test_error_classification!
    Error_classification.fetch(MinimalMaturity.get_error_score!, :multiple_tests_fail)
  end # error_classification!

  def test_deserving_commit_to_branch!
    TestMaturity::Push_branch[MinimalMaturity.error_classification!]
  end # deserving_commit_to_branch!

  def test_expected_next_commit_branch!
    TestMaturity::Pull_branch[MinimalMaturity.error_classification!]
  end # expected_next_commit_branch!

  def test_branch_enhancement!
    assert_instance_of(Symbol, MinimalMaturity.deserving_commit_to_branch!)
    #	Branch::Branch_enhancement[MinimalMaturity.deserving_commit_to_branch!]
  end # branch_enhancement!

	def test_assert_log_hash
    log_files = TestMaturity.all
    file_times = log_files.map do |path|
      file_contents = IO.read(path)
      read_return = RubyLinesStorage.read(path)
			if read_return.keys.include?(:exception_hash)
				puts read_return.inspect
			end # if
#!      um_hash = TestMaturity.new(version: nil, test_maturity: TestExecutable.new(argument_path: path)).read_state
#!      assert_equal(um_hash, hash)
#!      TestMaturity.assert_log_hash(eval(file_contents))
      TestMaturity.assert_log_hash(read_return)
#!      TestMaturity.assert_log_hash(um_hash)
    end # each
	end # assert_log_state

  def test_nested_scope_modules?
    assert_include(TestMaturity::Assertions::ClassMethods.instance_methods(false), :nested_scope_modules?)
    assert_include(TestMaturity::Assertions::ClassMethods.nested_scope_modules?, :Assertions)
  end # nested_scopes

  def test_included_module_names
    this_class = TestMaturity
    # !		assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
    # !		assert_includes(this_class.included_module_names, (this_class.name + '::Constructors').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::ReferenceObjects').to_sym)
    assert_includes(this_class.included_module_names, (this_class.name + '::Assertions').to_sym)
  end # included_module_names

  def test_nested_scope_module_names
    this_class = TestMaturity
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalClassMethods').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::DefinitionalConstants').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Constructors').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::ReferenceObjects').to_sym)
    assert_includes(this_class.nested_scope_module_names, (this_class.name + '::Assertions').to_sym)
    assert_includes(this_class.constants, :Working_maturity)
  end # nested_scope_module_names

  def test_assert_nested_scope_submodule
    this_class = TestMaturity
    this_class.assert_nested_scope_submodule((this_class.name + '::DefinitionalClassMethods').to_sym)
    this_class.assert_nested_scope_submodule((this_class.name + '::DefinitionalConstants').to_sym)
    this_class.assert_nested_scope_submodule((this_class.name + '::Constructors').to_sym)
    this_class.assert_nested_scope_submodule((this_class.name + '::ReferenceObjects').to_sym)
    this_class.assert_nested_scope_submodule((this_class.name + '::Assertions').to_sym)
  end # assert_included_submodule

  def test_assert_included_submodule
    this_class = TestMaturity
    # !class				this_class.assert_included_submodule((this_class.name + '::DefinitionalClassMethods').to_sym)
    this_class.assert_included_submodule((this_class.name + '::DefinitionalConstants').to_sym)
    # !class				this_class.assert_included_submodule((this_class.name + '::Constructors').to_sym)
    this_class.assert_included_submodule((this_class.name + '::ReferenceObjects').to_sym)
    this_class.assert_included_submodule((this_class.name + '::Assertions').to_sym)
  end # assert_included_submodule

  def test_assert_nested_and_included
    TestMaturity.assert_nested_and_included(:Assertions)
  end # assert_nested_and_included
end # TestMaturity

class UnitMaturityTest < TestCase
  # include DefaultTests
  include Repository::Examples
  def test_DefinitionalConstants
  end # DefinitionalConstants
  module Examples
    #    include Constants
    File_not_in_oldest_branch = 'test/slowest/repository_test.rb'.freeze
    Most_stable_file = 'test/unit/minimal2_test.rb'.freeze
    Formerly_existant_file = 'test/unit/related_file.rb'.freeze
    TestUnitMaturity = UnitMaturity.new(Repository::This_code_repository, Repository::Repository_Unit)
  end # Examples
  include Examples

  def test_diff_command?
    filename = Most_stable_file
    branch_index = Branch.branch_index?(Branch.current_branch_name?(Repository::This_code_repository).to_sym)
    message = Branch::Branch_enhancement.inspect + Branch.current_branch_name?(Repository::This_code_repository).inspect
    refute_nil(branch_index, message)
    branch_string = Branch.branch_symbol?(branch_index).to_s
    git_command = "diff --summary --shortstat #{branch_string} -- " + filename.to_s
    diff_run = Repository::This_code_repository.git_command(git_command)
    #	diff_run.assert_post_conditions
    assert_instance_of(ShellCommands, diff_run)
    assert_operator(diff_run.output.size, :==, 0)
    message = "diff_run=#{diff_run.inspect}"
    assert_equal('', diff_run.output, message)
    message = "diff_run=#{diff_run.inspect}"
    assert_equal('', TestUnitMaturity.diff_command?(Most_stable_file, branch_index).output)
  end # diff_command?

  def test_working_different_from?
    current_branch_index = Branch.branch_index?(Branch.current_branch_name?(Repository::This_code_repository).to_sym)
    assert_equal('', TestUnitMaturity.diff_command?(Most_stable_file, current_branch_index).output)
    assert_equal(false, TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index))
    #	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 1))
    #	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 2))
    #	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 3))
    #	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 4))
    filename = File_not_in_oldest_branch
    diff_run = Repository::This_code_repository.git_command('diff --summary --shortstat origin/master -- ' + filename)
    refute_equal([], diff_run.output.split("\n"), diff_run.inspect)
    assert_equal(2, diff_run.output.split("\n").size, diff_run.inspect)
    #	assert_nil(TestUnitMaturity.working_different_from?(File_not_in_oldest_branch,-2))
  end # working_different_from?

  def test_differences?
    range = -2..0
    filename = File_not_in_oldest_branch
    #	assert_nil(TestUnitMaturity.working_different_from?(File_not_in_oldest_branch,-2))
    differences = range.map do |branch_index|
      TestUnitMaturity.working_different_from?(filename, branch_index)
    end # map
    #	assert_nil(differences[0])
    #	assert_nil(TestUnitMaturity.differences?(File_not_in_oldest_branch, range)[0], message)
    #	assert_equal([false, false, false], TestUnitMaturity.differences?(Most_stable_file, range), message)
  end # differences?

  def test_scan_verions?
    filename = File_not_in_oldest_branch
    range = -2..3
    direction = :last
    differences = TestUnitMaturity.differences?(filename, range)
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
      end # case
    end # zip
    scan_verions = case direction
                   when :first then
                     (different_indices + [existing_indices[-1]]).min
                   when :last then
                     ([existing_indices[0]] + different_indices).max
                   else
                     raise
    end # case
    message = 'filename=' + filename.inspect
    message += "\nrange=" + range.inspect
    message += "\ndirection=" + direction.inspect
    message += "\ndifferences=" + differences.inspect
    message += "\ndifferent_indices=" + different_indices.inspect
    message += "\nexisting_indices=" + existing_indices.inspect
    message += "\nscan_verions=" + scan_verions.inspect
    #	assert_equal(existing_indices[0], scan_verions, message)
    filename = Most_stable_file
    #	assert_equal(First_slot_index, TestUnitMaturity.scan_verions?(filename, range, :last), message)
    #	assert_equal(Last_slot_index, TestUnitMaturity.scan_verions?(filename, First_slot_index..Last_slot_index, :first), message)
  end # scan_verions?

  def test_bracketing_versions?
    filename = Most_stable_file
    current_index = 0
    left_index = TestUnitMaturity.scan_verions?(filename, Branch::First_slot_index..current_index, :last)
    right_index = TestUnitMaturity.scan_verions?(filename, current_index + 1..Branch::Last_slot_index, :first)
    #	assert_equal(First_slot_index, TestUnitMaturity.scan_verions?(filename, Branch::First_slot_index..current_index, :last))
    #	assert_equal(Branch::First_slot_index, left_index)
    #	assert(!TestUnitMaturity.working_different_from?(filename, 1))
    #	assert_equal(false, TestUnitMaturity.working_different_from?(filename, 1))
    #	assert_equal(Branch::Last_slot_index, right_index)
    #	assert_equal([Branch::First_slot_index, Branch::Last_slot_index], TestUnitMaturity.bracketing_versions?(filename, 0))
  end # bracketing_versions?
end # UnitMaturity

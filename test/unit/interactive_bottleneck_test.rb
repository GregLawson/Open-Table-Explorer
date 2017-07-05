###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/interactive_bottleneck.rb'
require_relative '../assertions/repository_assertions.rb'
require_relative '../assertions/shell_command_assertions.rb'
class InteractiveBottleneckTest < TestCase
  # include DefaultTests
  # include InteractiveBottleneck
  # extend InteractiveBottleneck::ClassMethods
  include InteractiveBottleneck::Examples
  Dir['test/data_sources/repository20*'].each do |test_repository|
    Repository.delete_existing(test_repository)
  end # each

  module Examples
    TestTestExecutable = TestExecutable.new(argument_path: File.expand_path($PROGRAM_NAME))
    TestInteractiveBottleneck = InteractiveBottleneck.new(interactive: :interactive, test_executable: TestTestExecutable, editor: Default_editor)
    include Constants
  end # Examples
  include Examples

  def setup
    @temp_repo = Repository.create_test_repository
    refute_equal(Repository::This_code_repository, @temp_repo)
    @temp_interactive_bottleneck = InteractiveBottleneck.new(test_executable: TestExecutable.new(argument_path: $PROGRAM_NAME), repository: @temp_repo, interactive: :echo)
    assert_equal(@temp_repo, @temp_interactive_bottleneck.repository)
    refute_nil(@temp_interactive_bottleneck.interactive)
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def test_calc_test_maturity
    #	recursion_danger = :recursion_danger
    dirty_test_executables = TestInteractiveBottleneck.dirty_test_executables
    dirty_test_executables.map do |test_executable|
      message = test_executable.inspect
      ret =
        if test_executable.testable?
          refute_nil(test_executable.unit, message)
          calc_test_maturity = InteractiveBottleneck.calc_test_maturity!(test_executable)
          message = calc_test_maturity.inspect
          assert_instance_of(TestExecutable, test_executable, message)
          assert_empty(Dir['log/*/*/*/*/*.jpg.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/*.pdf.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/*.xml.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/repository20*.log'], test_executable.inspect)
          calc_test_maturity # to be sorted
          calc_test_maturity = InteractiveBottleneck.calc_test_maturity!(test_executable)
          message = calc_test_maturity.inspect
          assert_instance_of(TestExecutable, test_executable, message)
          assert_empty(Dir['log/*/*/*/*/*.jpg.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/*.pdf.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/*.xml.log'], test_executable.inspect)
          assert_empty(Dir['log/*/*/*/*/repository20*.log'], test_executable.inspect)
        elsif test_executable.testable?.nil?
          assert_nil(test_executable.unit, message)
          nil
        elsif !TestInteractiveBottleneck.test_executable.recursion_danger?
          nil
        else
          refute_nil(test_executable.unit, message)
          nil
        end # if
      assert_empty(Dir['log/*/*/*/*/*.jpg.log'], test_executable.inspect)
      assert_empty(Dir['log/*/*/*/*/*.pdf.log'], test_executable.inspect)
      assert_empty(Dir['log/*/*/*/*/*.xml.log'], test_executable.inspect)
      assert_empty(Dir['log/*/*/*/*/repository20*.log'], test_executable.inspect)
      refute_equal(test_executable.argument_path.to_s[-4..-1], '.log', test_executable.inspect)
      refute_equal(test_executable.regression_unit_test_file.to_s[-4..-1], '.log', test_executable.inspect)
      ret
    end.select { |m| m && m.get_error_score! }.sort
    assert_empty(Dir['log/*/*/*/*/*.jpg.log'])
    assert_empty(Dir['log/*/*/*/*/*.pdf.log'])
    assert_empty(Dir['log/*/*/*/*/*.xml.log'])
    assert_empty(Dir['log/*/*/*/*/repository20*.log'])
  end # calc_test_maturity!

  def test_initialize
    refute_empty(TestInteractiveBottleneck.test_executable.unit.edit_files, 'TestInteractiveBottleneck.test_executable.unit.edit_files= ' + TestInteractiveBottleneck.test_executable.unit.inspect)
    assert_includes(TestInteractiveBottleneck.test_executable.unit.edit_files, Pathname.new($PROGRAM_NAME).expand_path, "TestInteractiveBottleneck.unit=#{TestInteractiveBottleneck.test_executable.unit.inspect}")
    assert_equal(TestTestExecutable, TestInteractiveBottleneck.test_executable, TestInteractiveBottleneck.inspect)
    assert_equal(Repository::This_code_repository, TestInteractiveBottleneck.repository, TestInteractiveBottleneck.inspect)
    #	assert_equal(, TestInteractiveBottleneck.unit_maturity, TestInteractiveBottleneck.inspect)
    #    assert_equal(Editor::Examples::TestEditor, TestInteractiveBottleneck.editor, TestInteractiveBottleneck.inspect)

    #    refute_nil(InteractiveBottleneck.new(interactive: :interactive, test_executable: TestTestExecutable, editor: Editor::Examples::TestEditor).interactive)
    #	refute_nil(InteractiveBottleneck.new(test_executable: TestTestExecutable, editor: Editor::Examples::TestEditor).interactive)

    refute_nil(TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
    assert_equal(:interactive, TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
  end # values
  include InteractiveBottleneck::Examples

  def test_dirty_test_executables
    line_by_line = TestInteractiveBottleneck.repository.status.map do |file_status|
      if file_status.log_file?
        nil
      elsif file_status.work_tree == :ignore
        nil
      else
        refute_nil(file_status.file)
        assert(File.exist?(file_status.file))

        argument_path = file_status.file
        test_type = nil
        repository = Repository::This_code_repository
        argument_path = RepositoryPathname.new_from_path(argument_path) if argument_path.instance_of?(String)
        unit = RailsishRubyUnit.new_from_path(argument_path)
        lookup = FilePattern.find_from_path(argument_path)
        unless lookup.nil?
          test_executable = TestExecutable.new_from_path(file_status.file)
        testable = test_executable.generatable_unit_file?
        if testable
          test_executable # find unique
        end # if
      end # if
      end # if
    end.select { |t| !t.nil? }.uniq # map
    assert_equal(line_by_line, TestInteractiveBottleneck.dirty_test_executables, 'diff = ' + (line_by_line - TestInteractiveBottleneck.dirty_test_executables).inspect)
    verify_output = TestInteractiveBottleneck.dirty_test_executables.each do |test_executable|
      message = test_executable.inspect
      assert_instance_of(TestExecutable, test_executable)
      testable = test_executable.testable?
      if testable
        test_executable
      elsif testable == false
        refute_nil(test_executable.unit, message)
        nil
      elsif testable.nil?
        assert_nil(test_executable.unit, message)
        nil
          end # if
      # OK		refute_nil(test_executable.unit.model_basename, test_executable.inspect)
      # OK		assert_equal(test_executable.unit, Unit::Executable, test_executable.inspect)
      if test_executable.unit.model_basename.nil?
        puts test_executable.inspect + ' does not match a known pattern.'
        assert_equal(:unit, test_executable.test_type, test_executable.inspect)
      end # if
    end # each
  end # dirty_test_executables

  def test_dirty_units
    TestInteractiveBottleneck.dirty_units.each do |prospective_unit|
      if prospective_unit[:unit].nil?
        puts prospective_unit.inspect + ' does not match a known pattern.'
      else
        refute_nil(prospective_unit[:unit], prospective_unit.inspect)
        #        assert_instance_of(Unit, prospective_unit[:unit])
        refute_nil(prospective_unit[:unit].model_basename, prospective_unit.inspect)
      end # if
      # OK		assert_equal(prospective_unit[:unit], Unit::Executable, prospective_unit.inspect)
    end # each
  end # dirty_units

  def test_dirty_test_maturities
    recursion_danger = :recursion_danger
    TestInteractiveBottleneck.dirty_test_executables.map do |test_executable|
      message = test_executable.inspect
      assert_instance_of(TestExecutable, test_executable, message)
      calc_test_maturity = InteractiveBottleneck.calc_test_maturity!(test_executable)
      message = calc_test_maturity.inspect
      assert_instance_of(TestExecutable, test_executable, message)
      testable = test_executable.testable?
      if testable
        refute_nil(test_executable.unit, message)
        nil
      elsif testable.nil?
        assert_nil(test_executable.unit, message)
        nil
      elsif !recursion_danger.nil? && (TestInteractiveBottleneck.test_executable.argument_path == $PROGRAM_NAME)
        nil
      else
        refute_nil(test_executable.unit, message)
        calc_test_maturity # to be sorted
      end # if
    end.compact.sort
    dirty_test_maturities = TestInteractiveBottleneck.dirty_test_maturities(:danger)
    assert_instance_of(Array, dirty_test_maturities)
    unless dirty_test_maturities.empty?
      refute_empty(dirty_test_maturities)
      a_dirty_test_maturity = dirty_test_maturities[0]
      start_message = 'a_dirty_test_maturity = ' + a_dirty_test_maturity.inspect + "\n"
      start_message += 'a_dirty_test_maturity.test_executable.testable? = ' + a_dirty_test_maturity.test_executable.testable?.inspect + "\n"
      #		refute_nil(a_dirty_test_maturity.get_error_score!, message)
      dirty_test_maturities.each do |test_maturity|
        refute_nil(test_maturity, test_maturity.inspect)
        assert_instance_of(TestMaturity, test_maturity)
        message = start_message + 'test_maturity = ' + test_maturity.inspect
        message += 'test_maturity.test_executable.testable? = ' + test_maturity.test_executable.testable?.inspect + "\n"
        message += "\n"
        assert_includes([1, 0, -1, nil], test_maturity.test_executable <=> a_dirty_test_maturity.test_executable, message)
        #		refute_nil(test_maturity.get_error_score!, message)
        assert_includes([1, 0, -1, nil], test_maturity.get_error_score! <=> a_dirty_test_maturity.get_error_score!, message)
        assert_includes([1, 0, -1, nil], test_maturity <=> a_dirty_test_maturity, message)
      end # each
    end # if

    dirty_test_maturities = dirty_test_maturities.compact.sort do |n1, n2|
      comparison = n1 <=> n2
      if comparison.nil?

      end # if
    end # sort
    dirty_test_maturities.each do |test_maturity|
      refute_nil(test_maturity, test_maturity.inspect)
      assert_instance_of(TestMaturity, test_maturity)
    end # each
  end # dirty_test_maturities

  def test_clean_directory
    dirty_test_maturities = TestInteractiveBottleneck.dirty_test_maturities(:danger).compact
    sorted = dirty_test_maturities # .sort{|n1, n2| n1[:error_score] <=> n2[:error_score]}
    sorted.sort.map do |test_maturity|
      target_branch = test_maturity.deserving_branch
      if test_maturity.nil? # rercursion avoided
        puts 'recursion avoided' + test_maturity.inspect
      else
        refute_nil(test_maturity, test_maturity.inspect)
        assert_instance_of(TestMaturity, test_maturity, test_maturity.inspect)
        assert_includes(Branch::Branch_enhancement, test_maturity.deserving_branch, test_maturity.inspect)
        assert_equal(:unit, test_maturity.test_executable.test_type, test_maturity.inspect)
          # OK		assert_equal(TestInteractiveBottleneck.repository.current_branch_name?, test_maturity.deserving_branch, test_maturity.inspect)
        end # if
    end # map
    TestInteractiveBottleneck.clean_directory
  end # clean_directory

  def test_switch_branch
  end # switch_branch

  def test_stage_files
  end # stage_files


  def test_script_deserves_commit!
    # (deserving_branch)
  end # script_deserves_commit!

  def test_InteractiveBottleneck_assert_pre_conditions
    TestInteractiveBottleneck.assert_pre_conditions
  end # assert_pre_conditions

  def test_InteractiveBottleneck_assert_post_conditions
    TestInteractiveBottleneck # .assert_post_conditions
  end # assert_post_conditions

  def test_local_assert_pre_conditions
    TestInteractiveBottleneck # .assert_pre_conditions
  end # assert_pre_conditions

  def test_local_assert_post_conditions
    TestInteractiveBottleneck # .assert_post_conditions
  end # assert_post_conditions

  def test_Examples
    refute_nil(TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
    assert_equal(:interactive, TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
  end # Examples
end # InteractiveBottleneck

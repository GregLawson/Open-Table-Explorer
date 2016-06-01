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
    assert_equal(Editor::Examples::TestEditor, TestInteractiveBottleneck.editor, TestInteractiveBottleneck.inspect)

    refute_nil(InteractiveBottleneck.new(interactive: :interactive, test_executable: TestTestExecutable, editor: Editor::Examples::TestEditor).interactive)
    #	refute_nil(InteractiveBottleneck.new(test_executable: TestTestExecutable, editor: Editor::Examples::TestEditor).interactive)

    refute_nil(TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
    assert_equal(:interactive, TestInteractiveBottleneck.interactive, TestInteractiveBottleneck.inspect)
  end # values
  include InteractiveBottleneck::Examples

  def test_dirty_test_executables
    line_by_line = TestInteractiveBottleneck.repository.status.map do |file_status|
      if file_status[:log_file]
        nil
      elsif file_status[:working_tree] == :ignore
        nil
      else
        test_executable = TestExecutable.new_from_path(file_status[:file])
        testable = test_executable.generatable_unit_file?
        if testable
          test_executable # find unique
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
        assert_instance_of(Unit, prospective_unit[:unit])
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
      #	.	refute_nil(dirty_test_maturities[0])
      a_dirty_test_maturity = dirty_test_maturities[0]
      start_message = 'a_dirty_test_maturity = ' + a_dirty_test_maturity.inspect + "\n"
      start_message += 'a_dirty_test_maturity.test_executable.testable? = ' + a_dirty_test_maturity.test_executable.testable?.inspect + "\n"
      #	refute_nil(dirty_test_maturities[0].get_error_score!, message)
      dirty_test_maturities.each do |test_maturity|
        refute_nil(test_maturity, test_maturity.inspect)
        assert_instance_of(TestMaturity, test_maturity)
        message = start_message + 'test_maturity = ' + test_maturity.inspect
        message += 'test_maturity.test_executable.testable? = ' + test_maturity.test_executable.testable?.inspect + "\n"
        message += "\n"
        assert_includes([1, 0, -1, nil], test_maturity.test_executable <=> a_dirty_test_maturity.test_executable, message)
        #		refute_nil(test_maturity.get_error_score!, message)
        assert_includes([1, 0, -1, nil], test_maturity.get_error_score! <=> dirty_test_maturities[0].get_error_score!, message)
        assert_includes([1, 0, -1, nil], test_maturity <=> a_dirty_test_maturity, message)
      end # each
    end # if

    dirty_test_maturities.each do |test_maturity|
      refute_nil(test_maturity, test_maturity.inspect)
      assert_instance_of(TestMaturity, test_maturity)
    end # each
  end # dirty_test_maturities

  def test_clean_directory
    dirty_test_maturities = TestInteractiveBottleneck.dirty_test_maturities(:danger).compact
    sorted = dirty_test_maturities # .sort{|n1, n2| n1[:error_score] <=> n2[:error_score]}
    sorted.sort.map do |test_maturity|
      target_branch = TestInteractiveBottleneck.test_maturity.deserving_branch
      if test_maturity.nil? # rercursion avoided
        puts 'rercursion avoided' + test_maturity.inspect
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

  def test_confirm_branch_switch
    assert_equal(:master, @temp_repo.current_branch_name?)
    @temp_interactive_bottleneck.confirm_branch_switch(:passed)
    assert_equal(:passed, @temp_repo.current_branch_name?)
    @temp_interactive_bottleneck.confirm_branch_switch(:master)
    assert_equal(:master, @temp_repo.current_branch_name?)
  end # confirm_branch_switch

  def test_safely_visit_branch
    @temp_repo.force_change
    push_branch = @temp_repo.current_branch_name?
    target_branch = :passed
    push = @temp_repo.something_to_commit? # remember
    if push
      @temp_repo.git_command('stash save') # .assert_post_conditions
      changes_branch = :stash
    end # if

    if push_branch != target_branch
      @temp_interactive_bottleneck.confirm_branch_switch(target_branch)
      ret = @temp_interactive_bottleneck.validate_commit(changes_branch, [@temp_repo.path + 'README'])
      @temp_interactive_bottleneck.confirm_branch_switch(push_branch)
    else
      ret = @temp_repo.validate_commit(changes_branch, [@temp_repo.path + 'README'])
    end # if
    if push
      @temp_repo.git_command('stash apply --quiet') # .assert_post_conditions
    end # if
    assert_equal(push_branch, @temp_interactive_bottleneck.safely_visit_branch(push_branch) { push_branch })
    assert_equal(push_branch, @temp_interactive_bottleneck.safely_visit_branch(push_branch) { @temp_repo.current_branch_name? })
    target_branch = :master
    checkout_target = @temp_repo.git_command("checkout #{target_branch}")
    #		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
    target_branch = :passed
    assert_equal(target_branch, @temp_interactive_bottleneck.safely_visit_branch(target_branch) { @temp_repo.current_branch_name? })
    @temp_interactive_bottleneck.safely_visit_branch(target_branch) do
      @temp_repo.current_branch_name?
    end #
  end # safely_visit_branch

  def test_switch_branch
  end # switch_branch

  def test_stage_files
  end # stage_files

  def test_confirm_commit
    assert_equal(:echo, @temp_interactive_bottleneck.interactive)
    @temp_interactive_bottleneck.confirm_commit
  end # confirm_commit

  def test_validate_commit
    @temp_repo # .assert_nothing_to_commit
    @temp_repo.force_change
    #	assert(@temp_repo.something_to_commit?)
    #	@temp_repo.assert_something_to_commit
    #	@temp_repo.validate_commit(:master, [@temp_repo.path+'README'])
    @temp_repo.git_command('stash')
    @temp_repo.git_command('checkout passed')
    @temp_interactive_bottleneck.validate_commit(:stash, [@temp_repo.path + 'README'])
  end # validate_commit

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
  end # Examples
end # InteractiveBottleneck

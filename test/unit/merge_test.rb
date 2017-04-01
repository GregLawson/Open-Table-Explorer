###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/merge.rb'
require_relative '../assertions/repository_assertions.rb'
require_relative '../assertions/shell_command_assertions.rb'
require_relative '../../app/models/command_line.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
class MergeTest < TestCase
  # include DefaultTests
  # include Merge
  # extend Merge::ClassMethods
  module Examples
    TestSelf = TestExecutable.new(argument_path: File.expand_path($PROGRAM_NAME))
    TestMerge = Merge.new(interactive: :interactive, repository: Repository::This_code_repository)
    # !    include Constants
    Merge_unit = RailsishRubyUnit::Executable
    Merge_executable_path = Merge_unit.pathname_pattern?(:script)
    Merge_test_executable = TestExecutable.new_from_path(Merge_executable_path)
    No_args_command_line_script = CommandLine.new(test_executable: Merge_test_executable, unit_class: Merge, argv: [])

    Parent_command_line = CommandLine.new(test_executable: Merge_test_executable, unit_class: CommandLine, argv: [Merge_executable_path])

    sub_command_unit = RailsishRubyUnit.new(model_basename: Parent_command_line.sub_command.to_sym)
    #		assert_path_exist(sub_command_unit.model_pathname?)
    Virtual_command_line = Parent_command_line.sub_command_commandline

    TestSelf = TestExecutable.new(argument_path: File.expand_path($PROGRAM_NAME))
    TestMerge = Merge.new(interactive: :interactive, repository: Repository::This_code_repository)
  end # Examples
  include Examples

  def setup
    @temp_repo = Repository.create_test_repository
    refute_equal(Repository::This_code_repository, @temp_repo)
    @temp_merge = Merge.new(repository: @temp_repo, interactive: :echo)
    assert_equal(@temp_repo, @temp_merge.repository)
    refute_nil(@temp_merge.interactive)
  end # setup

  def test_Merge_Examples
    assert_instance_of(CommandLine, No_args_command_line_script)
    assert_instance_of(RepositoryPathname, No_args_command_line_script.test_executable.argument_path)
    assert_equal(RepositoryPathname.new_from_path('script/merge.rb'), No_args_command_line_script.test_executable.argument_path)
    assert_equal([], No_args_command_line_script.arguments, No_args_command_line_script.inspect)
    assert_equal([], Virtual_command_line.arguments, No_args_command_line_script.inspect)
    assert_equal(:help, No_args_command_line_script.sub_command, No_args_command_line_script.inspect)
    assert_equal(Virtual_command_line.test_executable, No_args_command_line_script.test_executable)
    #		assert_equal(Virtual_command_line.unit_class, No_args_command_line_script.unit_class)
    assert_equal(Virtual_command_line.argv, No_args_command_line_script.argv)
    assert_equal(Virtual_command_line.test_executable, No_args_command_line_script.test_executable)
    assert_equal(Virtual_command_line, No_args_command_line_script)
  end # Examples

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def test_Merge_attributes
    assert_equal(Repository::This_code_repository, TestMerge.repository, TestMerge.inspect)

    refute_nil(Merge.new(interactive: :interactive, repository: Repository::This_code_repository).interactive)

    refute_nil(TestMerge.interactive, TestMerge.inspect)
    assert_equal(:interactive, TestMerge.interactive, TestMerge.inspect)
  end # values

  def test_standardize_position!
    @temp_repo.git_command('rebase --abort').puts
    @temp_repo.git_command('merge --abort').puts
    @temp_repo.git_command('stash save') # .assert_post_conditions
    @temp_repo.git_command('checkout master').puts
    @temp_merge.standardize_position!
  end # standardize_position!

  def test_abort_rebase_and_merge!
  end # abort_rebase_and_merge!

  def test_state?
    state = TestMerge.state?
    assert_includes([:clean, :dirty, :merge, :rebase], state[0])
    assert_equal(1, state.size, state)
  end # state?

  def test_discard_log_file_merge
    @temp_repo.force_change
    all_files = Repository::This_code_repository.status
    all_files.each do |conflict|
      next unless conflict[:file][-4..-1] == '.log'
      if conflict[:index] == :ignored || conflict[:work_tree] == :ignored
        puts conflict[:file] + ' is an ignored log file.'
      elsif conflict[:index] == :untracked || conflict[:work_tree] == :untracked
        puts conflict[:file] + ' is an untracked log file.'
      elsif conflict[:index] == :unmodified && conflict[:work_tree] == :modified
        puts conflict[:file] + ' is an updated log file.'
      elsif conflict[:index] == :modified && conflict[:work_tree] == :unmodified
        puts conflict[:file] + ' is a staged log file.'
      elsif conflict[:work_tree] == :updated_but_unmerged
        assert_include(['unmerged, deleted by us'], conflict[:description], conflict.inspect)
        Repository::This_code_repository.git_command('checkout HEAD ' + conflict[:file])
        puts 'checkout HEAD ' + conflict[:file]
      else
        raise Exception.new(conflict.inspect)
      end # if
      # if
    end # each
  end # discard_log_file_merge

  def test_merge_conflict_recovery
    @temp_repo.force_change
  end # merge_conflict_recovery

  def test_merge_interactive
  end # merge_interactive

  def test_stash_and_checkout
    @temp_repo.force_change
  end # stash_and_checkout

  def test_trial_merge
    assert_equal([], @temp_repo.status)
    @temp_repo.force_change
    unmerged_files = @temp_merge.trial_merge
    assert_instance_of(Array, unmerged_files, @temp_repo.inspect)
    assert_equal(1, unmerged_files.size)
    assert_equal(unmerged_files, unmerged_files)
    assert_equal('README', unmerged_files[0].file)
    assert_equal(false, unmerged_files[0].log_file?)
    assert_equal(:unmodified, unmerged_files[0].index)
    assert_equal(:modified, unmerged_files[0].work_tree)
    #		assert_equal("not updated", unmerged_files[0].description)
  end # trial_merge

  def test_merge
    TestMerge.repository.tested_superset_of_passed # .assert_post_conditions
    TestMerge.repository.edited_superset_of_tested # .assert_post_conditions
    #	TestMerge.merge(:edited, :tested) # not too long or too dangerous
    @temp_repo.force_change
  end # merge

  def test_merge_down
    # (deserving_branch = @repository.current_branch_name?)
    @temp_repo.force_change
  end # merge_down

  def test_Merge_assert_pre_conditions
    #    TestMerge.assert_pre_conditions
  end # assert_pre_conditions

  def test_Merge_assert_post_conditions
    #    TestMerge.assert_post_conditions
  end # assert_post_conditions

  def test_local_assert_pre_conditions
    #    TestMerge.assert_pre_conditions
  end # assert_pre_conditions

  def test_local_assert_post_conditions
    #    TestMerge.assert_post_conditions
  end # assert_post_conditions

  def test_Examples
  end # Examples
end # Merge

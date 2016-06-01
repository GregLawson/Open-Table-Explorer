###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../assertions/repository_assertions.rb'
require_relative '../assertions/shell_command_assertions.rb'
require_relative '../../app/models/merge.rb'
class MergeTest < TestCase
  # include DefaultTests
  # include Merge
  # extend Merge::ClassMethods
  include Merge::Examples
  def setup
    @temp_repo = Repository.create_test_repository
    refute_equal(Repository::This_code_repository, @temp_repo)
    @temp_merge = Merge.new(repository: @temp_repo, interactive: :echo)
    assert_equal(@temp_repo, @temp_merge.repository)
    refute_nil(@temp_merge.interactive)
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def test_initialize
    assert_equal(Repository::This_code_repository, TestMerge.repository, TestMerge.inspect)

    refute_nil(Merge.new(interactive: :interactive, repository: Repository::This_code_repository).interactive)

    refute_nil(TestMerge.interactive, TestMerge.inspect)
    assert_equal(:interactive, TestMerge.interactive, TestMerge.inspect)
  end # values
  include Merge::Examples
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
    all_files = Repository::This_code_repository.status
    all_files.each do |conflict|
      next unless conflict[:file][-4..-1] == '.log'
      if conflict[:index] == :ignored || conflict[:work_tree] == :ignored
        puts conflict[:file] + ' is an ignored log file.'
      elsif conflict[:index] == :untracked || conflict[:work_tree] == :untracked
        puts conflict[:file] + ' is an untracked log file.'
      elsif conflict[:index] == :unmodified && conflict[:work_tree] == :modified
        puts conflict[:file] + ' is an updated log file.'
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
  end # merge_conflict_recovery

  def test_merge_interactive
  end # merge_interactive

  def test_stash_and_checkout
  end # stash_and_checkout

  def test_merge_cleanup
    @temp_repo.force_change
    #    @temp_merge.merge_cleanup
  end # merge_cleanup

  def test_merge
    TestMerge.repository.testing_superset_of_passed # .assert_post_conditions
    TestMerge.repository.edited_superset_of_testing # .assert_post_conditions
    #	TestMerge.merge(:edited, :testing) # not too long or too dangerous
  end # merge

  def test_merge_down
    # (deserving_branch = @repository.current_branch_name?)
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

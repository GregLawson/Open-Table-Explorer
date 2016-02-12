###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/interactive_bottleneck.rb'
require_relative '../assertions/repository_assertions.rb'
require_relative '../assertions/shell_command_assertions.rb'
class InteractiveBottleneckTest < TestCase
#include DefaultTests
#include InteractiveBottleneck
#extend InteractiveBottleneck::ClassMethods
include InteractiveBottleneck::Examples
@temp_repo = Repository.create_test_repository(Repository::Examples::Empty_Repo_path)
def setup
	@temp_repo = Repository.create_test_repository(Repository::Examples::Empty_Repo_path)
	refute_equal(Repository::This_code_repository, @temp_repo)
	@temp_interactive_bottleneck = InteractiveBottleneck.new(test_executable: TestExecutable.new(executable_file: $0), repository: @temp_repo, interactive: :echo)
	assert_equal(@temp_repo, @temp_interactive_bottleneck.repository)
	refute_nil(@temp_interactive_bottleneck.interactive)
end # setup
def teardown
	Repository.delete_existing(@temp_repo.path)
end # teardown
def test_initialize
	refute_empty(TestInteractiveBottleneck.test_executable.unit.edit_files, "TestInteractiveBottleneck.test_executable.unit.edit_files=#{TestInteractiveBottleneck.test_executable.unit.edit_files}")
	assert_includes(TestInteractiveBottleneck.test_executable.unit.edit_files, File.expand_path($PROGRAM_NAME), "TestInteractiveBottleneck.unit=#{TestInteractiveBottleneck.test_executable.unit.inspect}")
end # values
include InteractiveBottleneck::Examples
def test_standardize_position!
	@temp_repo.git_command("rebase --abort").puts
	@temp_repo.git_command("merge --abort").puts
	@temp_repo.git_command("stash save") #.assert_post_conditions
	@temp_repo.git_command("checkout master").puts
	@temp_interactive_bottleneck.standardize_position!
end # standardize_position!
def test_abort_rebase_and_merge!
end # abort_rebase_and_merge!
def test_state?
	assert_includes([:clean, :dirty], TestInteractiveBottleneck.state?[0])
	assert_equal(1, TestInteractiveBottleneck.state?.size)
end # state?
def test_dirty_test_executables
	TestInteractiveBottleneck.dirty_test_executables.each do |test_executable|
		assert_instance_of(TestExecutable, test_executable)
#OK		refute_nil(test_executable.unit.model_basename, test_executable.inspect)
#OK		assert_equal(test_executable.unit, Unit::Executable, test_executable.inspect)
		if test_executable.unit.model_basename.nil? then
			puts test_executable.inspect + ' does not match a known pattern.'
		end # if
	end # each
end # dirty_test_executables
def test_dirty_units
	TestInteractiveBottleneck.dirty_units.each do |prospective_unit|
		assert_instance_of(Unit, prospective_unit[:unit])
		refute_nil(prospective_unit[:unit].model_basename, prospective_unit.inspect)
		assert_equal(prospective_unit[:unit], Unit::Executable, prospective_unit.inspect)
	end # each
end # dirty_units
def test_dirty_test_runs
	TestInteractiveBottleneck.dirty_test_executables.map do |test_executable|
		assert_equal(test_executable.unit, Unit::Executable, test_executable.inspect)
		if test_executable == $PROGRAM_NAME then
			{test_executable: test_executable, test_run: nil, error_score: nil} # terminate recursion
		else
		end # if
	end.sort{|n1, n2| n1[:error_score] <=> n2[:error_score]}
	TestInteractiveBottleneck.dirty_test_runs.each do |test_run|
		assert_instance_of(TestRun, test_run[:test_run])
	end # each
end # dirty_test_runs
def test_clean_directory
	sorted = TestInteractiveBottleneck.dirty_test_runs.sort
	sorted.map do |test_executable|
		test(test_executable)
		stage_test_executable
	end # map
end # clean_directory
def test_merge_conflict_recovery
end # merge_conflict_recovery
def test_confirm_branch_switch
	assert_equal(:master, @temp_repo.current_branch_name?)
	@temp_interactive_bottleneck.confirm_branch_switch(:passed)
	assert_equal(:passed, @temp_repo.current_branch_name?)
	@temp_interactive_bottleneck.confirm_branch_switch(:master)
	assert_equal(:master, @temp_repo.current_branch_name?)
end #confirm_branch_switch
def test_safely_visit_branch
	@temp_repo.force_change
	push_branch=@temp_repo.current_branch_name?
	target_branch=:passed
	push=@temp_repo.something_to_commit? # remember
	if push then
		@temp_repo.git_command('stash save') #.assert_post_conditions
		changes_branch=:stash
	end #if

	if push_branch!=target_branch then
		@temp_interactive_bottleneck.confirm_branch_switch(target_branch)
		ret=@temp_interactive_bottleneck.validate_commit(changes_branch, [@temp_repo.path+'README'])
		@temp_interactive_bottleneck.confirm_branch_switch(push_branch)
	else
		ret=@temp_repo.validate_commit(changes_branch, [@temp_repo.path+'README'])
	end #if
	if push then
		@temp_repo.git_command('stash apply --quiet') #.assert_post_conditions
	end #if
	assert_equal(push_branch, @temp_interactive_bottleneck.safely_visit_branch(push_branch){push_branch})
	assert_equal(push_branch, @temp_interactive_bottleneck.safely_visit_branch(push_branch){@temp_repo.current_branch_name?})
	target_branch=:master
	checkout_target=@temp_repo.git_command("checkout #{target_branch}")
#		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
	target_branch=:passed
	assert_equal(target_branch, @temp_interactive_bottleneck.safely_visit_branch(target_branch){@temp_repo.current_branch_name?})
	@temp_interactive_bottleneck.safely_visit_branch(target_branch) do
		@temp_repo.current_branch_name?
	end #
end #safely_visit_branch
def test_switch_branch
end # switch_branch
def test_merge_interactive
end # merge_interactive
def test_stash_and_checkout
end # stash_and_checkout
def test_merge_cleanup
	@temp_repo.force_change
	@temp_interactive_bottleneck.merge_cleanup
end # merge_cleanup
def test_merge
	TestInteractiveBottleneck.repository.testing_superset_of_passed #.assert_post_conditions
	TestInteractiveBottleneck.repository.edited_superset_of_testing #.assert_post_conditions
#	TestInteractiveBottleneck.merge(:edited, :testing) # not too long or too dangerous
end #merge
def test_merge_down
#(deserving_branch = @repository.current_branch_name?)
end # merge_down
def test_stage_files
end #stage_files
def test_confirm_commit
	assert_equal(:echo, @temp_interactive_bottleneck.interactive)
	@temp_interactive_bottleneck.confirm_commit
end # confirm_commit
def test_validate_commit
	@temp_repo #.assert_nothing_to_commit
	@temp_repo.force_change
#	assert(@temp_repo.something_to_commit?)
#	@temp_repo.assert_something_to_commit
#	@temp_repo.validate_commit(:master, [@temp_repo.path+'README'])
	@temp_repo.git_command('stash')
	@temp_repo.git_command('checkout passed')
	@temp_interactive_bottleneck.validate_commit(:stash, [@temp_repo.path+'README'])
end #validate_commit
def test_script_deserves_commit!
#(deserving_branch)
end # script_deserves_commit!
def test_local_assert_pre_conditions
		TestInteractiveBottleneck.assert_pre_conditions
end # assert_pre_conditions
def test_local_assert_post_conditions
		TestInteractiveBottleneck #.assert_post_conditions
end # assert_post_conditions
def test_local_assert_pre_conditions
		TestInteractiveBottleneck #.assert_pre_conditions
end # assert_pre_conditions
def test_local_assert_post_conditions
		TestInteractiveBottleneck #.assert_post_conditions
end # assert_post_conditions

def test_Examples
end # Examples
end # InteractiveBottleneck

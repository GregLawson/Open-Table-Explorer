###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/interactive_bottleneck.rb'
require_relative '../assertions/repository_assertions.rb'
class InteractiveBottleneckTest < TestCase
#include DefaultTests
#include InteractiveBottleneck
#extend InteractiveBottleneck::ClassMethods
include InteractiveBottleneck::Examples
@temp_repo = Repository.create_test_repository(Repository::Examples::Empty_Repo_path)
def setup
	@temp_repo = Repository.create_test_repository(Repository::Examples::Empty_Repo_path)
end # setup
def teardown
	Repository.delete_existing(@temp_repo.path)
end # teardown
def test_initialize
	te=Unit.new(TestExecutable.executable_file)
	refute_nil(te)
	wf=InteractiveBottleneck.new(TestExecutableFile)
	refute_nil(wf)
	refute_empty(TestInteractiveBottleneck.related_files.edit_files, "TestInteractiveBottleneck.related_files.edit_files=#{TestInteractiveBottleneck.related_files.edit_files}")
	assert_includes(TestInteractiveBottleneck.related_files.edit_files, TestExecutable, "TestInteractiveBottleneck.related_files=#{TestInteractiveBottleneck.related_files.inspect}")
end #initialize
include InteractiveBottleneck::Examples
def test_standardize_position
	@temp_repo.git_command("rebase --abort").puts
	@temp_repo.git_command("merge --abort").puts
	@temp_repo.git_command("stash save").assert_post_conditions
	@temp_repo.git_command("checkout master").puts
	@temp_repo.standardize_position!
end #standardize_position
def test_state?
	assert_includes([:clean, :dirty], state?)
end # state?
def test_merge_conflict_recovery
end # merge_conflict_recovery
def test_confirm_branch_switch
	assert_equal(:master, @temp_repo.current_branch_name?)
	@temp_repo.confirm_branch_switch(:passed)
	assert_equal(:passed, @temp_repo.current_branch_name?)
	@temp_repo.confirm_branch_switch(:master)
	assert_equal(:master, @temp_repo.current_branch_name?)
end #confirm_branch_switch
def test_safely_visit_branch
	@temp_repo.force_change
	push_branch=@temp_repo.current_branch_name?
	target_branch=:passed
	push=@temp_repo.something_to_commit? # remember
	if push then
		@temp_repo.git_command('stash save').assert_post_conditions
		changes_branch=:stash
	end #if

	if push_branch!=target_branch then
		@temp_repo.confirm_branch_switch(target_branch)
		ret=@temp_repo.validate_commit(changes_branch, [@temp_repo.path+'README'], :echo)
		@temp_repo.confirm_branch_switch(push_branch)
	else
		ret=@temp_repo.validate_commit(changes_branch, [@temp_repo.path+'README'], :echo)
	end #if
	if push then
		@temp_repo.git_command('stash apply --quiet').assert_post_conditions
	end #if
	assert_equal(push_branch, @temp_repo.safely_visit_branch(push_branch){push_branch})
	assert_equal(push_branch, @temp_repo.safely_visit_branch(push_branch){@temp_repo.current_branch_name?})
	target_branch=:master
	checkout_target=@temp_repo.git_command("checkout #{target_branch}")
#		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
	target_branch=:passed
	assert_equal(target_branch, @temp_repo.safely_visit_branch(target_branch){@temp_repo.current_branch_name?})
	@temp_repo.safely_visit_branch(target_branch) do
		@temp_repo.current_branch_name?
	end #
end #safely_visit_branch
def test_merge
	TestInteractiveBottleneck.repository.testing_superset_of_passed.assert_post_conditions
	TestInteractiveBottleneck.repository.edited_superset_of_testing.assert_post_conditions
	TestInteractiveBottleneck.merge(:edited, :testing) # not too long or too dangerous
end #merge
def test_merge_down
#(deserving_branch = @repository.current_branch_name?)
end # merge_down
def test_validate_commit
	@temp_repo.assert_nothing_to_commit
	@temp_repo.force_change
	assert(@temp_repo.something_to_commit?)
	@temp_repo.assert_something_to_commit
#	@temp_repo.validate_commit(:master, [@temp_repo.path+'README'], :echo)
	@temp_repo.git_command('stash')
	@temp_repo.git_command('checkout passed')
	@temp_repo.validate_commit(:stash, [@temp_repo.path+'README'], :echo)
end #validate_commit
def test_script_deserves_commit!
#(deserving_branch)
end # script_deserves_commit!
def test_rebase!
#	@temp_repo.rebase!
end #rebase!
def test_local_assert_post_conditions
		TestInteractiveBottleneck.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestInteractiveBottleneck.assert_pre_conditions
end #assert_pre_conditions
def test_help_command
	help_run=ShellCommands.new('ruby  script/work_flow.rb --help').assert_post_conditions
	assert_equal('', help_run.errors)
end #  help_command
def test_merge_command
	help_run=ShellCommands.new('ruby  script/work_flow.rb --merge-down').assert_post_conditions
	assert_equal('', help_run.errors)
end #  merge_command
def test_local_assert_post_conditions
		TestInteractiveBottleneck.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestInteractiveBottleneck.assert_pre_conditions
end #assert_pre_conditions

end # InteractiveBottleneck - test

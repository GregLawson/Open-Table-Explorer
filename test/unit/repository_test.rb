###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/repository_assertions.rb'
class RepositoryTest < TestCase
include DefaultTests
include Repository::Examples
Minimal_repository=Empty_Repo
def test_Constants
#	assert_pathname_exists(Temporary)
	assert_pathname_exists(Root_directory)
	assert_pathname_exists(Source)
end #Constants
def test_Repository_git_command
	git_execution=Repository.git_command('branch', Empty_Repo_path)
#	git_execution=Repository.git_command('branch --list --contains HEAD', Unique_repository_directory_pathname)
	git_execution.assert_post_conditions
end #git_command
def test_create_empty
	Dir.mkdir(Unique_repository_directory_pathname)
	assert_pathname_exists(Unique_repository_directory_pathname)
	switch_dir=ShellCommands.new([['cd', Unique_repository_directory_pathname], '&&', ['pwd']])
	assert_equal(Unique_repository_directory_pathname+"\n", switch_dir.output)
#	ShellCommands.new('cd "'+Unique_repository_directory_pathname+'";git init').assert_post_conditions
	ShellCommands.new([['cd', Unique_repository_directory_pathname], '&&', ['git', 'init']])
	new_repository=Repository.new(Unique_repository_directory_pathname)
	IO.write(Unique_repository_directory_pathname+'/README', README_start_text+"1\n") # two consecutive slashes = one slash
	new_repository.git_command('add README')
	new_repository.git_command('commit -m "test_create_empty initial commit of README"')
	Repository.delete_existing(Unique_repository_directory_pathname)
	Repository.create_empty(Unique_repository_directory_pathname)
	Repository.delete_existing(Unique_repository_directory_pathname)
end #create_empty
def test_delete_existing
	Repository.create_if_missing(Unique_repository_directory_pathname)
	Repository.delete_existing(Unique_repository_directory_pathname)
	assert(!File.exists?(Unique_repository_directory_pathname))
end #delete_existing
def test_replace_or_create
end #replace_or_create
def test_create_if_missing
	Repository.create_if_missing(Unique_repository_directory_pathname)
	FileUtils.remove_entry_secure(Unique_repository_directory_pathname) #, force = false)
end #create_if_missing
def test_initialize
	assert_pathname_exists(SELF_code_Repo.path)
	assert_pathname_exists(Empty_Repo.path)
end #initialize
def test_shell_command
	assert_equal(SELF_code_Repo.path, SELF_code_Repo.shell_command('pwd').output.chomp+'/')
	assert_equal(Empty_Repo.path, Empty_Repo.shell_command('pwd').output.chomp+'/')
end #shell_command
def test_git_command
	assert_match(/branch/,SELF_code_Repo.git_command('status').output)
	assert_match(/branch/,Empty_Repo.git_command('status').output)
end #git_command
def test_inspect
	clean_run=Minimal_repository.git_command('status --short --branch').assert_post_conditions
	assert_equal("## master\n", clean_run.output)
	assert_equal("## master\n", Minimal_repository.inspect)
	Minimal_repository.force_change
	assert_not_equal("## master\n", Minimal_repository.inspect)
	assert_equal("## master\n M README\n", Minimal_repository.inspect)
end #inspect
def test_corruption_fsck
	Minimal_repository.git_command("fsck").assert_post_conditions
	Minimal_repository.corruption_fsck.assert_post_conditions
end #corruption
def test_corruption_rebase
#	Minimal_repository.git_command("rebase").assert_post_conditions
#	Minimal_repository.corruption_rebase.assert_post_conditions
end #corruption
def test_corruption_gc
	Minimal_repository.git_command("gc").assert_post_conditions
	Minimal_repository.corruption_gc.assert_post_conditions
end #corruption
#exists Minimal_repository.git_command("branch details").assert_post_conditions
#exists Minimal_repository.git_command("branch summary").assert_post_conditions
def test_standardize_position
	Minimal_repository.git_command("rebase --abort").puts
	Minimal_repository.git_command("merge --abort").puts
	Minimal_repository.git_command("stash save").assert_post_conditions
	Minimal_repository.git_command("checkout master").puts
	Minimal_repository.standardize_position!
end #standardize_position
def test_current_branch_name?
#	assert_include(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
#	assert_include(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)

end #current_branch_name
def test_error_score?
#	executable=SELF_code_Repo.related_files.model_test_pathname?
	executable='/etc/mtab' #force syntax error with non-ruby text
		recent_test=SELF_code_Repo.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 1, recent_test.inspect)
		syntax_test=SELF_code_Repo.shell_command("ruby -c "+executable)
		assert_not_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(10000, SELF_code_Repo.error_score?(executable))
#	SELF_code_Repo.assert_deserving_branch(:edited, executable)

	executable='test/unit/minimal2_test.rb'
		recent_test=SELF_code_Repo.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=SELF_code_Repo.shell_command("ruby -c "+executable)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(0, SELF_code_Repo.error_score?('test/unit/minimal2_test.rb'))
#	SELF_code_Repo.assert_deserving_branch(:passed, executable)
	Error_classification.each_pair do |key, value|
		executable=data_source_directory?+'/'+value.to_s+'.rb'
		assert_equal(key, SELF_code_Repo.error_score?(executable), SELF_code_Repo.recent_test.inspect)
	end #each
end #error_score
def test_confirm_branch_switch
	assert_equal(:master, Minimal_repository.current_branch_name?)
	Minimal_repository.confirm_branch_switch(:passed)
	assert_equal(:passed, Minimal_repository.current_branch_name?)
	Minimal_repository.confirm_branch_switch(:master)
	assert_equal(:master, Minimal_repository.current_branch_name?)
end #confirm_branch_switch
def test_safely_visit_branch
	Minimal_repository.force_change
	push_branch=Minimal_repository.current_branch_name?
	target_branch=:passed
	push=Minimal_repository.something_to_commit? # remember
	if push then
		Minimal_repository.git_command('stash save').assert_post_conditions
		changes_branch=:stash
	end #if

	if push_branch!=target_branch then
		Minimal_repository.confirm_branch_switch(target_branch)
		ret=Minimal_repository.validate_commit(changes_branch, [Minimal_repository.path+'README'], :echo)
		Minimal_repository.confirm_branch_switch(push_branch)
	else
		ret=Minimal_repository.validate_commit(changes_branch, [Minimal_repository.path+'README'], :echo)
	end #if
	if push then
		Minimal_repository.git_command('stash apply --quiet').assert_post_conditions
	end #if
	assert_equal(push_branch, Minimal_repository.safely_visit_branch(push_branch){push_branch})
	assert_equal(push_branch, Minimal_repository.safely_visit_branch(push_branch){Minimal_repository.current_branch_name?})
	target_branch=:master
	checkout_target=Minimal_repository.git_command("checkout #{target_branch}")
#		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
	target_branch=:passed
	assert_equal(target_branch, Minimal_repository.safely_visit_branch(target_branch){Minimal_repository.current_branch_name?})
	Minimal_repository.safely_visit_branch(target_branch) do
		Minimal_repository.current_branch_name?
	end #
end #safely_visit_branch
def test_stage_file
	Minimal_repository.force_change
	assert_pathname_exists(Minimal_repository.path)
	assert_pathname_exists(Minimal_repository.path+'.git/')
	assert_pathname_exists(Minimal_repository.path+'.git/logs/')
#	assert_pathname_exists(Minimal_repository.path+'.git/logs/refs/')
	assert_pathname_exists(Minimal_repository.path+'README')

	Minimal_repository.safely_visit_branch(:passed) do |changes_branch|
		Minimal_repository.validate_commit(changes_branch, [Minimal_repository.path+'README'], :echo)
	end #safely_visit_branch

	Minimal_repository.stage_files(:passed, [Minimal_repository.path+'README'])
	Minimal_repository.git_command('checkout passed') #.assert_post_conditions
	assert_not_equal(README_start_text+"\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
end #stage_files
def test_validate_commit
	Minimal_repository.assert_nothing_to_commit
	Minimal_repository.force_change
	assert(Minimal_repository.something_to_commit?)
	Minimal_repository.assert_something_to_commit
#	Minimal_repository.validate_commit(:master, [Minimal_repository.path+'README'], :echo)
	Minimal_repository.git_command('stash')
	Minimal_repository.git_command('checkout passed')
	Minimal_repository.validate_commit(:stash, [Minimal_repository.path+'README'], :echo)
end #validate_commit
def test_something_to_commit?
	assert_respond_to(Minimal_repository.grit_repo, :status)
	assert_instance_of(Grit::Status, Minimal_repository.grit_repo.status)
	status=Minimal_repository.grit_repo.status
	assert_instance_of(Hash, status.added)
	assert_instance_of(Hash, status.changed)
	assert_instance_of(Hash, status.deleted)
	assert_equal({}, status.added)
	assert_equal({}, status.changed)
	assert_equal({}, status.deleted)
	assert((status.added=={}), status.inspect)
	Minimal_repository.assert_nothing_to_commit
	Minimal_repository.force_change
	assert(Minimal_repository.something_to_commit?, Minimal_repository.grit_repo.status.inspect)
end #something_to_commit
def setup
	Minimal_repository.revert_changes # so next test starts clean
	Minimal_repository.assert_nothing_to_commit  # check if next test starts clean
	Minimal_repository.git_command('checkout master')
end #setup
def teardown
	Minimal_repository.revert_changes # so next test starts clean
end #teardown
def test_testing_superset_of_passed
	assert_equal('', SELF_code_Repo.testing_superset_of_passed.assert_post_conditions.output)
end #testing_superset_of_passed
def test_edited_superset_of_testing
#	assert_equal('', SELF_code_Repo.edited_superset_of_testing.assert_post_conditions.output)
end #edited_superset_of_testing
def test_force_change
	Minimal_repository.assert_nothing_to_commit
	IO.write(Modified_path, README_start_text+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")+"\n") # timestamp make file unique
	assert_not_equal(README_start_text, IO.read(Modified_path))
	Minimal_repository.revert_changes
	Minimal_repository.force_change
	assert_not_equal({}, Minimal_repository.grit_repo.status.changed)
	Minimal_repository.assert_something_to_commit
	assert_not_equal({}, Minimal_repository.grit_repo.status.changed)
	Minimal_repository.git_command('add README')
	assert_not_equal({}, Minimal_repository.grit_repo.status.changed)
	assert(Minimal_repository.something_to_commit?)
#	Minimal_repository.git_command('commit -m "timestamped commit of README"')
	Minimal_repository.revert_changes.assert_post_conditions
	Minimal_repository.assert_nothing_to_commit
end #force_change
def test_revert_changes
	Minimal_repository.revert_changes.assert_post_conditions
	Minimal_repository.assert_nothing_to_commit
	assert_equal(README_start_text+"\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
end #revert_changes

#add_commits("postgres", :postgres, Temporary+"details")
#add_commits("activeRecord", :activeRecord, Temporary+"details")
#add_commits("rails2", :rails2, Temporary+"details")
#add_commits("rails3", :rails3, Temporary+"details")
#add_commits("", :default, Source+"details")
#add_commits("taxesFreeeze", :taxesFreeeze, Source+"copy-master")
#add_commits("", :taxesStopped, Source+"copy-master")
#add_commits("development", :development, Source+"copy-master")
#add_commits("compiles", :compiles, Source+"copy-master")
#add_commits("master", :master, Source+"copy-master")
#add_commits("usb", :usb, Source+"clone-reconstruct-newer ")


#ShellCommands.new("rsync -a #{Temporary}recover /media/greg/B91D-59BB/recover").assert_post_conditions
end #Repository

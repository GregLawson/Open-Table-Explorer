###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/repository_assertions.rb'
class RepositoryTest < TestCase
#include DefaultTests
include Repository::Examples
Minimal_repository=Empty_Repo
def test_Constants
#	assert_pathname_exists(Temporary)
	assert_pathname_exists(Root_directory)
	assert_pathname_exists(Source)
	assert_equal(FilePattern.project_root_dir?(__FILE__), FilePattern.project_root_dir?($0))
	assert_equal(FilePattern.project_root_dir?, Root_directory)
#	message="SELF_code_Repo=#{SELF_code_Repo.inspect}"
#	message+="\nThis_code_repository=#{This_code_repository.inspect}"
#	message+="\nThis_code_repository.path=#{This_code_repository.path.inspect}"
	this_code_repository=Repository.new(Root_directory)
	sELF_code_Repo=Repository.new(Root_directory)
	assert_equal(Root_directory, this_code_repository.path, message)
#	SELF_code_Repo.assert_pre_conditions
	this_code_repository.assert_pre_conditions
	This_code_repository.assert_pre_conditions
	assert_equal(Root_directory, This_code_repository.path, message)

#	assert_equal(SELF_code_Repo.path, Root_directory, message)
#	assert_equal(SELF_code_Repo.path, This_code_repository.path, message)
#	assert_equal(SELF_code_Repo, This_code_repository, message)
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
	assert_pathname_exists(This_code_repository.path)
	assert_pathname_exists(Empty_Repo.path)
	This_code_repository.assert_pre_conditions
end #initialize
def test_shell_command
	assert_equal(This_code_repository.path, This_code_repository.shell_command('pwd').output.chomp+'/')
	assert_equal(Empty_Repo.path, Empty_Repo.shell_command('pwd').output.chomp+'/')
end #shell_command
def test_git_command
	assert_match(/branch/,This_code_repository.git_command('status').output)
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
def test_current_branch_name?
#	assert_include(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
#	assert_include(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)

end #current_branch_name
def test_testing_superset_of_passed
#?	assert_equal('', This_code_repository.testing_superset_of_passed.assert_post_conditions.output)
end #testing_superset_of_passed
def test_edited_superset_of_testing
#?	assert_equal('', This_code_repository.edited_superset_of_testing.assert_post_conditions.output)
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
#	assert_equal(README_start_text+"\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
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
def test_merge_conflict_files?
end #merge_conflict_files?
end #Repository

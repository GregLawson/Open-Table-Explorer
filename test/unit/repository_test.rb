###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
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
	assert_equal(FilePattern.project_root_dir?(__FILE__), FilePattern.project_root_dir?($0))
	assert_equal(FilePattern.project_root_dir?, Root_directory)
	This_code_repository.assert_pre_conditions
	assert_equal(Root_directory, This_code_repository.path, message)
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
	new_repository=Repository.new(Unique_repository_directory_pathname, :echo)
	IO.write(Unique_repository_directory_pathname+'/README', README_start_text+"1\n") # two consecutive slashes = one slash
	new_repository.git_command('add README')
	new_repository.git_command('commit -m "test_create_empty initial commit of README"')
	Repository.delete_existing(Unique_repository_directory_pathname)
	Repository.create_empty(Unique_repository_directory_pathname, :echo)
	Repository.delete_existing(Unique_repository_directory_pathname)
end #create_empty
def test_delete_existing
	Repository.create_if_missing(Unique_repository_directory_pathname, :echo)
	Repository.delete_existing(Unique_repository_directory_pathname)
	assert(!File.exists?(Unique_repository_directory_pathname))
end #delete_existing
def test_replace_or_create
end #replace_or_create
def test_create_if_missing
	Repository.create_if_missing(Unique_repository_directory_pathname, :echo)
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
#	executable=This_code_repository.related_files.model_test_pathname?
	executable='/etc/mtab' #force syntax error with non-ruby text
		recent_test=This_code_repository.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 1, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_not_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(10000, This_code_repository.error_score?(executable))
#	This_code_repository.assert_deserving_branch(:edited, executable)

	executable='test/unit/minimal2_test.rb'
		recent_test=This_code_repository.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(0, This_code_repository.error_score?('test/unit/minimal2_test.rb'))
#	This_code_repository.assert_deserving_branch(:passed, executable)
	Error_classification.each_pair do |key, value|
		executable=data_source_directory?+'/'+value.to_s+'.rb'
		assert_equal(key, This_code_repository.error_score?(executable), This_code_repository.recent_test.inspect)
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
		ret=Minimal_repository.validate_commit(changes_branch, [Minimal_repository.path+'README'])
		Minimal_repository.confirm_branch_switch(push_branch)
	else
		ret=Minimal_repository.validate_commit(changes_branch, [Minimal_repository.path+'README'])
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
def test_unit_names?
	assert_equal(['Repository'], Minimal_repository.unit_names?([$0]))	
end #unit_names?
def test_validate_commit
	Minimal_repository.assert_nothing_to_commit
	Minimal_repository.force_change
	assert(Minimal_repository.something_to_commit?)
	Minimal_repository.assert_something_to_commit
#	Minimal_repository.validate_commit(:master, [Minimal_repository.path+'README'])
	Minimal_repository.git_command('stash')
	Minimal_repository.git_command('checkout passed')
	Minimal_repository.validate_commit(:stash, [Minimal_repository.path+'README'])
end #validate_commit
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
def test_merge_conflict_files?
end #merge_conflict_files?
def test_git_parse
	pattern=/  /*(/[a-z0-9\/A-Z]+/.capture(:remote))
	command = 'branch --list --remote'
	output=This_code_repository.git_command(command).assert_post_conditions.output
	parse = output.parse(Parse.new(pattern, {ending: :optional}))
	assert_instance_of(Hash, parse, self.inspect)
	assert_equal({remote: :master}, parse, output.inspect)
	git_parse(command, pattern)[:remote]
end # git_parse
def test_branches?
	assert_equal(:master, Empty_Repo.current_branch_name?)
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output=Empty_Repo.git_command('branch --list').assert_post_conditions.output
	pattern = /[* ]/*/[a-z0-9A-Z_-]+/.capture(:branch)*/\n/
	patterns = [Branch_regexp,
					/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch),
					/^[* ] /*/[a-z0-9A-Z_-]+/.capture(:branch),
					pattern]
	patterns.each do |p|
		assert_match(p, branch_output)
		branches=Parse.parse_into_array(branch_output, p, {ending: :optional})
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches, branch_output.inspect)
	end # each
	
	assert_includes(Empty_Repo.branches?.map{|b| b.branch}, Empty_Repo.current_branch_name?)
	assert_equal([:master, :passed], Empty_Repo.branches?.map{|b| b.branch})
	assert_includes(This_code_repository.branch_names?.map{|b| b.branch}, This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_includes(This_code_repository.remotes?, "origin/"+Empty_Repo.current_branch_name?.to_s)
	assert_empty(Empty_Repo.remotes?)
	assert_not_empty(This_code_repository.remotes_names?)
end #remotes?
def test_remote_branch_names?
	assert_includes(This_code_repository.remote_branch_names?, "origin/"+Empty_Repo.current_branch_name?.to_s)
	assert_empty(Empty_Repo.remote_branch_names?)
	assert_not_empty(This_code_repository.remote_branch_names?)
end # remote_branch_names?
def test_rebase!
	Minimal_repository.rebase!
end #rebase!
end #Repository

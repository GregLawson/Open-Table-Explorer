###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative "../../app/models/repository.rb"
class RepositoryTest < TestCase
include Repository::Examples
Clean_Example=Empty_Repo
def test_Constants
#	assert_pathname_exists(Temporary)
	assert_pathname_exists(Root_directory)
	assert_pathname_exists(Source)
end #Constants
def test_create_empty
	Dir.mkdir(Unique_repository_directory_pathname)
	ShellCommands.new('cd "'+Unique_repository_directory_pathname+'";git init').assert_post_conditions
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
	clean_run=Clean_Example.git_command('status --short --branch').assert_post_conditions
	assert_equal("## master\n", clean_run.output)
	assert_equal("## master\n", Clean_Example.inspect)
	Clean_Example.force_change
	assert_not_equal("## master\n", Clean_Example.inspect)
	assert_equal("## master\n M README\n", Clean_Example.inspect)
end #inspect
def test_corruption_fsck
	Clean_Example.git_command("fsck").assert_post_conditions
	Clean_Example.corruption_fsck.assert_post_conditions
end #corruption
def test_corruption_rebase
#	Clean_Example.git_command("rebase").assert_post_conditions
#	Clean_Example.corruption_rebase.assert_post_conditions
end #corruption
def test_corruption_gc
	Clean_Example.git_command("gc").assert_post_conditions
	Clean_Example.corruption_gc.assert_post_conditions
end #corruption
#exists Clean_Example.git_command("branch details").assert_post_conditions
#exists Clean_Example.git_command("branch summary").assert_post_conditions
def test_standardize_position
	Clean_Example.git_command("rebase --abort").puts
	Clean_Example.git_command("merge --abort").puts
	Clean_Example.git_command("stash save").assert_post_conditions
	Clean_Example.git_command("checkout master").puts
	Clean_Example.standardize_position!
end #standardize_position
def test_current_branch_name?
#	assert_include(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
#	assert_include(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)

end #current_branch_name
def test_deserving_branch
	executable='/etc/mtab' #force syntax error with non-ruby text
		recent_test=SELF_code_Repo.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 1, recent_test.inspect)
		syntax_test=SELF_code_Repo.shell_command("ruby -c "+executable)
		assert_not_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(:edited, SELF_code_Repo.deserving_branch?(executable))
	SELF_code_Repo.assert_deserving_branch(:edited, executable)

	executable='test/unit/minimal2_test.rb'
		recent_test=SELF_code_Repo.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=SELF_code_Repo.shell_command("ruby -c "+executable)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(:passed, SELF_code_Repo.deserving_branch?('test/unit/minimal2_test.rb'))
	SELF_code_Repo.assert_deserving_branch(:passed, executable)

end #deserving_branch
def test_safely_visit_branch
	push_branch=Clean_Example.current_branch_name?
	assert_equal(push_branch, Clean_Example.safely_visit_branch(push_branch){push_branch})
	assert_equal(push_branch, Clean_Example.safely_visit_branch(push_branch){Clean_Example.current_branch_name?})
	target_branch=:master
	checkout_target=Clean_Example.git_command("checkout #{target_branch}")
#		assert_equal("Switched to branch '#{target_branch}'\n", checkout_target.errors)
end #safely_visit_branch
def test_validate_commit
	Clean_Example.assert_nothing_to_commit
	Clean_Example.force_change
	assert(Clean_Example.something_to_commit?)
	Clean_Example.assert_something_to_commit
end #validate_commit
def test_something_to_commit?
	assert_respond_to(Clean_Example.grit_repo, :status)
	assert_instance_of(Grit::Status, Clean_Example.grit_repo.status)
	status=Clean_Example.grit_repo.status
	assert_instance_of(Hash, status.added)
	assert_instance_of(Hash, status.changed)
	assert_instance_of(Hash, status.deleted)
	assert_equal({}, status.added)
	assert_equal({}, status.changed)
	assert_equal({}, status.deleted)
	assert((status.added=={}), status.inspect)
	Clean_Example.assert_nothing_to_commit
	Clean_Example.force_change
	assert(Clean_Example.something_to_commit?, Clean_Example.grit_repo.status.inspect)
end #something_to_commit
def setup
	Clean_Example.revert_changes # so next test starts clean
	Clean_Example.assert_nothing_to_commit  # check if next test starts clean
end #setup
def teardown
	Clean_Example.revert_changes # so next test starts clean
end #teardown
def test_force_change
	Clean_Example.assert_nothing_to_commit
	IO.write(Modified_path, README_start_text+Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")+"\n") # timestamp make file unique
	assert_not_equal(README_start_text, IO.read(Modified_path))
	Clean_Example.revert_changes
	Clean_Example.force_change
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	Clean_Example.assert_something_to_commit
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	Clean_Example.git_command('add README')
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	assert(Clean_Example.something_to_commit?)
#	Clean_Example.git_command('commit -m "timestamped commit of README"')
	Clean_Example.revert_changes.assert_post_conditions
	Clean_Example.assert_nothing_to_commit
end #force_change
def test_revert_changes
	Clean_Example.revert_changes.assert_post_conditions
	Clean_Example.assert_nothing_to_commit
	assert_equal(README_start_text+"\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
end #revert_changes
def test_assert_nothing_to_commit
	Clean_Example.assert_nothing_to_commit
end #assert_nothing_to_commit
def test_assert_something_to_commit
	Clean_Example.force_change
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	Clean_Example.assert_something_to_commit
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	Clean_Example.git_command('add README')
	assert_not_equal({}, Clean_Example.grit_repo.status.changed)
	assert(Clean_Example.something_to_commit?)
#	Clean_Example.git_command('commit -m "initial commit of README"')
	Clean_Example.assert_something_to_commit
	Clean_Example.revert_changes
	Clean_Example.assert_nothing_to_commit
end #assert_something_to_commit
def test_assert_deserving_branch
	SELF_code_Repo.assert_deserving_branch(:passed, '/dev/null')
	SELF_code_Repo.assert_deserving_branch(:passed, 'test/unit/minimal2_test.rb')
	executable='/etc/mtab' #force syntax error with non-ruby text
	SELF_code_Repo.assert_deserving_branch(:edited, executable)
#	assert_equal(:testing, SELF_code_Repo.deserving_branch?(''))
end #deserving_branch

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
def test_Examples
  path=Source+'test_recover'
  assert_pathname_exists(path)
#  development_old=Repository.new(path)
end #Examples
end #Repository

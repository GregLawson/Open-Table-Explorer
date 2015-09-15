###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative "../../test/assertions/repository_assertions.rb"
class RepositoryTest < TestCase
include DefaultTests
include Repository::Examples
Minimal_repository = Repository.create_test_repository(Empty_Repo_path)
def test_assert_pre_conditions
#	assert_includes(Minimal_repository.methods, :unit_names?)
#	assert_includes(Minimal_repository.methods(false), :unit_names?)
end #assert_pre_conditions
def test_assert_nothing_to_commit
	Minimal_repository.assert_nothing_to_commit
end #assert_nothing_to_commit
def test_assert_something_to_commit
	Minimal_repository.force_change
	refute_equal({}, Minimal_repository.grit_repo.status.changed)
	Minimal_repository.assert_something_to_commit
	refute_equal({}, Minimal_repository.grit_repo.status.changed)
	Minimal_repository.git_command('add README')
	refute_equal({}, Minimal_repository.grit_repo.status.changed)
	assert(Minimal_repository.something_to_commit?)
#	Minimal_repository.git_command('commit -m "initial commit of README"')
	Minimal_repository.assert_something_to_commit
	Minimal_repository.revert_changes
	Minimal_repository.assert_nothing_to_commit
end #assert_something_to_commit

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

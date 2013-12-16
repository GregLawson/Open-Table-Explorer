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
end #Repository

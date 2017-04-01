###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/repository_assertions.rb'
class RepositoryTest < TestCase
  #  include DefaultTests
  include Repository::Examples
  def test_stage_file
    @temp_repo.force_change
    assert_pathname_exists(@temp_repo.path)
    assert_pathname_exists(@temp_repo.path + '.git/')
    assert_pathname_exists(@temp_repo.path + '.git/logs/')
    #	assert_pathname_exists(@temp_repo.path+'.git/logs/refs/')
    assert_pathname_exists(@temp_repo.path + 'README')

    #    @temp_repo.safely_visit_branch(:passed) do |changes_branch|
    #      @temp_repo.validate_commit(changes_branch, [@temp_repo.path + 'README'], :echo)
    #    end # safely_visit_branch

    #    @temp_repo.stage_files(:passed, [@temp_repo.path + 'README'])
    @temp_repo.git_command('checkout passed') # .assert_post_conditions
    #    refute_equal(README_start_text + "\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
  end # stage_files

  def test_something_to_commit?
    assert_respond_to(@temp_repo.grit_repo, :status)
    assert_instance_of(Grit::Status, @temp_repo.grit_repo.status)
    status = @temp_repo.grit_repo.status
    assert_instance_of(Hash, status.added)
    assert_instance_of(Hash, status.changed)
    assert_instance_of(Hash, status.deleted)
    assert_equal({}, status.added)
    assert_equal({}, status.changed)
    assert_equal({}, status.deleted)
    assert((status.added == {}), status.inspect)
    @temp_repo.assert_nothing_to_commit
    @temp_repo.force_change
    assert(@temp_repo.something_to_commit?, @temp_repo.grit_repo.status.inspect)
  end # something_to_commit

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_even_nonxisting(@temp_repo.path)
  end # teardown
end # Repository

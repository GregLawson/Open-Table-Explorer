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
  # include DefaultTests
  include Repository::Examples
  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def test_recursive_delete
  end # recursive_delete

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def test_DefinitionalConstants
    #	assert_pathname_exists(Temporary)
    assert_pathname_exists(Root_directory)
    assert_pathname_exists(Source)
    assert_equal(FilePattern.project_root_dir?(__FILE__), FilePattern.project_root_dir?($PROGRAM_NAME))
    #	assert_equal(FilePattern.project_root_dir?, Root_directory)
    #	message="SELF_code_Repo=#{SELF_code_Repo.inspect}"
    #	message+="\nThis_code_repository=#{This_code_repository.inspect}"
    #	message+="\nThis_code_repository.path=#{This_code_repository.path.inspect}"
    this_code_repository = Repository.new(Root_directory)
    sELF_code_Repo = Repository.new(Root_directory)
    assert_equal(Root_directory, this_code_repository.path, message)
    #	SELF_code_Repo.assert_pre_conditions
    this_code_repository.assert_pre_conditions
    This_code_repository.assert_pre_conditions
    assert_equal(Root_directory, This_code_repository.path, message)

    #	assert_equal(SELF_code_Repo.path, Root_directory, message)
    #	assert_equal(SELF_code_Repo.path, This_code_repository.path, message)
    #	assert_equal(SELF_code_Repo, This_code_repository, message)
  end # DefinitionalConstants

  def test_Repository_git_command
    git_execution = Repository.git_command('branch', @temp_repo.path)
    #	git_execution=Repository.git_command('branch --list --contains HEAD', Unique_repository_directory_pathname)
    git_execution # .assert_post_conditions
  end # git_command

  def test_create_empty
    Dir.mkdir(Unique_repository_directory_pathname)
    assert_pathname_exists(Unique_repository_directory_pathname)
    switch_dir = ShellCommands.new([['cd', Unique_repository_directory_pathname], '&&', ['pwd']])
    assert_equal(Unique_repository_directory_pathname + "\n", switch_dir.output)
    #	ShellCommands.new('cd "'+Unique_repository_directory_pathname+'";git init').assert_post_conditions
    ShellCommands.new([['cd', Unique_repository_directory_pathname], '&&', %w(git init)])
    new_repository = Repository.new(Unique_repository_directory_pathname)
    IO.write(Unique_repository_directory_pathname + '/README', README_start_text + "1\n") # two consecutive slashes = one slash
    new_repository.git_command('add README')
    new_repository.git_command('commit -m "test_create_empty initial commit of README"')
    Repository.delete_existing(Unique_repository_directory_pathname)
    Repository.create_empty(Unique_repository_directory_pathname)
    Repository.delete_existing(Unique_repository_directory_pathname)
  end # create_empty

  def test_delete_existing
    Repository.create_if_missing(Unique_repository_directory_pathname)
    Repository.delete_existing(Unique_repository_directory_pathname)
    assert(!File.exist?(Unique_repository_directory_pathname))
  end # delete_existing

  def test_replace_or_create
  end # replace_or_create

  def test_create_if_missing
    Repository.create_if_missing(Unique_repository_directory_pathname)
    FileUtils.remove_entry_secure(Unique_repository_directory_pathname) # , force = false)
  end # create_if_missing

  def test_create_test_repository
  end # create_test_repository

  def test_file_change
    assert_equal(:unmodified, Repository.file_change(' '))
    assert_equal(:modified, Repository.file_change('M'))
    assert_equal(:added, Repository.file_change('A'))
    assert_equal(:deleted, Repository.file_change('D'))
    assert_equal(:renamed, Repository.file_change('R'))
    assert_equal(:copied, Repository.file_change('C'))
    assert_equal(:updated_but_unmerged, Repository.file_change('U'))
    assert_equal(:untracked, Repository.file_change('?'))
    assert_equal(:ignored, Repository.file_change('!'))
  end # file_change

  def test_match_possibilities?
    assert_equal(true, Repository.match_possibilities?(' ', ' '))
    assert_equal(false, Repository.match_possibilities?('A', 'B'))
    assert_equal(false, Repository.match_possibilities?('A', 'a')) # no lower case seen
    assert_equal(true, Repository.match_possibilities?(' ', '[ A]'))
    assert_equal(false, Repository.match_possibilities?('A', '[BC]'))
    assert_equal(false, Repository.match_possibilities?('[', '[BC]')) # array
    assert_equal(false, Repository.match_possibilities?(']', '[BC]')) # array
    assert_equal(true, Repository.match_possibilities?(' ', '[ A]'))
  end # match_possibilities?

  def test_match_two_possibilities?
    assert_equal(true, Repository.match_two_possibilities?('  ', ' ', ' '))
    assert_equal(true, Repository.match_two_possibilities?('MM', 'M', '[ MD]'))
    assert_equal(true, Repository.match_two_possibilities?('AD', 'A', '[ MD]'))
    assert_equal(true, Repository.match_two_possibilities?('DM', 'D', ' [ M]'))
    assert_equal(true, Repository.match_two_possibilities?('R ', 'R', '[ MD]'))
    assert_equal(true, Repository.match_two_possibilities?('CD', 'C', '[ MD]'))
    assert_equal(true, Repository.match_two_possibilities?('A ', '[MARC]', ' '))
    assert_equal(true, Repository.match_two_possibilities?(' M', '[ MARC]', 'M'))
    assert_equal(true, Repository.match_two_possibilities?('CD', '[ MARC]', 'D'))
    assert_equal(false, Repository.match_two_possibilities?('[D', '[ MARC]', 'D'))
    assert_equal(false, Repository.match_two_possibilities?(']D', '[ MARC]', 'D'))
  end # match_two_possibilities?

  def test_normal_status_descriptions
    assert_equal(true, Repository.match_two_possibilities?('  ', ' ', ' '))
    assert_equal(Repository.normal_status_descriptions(' D'), 'not updated')
    assert_equal(Repository.normal_status_descriptions('MM'), 'updated in index')
    assert_equal(Repository.normal_status_descriptions('AD'), 'added to index')
    assert_equal(Repository.normal_status_descriptions('DM'), 'deleted from index')
    assert_equal(Repository.normal_status_descriptions('R '), 'renamed in index')
    assert_equal(Repository.normal_status_descriptions('CD'), 'copied in index')
    assert_equal(true, Repository.match_two_possibilities?('A ', '[MARC]', ' '))
    # ambigujous	assert_equal(Repository.normal_status_descriptions('A '), 'index and work tree matches')
    assert_equal(true, Repository.match_two_possibilities?(' M', '[ MARC]', 'M'))
    # ambigujous	assert_equal(Repository.normal_status_descriptions(' M'), 'work tree changed since index')
    # ambigujous	assert_equal(Repository.normal_status_descriptions('CD'), 'deleted in work tree')
    assert_equal(Repository.normal_status_descriptions('??'), 'both untracked')
    assert_equal(Repository.normal_status_descriptions('!!'), 'both ignored')
  end # normal_status_descriptions

  def test_unmerged_status_descriptions
    assert_equal(Repository.unmerged_status_descriptions('DD'), 'unmerged, both deleted')
    assert_equal(Repository.unmerged_status_descriptions('AU'), 'unmerged, added by us')
    assert_equal(Repository.unmerged_status_descriptions('UD'), 'unmerged, deleted by them')
    assert_equal(Repository.unmerged_status_descriptions('UA'), 'unmerged, added by them')
    assert_equal(Repository.unmerged_status_descriptions('DU'), 'unmerged, deleted by us')
    assert_equal(Repository.unmerged_status_descriptions('AA'), 'unmerged, both added')
    assert_equal(Repository.unmerged_status_descriptions('UU'), 'unmerged, both modified')

    assert_equal(Repository.normal_status_descriptions('DD'), 'unmerged, both deleted')
    assert_equal(Repository.normal_status_descriptions('AU'), 'unmerged, added by us')
    assert_equal(Repository.normal_status_descriptions('UD'), 'unmerged, deleted by them')
    assert_equal(Repository.normal_status_descriptions('UA'), 'unmerged, added by them')
    assert_equal(Repository.normal_status_descriptions('DU'), 'unmerged, deleted by us')
    assert_equal(Repository.normal_status_descriptions('AA'), 'unmerged, both added')
    assert_equal(Repository.normal_status_descriptions('UU'), 'unmerged, both modified')
  end # unmerged_status_descriptions

  def test_initialize
    assert_pathname_exists(This_code_repository.path)
    assert_pathname_exists(@temp_repo.path)
    This_code_repository # .assert_pre_conditions
  end # initialize

  def test_shell_command
    assert_equal(This_code_repository.path, This_code_repository.shell_command('pwd').output.chomp + '/')
    assert_equal(@temp_repo.path, @temp_repo.shell_command('pwd').output.chomp + '/')
  end # shell_command

  def test_git_command
    assert_match(/branch/, This_code_repository.git_command('status').output)
    assert_match(/branch/, @temp_repo.git_command('status').output)
  end # git_command

  def test_inspect
    clean_run = @temp_repo.git_command('status --short --branch') # .assert_post_conditions
    assert_equal("## master\n", clean_run.output)
    #	assert_equal("## master\n", @temp_repo.inspect)
    @temp_repo.force_change
    #	refute_equal("## master\n", @temp_repo.inspect)
    #	assert_equal("## master\n M README\n", @temp_repo.inspect)
  end # inspect

  def test_corruption_fsck
    @temp_repo.git_command('fsck') # .assert_post_conditions
    @temp_repo.corruption_fsck # .assert_post_conditions
  end # corruption

  def test_corruption_rebase
    #	@temp_repo.git_command("rebase").assert_post_conditions
    #	@temp_repo.corruption_rebase.assert_post_conditions
  end # corruption

  def test_corruption_gc
    @temp_repo.git_command('gc') # .assert_post_conditions
    @temp_repo.corruption_gc # .assert_post_conditions
  end # corruption

  # exists @temp_repo.git_command("branch details").assert_post_conditions
  # exists @temp_repo.git_command("branch summary").assert_post_conditions
  def test_current_branch_name?
    #	assert_includes(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
    #	assert_includes(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
  end # current_branch_name

  def test_diff_branch_files
    diff = This_code_repository.diff_branch_files(This_code_repository.current_branch_name?, '--numstat').output
    assert_empty(diff)
    diff = ShellCommands.new('pwd').output
    refute_empty(diff)
    diff = This_code_repository.git_command('branch').output
    refute_empty(diff)
    refute_empty(ShellCommands.new('git diff').output)
    refute_empty(ShellCommands.new('git diff -z ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing -- ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing -- *.rb').output)
    diff = This_code_repository.git_command('diff -z --numstat master..testing -- *.rb').output
    refute_empty(diff)
    diff = This_code_repository.diff_branch_files(:master)
    refute_empty(diff.output, diff.inspect)
  end # diff_branch_files

  def test_pull_differences
    diff = This_code_repository.pull_differences(This_code_repository.current_branch_name?)
    assert_empty(diff)
    diff = This_code_repository.pull_differences(:master)
    refute_empty(diff, diff.inspect)
  end # pull

  def test_merge_up_discard_files
    diff = This_code_repository.merge_up_discard_files(This_code_repository.current_branch_name?)
    assert_empty(diff)
    diff = This_code_repository.merge_up_discard_files(:master)
    refute_empty(diff, diff.inspect)
  end # pull

  def test_subset_changes
    subset_change_files_run = This_code_repository.diff_branch_files(:master, '--numstat')
    assert(subset_change_files_run.success?, subset_change_files_run.inspect)
    refute_equal('', subset_change_files_run.output)
    assert_equal('', subset_change_files_run.errors)
    assert_equal(0, subset_change_files_run.process_status.exitstatus)
    assert_instance_of(ShellCommands, subset_change_files_run)
    subset_change_files = subset_change_files_run.output

    refute_empty(subset_change_files, 'subset_change_files_run = ' + subset_change_files_run.inspect(true))
    numstat_regexp = /[0-9]+/.capture(:deletions) * /\s+/ * /[0-9]+/.capture(:additions)
    numstat_regexp = /[0-9]+/.capture(:deletions) * /\s+/
    numstat_regexp = /[0-9]+/.capture(:deletions)
    numstat_regexp = /[0-9]+/.capture(:deletions) * /\s+/ * /[0-9]+/.capture(:additions) * /\s+/ * FilePattern::Relative_pathname_regexp.capture(:path)
    numstat_regexp = /[0-9]+/.capture(:deletions) * /\s+/ * /[0-9]+/.capture(:additions) * /\s+/
    capture_many = subset_change_files.capture_many(numstat_regexp)
    assert(capture_many.success?, capture_many.inspect)
    assert_instance_of(SplitCapture, capture_many)
    assert_instance_of(Hash, capture_many.named_hash)
  end # subset_changes

  def test_status
    This_code_repository.status.each do |status|
      assert_nil(status[:file].index("\u0000"), status.inspect)
      assert(File.exist?(status[:file]) == (status[:work_tree] != :deleted), status.inspect)
    end # each
  end # status

  def test_status_descriptions
  end # status_descriptions

  def test_something_to_commit?
  end # something_to_commit

  def test_testing_superset_of_passed
    # ?	assert_equal('', This_code_repository.testing_superset_of_passed.assert_post_conditions.output)
  end # testing_superset_of_passed

  def test_edited_superset_of_testing
    # ?	assert_equal('', This_code_repository.edited_superset_of_testing.assert_post_conditions.output)
  end # edited_superset_of_testing

  def test_force_change
    empty_Repo = Repository.create_test_repository(Empty_Repo_path)
    empty_Repo.assert_nothing_to_commit
    IO.write(Modified_path, README_start_text + Time.now.strftime('%Y-%m-%d %H:%M:%S.%L') + "\n") # timestamp make file unique
    refute_equal(README_start_text, IO.read(Modified_path))
    empty_Repo.revert_changes
    empty_Repo.force_change
    refute_equal({}, empty_Repo.grit_repo.status.changed)
    empty_Repo.assert_something_to_commit
    refute_equal({}, empty_Repo.grit_repo.status.changed)
    empty_Repo.git_command('add README')
    refute_equal({}, empty_Repo.grit_repo.status.changed)
    assert(empty_Repo.something_to_commit?)
    #	empty_Repo.git_command('commit -m "timestamped commit of README"')
    empty_Repo.revert_changes # .assert_post_conditions
    empty_Repo.assert_nothing_to_commit
    Repository.delete_existing(Unique_repository_directory_pathname)
  end # force_change

  def test_revert_changes
    @temp_repo.revert_changes # .assert_post_conditions
    @temp_repo.assert_nothing_to_commit
    #	assert_equal(README_start_text+"\n", IO.read(Modified_path), "Modified_path=#{Modified_path}")
  end # revert_changes

  # add_commits("postgres", :postgres, Temporary+"details")
  # add_commits("activeRecord", :activeRecord, Temporary+"details")
  # add_commits("rails2", :rails2, Temporary+"details")
  # add_commits("rails3", :rails3, Temporary+"details")
  # add_commits("", :default, Source+"details")
  # add_commits("taxesFreeeze", :taxesFreeeze, Source+"copy-master")
  # add_commits("", :taxesStopped, Source+"copy-master")
  # add_commits("development", :development, Source+"copy-master")
  # add_commits("compiles", :compiles, Source+"copy-master")
  # add_commits("master", :master, Source+"copy-master")
  # add_commits("usb", :usb, Source+"clone-reconstruct-newer ")

  # ShellCommands.new("rsync -a #{Temporary}recover /media/greg/B91D-59BB/recover").assert_post_conditions
  def test_merge_conflict_files?
  end # merge_conflict_files?

  def test_git_parse
    command = 'branch --list --remote'
    pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:remote)
    output = This_code_repository.git_command(command).output # .assert_post_conditions
    capture = output.capture?(pattern)
    assert_instance_of(Hash, capture.output, capture.inspect)
    remotes_output = This_code_repository.git_parse(command, pattern)
    assert_instance_of(Hash, remotes_output, capture.inspect)

    assert_instance_of(String, remotes_output.fetch(:remote), capture.inspect)
  end # git_parse
end # Repository

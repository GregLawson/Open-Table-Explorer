###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/repository_assertions.rb'

module Examples
	Self_file_status = FileStatus.new_from_status_line('   ' + $PROGRAM_NAME)
end # Examples

class FileStatusTest < TestCase
	include Examples
  def test_file_change
    assert_equal(:unmodified, FileStatus.file_change(' '))
    assert_equal(:modified, FileStatus.file_change('M'))
    assert_equal(:added, FileStatus.file_change('A'))
    assert_equal(:deleted, FileStatus.file_change('D'))
    assert_equal(:renamed, FileStatus.file_change('R'))
    assert_equal(:copied, FileStatus.file_change('C'))
    assert_equal(:updated_but_unmerged, FileStatus.file_change('U'))
    assert_equal(:untracked, FileStatus.file_change('?'))
    assert_equal(:ignored, FileStatus.file_change('!'))
		characters = FileStatus::File_change.keys
		symbols = FileStatus::File_change.values
		characters.each do |character|
			assert_equal(FileStatus::File_change[character], FileStatus.file_change(character), FileStatus::File_change.inspect)
		end # each
  end # file_change

  def test_match_possibilities?
    assert_equal(true, FileStatus.match_possibilities?(' ', ' '))
    assert_equal(false, FileStatus.match_possibilities?('A', 'B'))
    assert_equal(false, FileStatus.match_possibilities?('A', 'a')) # no lower case seen
    assert_equal(true, FileStatus.match_possibilities?(' ', '[ A]'))
    assert_equal(false, FileStatus.match_possibilities?('A', '[BC]'))
    assert_equal(false, FileStatus.match_possibilities?('[', '[BC]')) # array
    assert_equal(false, FileStatus.match_possibilities?(']', '[BC]')) # array
    assert_equal(true, FileStatus.match_possibilities?(' ', '[ A]'))
  end # match_possibilities?

  def test_match_two_possibilities?
    assert_equal(true, FileStatus.match_two_possibilities?('  ', ' ', ' '))
    assert_equal(true, FileStatus.match_two_possibilities?('MM', 'M', '[ MD]'))
    assert_equal(true, FileStatus.match_two_possibilities?('AD', 'A', '[ MD]'))
    assert_equal(true, FileStatus.match_two_possibilities?('DM', 'D', ' [ M]'))
    assert_equal(true, FileStatus.match_two_possibilities?('R ', 'R', '[ MD]'))
    assert_equal(true, FileStatus.match_two_possibilities?('CD', 'C', '[ MD]'))
    assert_equal(true, FileStatus.match_two_possibilities?('A ', '[MARC]', ' '))
    assert_equal(true, FileStatus.match_two_possibilities?(' M', '[ MARC]', 'M'))
    assert_equal(true, FileStatus.match_two_possibilities?('CD', '[ MARC]', 'D'))
    assert_equal(false, FileStatus.match_two_possibilities?('[D', '[ MARC]', 'D'))
    assert_equal(false, FileStatus.match_two_possibilities?(']D', '[ MARC]', 'D'))
  end # match_two_possibilities?

  def test_normal_status_descriptions
    assert_equal(true, FileStatus.match_two_possibilities?('  ', ' ', ' '))
    assert_equal(FileStatus.normal_status_descriptions(' D'), 'not updated')
    assert_equal(FileStatus.normal_status_descriptions('MM'), 'updated in index')
    assert_equal(FileStatus.normal_status_descriptions('AD'), 'added to index')
    assert_equal(FileStatus.normal_status_descriptions('DM'), 'deleted from index')
    assert_equal(FileStatus.normal_status_descriptions('R '), 'renamed in index')
    assert_equal(FileStatus.normal_status_descriptions('CD'), 'copied in index')
    assert_equal(true, FileStatus.match_two_possibilities?('A ', '[MARC]', ' '))
    # ambiguous	assert_equal(FileStatus.normal_status_descriptions('A '), 'index and work tree matches')
    assert_equal(true, FileStatus.match_two_possibilities?(' M', '[ MARC]', 'M'))
    # ambiguous	assert_equal(FileStatus.normal_status_descriptions(' M'), 'work tree changed since index')
    # ambiguous	assert_equal(FileStatus.normal_status_descriptions('CD'), 'deleted in work tree')
    assert_equal(FileStatus.normal_status_descriptions('??'), 'both untracked')
    assert_equal(FileStatus.normal_status_descriptions('!!'), 'both ignored')
  end # normal_status_descriptions

  def test_unmerged_status_descriptions
    assert_equal(FileStatus.unmerged_status_descriptions('DD'), 'unmerged, both deleted')
    assert_equal(FileStatus.unmerged_status_descriptions('AU'), 'unmerged, added by us')
    assert_equal(FileStatus.unmerged_status_descriptions('UD'), 'unmerged, deleted by them')
    assert_equal(FileStatus.unmerged_status_descriptions('UA'), 'unmerged, added by them')
    assert_equal(FileStatus.unmerged_status_descriptions('DU'), 'unmerged, deleted by us')
    assert_equal(FileStatus.unmerged_status_descriptions('AA'), 'unmerged, both added')
    assert_equal(FileStatus.unmerged_status_descriptions('UU'), 'unmerged, both modified')

    assert_equal(FileStatus.normal_status_descriptions('DD'), 'unmerged, both deleted')
    assert_equal(FileStatus.normal_status_descriptions('AU'), 'unmerged, added by us')
    assert_equal(FileStatus.normal_status_descriptions('UD'), 'unmerged, deleted by them')
    assert_equal(FileStatus.normal_status_descriptions('UA'), 'unmerged, added by them')
    assert_equal(FileStatus.normal_status_descriptions('DU'), 'unmerged, deleted by us')
    assert_equal(FileStatus.normal_status_descriptions('AA'), 'unmerged, both added')
    assert_equal(FileStatus.normal_status_descriptions('UU'), 'unmerged, both modified')
  end # unmerged_status_descriptions

  def test_DefinitionalConstants
		assert_include(FileStatus::Commitable, :modified)
#		assert_equal(FileStatus::Commitable, FileStatus::File_change.values)
		assert_empty(FileStatus::Commitable - FileStatus::File_change.values)
		refute_empty(FileStatus::File_change.keys - FileStatus::Commitable)
		assert_equal(FileStatus::File_change.keys.size, FileStatus::File_change.values.size, FileStatus::File_change.inspect)
		assert_include(FileStatus::File_change.keys, 'D', FileStatus::File_change.inspect)
		FileStatus::File_change.keys.each do |key|
			assert_equal(key, FileStatus::File_change.invert[FileStatus::File_change[key]], FileStatus::File_change.inspect)
		end # each
  end # DefinitionalConstants

  def test_new_from_status_line
    refute_nil(Self_file_status.file)
    assert(File.exist?(Self_file_status.file))
  end # new_from_status_line

  def test_description
		two_letter_code = FileStatus::File_change.invert[Self_file_status.index] + FileStatus::File_change.invert[Self_file_status.work_tree]
    assert_include(['  ', 'MM'], two_letter_code, Self_file_status.explain)
    assert_include(['both unmodified', 'both unmodified'], Self_file_status.description, Self_file_status.explain)
  end # description
end # FileStatus

class RepositoryTest < TestCase
	include Examples

  def test_log_file?
    refute_empty(This_code_repository.status.select(&:log_file?))
    refute_empty(This_code_repository.status - This_code_repository.status.select(&:log_file?))
  end # log_file?

  def test_rubocop_file?
    refute_empty(This_code_repository.status.select(&:rubocop_file?))
    refute_empty(This_code_repository.status - This_code_repository.status.select(&:rubocop_file?))
  end # rubocop_file?

	def test_branch_specific?
    refute_empty(This_code_repository.status.select(&:branch_specific?))
    refute_empty(This_code_repository.status - This_code_repository.status.select(&:branch_specific?))
	end # branch_specific?

  def test_addable?
    refute_empty(This_code_repository.status.select(&:addable?))
  end # needs_commit?

  def test_needs_test?
    refute_empty(This_code_repository.status.select(&:needs_test?))
  end # needs_test?

  def test_needs_commit?
    refute_empty(This_code_repository.status.select(&:needs_commit?))
  end # needs_commit?

  def test_merge_conflict?
    This_code_repository.status.each do |file_stat|
      refute(file_stat.merge_conflict?, file_stat.explain)
    end # each
  end # merge_conflict?

	def test_untracked?
    refute_empty(This_code_repository.status.select(&:untracked?))
	end # untracked?
	
	def test_ignored?
    refute_empty(This_code_repository.status.select(&:ignored?))
	end # ignored?
	
	def test_group
		assert_equal(false, Self_file_status.group[:log_file])
		assert_equal(false, Self_file_status.group[:rubocop_file])
		assert_include([:unmodified], Self_file_status.group[:index])
		assert_include([:unmodified], Self_file_status.group[:work_tree])
		assert_include(['both unmodified'], Self_file_status.group[:description])
		assert_include([false], Self_file_status.group[:needs_test])
	end # group

	def test_explain
    assert_match(/FileStatus/, Self_file_status.explain)
	
	end # explain
		
	def test_assert_preconditions
    This_code_repository.status.each do |file_stat|
#!      file_stat.assert_preconditions
    end # each
	end # assert_preconditions
	def test_assert_status_character
		FileStatus.assert_status_character('?')
	end # assert_status_character

  include RubyAssertions
  include Repository::Examples
  Cleanup_failed_test_paths = Root_directory + '/test/data_sources/repository20*/'
  Cleanup_failed_test_repositories = Dir[Cleanup_failed_test_paths]
  Cleanup_failed_test_repositories.each do |temp_git_repository|
    Repository.delete_even_nonxisting(temp_git_repository, :force)
  end # each
  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def test_recursive_delete
  end # recursive_delete

  def teardown
    Repository.delete_even_nonxisting(@temp_repo.path)
    assert_empty(Dir[Cleanup_failed_test_paths], Cleanup_failed_test_paths)
  end # teardown

  def test_DefinitionalConstants
    #	assert_pathname_exists(Temporary)
    assert_pathname_exists(Root_directory)
    assert_pathname_exists(Source)
    assert_equal(FilePattern.project_root_dir?(__FILE__), FilePattern.project_root_dir?($PROGRAM_NAME))
    assert_equal(FilePattern.project_root_dir?, Root_directory)
    #	message="SELF_code_Repo=#{SELF_code_Repo.inspect}"
    #	message+="\nThis_code_repository=#{This_code_repository.inspect}"
    #	message+="\nThis_code_repository.path=#{This_code_repository.path.inspect}"
    this_code_repository = Repository.new(path: Root_directory)
    sELF_code_Repo = Repository.new(path: Root_directory)
    assert_equal(Root_directory, this_code_repository.path)
    This_code_repository.assert_pre_conditions
    this_code_repository.assert_pre_conditions
    This_code_repository.assert_pre_conditions
    assert_equal(Root_directory, This_code_repository.path)

    #	assert_equal(SELF_code_Repo.path, Root_directory, message)
    #	assert_equal(SELF_code_Repo.path, This_code_repository.path, message)
    #	assert_equal(SELF_code_Repo, This_code_repository, message)
  end # DefinitionalConstants

  def test_Repository_git_command
    git_execution = Repository.git_command('branch', @temp_repo.path)
    #	git_execution=Repository.git_command('branch --list --contains HEAD', Unique_repository_directory_pathname)
    git_execution.assert_post_conditions
  end # git_command

  def test_initialize
    assert_pathname_exists(This_code_repository.path)
    assert_pathname_exists(@temp_repo.path)
    This_code_repository # .assert_pre_conditions
  end # initialize

  def test_compare
  end # compare

  def test_git_pathname
    assert_pathname_exists(@temp_repo.git_pathname('refs'))
    assert_pathname_exists(@temp_repo.git_pathname('branches'))
    assert_pathname_exists(@temp_repo.git_pathname('HEAD'))
    assert_pathname_exists(This_code_repository.git_pathname('refs'))
  end # git_pathname

  def test_state?
    assert_equal([:clean], @temp_repo.state?)
    @temp_repo.force_change
    assert_equal([:dirty], @temp_repo.state?)
    @temp_repo.git_command('merge passed --no-commit --no-ff').assert_post_conditions
    # !    assert_equal([:clean, :merge], @temp_repo.state?, @temp_repo.status.inspect)
    @temp_repo.revert_changes
    assert_equal([:clean], @temp_repo.state?)
    assert_equal([:dirty], This_code_repository.state?)
  end # state?

  def test_shell_command
    assert_equal(This_code_repository.path, This_code_repository.shell_command('pwd').output.chomp + '/')
    assert_equal(@temp_repo.path_with_trailing_slash, @temp_repo.shell_command('pwd').output.chomp + '/')
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

  def test_standardize_position!
    @temp_repo.git_command('rebase --abort').puts
    @temp_repo.git_command('merge --abort').puts
    @temp_repo.git_command('stash save') # .assert_post_conditions
    @temp_repo.git_command('checkout master').puts
    @temp_repo.standardize_position!
  end # standardize_position!

  def abort_merge!
  end # abort_rebase_and_merge!

  def abort_rebase!
  end # abort_rebase_and_merge!

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

  def test_status
    This_code_repository.status.each do |status|
      assert_nil(status.file.index("\u0000"), status.inspect)
      assert(File.exist?(status.file) == (status.work_tree != :deleted), status.inspect)
    end # each
  end # status

	def test_file_status_groups
		file_status_groups = This_code_repository.file_status_groups
		file_status_groups.keys.each do |group|
			signature =file_status_groups[group].map do |file_status|
				file_status.group
			end.uniq # each
			assert_equal(1, signature.size, signature.inspect)
			assert_include([true, false], group[:log_file], group.inspect)
			assert_include([true, false], group[:rubocop_file], group.inspect)
			assert_include([:unmodified, :modified, :untracked, :ignored], group[:index], group.inspect)
			assert_include([:unmodified, :modified, :untracked, :ignored], group[:work_tree], group.inspect)
			assert_include(['both ignored', 'both unmodified', 'not updated', 'both untracked'], group[:description], group.inspect)
			assert_include([true, false], group[:needs_test], group.inspect)
			
			partitions = [:log_file, :rubocop_file, :needs_test, :untracked, :ignored]
			partitions.each do |partition|
				assert_include([true, false], group[partition], group.inspect)
			end # each
			refute_equal(0, partitions.map{|partition| group[partition] ? 1 : 0}.sum, group.inspect)
			assert(group[:ignored] || group[:untracked] || (group[:needs_test] || group[:log_file] || group[:rubocop_file]), group.inspect)
		end # each

	end # file_status_groups
	
  def test_something_to_commit?
    message = This_code_repository.status.inspect
    assert(This_code_repository.something_to_commit?, message)
    This_code_repository.status.each do |file_stat|
      #			puts file_stat.inspect
      assert(File.exist?(file_stat.file) == (file_stat.work_tree != :deleted), message)
    end # each
  end # something_to_commit

  def test_tested_superset_of_passed
    # ?	assert_equal('', This_code_repository.tested_superset_of_passed.assert_post_conditions.output)
  end # tested_superset_of_passed

  def test_edited_superset_of_tested
    # ?	assert_equal('', This_code_repository.edited_superset_of_tested.assert_post_conditions.output)
  end # edited_superset_of_tested

  def test_force_change
    @temp_repo.assert_nothing_to_commit
    modified_path = @temp_repo.path + '/README'

    IO.write(modified_path, README_start_text + Time.now.strftime('%Y-%m-%d %H:%M:%S.%L') + "\n") # timestamp make file unique
    refute_equal(README_start_text, IO.read(modified_path))
    @temp_repo.revert_changes
    @temp_repo.force_change
    refute_equal({}, @temp_repo.something_to_commit?)
    @temp_repo.assert_something_to_commit
    refute_equal({}, @temp_repo.something_to_commit?)
    @temp_repo.git_command('add README')
    refute_equal({}, @temp_repo.something_to_commit?)
    assert(@temp_repo.something_to_commit?, @temp_repo.status.inspect)
    #	@temp_repo.git_command('commit -m "timestamped commit of README"')
    @temp_repo.revert_changes # .assert_post_conditions
    @temp_repo.assert_nothing_to_commit

    assert_equal([], @temp_repo.status)

    @temp_repo.force_change
    assert_equal(1, @temp_repo.status.size)
    assert_equal('README', @temp_repo.status[0].file)
    assert_equal(false, @temp_repo.status[0].log_file?)
    assert_equal(:unmodified, @temp_repo.status[0].index)
    assert_equal(:modified, @temp_repo.status[0].work_tree)
    #		assert_equal("not updated", @temp_repo.status[0].description)
  end # force_change

  def test_revert_changes
    @temp_repo.revert_changes # .assert_post_conditions
    @temp_repo.assert_nothing_to_commit
    modified_path = @temp_repo.path + '/README'
    assert_equal(README_start_text + "\n", IO.read(modified_path), "modified_path=#{modified_path}")
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

  def test_create_empty
    unique_repository_directory_pathname = Repository.timestamped_repository_name?
    Dir.mkdir(unique_repository_directory_pathname)
    assert_pathname_exists(unique_repository_directory_pathname)
    switch_dir = ShellCommands.new([['cd', unique_repository_directory_pathname], '&&', ['pwd']])
    assert_equal(unique_repository_directory_pathname + "\n", switch_dir.output)
    #	ShellCommands.new('cd "'+unique_repository_directory_pathname+'";git init').assert_post_conditions
    ShellCommands.new([['cd', unique_repository_directory_pathname], '&&', %w(git init)])
    new_repository = Repository.new(path: unique_repository_directory_pathname)
    IO.write(unique_repository_directory_pathname + '/README', README_start_text + "1\n") # two consecutive slashes = one slash
    new_repository.git_command('add README')
    new_repository.git_command('commit -m "test_create_empty initial commit of README"')
    Repository.delete_existing(unique_repository_directory_pathname)
    Repository.create_empty(unique_repository_directory_pathname)
    Repository.delete_existing(unique_repository_directory_pathname)
  end # create_empty

  def test_delete_existing
    Repository.create_if_missing(@temp_repo.path)
    Repository.delete_existing(@temp_repo.path)
    assert(!File.exist?(@temp_repo.path))
  end # delete_existing

  def test_replace_or_create
  end # replace_or_create

  def test_create_if_missing
    Repository.create_if_missing(@temp_repo.path)
    FileUtils.remove_entry_secure(@temp_repo.path) # , force = false)
    unique_repository_directory_pathname = Repository.timestamped_repository_name?
    Repository.create_if_missing(unique_repository_directory_pathname)
    FileUtils.remove_entry_secure(unique_repository_directory_pathname) # , force = false)
  end # create_if_missing

  def test_create_test_repository
  end # create_test_repository
end # Repository

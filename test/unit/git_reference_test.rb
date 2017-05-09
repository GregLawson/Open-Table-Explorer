###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/git_reference.rb'
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
require_relative '../../app/models/parse.rb'
class TimeTypesTest < TestCase
  include NamedCommit::ReferenceObjects
  # include DefaultTests
  # include Repository::Examples
	include TimeTypes


end # GitReference

class CommitTest < TestCase
  include Commit::ReferenceObjects
  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown
end # Commit
	
	def test_TimeTypes
		show_commit_output = Head_at_start.show_run.output
		show_matches = ParsedCapture.show_matches([show_commit_output], Git_show_medium_timestamp_regexp_array)
		assert_match(Git_show_medium_timestamp_regexp, show_commit_output, show_matches.ruby_lines_storage)
	end # TimeTypes
	

class GitReferenceTest < TestCase
  include NamedCommit::ReferenceObjects
		def test_head
			assert_kind_of(GitReference, Commit.head(@temp_repo))
			assert_kind_of(GitReference, Commit.head(Repository::This_code_repository))
		end # head
		
	def test_GitReference_to_s
		assert_equal('HEAD', Head_at_start.to_s, Head_at_start.inspect)
	end # to_s

	def test_show_run
	end # show_run
end # GitReference

class CommitTest < TestCase
  include Commit::DefinitionalConstants
  include NamedCommit::ReferenceObjects
	
	def test_GitReference_to_sym
		assert_equal(:HEAD, Head_at_start.to_sym, Head_at_start.inspect)
	end # to_s
	
	def test_DefinitionalConstants
		show_commit_output = Head_at_start.show_run.output
		show_matches = ParsedCapture.show_matches([show_commit_output], Show_commit_array)
		assert_match(Email_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Aurthor_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(/commit / * SHA1_hex_40 * /\n/ * Aurthor_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Aurthor_regexp * /Date:   / * Git_show_medium_timestamp_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Show_commit_regexp, show_commit_output, show_matches.ruby_lines_storage)

		commit_part = "commit c2db421dba8518e664111b0ba89ee1d70a789fbc\n"
		merge_part = "Merge: 6b1c04d 6ef1536\n"
		author_part = "Author: greg <GregLawson123@gmail.com>\n"
		date_part = "Date:   Wed Dec 7 10:50:17 2016 -0800"
		title_part = "\n\n    Merge branch 'tested' into edited\n"
		explain_part = "    \n    Conflicts:\n            app/models/repository.rb\n            test/unit/branch_test.rb\n            test/unit/minimal2_test.rb\n            test/unit/repository_test.rb\n            test/unit/test_executable_test.rb\n"
		multi_line = commit_part + merge_part + author_part + date_part + title_part + explain_part
		show_commit_output = multi_line
		show_matches = ParsedCapture.show_matches([show_commit_output], Show_commit_array)
		assert_match(Email_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Aurthor_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Merge_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(/commit / * SHA1_hex_40 * /\n/ * Merge_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Merge_regexp * Aurthor_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(/commit / * SHA1_hex_40 * /\n/ * Merge_regexp * Aurthor_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Aurthor_regexp * /Date:   / * Git_show_medium_timestamp_regexp, show_commit_output, show_matches.ruby_lines_storage)
		assert_match(Show_commit_regexp, show_commit_output, show_matches.ruby_lines_storage)

#!		ParsedCapture.assert_show_matches(["\nMerge: 6b1c04d 6ef1536\n"], [Merge_regexp], captures: [sha1_hex_short: ['6b1c04d', '6ef1536']])
#!		ParsedCapture.assert_show_matches(["commit c2db421dba8518e664111b0ba89ee1d70a789fbc\nMerge: 6b1c04d 6ef1536\n"], [ Regexp::Start_string * /commit / * SHA1_hex_40 * /\n/, Merge_regexp], captures: [sha1_hex_short: ['6b1c04d', '6ef1536']])

		Show_commit_array.each do|regexp|
#			ParsedCapture.assert_show_matches([show_commit_output], [regexp])
		end # each
#!		ParsedCapture.assert_show_matches([show_commit_output], Show_commit_array)
	end # DefinitionalConstants
	
  def test_DefinitionalClassMethods
		assert_equal(:HEAD, Head_at_start.initialization_string, Head_at_start.inspect)
		assert_instance_of(String, Head_at_start.sha1_hex_40, Head_at_start.inspect)
		assert_instance_of(String, Head_at_start.commit_title, Head_at_start.inspect)
  end # DefinitionalClassMethods
	
	def test_show_commit
		initialization_string = :HEAD
		repository = Repository::Repository::This_code_repository
		run = repository.git_command('show ' + initialization_string.to_s + ' --pretty=medium  --no-abbrev-commit --no-patch')
		run.assert_post_conditions
		capture = run.output.capture?(Show_commit_regexp)
		assert(capture.success?, capture.inspect)
		sha1_hex_40 = capture.output[:sha1_hex_40]
		assert_equal(40, sha1_hex_40.size, capture.inspect)
	end # show_commit
	
	def test_sha1_hex_40
	end # sha1_hex_40
	
	def test_commit_title
	end # commit_title

	def test_tree
		initialization_string = Head_at_start
		tree_ref = GitReference.new(initialization_string: initialization_string.to_s + '^{tree}')
		tree_run = tree_ref.show_run
		tree_run.assert_post_conditions
		output = tree_run.output
		array = output.split("\n")[1..-1] # discard echo of tree
#		assert_equal(Dir['*'].sort, array.sort, Head_at_start.inspect)
	end # tree

	def test_file_contents
		refute_equal(WorkingTree::Working_tree, Code_head)
		path = $PROGRAM_NAME
			git_command = 'git cat-file blob ' + Code_head.initialization_string.to_s + ':' + path
			git_run = Repository::This_code_repository.git_command(git_command)
			git_run.assert_pre_conditions
			head_file_contents = git_run.output
		assert_equal(head_file_contents, Code_head.file_contents(path))
	end # file_contents

  def test_diff_branch_files
    diff = WorkingTree::Working_tree.diff_branch_files(Head_at_start, '--numstat').output
#    assert_empty(diff)
    diff = ShellCommands.new('pwd').output
    refute_empty(diff)
    diff = Repository::This_code_repository.git_command('branch').output
    refute_empty(diff)
#    refute_empty(ShellCommands.new('git diff').output)
    refute_empty(ShellCommands.new('git diff -z ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing -- ').output)
    refute_empty(ShellCommands.new('git diff -z --numstat master..testing -- *.rb').output)
    diff = Repository::This_code_repository.git_command('diff -z --numstat master..testing -- *.rb').output
    refute_empty(diff)
    diff = WorkingTree::Working_tree.diff_branch_files(:master)
    refute_empty(diff.output, diff.inspect)
  end # diff_branch_files

  def test_pull_differences
    diff = WorkingTree::Working_tree.pull_differences(Head_at_start)
#    assert_empty(diff)
    diff = WorkingTree::Working_tree.pull_differences(:master)
    refute_empty(diff, diff.inspect)
  end # pull_differences

  def test_merge_up_discard_files
    diff = WorkingTree::Working_tree.merge_up_discard_files(Head_at_start)
    assert_empty(diff)
    diff = WorkingTree::Working_tree.merge_up_discard_files(:master)
    refute_empty(diff, diff.inspect)
  end # merge_up_discard_files

  def test_subset_changes
    subset_change_files_run = WorkingTree::Working_tree.diff_branch_files(:master, '--numstat')
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
end # Commit
	
class WorkingTreeTest < TestCase
	include WorkingTree::ReferenceObjects
  def test_ReferenceObjects
		assert_equal(:Working_tree, Working_tree.initialization_string, Working_tree.inspect)
		assert_equal(nil, Working_tree.sha1_hex_40, Working_tree.inspect)
		assert_equal('not yet committed', Working_tree.commit_title, Working_tree.inspect)
		assert_equal(Commit::Working_tree, Working_tree)
		path = $PROGRAM_NAME
		this_file_contents = IO.read(path)
		assert_equal(this_file_contents, Working_tree.file_contents(path))
  end # ReferenceObjects
	
end # WorkingTree

class NamedCommitTest < TestCase
  include NamedCommit::ReferenceObjects
end # NamedCommit

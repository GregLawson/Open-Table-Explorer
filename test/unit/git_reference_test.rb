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
class GitReferenceTest < TestCase
  include NamedCommit::ReferenceObjects
  # include DefaultTests
  # include Repository::Examples

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown
	
		def test_head
			assert_kind_of(GitReference, Commit.head(@temp_repo))
			assert_kind_of(GitReference, Commit.head(Repository::This_code_repository))
		end # head
		
	
	def test_GitReference_to_s
		assert_equal('HEAD', Head_at_start.to_s, Head_at_start.inspect)
	end # to_s
	
	def test_dry
		top_level_types = [:String,  :Int, :Float, :Decimal, :Array, :Hash, :Nil, :Symbol, :Class, :True,
			:False, :Date, :DateTime, :Time, :Strict, :Coercible, :Maybe, :Optional, :Bool, :Form, :Json]
		assert_equal(top_level_types, Types.constants)
		type_tree = top_level_types.map do |type_name|
			type = eval('Types::' + type_name.to_s)
			if type.methods.include?(:constants)
				{type_name =>  type.constants}
			else
					{type_name => type.inspect}
			end # if
		end # map
		puts type_tree
	end # dry
end # GitReference

class CommitTest < TestCase
  include Commit::DefinitionalConstants
  include NamedCommit::ReferenceObjects
	
	def test_GitReference_to_sym
		assert_equal(:HEAD, Head_at_start.to_sym, Head_at_start.inspect)
	end # to_s
	
	def test_show_commit
		initialization_string = :HEAD
		repository = Repository::This_code_repository
		run = repository.git_command('show ' + initialization_string.to_s + ' --pretty=oneline  --no-abbrev-commit --no-patch')
		run.assert_post_conditions
		capture = run.output.capture?(Show_commit_regexp)
		assert(capture.success?, capture.inspect)
		sha1 = capture.output[:sha1]
	end # show_commit
	
	def test_sha1
	end # sha1
	
	def test_tree
	end # tree

  def test_diff_branch_files
    diff = Commit::Working_tree.diff_branch_files(Head_at_start, '--numstat').output
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
    diff = Commit::Working_tree.diff_branch_files(:master)
    refute_empty(diff.output, diff.inspect)
  end # diff_branch_files

  def test_pull_differences
    diff = Commit::Working_tree.pull_differences(Head_at_start)
#    assert_empty(diff)
    diff = Commit::Working_tree.pull_differences(:master)
    refute_empty(diff, diff.inspect)
  end # pull_differences

  def test_merge_up_discard_files
    diff = Commit::Working_tree.merge_up_discard_files(Head_at_start)
    assert_empty(diff)
    diff = Commit::Working_tree.merge_up_discard_files(:master)
    refute_empty(diff, diff.inspect)
  end # merge_up_discard_files

  def test_subset_changes
    subset_change_files_run = Commit::Working_tree.diff_branch_files(:master, '--numstat')
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

class NamedCommitTest < TestCase
  include NamedCommit::ReferenceObjects
end # NamedCommit

###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
#require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
module Types
	include Dry::Types.module
end # Types
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class GitReference # base class for all git references (readable, maybe not writeable)
	
	
  include Virtus.value_object

  values do
    attribute :initialization_string, Symbol
    attribute :repository, Repository, default: Repository::This_code_repository
#		attribute :sha1, String
  end # values

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
#    include DefinitionalConstants
		# Simulate a NamedCommit for working directory not yet in git.
		Tree = GitReference.new(initialization_string: 'HEAD:' + '^{tree}', repository: Repository::This_code_repository) 
		File = GitReference.new(initialization_string: 'HEAD:' + $0, repository: Repository::This_code_repository) 
  end # ReferenceObjects
  include ReferenceObjects

	def to_s
		@initialization_string.to_s
	end # to_s
	
	def to_sym
		to_s.to_sym
	end # to_s
	
	def show_run
		run = repository.git_command('show ' + initialization_string.to_s + ' --pretty=oneline  --no-abbrev-commit --no-patch')
	end # show_run
	end # GitReference

class Commit < GitReference
	module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		include Regexp::DefinitionalConstants
    SHA_hex_7 = /[[:xdigit:]]{7}/.capture(:sha_hex)
    SHA1_hex_40 = /[[:xdigit:]]{40}/.capture(:sha1)
		Show_commit_regexp = (SHA1_hex_40 * / / * /[[:print:]]*/.capture(:commit_title) * /\n/).exact
	end # DefinitionalConstants
	include DefinitionalConstants

  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
		def head(repository)
			Commit.new(initialization_string: :HEAD, repository: repository)
		end # head
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
	
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
#    include DefinitionalConstants
		# Simulate a NamedCommit for working directory not yet in git.
		Working_tree = Commit.new(initialization_string: :Working_tree, repository: Repository::This_code_repository) 
  end # ReferenceObjects
  include ReferenceObjects
	
	def show_commit
		capture = show_run.output.capture?(Show_commit_regexp)
		capture.output
	end # show_commit
	
	def sha1
		show_commit[:sha1]
	end # sha1

	def commit_title
		show_commit[:commit_title]
	end # commit_title
	
	def tree
		GitReference.new(initialization_string: @initialization_string + '^{tree}').show_run.output
	end # tree

  def diff_branch_files(other_ref, options = '--summary', file_glob = '*.rb')
    if self == NamedCommit::Working_tree
			if other_ref == NamedCommit::Working_tree
				[]
			else
				@repository.git_command('diff -z ' + options + ' ' + other_ref.to_s  + ' -- ' + file_glob)
			end # if
		else
			if other_ref == NamedCommit::Working_tree
				@repository.git_command('diff -z ' + options + ' ' + to_s  + ' -- ' + file_glob)
			else
				@repository.git_command('diff -z ' + options + ' ' + to_s + '..' + other_ref.to_s + ' -- ' + file_glob)
			end # if
		end # if
  end # diff_branch_files

  def pull_differences(more_mature_branch)
    branch_file_changes = diff_branch_files(more_mature_branch, '--summary').output
    branch_num_line_changes = diff_branch_files(more_mature_branch, '--numstat').output
  end # pull_differences

  def merge_up_discard_files(more_mature_branch)
    merge_up_file_changes = diff_branch_files(more_mature_branch, '--summary').output
  end # merge_up_discard_files

  def subset_changes(more_mature_branch)
    subset_change_files = diff_branch_files(more_mature_branch, options = '--numstat').output
    '|grep -v "^0"'
    numstat_regexp = /[0-9]+/.capture(:deletions) * /\s+/ * /[0-9]+/.capture(:additions) * /\s+/ * FilePattern::Relative_pathname_regexp.capture(:path)
    subset_change_files.capture_many(numstat_regexp).column_output.select do |_capture|
      true # capture[:deletions] = '0'
    end # select
  end # subset_changes

end # Commit
class NamedCommit < Commit # tags, symbols, and of course branches (subtype)
  
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
		include Commit::ReferenceObjects
#    include DefinitionalConstants
		Head_at_start = NamedCommit.new(initialization_string: :HEAD, repository: Repository::This_code_repository)
		Orig_head_at_start = NamedCommit.new(initialization_string: :ORIG_HEAD, repository: Repository::This_code_repository)
		Fetch_head_at_start = NamedCommit.new(initialization_string: :FETCH_HEAD, repository: Repository::This_code_repository)
		Merge_head_at_start = NamedCommit.new(initialization_string: :MERGE_HEAD, repository: Repository::This_code_repository)
  end # ReferenceObjects
  include ReferenceObjects
end # NamedCommit


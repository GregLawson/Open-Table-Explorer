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





module TimeTypes
    Week_day_regexp = /[MTWFS][a-z]{2}/.capture(:weekday)
    Day_regexp = /[0-9]{1,2}/.capture(:day_of_month)
    Month_regexp = /[ADFJMNOS][a-z]+/.capture(:month)
    Year_regexp = /[0-9]{2,4}/.capture(:year)
    Hour_regexp = /[0-9][0-9]/.capture(:hour)
    Minute_regexp = /[0-9][0-9]/.capture(:minute)
    Second_regexp = /[0-9][0-9]/.capture(:second)
    AMPM_regexp = / ?([PApa][Mm])?/.capture(:AMPM)
    Timezone_number_regexp = /[-+][0-1][0-9][03]0/.capture(:timezone)
		Day_after_month_regexp = Month_regexp * ' ' * Day_regexp
    Date_regexp = Day_regexp * ' ' * Month_regexp
		Space_regexp = /\ /
    Time_regexp = Hour_regexp * ':' * Minute_regexp * ':' * Second_regexp

    Git_show_medium_timestamp_regexp_array = [Week_day_regexp, 
			Space_regexp * Month_regexp * Space_regexp * Day_regexp, 
			Space_regexp * Time_regexp, Space_regexp * Year_regexp, Space_regexp * Timezone_number_regexp]
		Git_show_medium_timestamp_regexp = Regexp[Git_show_medium_timestamp_regexp_array] 

		Git_reflog_timestamp_regexp_array = [Week_day_regexp,
			/,/ * Space_regexp * Day_regexp * Space_regexp * Month_regexp * Space_regexp * Year_regexp, 
			Space_regexp * Hour_regexp * ':' * Minute_regexp * ':' * Second_regexp * Space_regexp * Timezone_number_regexp]
		Git_reflog_timestamp_regexp = Regexp[Git_reflog_timestamp_regexp_array]
end # TimeTypes

class GitReference # base class for all git references (readable, maybe not writeable)
	
	
  include Virtus.value_object

  values do
    attribute :initialization_string, Symbol
    attribute :repository, Repository, default: Repository::This_code_repository
#		attribute :sha1_hex_7, String
  end # values

  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
#    include DefinitionalConstants
		# Simulate a NamedCommit for working directory not yet in git.
		Tree = GitReference.new(initialization_string: 'HEAD' + '^{tree}', repository: Repository::This_code_repository) 
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
		run = repository.git_command('show ' + initialization_string.to_s + ' --pretty=medium  --no-abbrev-commit --no-patch')
	end # show_run
	end # GitReference
	
class Commit < GitReference
	module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		include Regexp::DefinitionalConstants
		include TimeTypes
    SHA1_hex_7 = /[[:xdigit:]]{7}/.capture(:sha1_hex_7)
    SHA1_hex_40 = /[[:xdigit:]]{40}/.capture(:sha1_hex_40)
		Merge_regexp = (/Merge: / * SHA1_hex_7 * / / * SHA1_hex_7 * /\n/).optional
		Name_regexp = /[\s[:word:]]+/.capture(:name)
		Email_regexp = /[[:word:]]*@[[:word:]]*\.[[:word:]]*/.capture(:email)
    Aurthor_regexp = /Author: / * Name_regexp * / </ * Email_regexp * />/ */\n/
		Title_regexp = /\n\n/ * /[\s[:graph:]]*/.capture(:commit_title) * /\n/ 
		Explanation_regexp = /[\s\n[:graph:]]*/.capture(:commit_explanation) * Regexp::End_string
		Show_commit_array = [ Regexp::Start_string * /commit / * SHA1_hex_40 * /\n/, Merge_regexp, Aurthor_regexp, /Date:   / * Git_show_medium_timestamp_regexp, Title_regexp, Explanation_regexp]
		Show_commit_regexp = Regexp[Show_commit_array].exact
	end # DefinitionalConstants
	include DefinitionalConstants

  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
		def head(repository)
			Commit.new(initialization_string: :HEAD, repository: repository)
		end # head
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
	
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
#		include WorkingTree::ReferenceObjects
    include DefinitionalConstants
  end # ReferenceObjects
  include ReferenceObjects
	
	def show_commit
		capture = show_run.output.capture?(Show_commit_regexp)
		if capture.success?
			capture.output
		else
			raise capture.inspect
		end # if
	end # show_commit
	
	def sha1_hex_40
		show_commit[:sha1_hex_40]
	end # sha1_hex_40

	def commit_title
		show_commit[:commit_title]
	end # commit_title
	
	def tree
		tree_ref = GitReference.new(initialization_string: initialization_string.to_s + '^{tree}')
		tree_run = tree_ref.show_run
		output = tree_run.output
		array = output.split("\n")[1..-1] # discard echo of tree
	end # tree

  def diff_branch_files(other_ref, options = '--summary', file_glob = '*.rb')
			if other_ref == WorkingTree::Working_tree
				@repository.git_command('diff -z ' + options + ' ' + to_s  + ' -- ' + file_glob)
			else
				@repository.git_command('diff -z ' + options + ' ' + to_s + '..' + other_ref.to_s + ' -- ' + file_glob)
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

class WorkingTree < Commit # extend Commit to include not yet committed
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
#    include DefinitionalConstants
		# Simulate a NamedCommit for working directory not yet in git.
		Working_tree = WorkingTree.new(initialization_string: :Working_tree, repository: Repository::This_code_repository) 
  end # ReferenceObjects
  include ReferenceObjects

  def diff_branch_files(other_ref, options = '--summary', file_glob = '*.rb')
			if other_ref == Working_tree
				[]
			else
				@repository.git_command('diff -z ' + options + ' ' + other_ref.to_s  + ' -- ' + file_glob)
			end # if
  end # diff_branch_files

	def sha1_hex_7
		nil
	end # sha1_hex_7

	def sha1_hex_40
		nil
	end # sha1_hex_40

	def commit_title
		'not yet committed'
	end # commit_title
	
end # WorkingTree

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


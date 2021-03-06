###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'dry-types'
require_relative 'unit.rb'
#!require_relative 'interactive_bottleneck.rb'
require_relative 'repository.rb'
require_relative 'unit_maturity.rb'
require_relative 'editor.rb'
module Types
  include Dry::Types.module
end # Types
class Merge
  module Constants
    Library_unit = RailsishRubyUnit.new_from_path(__FILE__)
    Library_class = Library_unit.model_class?
  end # Constants
  include Constants

  module ClassMethods
    include Constants
  end # ClassMethods
  extend ClassMethods
  # Define related (unit) versions
  # Use as current, lower/upper bound, branch history
  # parametized by related files, repository, branch_number, executable
  # record error_score, recent_test, time
  include Virtus.value_object
  values do
    attribute :repository, Repository, default: Repository::This_code_repository
    attribute :source_commit, Branch, default: Branch.new(initialization_string: :passed)
    attribute :target_branch_name, Symbol, default: Branch.current_branch_name?(Repository::This_code_repository)
    attribute :interactive, Symbol, default: :interactive # non-defaults are primarily for non-interactive testing testing
    attribute :editor, Editor, default: Default_editor
  end # values
  def discard_log_file_merge
    unmerged_files = @repository.status
    unmerged_files.each do |conflict|
      if conflict[:file][-4..-1] == '.log'
        @repository.git_command('checkout HEAD ' + conflict[:file])
        puts 'checkout HEAD ' + conflict[:file]
      end # if
    end # each
  end # discard_log_file_merge

  def merge_conflict_recovery
    # see man git status
    discard_log_file_merge # each branch's log file status is independant
    puts '@repository.status = ' + @repository.status.inspect
    unmerged_files = @repository.status
    unless unmerged_files.empty?
      puts 'merge --abort'
      merge_abort = @repository.git_command('merge --abort')
      if merge_abort.success?
        puts 'merge --X ours ' + @source_commit.to_s
        remerge = @repository.git_command('merge --X ours ' + @source_commit.to_s)
      end # if
      unmerged_files.each do |conflict|
        puts 'not checkout HEAD ' + conflict[:file]
        if conflict[:index] == :ignored || conflict[:work_tree] == :ignored
        # ignore
        elsif conflict[:description] == 'updated in index'
        # no merge conflict; test!
        elsif conflict[:description][0..7] == 'unmerged'
          test_executable = TestExecutable.new_from_path(conflict[:file])
          Editor.new(test_executable).edit
        #				@repository.validate_commit(@repository.current_branch_name?, [conflict[:file]])
        else
          raise Exception.new(conflict.inspect)
          end # if
      end # each
      confirm_commit
    end # if
  end # merge_conflict_recovery

  # does not return to original branch unlike #safely_visit_branch
  # does not need a block, since it doesn't switch back
  # moves all working directory files to new branch
  def switch_branch(target_branch)
    push = stash_and_checkout(target_branch)
  end # switch_branch

  def merge_interactive
    merge_status = @repository.git_command('merge --no-commit ' + @source_commit.to_s)
  end # merge_interactive

  def trial_merge
    merge_status = @repository.git_command('merge --no-commit ' + source_commit.to_s)
    puts 'merge_status= ' + merge_status.inspect
    if merge_status.output == "Automatic merge went well; stopped before committing as requested\n"
      puts 'merge OK'
    else
      if merge_status.success?
        puts 'not merge_conflict_recovery' + merge_status.inspect
      else
        puts 'merge_conflict_recovery' + merge_status.inspect
        merge_conflict_recovery
      end # if
    end # if
    unmerged_files = @repository.status
    unless unmerged_files.empty?
      merge_abort = @repository.git_command('merge --abort')
      if merge_abort.success?
        remerge = @repository.git_command('merge --X ours ' + @source_commit.to_s)
      end # if
    end # if
    unmerged_files # work still to do
  end # trial_merge

  def merge
    puts 'merge(' + @target_branch_name.inspect + ', ' + @source_commit.inspect + ', ' + @interactive.inspect + ')'
    stash_and_checkout
    trial_merge
    confirm_commit
  end # merge

  def merge_down
    Branch.merge_range(deserving_branch).each do |i|
      safely_visit_branch(Branch::Branch_enhancement[i]) do |_changes_branch|
        puts 'merge(' + Branch::Branch_enhancement[i].to_s + '), ' + Branch::Branch_enhancement[i - 1].to_s + ')' unless $VERBOSE.nil?
        merge(Branch::Branch_enhancement[i], Branch::Branch_enhancement[i - 1])
        merge_conflict_recovery(Branch::Branch_enhancement[i - 1])
        confirm_commit
      end # safely_visit_branch
    end # each
  end # merge_down

  module Assertions
    module ClassMethods
      def assert_pre_conditions
      end # assert_pre_conditions

      def assert_post_conditions
        #	assert_pathname_exists(TestExecutable, "assert_post_conditions")
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions
      #	refute_nil(@test_executable.unit)
      #	refute_empty(@test_executable.unit.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @test_executable.unit.edit_files=#{@test_executable.unit.edit_files.inspect}")
      #	assert_kind_of(Grit::Repo, @repository.grit_repo)
      #	assert_respond_to(@repository.grit_repo, :status)
      #	assert_respond_to(@repository.grit_repo.status, :changed)
    end # assert_pre_conditions

    def assert_post_conditions
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # TestWorkFlow.assert_pre_conditions
  include Constants
end # Merge

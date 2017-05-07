###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
require_relative 'repository.rb'
require_relative 'unit_maturity.rb'
require_relative 'editor.rb'
class InteractiveBottleneck
  module Constants
  end # Constants
  include Constants
  module ClassMethods
    include Constants
    def calc_test_maturity!(test_executable)
      if test_executable.testable?
        TestMaturity.new(test_executable: test_executable)
       end # if
    end # calc_test_maturity!
  end # ClassMethods
  extend ClassMethods
  # Define related (unit) versions
  # Use as current, lower/upper bound, branch history
  # parametized by related files, repository, branch_number, executable
  # record error_score, recent_test, time
  include Virtus.value_object
  values do
    attribute :test_executable, TestExecutable
    attribute :interactive, Symbol, default: :interactive # non-defaults are primarily for non-interactive testing testing
    attribute :editor, Editor, default: ->(_interactive_bottleneck, _attribute) { Default_editor }
    attribute :repository, Repository, default: ->(interactive_bottleneck, _attribute) { interactive_bottleneck.test_executable.repository }
    attribute :unit_maturity, UnitMaturity, default: ->(interactive_bottleneck, _attribute) { UnitMaturity.new(interactive_bottleneck.test_executable.repository, interactive_bottleneck.test_executable.unit) }
    #	attribute :branch_index, Fixnum, :default => lambda { |interactive_bottleneck, attribute| InteractiveBottleneck.index(interactive_bottleneck.test_executable.repository) }
  end # values
  def dirty_test_executables
    @repository.status.map do |file_status|
      if file_status.log_file?
        nil
      elsif file_status.work_tree == :ignore
        nil
      else
        lookup = FilePattern.find_from_path(file_status.file)
        unless lookup.nil?
          test_executable = TestExecutable.new_from_path(file_status.file)
          testable = test_executable.generatable_unit_file?
          if testable
            test_executable # find unique
          end # if
        end # if
      end # if
    end.select { |t| !t.nil? }.uniq # map
  end # dirty_test_executables

  def dirty_units
    dirty_test_executables.map do |test_executable|
      if test_executable.unit.model_basename.nil?
        { test_executable: test_executable, unit: nil }
      else
        { test_executable: test_executable, unit: test_executable.unit }
      end # if
    end # map
  end # dirty_units

  def dirty_test_maturities(_recursion_danger = nil)
    dirty_test_executables.map do |test_executable|
      if test_executable.testable?
        test_maturity = TestMaturity.new(test_executable: test_executable)
      end # if
    end.compact.sort
  end # dirty_test_maturities

  def clean_directory
    sorted = dirty_test_maturities # .sort{|n1, n2| n1[:error_score] <=> n2[:error_score]}
    sorted.sort.map do |test_maturity|
      target_branch = test_maturity.deserving_branch
      case target_branch <=> Branch.current_branch
      when +1 then
        switch_branch(target_branch)
      when 0  then
        stage_test_executable
      when -1 then
        merge_down
      end # case
    end # map
  end # clean_directory

  def confirm_branch_switch(branch)
    checkout_branch = @repository.git_command("checkout #{branch}")
    if checkout_branch.errors != "Already on '#{branch}'\n" && checkout_branch.errors != "Switched to branch '#{branch}'\n"
      checkout_branch # .assert_post_conditions
    end # if
    checkout_branch # for command chaining
  end # confirm_branch_switch

  # This is safe in the sense that a stash saves all files
  # and a stash apply restores all tracked files
  # safe is meant to mean no files or changes are lost or buried.
  def safely_visit_branch(target_branch)
    stash_branch = @repository.current_branch_name?
    changes_branch = stash_branch #
    push = @repository.something_to_commit? # remember
    if push
      #		status=@grit_repo.status
      #		puts "status.added=#{status.added.inspect}"
      #		puts "status.changed=#{status.changed.inspect}"
      #		puts "status.deleted=#{status.deleted.inspect}"
      #		puts "@repository.something_to_commit?=#{@repository.something_to_commit?.inspect}"
      @repository.stash!.assert_post_conditions
      merge_cleanup
      changes_branch = :stash
    end # if

    if stash_branch != target_branch
      confirm_branch_switch(target_branch)
      ret = yield(changes_branch)
      confirm_branch_switch(stash_branch)
    else
      ret = yield(changes_branch)
    end # if
    if push
      apply_run = @repository.git_command('stash apply --quiet')
      if apply_run.errors =~ /Could not restore untracked files from stash/
        puts apply_run.errors
        puts @repository.git_command('status').output
        puts @repository.git_command('stash show').output
      else
        apply_run # .assert_post_conditions('unexpected stash apply fail')
      end # if
      merge_cleanup
    end # if
    ret
  end # safely_visit_branch

  def merge_cleanup
    @repository.status.each do |conflict|
      case @interactive
      when :interactive then
        @repository.shell_command('diffuse -m ' + conflict.file)
      end # case
      confirm_commit
    end # each
  end # merge_cleanup

  def stage_files(branch, files)
    safely_visit_branch(branch) do |changes_branch|
      validate_commit(changes_branch, files)
    end # safely_visit_branch
  end # stage_files

  def confirm_commit
    if @repository.something_to_commit?
      case @interactive
      when :interactive then
        cola_run = @repository.git_command('cola')
        cola_run = cola_run.tolerate_status_and_error_pattern(0, /Warning/)
        @repository.git_command('rerere')
        cola_run # .assert_post_conditions
        unless @repository.something_to_commit?
          #				@repository.git_command('cola rebase '+@repository.current_branch_name?.to_s)
        end # if
      when :echo then
      when :staged then
        @repository.git_command('commit ').assert_post_conditions
      when :all then
        @repository.git_command('add . ').assert_post_conditions
        @repository.git_command('commit ').assert_post_conditions
      else
        raise 'Unimplemented option @interactive = ' + @interactive.inspect + "\n" + inspect
      end # case
    end # if
    puts 'confirm_commit(' + @interactive.inspect + ' @repository.something_to_commit?=' + @repository.something_to_commit?.inspect
  end # confirm_commit

  def validate_commit(changes_branch, files)
    puts files.inspect if $VERBOSE
    files.each do |p|
      puts p.inspect if $VERBOSE
      @repository.git_command(['checkout', changes_branch.to_s, p])
    end # each
    if @repository.something_to_commit?
      confirm_commit
      #		@repository.git_command('rebase --autosquash --interactive')
    end # if
  end # validate_commit

  def script_deserves_commit!(deserving_branch)
    if working_different_from?($PROGRAM_NAME,	UnitMaturity.branch_index?(deserving_branch))
      repository.stage_files(deserving_branch, related_files.tested_files($PROGRAM_NAME))
      merge_down(deserving_branch)
    end # if
  end # script_deserves_commit!
  # require_relative '../../app/models/assertions.rb'
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
      odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
      #	assert_empty(odd_files, 'InteractiveBottleneck#assert_post_conditions')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # TestWorkFlow.assert_pre_conditions
  include Constants
  module Examples
    TestTestExecutable = TestExecutable.new(argument_path: File.expand_path($PROGRAM_NAME))
    TestInteractiveBottleneck = InteractiveBottleneck.new(interactive: :interactive, test_executable: TestTestExecutable, editor: Default_editor)
    include Constants
  end # Examples
  include Examples
end # InteractiveBottleneck

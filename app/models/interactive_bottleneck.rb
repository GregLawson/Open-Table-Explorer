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
require_relative 'nomination.rb'
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
    attribute :interactive, Symbol, default: :interactive # non-defaults are primarily for non-interactive testing
    attribute :editor, Editor, default: ->(_interactive_bottleneck, _attribute) { Default_editor }
    attribute :repository, Repository, default: ->(interactive_bottleneck, _attribute) { interactive_bottleneck.test_executable.repository }
    attribute :unit_maturity, UnitMaturity, default: ->(interactive_bottleneck, _attribute) { UnitMaturity.new(interactive_bottleneck.test_executable.repository, interactive_bottleneck.test_executable.unit) }
    #	attribute :branch_index, Fixnum, :default => lambda { |interactive_bottleneck, attribute| InteractiveBottleneck.index(interactive_bottleneck.test_executable.repository) }
  end # values

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

  def merge_cleanup
    @repository.status.each do |conflict|
      case @interactive
      when :interactive then
        @repository.shell_command('diffuse -m ' + conflict.file)
      end # case
      confirm_commit
    end # each
  end # merge_cleanup


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
end # InteractiveBottleneck

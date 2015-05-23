###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'interactive_bottleneck.rb'
#require_relative 'repository.rb'
#require_relative 'unit_maturity.rb'
#require_relative 'editor.rb'
class WorkFlow
module Constants
end # Constants
include Constants
module ClassMethods
include Constants
def all(pattern_name = :test)
	pattern = FilePattern.find_by_name(pattern_name)
	glob = FilePattern.new(pattern).pathname_glob
	tests = Dir[glob].sort do |x, y|
		-(File.mtime(x) <=> File.mtime(y)) # reverse order; most recently changed first
	end # sort
	puts tests.inspect if $VERBOSE
	tests.each do |test|
		WorkFlow.new(test).unit_test
	end # each
end # all
end # ClassMethods
extend ClassMethods
# Define related (unit) versions
# Use as current, lower/upper bound, branch history
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :related_files, :edit_files, :repository, :unit_maturity, :editor
def initialize(executable, editor)
	@test_executable = executable

	@executable_file = executable.executable_file
	@editor = editor
	@unit_maturity = UnitMaturity.new(executable.repository, executable.unit)
	@related_files = related_files
	@repository = repository
	index = UnitMaturity::Branch_enhancement.index(executable.repository.current_branch_name?)
	if index.nil? then
		@branch_index = UnitMaturity::First_slot_index
	else
		@branch_index = index
	end # if
end # initialize
def test(executable = @related_files.model_test_pathname?)
	merge_conflict_recovery(:MERGE_HEAD)
	deserving_branch = UnitMaturity.deserving_branch?(executable, @repository)
	puts deserving_branch if $VERBOSE
	@repository.safely_visit_branch(deserving_branch) do |changes_branch|
		@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
	end # safely_visit_branch
	current_branch = repository.current_branch_name?

	if UnitMaturity.branch_index?(current_branch) > UnitMaturity.branch_index?(deserving_branch) then
		@repository.validate_commit(current_branch, @related_files.tested_files(executable))
	end # if
	deserving_branch
end # test
def loop(executable = @related_files.model_test_pathname?)
	merge_conflict_recovery(:MERGE_HEAD)
	@repository.safely_visit_branch(:master) do |changes_branch|
		begin
			deserving_branch = UnitMaturity.deserving_branch?(executable, @repository)
			puts "deserving_branch=#{deserving_branch} != :passed=#{deserving_branch != :passed}"
			if !File.exists?(executable) then
				done = true
			elsif deserving_branch != :passed then # master corrupted
				editor.edit('master branch not passing')
				done = false
			else
				done = true
			end # if
		end until done
		@repository.confirm_commit(:interactive)
#		@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
	end # safely_visit_branch
	begin
		deserving_branch = test(executable)
		merge_down(deserving_branch)
		editor.edit('loop')
		if @repository.something_to_commit? then
			done = false
		else
			if @expected_next_commit_branch == @repository.current_branch_name? then
				done = true # branch already checked
			else
				done = false # check other branch
				@repository.confirm_branch_switch(@expected_next_commit_branch)
				puts 'Switching to deserving branch' + @expected_next_commit_branch.to_s
			end # if
		end # if
	end until done
end # loop
def unit_test(executable = @related_files.model_test_pathname?)
	begin
		deserving_branch = UnitMaturity.deserving_branch?(executable, @repository)
		if !@repository.recent_test.nil? && @repository.recent_test.success? then
			break
		end # if
		@repository.recent_test.puts
		puts deserving_branch if $VERBOSE
		@repository.safely_visit_branch(deserving_branch) do |changes_branch|
			@repository.validate_commit(changes_branch, @related_files.tested_files(executable))
		end # safely_visit_branch
#		if !@repository.something_to_commit? then
#			@repository.confirm_branch_switch(deserving_branch)
#		end #if
		editor.edit('unit_test')
	end until !@repository.something_to_commit?
end # unit_test
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods

def assert_pre_conditions
end # assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(TestFile, "assert_post_conditions")
end # assert_post_conditions
end # ClassMethods
def assert_pre_conditions
	assert_not_nil(@related_files)
	assert_not_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
	assert_kind_of(Grit::Repo, @repository.grit_repo)
	assert_respond_to(@repository.grit_repo, :status)
	assert_respond_to(@repository.grit_repo.status, :changed)
end # assert_pre_conditions
def assert_post_conditions
	odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
	assert_empty(odd_files, 'WorkFlow#assert_post_conditions')
end # assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
# TestWorkFlow.assert_pre_conditions
include Constants
module Examples
TestExecutable = TestExecutable.new(executable_file: File.expand_path($PROGRAM_NAME))
TestWorkFlow = WorkFlow.new(TestExecutable, Editor::Examples::TestEditor)
include Constants
end # Examples
include Examples
end # WorkFlow

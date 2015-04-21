###########################################################################
#    Copyright (C) 2013-15 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
#require_relative 'repository.rb'
require_relative 'unit_maturity.rb'
require_relative 'editor.rb'
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
attr_reader :related_files, :edit_files, :repository, :unit_maturity
def initialize(specific_file,
	related_files = Unit.new_from_path?(specific_file),
	repository = Repository.new(FilePattern.repository_dir?, :interactive))

	@specific_file = specific_file
	@unit_maturity = UnitMaturity.new(repository, related_files)
	@related_files = related_files
	@repository = repository
	index = UnitMaturity::Branch_enhancement.index(repository.current_branch_name?)
	if index.nil? then
		@branch_index = UnitMaturity::First_slot_index
	else
		@branch_index = index
	end # if
end # initialize
def merge_conflict_recovery(from_branch)
# see man git status
	puts '@repository.merge_conflict_files?= ' + @repository.merge_conflict_files?.inspect
	unmerged_files = @repository.merge_conflict_files?
	if !unmerged_files.empty? then
		puts 'merge --abort'
		merge_abort = @repository.git_command('merge --abort')
		if merge_abort.success? then
			puts 'merge --X ours ' + from_branch.to_s
			remerge = @repository.git_command('merge --X ours ' + from_branch.to_s)
		end # if
		unmerged_files.each do |conflict|
			if conflict[:file][-4..-1] == '.log' then
				@repository.git_command('checkout HEAD ' + conflict[:file])
				puts 'checkout HEAD ' + conflict[:file]
			else
				puts 'not checkout HEAD ' + conflict[:file]
				case conflict[:conflict]
				# DD unmerged, both deleted
				when 'DD' then fail Exception.new(conflict.inspect)
				# AU unmerged, added by us
				when 'AU' then fail Exception.new(conflict.inspect)
				# UD unmerged, deleted by them
				when 'UD' then fail Exception.new(conflict.inspect)
				# UA unmerged, added by them
				when 'UA' then fail Exception.new(conflict.inspect)
				# DU unmerged, deleted by us
				when 'DU' then fail Exception.new(conflict.inspect)
				# AA unmerged, both added
				when 'AA' then fail Exception.new(conflict.inspect)
				# UU unmerged, both modified
				when 'UU', ' M', 'M ', 'MM', 'A ' then
					WorkFlow.new(conflict[:file]).edit('merge_conflict_recovery')
	#				@repository.validate_commit(@repository.current_branch_name?, [conflict[:file]])
				else
					fail Exception.new(conflict.inspect)
				end # case
			end # if
		end # each
		@repository.confirm_commit
	end # if
end # merge_conflict_recovery
def merge(target_branch, source_branch, interact=:interactive)
	puts 'merge('+target_branch.inspect+', '+source_branch.inspect+', '+interact.inspect+')'
	@repository.safely_visit_branch(target_branch) do |changes_branch|
		merge_status = @repository.git_command('merge ' + source_branch.to_s)
		puts 'merge_status= ' + merge_status.inspect
		if merge_status.output == "Automatic merge went well; stopped before committing as requested\n" then
			puts 'merge OK'
		else
			if merge_status.success? then
				puts 'not merge_conflict_recovery' + merge_status.inspect
			else
				puts 'merge_conflict_recovery' + merge_status.inspect
				merge_conflict_recovery(source_branch)
			end # if
		end # if
		@repository.confirm_commit(interact)
	end # safely_visit_branch
end # merge
def merge_down(deserving_branch = @repository.current_branch_name?)
	UnitMaturity.merge_range(deserving_branch).each do |i|
		@repository.safely_visit_branch(UnitMaturity::Branch_enhancement[i]) do |changes_branch|
			puts 'merge(' + UnitMaturity::Branch_enhancement[i].to_s + '), ' + UnitMaturity::Branch_enhancement[i - 1].to_s + ')' if !$VERBOSE.nil?
			merge(UnitMaturity::Branch_enhancement[i], UnitMaturity::Branch_enhancement[i - 1])
			merge_conflict_recovery(UnitMaturity::Branch_enhancement[i - 1])
			@repository.confirm_commit(:interactive)
		end # safely_visit_branch
	end # each
end # merge_down
def script_deserves_commit!(deserving_branch)
	if working_different_from?($PROGRAM_NAME, 	UnitMaturity.branch_index?(deserving_branch)) then
		repository.stage_files(deserving_branch, related_files.tested_files($PROGRAM_NAME))
		merge_down(deserving_branch)
	end # if
end # script_deserves_commit!
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
				edit('master branch not passing')
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
		edit('loop')
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
		edit('unit_test')
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
TestFile = File.expand_path($PROGRAM_NAME)
TestWorkFlow = WorkFlow.new(TestFile)
include Constants
end # Examples
include Examples
end # WorkFlow

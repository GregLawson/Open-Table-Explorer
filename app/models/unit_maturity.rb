###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
#assert_global_name(:Repository)
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/test_run.rb'
class UnitMaturity
#include Repository::Constants
module Constants
#assert_global_name(:Repository)
#include Repository::Examples
Branch_enhancement = [:passed, :testing, :edited] # higher inex means more enhancements/bugs
Extended_branches = { -4 => :'origin/master',
	-3 => :work_flow,
	-2 => :tax_form,
	-1 => :master }
First_slot_index = Extended_branches.keys.min
Last_slot_index = Branch_enhancement.size + 10 # how many is too slow?
Deserving_commit_to_branch = { success:             0,
				single_test_fail:    1,
			              multiple_tests_fail: 1, # visibility boundary
			              initialization_fail: 2,
			              syntax_error:        2
			}
Expected_next_commit_branch = { success:             0,
							  single_test_fail:    0,
			              multiple_tests_fail: 1, # visibility boundary
			              initialization_fail: 1,
			              syntax_error:        2
			}
# define branch maturity partial order
# use for merge-down and maturity promotion
More_mature = {
	:master => :'origin/master',
	:passed => :master,
	:testing => :passed,
	:edited => :testing
}
Subset_branch = {
	:master => :tax_form,
	:master => :work_flow,
	:work_flow => :unit,
	:unit => :regexp
}
end #Constants
include Constants
module ClassMethods
#include Repository::Constants
include Constants
def branch_symbol?(branch_index)
	case branch_index
	when nil then fail 'branch_index=' + branch_index.inspect
	when -4 then :'origin/master'
	when -3 then :work_flow
	when -2 then :tax_form
	when -1 then :master
	when 0..UnitMaturity::Branch_enhancement.size - 1 then UnitMaturity::Branch_enhancement[branch_index]
	when UnitMaturity::Branch_enhancement.size then :stash
	else
		('stash~' + (branch_index - UnitMaturity::Branch_enhancement.size).to_s).to_sym
	end # case
end # branch_symbol?
def branch_index?(branch_name)
	branch_index = Branch_enhancement.index(branch_name.to_sym)
	if branch_index.nil? then
		if branch_name.to_s[0, 5] == 'stash' then
			stash_depth = branch_name.to_s[6, branch_name.size - 1].to_i
			branch_index = stash_depth + Branch_enhancement.size
		end # if
		Extended_branches.each_pair do |index, branch|
			branch_index = index if branch == branch_name.to_sym
		end # each_pair
	end # if
	branch_index
end # branch_index?
def revison_tag?(branch_index)
	'-r ' + branch_symbol?(branch_index).to_s
end # revison_tag?
def merge_range(deserving_branch)
	deserving_index = UnitMaturity.branch_index?(deserving_branch)
	if deserving_index.nil? then
		fail deserving_branch.inspect + ' not found in ' + UnitMaturity::Branch_enhancement.inspect + ' or ' + Extended_branches.inspect
	else
		deserving_index + 1..UnitMaturity::Branch_enhancement.size - 1
	end # if
end # merge_range
def deserving_branch?(executable,
	repository)
	if File.exists?(executable) then
		@working_test_run = TestRun.new(executable).error_score?(executable)
		@deserving_commit_to_branch = UnitMaturity::Deserving_commit_to_branch[test_run.error_classification]
		@expected_next_commit_branch = UnitMaturity::Expected_next_commit_branch[test_run.error_classification]
		@branch_enhancement = UnitMaturity::Branch_enhancement[@deserving_commit_to_branch]
	else
		:edited
	end # if
end # deserving_branch
end #ClassMethods
extend ClassMethods
attr_reader :repository, :unit
def initialize(repository, unit)
	fail "UnitMaturity.new first argument must be of type Repository" unless repository.instance_of?(Repository)
#	fail "@repository must respond to :remotes?\n"+
#		"repository.inspect=#{repository.inspect}\n" +
#		"repository.methods(false)=#{repository.methods(false).inspect}" unless repository.respond_to?(:remotes?)
	@repository=repository
	@unit = unit
end # initialize
def diff_command?(filename, branch_index)
	fail filename + ' does not exist.' if !File.exists?(filename)
	branch_string = UnitMaturity.branch_symbol?(branch_index).to_s
	git_command = "diff --summary --shortstat #{branch_string} -- " + filename
	diff_run = @repository.git_command(git_command)
end # diff_command?
# What happens to non-existant versions? returns nil Are they different? 
# What do I want?
def working_different_from?(filename, branch_index)
	diff_run = diff_command?(filename, branch_index)
	if diff_run.output == '' then
		false # no difference
	elsif diff_run.output.split("\n").size == 2 then
		nil # missing version
	else
		true # real difference
	end # if
end # working_different_from?
def differences?(filename, range)
	differences = range.map do |branch_index|
		working_different_from?(filename, branch_index)
	end # map
end # differences?
def scan_verions?(filename, range, direction)
	differences = differences?(filename, range)
	different_indices = []
	existing_indices = []
	range.zip(differences) do |index, s|
		case s
		when true then
			different_indices << index
			existing_indices << index
		when nil then
		when false then
			existing_indices << index
		else
			fail 'else ' + local_variables.map{|v| eval(v).inspect}.join("\n")
		end # case
	end # zip
	case direction
	when :first then
		(different_indices + [existing_indices[-1]]).min
	when :last then
		([existing_indices[0]] + different_indices).max
	else
		fail
	end # case
end # scan_verions?
def bracketing_versions?(filename, current_index)
	left_index = scan_verions?(filename, First_slot_index..current_index, :last)
	right_index = scan_verions?(filename, current_index + 1..Last_slot_index, :first)
	[left_index, right_index]
end # bracketing_versions?
def rebase!
	if remotes?.include?(current_branch_name?) then
		git_command('rebase --interactive origin/'+current_branch_name?).assert_post_conditions.output.split("\n")
	else
		puts current_branch_name?.to_s+' has no remote branch in origin.'
	end #if
end #rebase!
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
end #ClassMethods
def assert_deserving_branch(branch_expected, executable, message = '')
	deserving_branch = UnitMaturity.deserving_branch?(executable, @repository)
	recent_test = shell_command('ruby ' + executable)
	message += "\nrecent_test=" + recent_test.inspect
	message += "\nrecent_test.process_status=" + recent_test.process_status.inspect
	syntax_test = shell_command('ruby -c ' + executable)
	message += "\nsyntax_test=" + syntax_test.inspect
	message += "\nsyntax_test.process_status=" + syntax_test.process_status.inspect
	message += "\nbranch_expected=#{branch_expected.inspect}"
	message += "\ndeserving_branch=#{deserving_branch.inspect}"
	case deserving_branch
	when :edited then
		assert_equal(1, recent_test.process_status.exitstatus, message)
		assert_not_equal("Syntax OK\n", syntax_test.output, message)
		assert_equal(1, syntax_test.process_status.exitstatus, message)
	when :testing then
		assert_operator(1, :<=, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	when :passed then
		assert_equal(0, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	end # case
	assert_equal(deserving_branch, branch_expected, message)
end # deserving_branch
end # Assertions
module Examples
include Constants
File_not_in_oldest_branch = 'test/long_test/repository_test.rb'
Most_stable_file = 'test/unit/minimal2_test.rb'
Formerly_existant_file = 'test/unit/related_file.rb'
TestUnitMaturity = UnitMaturity.new(Repository::This_code_repository, Repository::Repository_Unit)
end # Examples
end # UnitMaturity

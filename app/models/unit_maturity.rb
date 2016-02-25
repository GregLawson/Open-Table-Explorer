###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
#assert_global_name(:Repository)
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/test_run.rb'
# abstracts TestRun and git commits for comparison
class TestMaturity
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
# Error score is a SWAG at order of magnitude of errors
Error_classification = {0 => :success,
				1     => :single_test_fail,
				100 => :initialization_fail,
				10000 => :syntax_error}
Push_branch = { success:             :passed,
				single_test_fail:    :testing,
			              multiple_tests_fail: :testing, # visibility boundary
			              initialization_fail: :edited,
			              syntax_error:        :edited
			}
Pull_branch = { success:             :passed,
							  single_test_fail:    :passed,
			              multiple_tests_fail: :testing, # visibility boundary
			              initialization_fail: :testing,
			              syntax_error:        :edited
			}
Error_score_directory = Unit.data_source_directories + '/test_maturity/'
end # DefinitionalConstants
include DefinitionalConstants
  include Virtus.value_object
  values do
 	attribute :version, BranchReference, :default => nil # working_directory
	attribute :test_executable, TestExecutable
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
	end # values
module ClassMethods
include DefinitionalConstants
def example_files
	ret = {} # accumulate a hash
 	Error_classification.each_pair do |expected_error_score, classification|
		executable_file = Error_score_directory + classification.to_s + '.rb'
		ret = ret.merge({executable_file => classification})
	end # each_pair
	ret
end # example_files
end # ClassMethods
extend ClassMethods
def get_error_score!
	if File.expand_path(@test_executable.executable_file) == File.expand_path($PROGRAM_NAME) then
		nil # avoid recursion
	elsif @cached_error_score.nil? then
		@cached_error_score = TestRun.new(test_executable: @test_executable).error_score?
	else
		@cached_error_score
	end # if
end # error_score
def deserving_branch
	if File.exists?(@test_executable.executable_file) then
		deserving_commit_to_branch
	else
		:edited
	end # if
end # deserving_branch
def <=>(other)
	get_error_score! <=> other.get_error_score!
end # <=>
def error_classification
	Error_classification.fetch(get_error_score!, :multiple_tests_fail)
end # error_classification
def deserving_commit_to_branch
	TestMaturity::Push_branch[error_classification]
end # deserving_commit_to_branch
def expected_next_commit_branch
	TestMaturity::Pull_branch[error_classification]
end # expected_next_commit_branch
def branch_enhancement
	Branch::Branch_enhancement[deserving_commit_to_branch]
end # branch_enhancement
module Examples
include DefinitionalConstants
ExecutableMaturity = TestMaturity.new(test_executable: TestExecutable.new(executable_file: $0))
MinimalMaturity = TestMaturity.new(test_executable: TestExecutable.new(executable_file: 'test/unit/minimal2_test.rb'))
end # Examples
end # TestMaturity

class UnitMaturity
#include Repository::Constants
module Constants
# define branch maturity partial order
# use for merge-down and maturity promotion
end #Constants
include Constants
module ClassMethods
#include Repository::Constants
include Constants
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
	branch_string = Branch.branch_symbol?(branch_index).to_s
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
	left_index = scan_verions?(filename, Branch::First_slot_index..current_index, :last)
	right_index = scan_verions?(filename, current_index + 1..Branch::Last_slot_index, :first)
	[left_index, right_index]
end # bracketing_versions?
require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
end #ClassMethods
def assert_deserving_branch(branch_expected, executable, message = '')
	deserving_branch = TestMaturity.deserving_branch
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
		refute_equal("Syntax OK\n", syntax_test.output, message)
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

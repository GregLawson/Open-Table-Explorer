###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/unit_maturity.rb'
class TestMaturityTest < TestCase
include TestMaturity::Examples
def test_Error_classification
	Error_classification.each_pair do |expected_error_score, classification|
		assert_instance_of(Fixnum, expected_error_score)
		assert_instance_of(Symbol, classification)
	end # each_pair
	assert_equal(4, Error_classification.keys.size, Error_classification.inspect)
	assert_equal(4, Error_classification.values.size, Error_classification.inspect)
end # Error_classification
def test_example_files
	ret = {} # accumulate a hash
 	Error_classification.each_pair do |expected_error_score, classification|
		executable_file = Error_score_directory + classification.to_s + '.rb'
		message = 'executable_file = ' + executable_file
		assert(File.exists?(executable_file), message)
		ret = ret.merge({executable_file => expected_error_score})
	end # each_pair
	refute_empty(TestMaturity.example_files)
	assert_equal(4, TestMaturity.example_files.keys.size, TestMaturity.example_files.inspect)
	assert_equal(4, TestMaturity.example_files.values.size, TestMaturity.example_files.inspect)
end # example_files
def test_get_error_score!
	assert_includes(TestMaturity.new(test_executable: TestExecutable.new(executable_file: $0)).instance_variables, :@test_executable)
	refute_includes(TestMaturity.new(test_executable: TestExecutable.new(executable_file: $0)).instance_variables, :@cached_error_score)
	assert_includes(ExecutableMaturity.instance_variables, :@test_executable)
	assert_nil(ExecutableMaturity.get_error_score!)
end # error_score
def test_deserving_branch
	error_classifications=[]
	branch_compressions=[]
	branch_enhancements=[]
	TestMaturity.example_files.each_pair do |executable_file, expected_error_score|
		test_executable = TestExecutable.new(executable_file: executable_file, test_type: :unit)
		refute_nil(test_executable.unit) # nonstandard unit assignment
		assert_equal(:unit, test_executable.test_type) # nonstandard unit assignment
		test_run = TestRun.new(test_executable: test_executable)
		error_score = test_run.error_score?
#		assert_equal(expected_error_score, error_score, test_run.inspect)
		error_classification = Error_classification.fetch(error_score, :multiple_tests_fail)
		error_classifications<<error_classification
#		branch_compression = Deserving_commit_to_branch[error_classification]
#		branch_compressions<<branch_compression
#		branch_enhancement=Branch_enhancement[branch_compression]
#		branch_enhancements<<branch_enhancement
	end #each
#	assert_equal(4, error_classifications.uniq.size, error_classifications.inspect)
#	assert_equal(3, branch_compressions.uniq.size, branch_compressions.inspect)
#	assert_equal(3, branch_enhancements.uniq.size, branch_enhancements.inspect)
#	error_classification=Error_classification.fetch(error_score, :multiple_tests_fail)
#	assert_equal(:passed, Branch_enhancement[Deserving_commit_to_branch[error_classification]])
end # deserving_branch
def test_error_classification
	Error_classification.fetch(MinimalMaturity.get_error_score!, :multiple_tests_fail)
end # error_classification
def test_deserving_commit_to_branch
	TestMaturity::Push_branch[MinimalMaturity.error_classification]
end # deserving_commit_to_branch
def test_expected_next_commit_branch
	TestMaturity::Pull_branch[MinimalMaturity.error_classification]
end # expected_next_commit_branch
def test_branch_enhancement
	assert_instance_of(Symbol, MinimalMaturity.deserving_commit_to_branch)
#	Branch::Branch_enhancement[MinimalMaturity.deserving_commit_to_branch]
end # branch_enhancement
end # TestMaturity
class UnitMaturityTest < TestCase
#include DefaultTests
include Repository::Examples
def test_DefinitionalConstants
end # DefinitionalConstants
include UnitMaturity::Examples
def test_diff_command?
	filename=Most_stable_file
	branch_index=Branch.branch_index?(This_code_repository.current_branch_name?.to_sym)
	refute_nil(branch_index)
	branch_string = Branch.branch_symbol?(branch_index).to_s
	git_command = "diff --summary --shortstat #{branch_string} -- " + filename
	diff_run = This_code_repository.git_command(git_command)
#	diff_run.assert_post_conditions
	assert_instance_of(ShellCommands, diff_run)
	assert_operator(diff_run.output.size, :==, 0)
	message="diff_run=#{diff_run.inspect}"
	assert_equal('', diff_run.output, message)
	message="diff_run=#{diff_run.inspect}"
	assert_equal('', TestUnitMaturity.diff_command?(Most_stable_file, branch_index).output)
end # diff_command?
def test_working_different_from?
	current_branch_index=Branch.branch_index?(This_code_repository.current_branch_name?.to_sym)
	assert_equal('', TestUnitMaturity.diff_command?(Most_stable_file, current_branch_index).output)
	assert_equal(false, TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index))
#	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 1))
#	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 2))
#	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 3))
#	assert(!TestUnitMaturity.working_different_from?(Most_stable_file, current_branch_index + 4))
	filename=File_not_in_oldest_branch
	diff_run=This_code_repository.git_command("diff --summary --shortstat origin/master -- "+filename)
	refute_equal([], diff_run.output.split("\n"), diff_run.inspect)
	assert_equal(2, diff_run.output.split("\n").size, diff_run.inspect)
#	assert_nil(TestUnitMaturity.working_different_from?(File_not_in_oldest_branch,-2))
end #working_different_from?
def test_differences?
	range=-2..0
	filename=File_not_in_oldest_branch
#	assert_nil(TestUnitMaturity.working_different_from?(File_not_in_oldest_branch,-2))
	differences=range.map do |branch_index|
		TestUnitMaturity.working_different_from?(filename, branch_index)
	end #map
#	assert_nil(differences[0])
#	assert_nil(TestUnitMaturity.differences?(File_not_in_oldest_branch, range)[0], message)
#	assert_equal([false, false, false], TestUnitMaturity.differences?(Most_stable_file, range), message)
end #differences?
def test_scan_verions?
	filename=File_not_in_oldest_branch
	range=-2..3
	direction=:last
	differences=TestUnitMaturity.differences?(filename, range)
	different_indices=[]
	existing_indices=[]
	range.zip(differences) do |index,s| 
		case s
		when true then
			different_indices<<index
			existing_indices<<index
		when nil then
		when false then
			existing_indices<<index
		end #case
	end #zip
	scan_verions=case direction
	when :first then 
		(different_indices+[existing_indices[-1]]).min
	when :last then 
		([existing_indices[0]]+different_indices).max
	else
		raise 
	end #case
	message="filename="+filename.inspect
	message+="\nrange="+range.inspect
	message+="\ndirection="+direction.inspect
	message+="\ndifferences="+differences.inspect
	message+="\ndifferent_indices="+different_indices.inspect
	message+="\nexisting_indices="+existing_indices.inspect
	message+="\nscan_verions="+scan_verions.inspect
#	assert_equal(existing_indices[0], scan_verions, message)
	filename=Most_stable_file
#	assert_equal(First_slot_index, TestUnitMaturity.scan_verions?(filename, range, :last), message)
#	assert_equal(Last_slot_index, TestUnitMaturity.scan_verions?(filename, First_slot_index..Last_slot_index, :first), message)
end #scan_verions?
def test_bracketing_versions?
	filename=Most_stable_file
	current_index=0
	left_index=TestUnitMaturity.scan_verions?(filename, Branch::First_slot_index..current_index, :last)
	right_index=TestUnitMaturity.scan_verions?(filename, current_index+1..Branch::Last_slot_index, :first)
#	assert_equal(First_slot_index, TestUnitMaturity.scan_verions?(filename, Branch::First_slot_index..current_index, :last))
#	assert_equal(Branch::First_slot_index, left_index)
#	assert(!TestUnitMaturity.working_different_from?(filename, 1))
#	assert_equal(false, TestUnitMaturity.working_different_from?(filename, 1))
#	assert_equal(Branch::Last_slot_index, right_index)
#	assert_equal([Branch::First_slot_index, Branch::Last_slot_index], TestUnitMaturity.bracketing_versions?(filename, 0))
end #bracketing_versions?
end # UnitMaturity

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
TestMaturity = UnitMaturity
#include DefaultTests
include Repository::Examples
include Branch::Constants
include TestRun::Constants
#include Branch::Examples
include UnitMaturity::Examples
def test_DefinitionalConstants
	Error_classification.each_pair do |key, value|
		executable_file = Unit.data_source_directories + '/test_maturity/' + value.to_s + '.rb'
		assert(File.exists?(executable_file), executable_file.inspect)
		message = 'executable_file = ' + executable_file
#		assert_path_exists(executable_file)
		test_run = TestRun.new(test_executable: TestExecutable.new(executable_file: executable_file))
#		assert_equal(key, test_run.error_score?, test_run.inspect + message)
	end #each
end # DefinitionalConstants
def test_revison_tag?
	assert_equal('-r master', TestMaturity.revison_tag?(-1))
	assert_equal('-r passed', TestMaturity.revison_tag?(0))
	assert_equal('-r testing', TestMaturity.revison_tag?(1))
	assert_equal('-r edited', TestMaturity.revison_tag?(2))
	assert_equal('-r stash', TestMaturity.revison_tag?(3))
	assert_equal('-r stash~1', TestMaturity.revison_tag?(4))
	assert_equal('-r stash~2', TestMaturity.revison_tag?(5))
	assert_equal('-r work_flow', TestMaturity.revison_tag?(-3))
	assert_equal('-r origin/master', TestMaturity.revison_tag?(-4))
end # revison_tag?
def test_merge_range
	assert_equal(1..2, TestMaturity.merge_range(:passed))
	assert_equal(2..2, TestMaturity.merge_range(:testing))
	assert_equal(3..2, TestMaturity.merge_range(:edited))
	assert_equal(0..2, TestMaturity.merge_range(:master))
end # merge_range
def test_branch_symbol?
	assert_equal(:master, TestMaturity.branch_symbol?(-1))
	assert_equal(:passed, TestMaturity.branch_symbol?(0))
	assert_equal(:testing, TestMaturity.branch_symbol?(1))
	assert_equal(:edited, TestMaturity.branch_symbol?(2))
	assert_equal(:stash, TestMaturity.branch_symbol?(3))
	assert_equal(:'stash~1', TestMaturity.branch_symbol?(4))
	assert_equal(:'stash~2', TestMaturity.branch_symbol?(5))
	assert_equal(:work_flow, TestMaturity.branch_symbol?(-3))
	assert_equal(:tax_form, TestMaturity.branch_symbol?(-2))
	assert_equal(:'origin/master', TestMaturity.branch_symbol?(-4))
end # branch_symbol?
def test_branch_index?
	assert_equal(0, UnitMaturity.branch_index?(:passed))
	assert_equal(1, TestMaturity.branch_index?(:testing))
	assert_equal(2, TestMaturity.branch_index?(:edited))
	assert_equal(3, TestMaturity.branch_index?(:stash))
	assert_equal(4, TestMaturity.branch_index?(:'stash~1'))
	assert_equal(5, TestMaturity.branch_index?(:'stash~2'))
	assert_equal(-1, TestMaturity.branch_index?(:master))
	assert_equal(-3, TestMaturity.branch_index?(:'work_flow'))
	assert_equal(-2, TestMaturity.branch_index?(:'tax_form'))
	assert_equal(-4, TestMaturity.branch_index?(:'origin/master'))
	assert_equal(nil, TestMaturity.branch_index?('/home/greg'))
end # branch_index?
def test_deserving_branch?
	error_classifications=[]
	branch_compressions=[]
	branch_enhancements=[]
	TestMaturity.example_files.each_pair do |executable_file, expected_error_score|
		test_run = TestRun.new(test_executable: TestExecutable.new(executable_file: executable_file))
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
end #deserving_branch
#include TestMaturity::DefinitionalConstants
end # TestMaturity
class UnitMaturityTest < TestCase
TestMaturity = UnitMaturity
include Repository::Examples
def test_DefinitionalConstants
end # DefinitionalConstants
include UnitMaturity::Examples
def test_diff_command?
	filename=Most_stable_file
	branch_index=TestMaturity.branch_index?(This_code_repository.current_branch_name?.to_sym)
	refute_nil(branch_index)
	branch_string = TestMaturity.branch_symbol?(branch_index).to_s
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
	current_branch_index=TestMaturity.branch_index?(This_code_repository.current_branch_name?.to_sym)
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
	left_index=TestUnitMaturity.scan_verions?(filename, First_slot_index..current_index, :last)
	right_index=TestUnitMaturity.scan_verions?(filename, current_index+1..Last_slot_index, :first)
#	assert_equal(First_slot_index, TestUnitMaturity.scan_verions?(filename, First_slot_index..current_index, :last))
#	assert_equal(First_slot_index, left_index)
#	assert(!TestUnitMaturity.working_different_from?(filename, 1))
#	assert_equal(false, TestUnitMaturity.working_different_from?(filename, 1))
#	assert_equal(Last_slot_index, right_index)
#	assert_equal([First_slot_index, Last_slot_index], TestUnitMaturity.bracketing_versions?(filename, 0))
end #bracketing_versions?
end # UnitMaturity

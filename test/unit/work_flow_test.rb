###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/work_flow.rb'

class WorkFlowTest < TestCase
include DefaultTests
#include WorkFlow
#extend WorkFlow::ClassMethods
include WorkFlow::Examples
def test_branch_symbol?
	assert_equal(:master, WorkFlow.branch_symbol?(-1))
	assert_equal(:passed, WorkFlow.branch_symbol?(0))
	assert_equal(:testing, WorkFlow.branch_symbol?(1))
	assert_equal(:edited, WorkFlow.branch_symbol?(2))
	assert_equal(:stash, WorkFlow.branch_symbol?(3))
end #branch_symbol?
def test_revison_tag
	assert_equal('-r master', WorkFlow.revison_tag(-1))
	assert_equal('-r passed', WorkFlow.revison_tag(0))
	assert_equal('-r testing', WorkFlow.revison_tag(1))
	assert_equal('-r edited', WorkFlow.revison_tag(2))
	assert_equal('-r stash', WorkFlow.revison_tag(3))
end #revison_tag
def test_merge_range
	assert_equal(1..2, WorkFlow.merge_range(:passed))
	assert_equal(2..2, WorkFlow.merge_range(:testing))
	assert_equal(3..2, WorkFlow.merge_range(:edited))
end #merge_range
def test_initialize
	te=RelatedFile.new(TestFile)
	assert_not_nil(te)
	wf=WorkFlow.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestWorkFlow.related_files.edit_files, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
	assert_include(TestWorkFlow.related_files.edit_files, TestFile, "TestWorkFlow.related_files=#{TestWorkFlow.related_files.inspect}")
end #initialize
def test_version_comparison
	assert_equal('', TestWorkFlow.version_comparison([]))
end #version_comparison
def test_working_different_from?
	filename='test/unit/minimal2_test.rb'
	branch_index=WorkFlow::Branch_enhancement.index(TestWorkFlow.repository.current_branch_name?.to_sym)
	diff_run=TestWorkFlow.repository.git_command("diff --summary --shortstat #{WorkFlow::Branch_enhancement[branch_index]} -- "+filename)
	assert_instance_of(ShellCommands, diff_run)
	assert_operator(diff_run.output.size, :==, 0)
	message="diff_run=#{diff_run.inspect}"
	assert_equal('', diff_run.output, message)
	assert(!TestWorkFlow.working_different_from?(filename, 0), message)
	assert(!TestWorkFlow.working_different_from?(filename, 0))
	assert(!TestWorkFlow.working_different_from?(filename, 1))
	assert(!TestWorkFlow.working_different_from?(filename, 2))
	assert(!TestWorkFlow.working_different_from?(filename, 3))
	assert(!TestWorkFlow.working_different_from?(filename, -1))
	assert(!TestWorkFlow.working_different_from?('test/long_test/repository_test.rb',-1))
end #working_different_from?
def test_different_indices?
	range=1..3
	filename='test/unit/minimal2_test.rb'
	assert_equal([], TestWorkFlow.different_indices?(filename, range))
end #different_indices?
def test_scan_verions?
	range=-1..3
	filename='test/unit/minimal2_test.rb'
	assert_equal(-1, TestWorkFlow.scan_verions?(filename, range, :last))
	assert_equal(3, TestWorkFlow.scan_verions?(filename, range, :first))
	
end #scan_verions?
def test_bracketing_versions?
	filename='test/unit/minimal2_test.rb'
	current_index=0
	left_index=TestWorkFlow.scan_verions?(filename, -1..current_index, :last)
	right_index=TestWorkFlow.scan_verions?(filename, current_index+1..Last_slot_index, :first)
	assert_equal(-1, TestWorkFlow.scan_verions?(filename, -1..current_index, :last))
	assert_equal(-1, left_index)
	assert(!TestWorkFlow.working_different_from?(filename, 1))
	assert_equal(false, TestWorkFlow.working_different_from?(filename, 1))
	assert_equal(Last_slot_index, right_index)
	assert_equal([-1, 3], TestWorkFlow.bracketing_versions?(filename, 0))
end #bracketing_versions?
def test_goldilocks
	assert_include(WorkFlow::Branch_enhancement, TestWorkFlow.repository.current_branch_name?.to_sym)
	current_index=WorkFlow::Branch_enhancement.index(TestWorkFlow.repository.current_branch_name?.to_sym)
	filename='test/unit/minimal2_test.rb'
	left_index,right_index=TestWorkFlow.bracketing_versions?(filename, current_index)
	assert_operator(current_index, :<, right_index)
	message="left_index=#{left_index}, right_index=#{right_index}"
	assert_operator(left_index, :<=, current_index, message)
	assert_operator(left_index, :<, right_index, message)
	assert_data_file(filename)
	assert_match(/ -t /, TestWorkFlow.goldilocks(filename))
	relative_filename=Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
	assert_match(/#{filename}/, TestWorkFlow.goldilocks(filename))
	assert_data_file(relative_filename)
end #goldilocks
include WorkFlow::Examples
def test_execute
	assert_include(TestWorkFlow.related_files.edit_files, TestFile)
#	assert_equal('', TestWorkFlow.version_comparison)
#	assert_equal('', TestWorkFlow.test_files)
end #execute
def test_functional_parallelism
	edit_files=TestWorkFlow.related_files.edit_files
	assert_operator(TestWorkFlow.functional_parallelism(edit_files).size, :>=, 1)
	assert_operator(TestWorkFlow.functional_parallelism.size, :<=, 4)
end #functional_parallelism
def test_test_files
	assert_equal('', TestWorkFlow.test_files([]))
# 	assert_equal(' -t /home/greg/Desktop/src/Open-Table-Explorer/app/models/work_flow.rb /home/greg/Desktop/src/Open-Table-Explorer/test/unit/work_flow_test.rb', TestWorkFlow.test_files([TestWorkFlow.edit_files]))
end #test_files
def test_minimal_comparison
	assert_equal(' -t app/models/work_flow.rb app/models/minimal2.rb -t test/unit/work_flow_test.rb test/unit/minimal2_test.rb', TestWorkFlow.minimal_comparison?)
	assert_equal(' -t app/models/regexp_parse.rb app/models/minimal4.rb -t test/unit/regexp_parse_test.rb test/unit/minimal4_test.rb -t test/assertions/regexp_parse_assertions.rb test/assertions/minimal4_assertions.rb -t test/unit/regexp_parse_assertions_test.rb test/unit/minimal4_assertions_test.rb', WorkFlow.new('test/unit/regexp_parse_test.rb').minimal_comparison?)
end #minimal_comparison
def test_deserving_branch?
	error_classifications=[]
	branch_compressions=[]
	branch_enhancements=[]
	Repository::Error_classification.each_pair do |key, value|
		executable=data_source_directory?('Repository')+'/'+value.to_s+'.rb'
		error_score=TestWorkFlow.repository.error_score?(executable)
		assert_equal(key, error_score, TestWorkFlow.repository.recent_test.inspect)
		error_classification=Repository::Error_classification.fetch(error_score, :multiple_tests_fail)
		error_classifications<<error_classification
		branch_compression=Branch_compression[error_classification]
		branch_compressions<<branch_compression
		branch_enhancement=Branch_enhancement[branch_compression]
		branch_enhancements<<branch_enhancement
	end #each
	assert_equal(4, error_classifications.uniq.size, error_classifications.inspect)
	assert_equal(3, branch_compressions.uniq.size, branch_compressions.inspect)
	assert_equal(3, branch_enhancements.uniq.size, branch_enhancements.inspect)
#	error_classification=Error_classification.fetch(error_score, :multiple_tests_fail)
#	assert_equal(:passed, Branch_enhancement[Branch_compression[error_classification]])
end #deserving_branch
def test_merge
	TestWorkFlow.repository.testing_superset_of_passed.assert_post_conditions
	TestWorkFlow.repository.edited_superset_of_testing.assert_post_conditions
	TestWorkFlow.merge(:edited, :passed) # not too long or too dangerous
end #merge
def test_local_assert_post_conditions
		TestWorkFlow.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestWorkFlow.assert_pre_conditions
end #assert_pre_conditions
end #WorkFlow

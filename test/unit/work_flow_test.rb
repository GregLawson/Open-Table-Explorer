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
def test_revison_tag
	assert_equal('-r compiles', WorkFlow.revison_tag(:compiles))
end #revison_tag
def test_initialize
	te=RelatedFile.new(TestFile)
	assert_not_nil(te)
	wf=WorkFlow.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestWorkFlow.related_files.edit_files, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
	assert_include(TestWorkFlow.related_files.edit_files, TestFile, "TestWorkFlow.related_files=#{TestWorkFlow.related_files.inspect}")
end #initialize
def test_goldilocks
	assert_include(WorkFlow::Branch_enhancement, TestWorkFlow.repository.current_branch_name?.to_sym)
	current_index=WorkFlow::Branch_enhancement.index(TestWorkFlow.repository.current_branch_name?.to_sym)
	last_slot_index=WorkFlow::Branch_enhancement.size-1
	right_index=[current_index, last_slot_index].min
	left_index=right_index-1 
	relative_filename=	Pathname.new(TestFile).relative_path_from(Pathname.new(Dir.pwd)).to_s
	assert_data_file(relative_filename)
	assert_include(['test/unit/work_flow_test.rb', 'work_flow_test.rb'], relative_filename)
	assert_match(/ -t /, TestWorkFlow.goldilocks(TestFile))
	assert_match(/#{relative_filename}/, TestWorkFlow.goldilocks(TestFile))
	assert_match(/#{TestWorkFlow.repository.current_branch_name?}/, TestWorkFlow.goldilocks(TestFile))
end #goldilocks
include WorkFlow::Examples
def test_execute
	assert_include(TestWorkFlow.related_files.edit_files, TestFile)
#	assert_equal('', TestWorkFlow.version_comparison)
#	assert_equal('', TestWorkFlow.test_files)
end #execute
def test_test_files
	assert_equal('', TestWorkFlow.test_files([]))
# 	assert_equal(' -t /home/greg/Desktop/src/Open-Table-Explorer/app/models/work_flow.rb /home/greg/Desktop/src/Open-Table-Explorer/test/unit/work_flow_test.rb', TestWorkFlow.test_files([TestWorkFlow.edit_files]))
end #test_files
def test_version_comparison
	assert_equal('', TestWorkFlow.version_comparison([]))
end #version_comparison
def test_functional_parallelism
	edit_files=TestWorkFlow.related_files.edit_files
	assert_operator(TestWorkFlow.functional_parallelism(edit_files).size, :>=, 1)
	assert_operator(TestWorkFlow.functional_parallelism.size, :<=, 4)
end #functional_parallelism
def test_minimal_comparison
	assert_equal(' -t app/models/work_flow.rb app/models/minimal2.rb -t test/unit/work_flow_test.rb test/unit/minimal2_test.rb', TestWorkFlow.minimal_comparison?)
	assert_equal(' -t app/models/regexp_parse.rb app/models/minimal4.rb', WorkFlow.new('test/unit/regexp_parse_test.rb').minimal_comparison?)
end #minimal_comparison
def test_local_assert_post_conditions
		TestWorkFlow.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestWorkFlow.assert_pre_conditions
end #assert_pre_conditions
end #WorkFlow

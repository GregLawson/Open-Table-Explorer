require_relative 'test_environment.rb'
require_relative '../../app/models/work_flow.rb'

class WorkFlowTest < TestCase
include DefaultTests
#include WorkFlow
#extend WorkFlow::ClassMethods
include WorkFlow::Examples
def test_revison_tag
	assert_equal('-r compiles', WorkFlow.revison_tag(:compiles))
end #revison_tag
def test_goldilocks
	assert_equal(" -t #{WorkFlow.revison_tag(:master)} #{TestFile} #{TestFile} #{WorkFlow.revison_tag(:compiles)} #{TestFile}", WorkFlow.goldilocks(TestFile))
end #goldilocks
include WorkFlow::Examples
def test_initialize
	te=RelatedFile.new(TestFile)
	assert_not_nil(te)
	wf=WorkFlow.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestWorkFlow.related_files.edit_files, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
	assert_include(TestWorkFlow.related_files.edit_files, TestFile, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
end #initialize
def test_branch
	assert_equal('master', Repo.head.name, Repo.head.inspect)
end #branch
def test_execute
	assert_include(TestWorkFlow.related_files.edit_files, TestFile)
#	assert_equal('', TestWorkFlow.version_comparison)
#	assert_equal('', TestWorkFlow.test_files)
end #execute
def test_test_files
	assert_equal(' -t ', TestWorkFlow.test_files([]))
	assert_equal(' -t '+TestFile, TestWorkFlow.test_files([TestFile]))
end #test_files
def test_version_comparison
	assert_equal(' -t ', TestWorkFlow.test_files([]))
	assert_equal(' -t '+TestFile, TestWorkFlow.test_files([TestFile]))
end #version_comparison
def test_local_assert_post_conditions
		TestWorkFlow.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestWorkFlow.assert_pre_conditions
end #assert_pre_conditions
end #WorkFlow

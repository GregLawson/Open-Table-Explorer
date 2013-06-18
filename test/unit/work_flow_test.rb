require_relative 'test_environment.rb'
require_relative '../../app/models/work_flow.rb'

class WorkFlowTest < TestCase
include DefaultTests
#include WorkFlow
#extend WorkFlow::ClassMethods
def test_revison_tag
	assert_equal('-r compiles', WorkFlow.revison_tag(:compiles))
end #revison_tag
def test_file_versions
	assert_equal(" -t #{WorkFlow.revison_tag(:master)} #{TestFile} #{WorkFlow.revison_tag(:compiles)} #{TestFile} #{WorkFlow.revison_tag(:development)} #{TestFile}", WorkFlow.file_versions(TestFile))
end #file_versions
include WorkFlow::Examples
def test_initialize
	te=TestIntrospection::TestEnvironment.new(TestFile)
	assert_not_nil(te)
	wf=WorkFlow.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestWorkFlow.test_environment.pathnames?)
	existance=TestWorkFlow.test_environment.pathnames?.map do |p|
		[File.exists?(p), p]
	end #map
	puts 'existance='+existance.inspect
	assert_not_empty(TestWorkFlow.edit_files, "TestWorkFlow.test_environment.pathnames?=#{TestWorkFlow.test_environment.pathnames?}")
	assert_include(TestWorkFlow.edit_files, TestFile, "existance=#{existance}\nTestWorkFlow.test_environment.pathnames=#{TestWorkFlow.test_environment.pathnames?}")
end #initialize
def test_execute
	assert_include(TestWorkFlow.edit_files, TestFile)
#	assert_equal('', TestWorkFlow.version_comparison)
#	assert_equal('', TestWorkFlow.test_files)
end #execute
def test_test_files
	assert_equal('', TestWorkFlow.test_files([]))
	assert_equal(TestFile, TestWorkFlow.test_files([TestFile]))
end #test_files
def test_version_comparison
	assert_equal('', TestWorkFlow.test_files([]))
	assert_equal(TestFile, TestWorkFlow.test_files([TestFile]))
end #version_comparison
end #WorkFlow

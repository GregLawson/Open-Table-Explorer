###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
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
def test_all
	pattern = FilePattern.find_by_name(:test)
	glob = FilePattern.new(pattern).pathname_glob
	tests=Dir[glob]
	x=tests[0]
	y=tests[1]
	message="File.mtime(#{x})="+File.mtime(x).inspect+", File.mtime(#{y})="+File.mtime(y).to_s
		assert_pathname_exists(x)
		assert_pathname_exists(y)
		assert_instance_of(Time, File.mtime(x))
		assert_instance_of(Time, File.mtime(y))
		assert_respond_to(File.mtime(x), :>)
#rare_fail		assert_operator(File.mtime(x), :!=, File.mtime(y),"x="+x+"\ny="+y)
#rare_fail		assert(File.mtime(x) != File.mtime(y))	
#rare_fail		refute_equal(0, File.mtime(x) <=> File.mtime(y), message)	
	tests=Dir[glob].sort do |x,y|
		assert_pathname_exists(x)
		assert_pathname_exists(y)
		assert_instance_of(Time, File.mtime(x))
		assert_instance_of(Time, File.mtime(y))
		assert_respond_to(File.mtime(x), :>)
		File.mtime(x) <=> File.mtime(y)
	end #sort
	puts tests.inspect if $VERBOSE
end #all
def test_initialize
	te=Unit.new(TestFile)
	refute_nil(te)
	wf=WorkFlow.new(TestFile)
	refute_nil(wf)
	refute_empty(TestWorkFlow.related_files.edit_files, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
	assert_include(TestWorkFlow.related_files.edit_files, TestFile, "TestWorkFlow.related_files=#{TestWorkFlow.related_files.inspect}")
end #initialize
include WorkFlow::Examples
def test_test
#(executable = @related_files.model_test_pathname?)
end # test
def test_loop
#(executable = @related_files.model_test_pathname?)
end # test
def test_unit_test
#	executable = @related_files.model_test_pathname?
end # unit_test
def test_local_assert_post_conditions
		TestWorkFlow.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestWorkFlow.assert_pre_conditions
end #assert_pre_conditions
def test_help_command
	help_run=ShellCommands.new('ruby  script/work_flow.rb --help').assert_post_conditions
	assert_equal('', help_run.errors)
end #  help_command
def test_merge_command
	help_run=ShellCommands.new('ruby  script/work_flow.rb --merge-down').assert_post_conditions
	assert_equal('', help_run.errors)
end #  merge_command

def test_deserve_command
	value = :testing
	executable = Repository::Repository_Unit.data_sources_directory?+'/'+value.to_s+'.rb'
	deserve_run = ShellCommands.new('ruby  script/work_flow.rb --deserve ' + executable)
	error_score = TestRun.error_score?(executable)
#	assert_equal(1, error_score, deserve_run.inspect)
#	assert_match(/deserving branch=testing/, deserve_run.output, deserve_run.inspect)
end #  deserve_command
def test_related_command
#	related_run=ShellCommands.new('ruby  script/work_flow.rb --related '+$0).assert_post_conditions
#	assert_match(/#{$0}/, related_run.output)
end #  related_command
end # WorkFlow

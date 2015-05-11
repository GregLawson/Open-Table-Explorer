###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/interactive_bottleneck.rb'

class InteractiveBottleneckTest < TestCase
include DefaultTests
#include InteractiveBottleneck
#extend InteractiveBottleneck::ClassMethods
include InteractiveBottleneck::Examples
def test_initialize
	te=Unit.new(TestFile)
	assert_not_nil(te)
	wf=InteractiveBottleneck.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestInteractiveBottleneck.related_files.edit_files, "TestInteractiveBottleneck.related_files.edit_files=#{TestInteractiveBottleneck.related_files.edit_files}")
	assert_include(TestInteractiveBottleneck.related_files.edit_files, TestFile, "TestInteractiveBottleneck.related_files=#{TestInteractiveBottleneck.related_files.inspect}")
end #initialize
include InteractiveBottleneck::Examples
def test_merge_conflict_recovery
end # merge_conflict_recovery
def test_merge
	TestInteractiveBottleneck.repository.testing_superset_of_passed.assert_post_conditions
	TestInteractiveBottleneck.repository.edited_superset_of_testing.assert_post_conditions
	TestInteractiveBottleneck.merge(:edited, :testing) # not too long or too dangerous
end #merge
def test_merge_down
#(deserving_branch = @repository.current_branch_name?)
end # merge_down
def test_script_deserves_commit!
#(deserving_branch)
end # script_deserves_commit!
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
		TestInteractiveBottleneck.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestInteractiveBottleneck.assert_pre_conditions
end #assert_pre_conditions

def test_related_command
#	related_run=ShellCommands.new('ruby  script/work_flow.rb --related '+$0).assert_post_conditions
#	assert_match(/#{$0}/, related_run.output)
end #  related_command
end # InteractiveBottleneck

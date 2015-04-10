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
#rare_fail		assert_not_equal(0, File.mtime(x) <=> File.mtime(y), message)	
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
def test_merge_range
	assert_equal(1..2, WorkFlow.merge_range(:passed))
	assert_equal(2..2, WorkFlow.merge_range(:testing))
	assert_equal(3..2, WorkFlow.merge_range(:edited))
	assert_equal(0..2, WorkFlow.merge_range(:master))
end #merge_range
def test_initialize
	te=Unit.new(TestFile)
	assert_not_nil(te)
	wf=WorkFlow.new(TestFile)
	assert_not_nil(wf)
	assert_not_empty(TestWorkFlow.related_files.edit_files, "TestWorkFlow.related_files.edit_files=#{TestWorkFlow.related_files.edit_files}")
	assert_include(TestWorkFlow.related_files.edit_files, TestFile, "TestWorkFlow.related_files=#{TestWorkFlow.related_files.inspect}")
end #initialize
def test_version_comparison
	assert_equal('', TestWorkFlow.version_comparison([]))
end #version_comparison
def test_goldilocks
	assert_not_nil(WorkFlow.branch_index?(TestWorkFlow.repository.current_branch_name?.to_sym))
#	assert_include(WorkFlow::Branch_enhancement, TestWorkFlow.repository.current_branch_name?.to_sym)
	current_index=WorkFlow.branch_index?(TestWorkFlow.repository.current_branch_name?.to_sym)
	filename=Most_stable_file
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
def test_test_files
	assert_equal('', TestWorkFlow.test_files([]))
# 	assert_equal(' -t /home/greg/Desktop/src/Open-Table-Explorer/app/models/work_flow.rb /home/greg/Desktop/src/Open-Table-Explorer/test/unit/work_flow_test.rb', TestWorkFlow.test_files([TestWorkFlow.edit_files]))
end #test_files
def test_minimal_comparison
	assert_equal(' -t app/models/work_flow.rb app/models/minimal2.rb -t test/unit/work_flow_test.rb test/unit/minimal2_test.rb -t script/work_flow.rb script/minimal2.rb -t test/integration/work_flow_test.rb test/integration/minimal2_test.rb -t test/long_test/work_flow_test.rb test/long_test/minimal2_test.rb -t test/assertions/work_flow_assertions.rb test/assertions/minimal2_assertions.rb -t test/unit/work_flow_assertions_test.rb test/unit/minimal2_assertions_test.rb -t log/library/work_flow.log log/library/minimal2.log -t log/assertions/work_flow.log log/assertions/minimal2.log -t log/integration/work_flow.log log/integration/minimal2.log -t log/long/work_flow.log log/long/minimal2.log -t test/data_sources/work_flow test/data_sources/minimal2', TestWorkFlow.minimal_comparison?)
	assert_equal(' -t app/models/regexp_parse.rb app/models/minimal4.rb -t test/unit/regexp_parse_test.rb test/unit/minimal4_test.rb -t script/regexp_parse.rb script/minimal4.rb -t test/integration/regexp_parse_test.rb test/integration/minimal4_test.rb -t test/long_test/regexp_parse_test.rb test/long_test/minimal4_test.rb -t test/assertions/regexp_parse_assertions.rb test/assertions/minimal4_assertions.rb -t test/unit/regexp_parse_assertions_test.rb test/unit/minimal4_assertions_test.rb -t log/library/regexp_parse.log log/library/minimal4.log -t log/assertions/regexp_parse.log log/assertions/minimal4.log -t log/integration/regexp_parse.log log/integration/minimal4.log -t log/long/regexp_parse.log log/long/minimal4.log -t test/data_sources/regexp_parse test/data_sources/minimal4', WorkFlow.new('test/unit/regexp_parse_test.rb').minimal_comparison?)
end #minimal_comparison
def test_deserving_branch?
	error_classifications=[]
	branch_compressions=[]
	branch_enhancements=[]
	Repository::Error_classification.each_pair do |key, value|
		executable=data_source_directory?('repository')+'/'+value.to_s+'.rb'
		error_score = TestWorkFlow.repository.error_score?(executable)
		assert_equal(key, error_score, TestWorkFlow.repository.recent_test.inspect)
		error_score=TestWorkFlow.repository.error_score?(executable)
#		assert_equal(key, error_score, TestWorkFlow.repository.recent_test.inspect)
		error_classification=Repository::Error_classification.fetch(error_score, :multiple_tests_fail)
		error_classifications<<error_classification
		branch_compression = Deserving_commit_to_branch[error_classification]
		branch_compressions<<branch_compression
		branch_enhancement=Branch_enhancement[branch_compression]
		branch_enhancements<<branch_enhancement
	end #each
	assert_equal(4, error_classifications.uniq.size, error_classifications.inspect)
	assert_equal(3, branch_compressions.uniq.size, branch_compressions.inspect)
	assert_equal(3, branch_enhancements.uniq.size, branch_enhancements.inspect)
#	error_classification=Error_classification.fetch(error_score, :multiple_tests_fail)
#	assert_equal(:passed, Branch_enhancement[Deserving_commit_to_branch[error_classification]])
end #deserving_branch
def test_merge_conflict_recovery
end # merge_conflict_recovery
def test_merge
	TestWorkFlow.repository.testing_superset_of_passed.assert_post_conditions
	TestWorkFlow.repository.edited_superset_of_testing.assert_post_conditions
	TestWorkFlow.merge(:edited, :testing) # not too long or too dangerous
end #merge
def test_edit
#(context = nil)
end # edit
def test_split
#(executable, new_base_name)
end # split
def test_minimal_edit
end # minimal_edit
def test_emacs
#(executable = @related_files.model_test_pathname?)
end # emacs
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
	error_score=TestWorkFlow.repository.error_score?(executable)
#	assert_equal(1, error_score, deserve_run.inspect)
#	assert_match(/deserving branch=testing/, deserve_run.output, deserve_run.inspect)
end #  deserve_command
def test_related_command
#	related_run=ShellCommands.new('ruby  script/work_flow.rb --related '+$0).assert_post_conditions
#	assert_match(/#{$0}/, related_run.output)
end #  related_command
end #WorkFlow

###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/work_flow.rb'

class EditorTest < TestCase
include DefaultTests
#include Editor
#extend Editor::ClassMethods
include Editor::Examples
include UnitMaturity::Examples
def test_initializes
	te=Unit.new(TestEditor.executable.executable_file)
	assert_not_nil(te)
	wf=Editor.new(TestEditor.executable)
	assert_not_nil(wf)
	assert_not_empty(TestEditor.executable.unit.edit_files, "TestEditor.executable.unit.edit_files=#{TestEditor.executable.unit.edit_files}")
	assert_include(TestEditor.executable.unit.edit_files, TestEditor.executable.file, "TestEditor.executable.unit=#{TestEditor.executable.unit.inspect}")
end #initialize
def test_version_comparison
	assert_equal('', TestEditor.version_comparison([]))
end #version_comparison
def test_goldilocks
	assert_not_nil(UnitMaturity.branch_index?(TestEditor.repository.current_branch_name?.to_sym))
#	assert_include(Editor::Branch_enhancement, TestEditor.repository.current_branch_name?.to_sym)
	current_index=UnitMaturity.branch_index?(TestEditor.repository.current_branch_name?.to_sym)
	filename= Most_stable_file
	left_index,right_index= TestEditor.unit_maturity.bracketing_versions?(filename, current_index)
	assert_operator(current_index, :<, right_index)
	message="left_index=#{left_index}, right_index=#{right_index}"
	assert_operator(left_index, :<=, current_index, message)
	assert_operator(left_index, :<, right_index, message)
	assert_data_file(filename)
	assert_match(/ -t /, TestEditor.goldilocks(filename))
	relative_filename=Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
	assert_match(/#{filename}/, TestEditor.goldilocks(filename))
	assert_data_file(relative_filename)
end #goldilocks
include Editor::Examples
def test_test_files
	assert_equal('', TestEditor.test_files([]))
# 	assert_equal(' -t /home/greg/Desktop/src/Open-Table-Explorer/app/models/work_flow.rb /home/greg/Desktop/src/Open-Table-Explorer/test/unit/work_flow_test.rb', TestEditor.test_files([TestEditor.edit_files]))
end #test_files
def test_minimal_comparison
	assert_equal(' -t app/models/editor.rb app/models/minimal2.rb -t test/unit/editor_test.rb test/unit/minimal2_test.rb', TestEditor.minimal_comparison?)
#	assert_equal(' -t app/models/work_flow.rb app/models/minimal2.rb -t test/unit/work_flow_test.rb test/unit/minimal2_test.rb -t script/work_flow.rb script/minimal2.rb -t test/integration/work_flow_test.rb test/integration/minimal2_test.rb -t test/long_test/work_flow_test.rb test/long_test/minimal2_test.rb -t test/assertions/work_flow_assertions.rb test/assertions/minimal2_assertions.rb -t test/unit/work_flow_assertions_test.rb test/unit/minimal2_assertions_test.rb -t log/library/work_flow.log log/library/minimal2.log -t log/assertions/work_flow.log log/assertions/minimal2.log -t log/integration/work_flow.log log/integration/minimal2.log -t log/long/work_flow.log log/long/minimal2.log -t test/data_sources/work_flow test/data_sources/minimal2', TestEditor.minimal_comparison?)
#	assert_equal(' -t app/models/regexp_parse.rb app/models/minimal4.rb -t test/unit/regexp_parse_test.rb test/unit/minimal4_test.rb -t script/regexp_parse.rb script/minimal4.rb -t test/integration/regexp_parse_test.rb test/integration/minimal4_test.rb -t test/long_test/regexp_parse_test.rb test/long_test/minimal4_test.rb -t test/assertions/regexp_parse_assertions.rb test/assertions/minimal4_assertions.rb -t test/unit/regexp_parse_assertions_test.rb test/unit/minimal4_assertions_test.rb -t log/library/regexp_parse.log log/library/minimal4.log -t log/assertions/regexp_parse.log log/assertions/minimal4.log -t log/integration/regexp_parse.log log/integration/minimal4.log -t log/long/regexp_parse.log log/long/minimal4.log -t test/data_sources/regexp_parse test/data_sources/minimal4', Editor.new('test/unit/regexp_parse_test.rb').minimal_comparison?)
end #minimal_comparison
def test_edit
#(context = nil)
end # edit
def test_split
#(executable, new_base_name)
end # split
def test_minimal_edit
end # minimal_edit
def test_emacs
#(executable = @executable.unit.model_test_pathname?)
end # emacs
def test_local_assert_post_conditions
		TestEditor.assert_post_conditions
end #assert_post_conditions
def test_local_assert_pre_conditions
		TestEditor.assert_pre_conditions
end #assert_pre_conditions

end # Editor

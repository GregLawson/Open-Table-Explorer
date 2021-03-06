###########################################################################
#    Copyright (C) 2013-16 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/editor.rb'

class EditorTest < TestCase
  # include DefaultTests
  # include Editor
  # extend Editor::ClassMethods
  module Examples
    EditorTestExecutable = TestExecutable.new_from_path(File.expand_path($PROGRAM_NAME))
    TestDiffuse = Diffuse.new(EditorTestExecutable)
    # TestEmacs = Emacs.new(EditorTestExecutable)
  end # Examples
  include Examples
#  include UnitMaturity::Examples
  def test_initializes
    te = Unit.new_from_path(TestDiffuse.test_executable.argument_path)
    refute_nil(te)
    wf = Editor.new(TestDiffuse.test_executable)
    refute_nil(wf)
    refute_empty(TestDiffuse.test_executable.unit.edit_files, "TestDiffuse.test_executable.unit.edit_files=#{TestDiffuse.test_executable.unit.edit_files}")
    assert_instance_of(RepositoryPathname, TestDiffuse.test_executable.argument_path, "TestDiffuse.test_executable.argument_path = #{TestDiffuse.test_executable.argument_path.inspect}")
    assert(TestDiffuse.test_executable.argument_path.exist?, "TestDiffuse.test_executable.argument_path = #{TestDiffuse.test_executable.argument_path.inspect}")
    assert_includes(TestDiffuse.test_executable.unit.edit_files, TestDiffuse.test_executable.argument_path, "TestDiffuse.test_executable.unit=#{TestDiffuse.test_executable.unit.inspect}")
  end # initialize

  def test_version_comparison
    assert_equal('', TestDiffuse.version_comparison([]))
  end # version_comparison

  def test_goldilocks
    refute_nil(Branch.branch_index?(Branch.current_branch_name?(TestDiffuse.test_executable.repository).to_sym))
    #	assert_includes(Editor::Branch_enhancement, TestDiffuse.repository.current_branch_name?.to_sym)
    current_index = Branch.branch_index?(Branch.current_branch_name?(TestDiffuse.test_executable.repository).to_sym)
    most_stable_file = 'test/unit/minimal2_test.rb'.freeze
    filename = most_stable_file
    left_index, right_index = TestDiffuse.unit_maturity.bracketing_versions?(filename, current_index)
    assert_operator(current_index, :<, right_index)
    message = "left_index=#{left_index}, right_index=#{right_index}"
    assert_operator(left_index, :<=, current_index, message)
    assert_operator(left_index, :<, right_index, message)
    assert_data_file(filename)
    assert_match(/ -t /, TestDiffuse.goldilocks(filename))
    relative_filename = Pathname.new(File.expand_path(filename)).relative_path_from(Pathname.new(Dir.pwd)).to_s
    assert_match(/#{filename}/, TestDiffuse.goldilocks(filename))
    assert_data_file(relative_filename)
  end # goldilocks

  def test_test_files
    assert_equal('', TestDiffuse.test_files([]))
    refute_empty(TestDiffuse.test_executable.unit.edit_files)
    parallel_display = TestDiffuse.test_executable.unit.parallel_display
    refute_empty(parallel_display, TestDiffuse.test_executable.unit.edit_files.inspect)
    pairs = TestDiffuse.test_executable.unit.edit_files.map do |file| 
			assert_data_file(file)
			symbol = FilePattern.find_name_from_path(file)
			parallel_symbol = TestDiffuse.test_executable.unit.parallel_display[symbol]
			if parallel_symbol.nil?
				nil
			else
				assert_instance_of(Symbol, parallel_symbol)
				parallel_file = TestDiffuse.test_executable.unit.pathname_pattern?(parallel_symbol)
				assert_data_file(parallel_file)
				' -t ' + Pathname.new(parallel_file).expand_path.relative_path_from(Pathname.new(Dir.pwd)).to_s +
					' ' + Pathname.new(file).expand_path.relative_path_from(Pathname.new(Dir.pwd)).to_s
			end # if
    end.compact # map
    assert_instance_of(Array, pairs, parallel_display.inspect)
    refute_empty(pairs, parallel_display.inspect)
    pairs.join(' ')
    refute_empty(TestDiffuse.test_files, pairs.inspect)
    assert_equal(TestDiffuse.test_files, pairs.join(' '))
    refute_empty(TestDiffuse.test_files(TestDiffuse.test_executable.unit.edit_files), pairs.inspect)
    assert_equal(' -t app/models/editor.rb test/unit/editor_test.rb  -t app/models/editor.rb script/editor.rb', TestDiffuse.test_files(TestDiffuse.test_executable.unit.edit_files))
    editor_command_string = 'ruby -W1 script/editor.rb test_files app/models/editor.rb'
    editor_command_line = ShellCommands.new(editor_command_string)
		text = editor_command_line.output.lines[-1, 1][0]
		assert_instance_of(String, text)
#		assert_match(TestDiffuse.test_files(TestDiffuse.test_executable.unit.edit_files), text)
  end # test_files

  def test_minimal_comparison
    assert_equal(' -t app/models/editor.rb app/models/minimal2.rb -t test/unit/editor_test.rb test/unit/minimal2_test.rb -t script/editor.rb script/minimal2.rb', TestDiffuse.minimal_comparison?)
    #	assert_equal(' -t app/models/work_flow.rb app/models/minimal2.rb -t test/unit/work_flow_test.rb test/unit/minimal2_test.rb -t script/work_flow.rb script/minimal2.rb -t test/integration/work_flow_test.rb test/integration/minimal2_test.rb -t test/long_test/work_flow_test.rb test/long_test/minimal2_test.rb -t test/assertions/work_flow_assertions.rb test/assertions/minimal2_assertions.rb -t test/unit/work_flow_assertions_test.rb test/unit/minimal2_assertions_test.rb -t log/library/work_flow.log log/library/minimal2.log -t log/assertions/work_flow.log log/assertions/minimal2.log -t log/integration/work_flow.log log/integration/minimal2.log -t log/long/work_flow.log log/long/minimal2.log -t test/data_sources/work_flow test/data_sources/minimal2', TestDiffuse.minimal_comparison?)
    #	assert_equal(' -t app/models/regexp_parse.rb app/models/minimal4.rb -t test/unit/regexp_parse_test.rb test/unit/minimal4_test.rb -t script/regexp_parse.rb script/minimal4.rb -t test/integration/regexp_parse_test.rb test/integration/minimal4_test.rb -t test/long_test/regexp_parse_test.rb test/long_test/minimal4_test.rb -t test/assertions/regexp_parse_assertions.rb test/assertions/minimal4_assertions.rb -t test/unit/regexp_parse_assertions_test.rb test/unit/minimal4_assertions_test.rb -t log/library/regexp_parse.log log/library/minimal4.log -t log/assertions/regexp_parse.log log/assertions/minimal4.log -t log/integration/regexp_parse.log log/integration/minimal4.log -t log/long/regexp_parse.log log/long/minimal4.log -t test/data_sources/regexp_parse test/data_sources/minimal4', Editor.new('test/unit/regexp_parse_test.rb').minimal_comparison?)
  end # minimal_comparison

  def test_edit
  end # edit

  def test_split
    # (test_executable, new_base_name)
  end # split

  def test_minimal_edit
  end # minimal_edit

	def test_lost_edit
		filename = $0
		repository = Repository::This_code_repository
		range = 0..10
		lost_code = 'def testing_superset_of_passed'
		lost_edit = TestDiffuse.lost_edit(lost_code, filename = @test_executable.to_s, range = 0..10)
		assert_instance_of(Array, lost_edit)
		lost_edit.each do |commit|
			assert_kind_of(Commit, commit)
			file = Commit.new(initialization_string: commit.sha1 + ':' + filename).show_run.output
			if file.match(lost_code)
				puts 'matched in ' + commit.inspect
			else
				puts 'unmatched in ' + commit.inspect
			end # if
		end # each
	end # lost_edit
  def test_emacs
    # (test_executable = @test_executable.unit.model_test_pathname?)
  end # emacs

  def test_local_assert_post_conditions
    TestDiffuse.assert_post_conditions
  end # assert_post_conditions

  def test_local_assert_pre_conditions
    TestDiffuse.assert_pre_conditions
  end # assert_pre_conditions
end # Editor

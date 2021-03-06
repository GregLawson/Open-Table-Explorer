###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/test_method.rb'
class TestMethodTest < TestCase
  include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  include Parse
  def test_initialize
    test_executable = $PROGRAM_NAME
    grep_test = ShellCommands.new('grep "def test_" ' + test_executable)
    grep_lines = parse_split(grep_test.output, LINES)
    assert_match(Parse_grep, grep_lines[0])
    assert_match(Parse_grep, grep_lines[1])
    assert_match(Parse_grep, grep_lines[2])
    refute_nil(parse(grep_lines, Parse_grep))
    refute_empty(parse(grep_lines, Parse_grep))
    assert_equal(['initialize'], parse(grep_lines, Parse_grep))
    library_file = RelatedFile.new_from_path(test_executable).pathname_pattern?(:model)
    grep_library = ShellCommands.new('grep "def " ' + library_file)
    grep_library_lines = parse(grep_library.output, LINES)
    assert_equal(['initialize'], TestMethod.new(test_executable).method_test_names)
  end # initialize

  def test_untested_methods
    assert_empty(SELF_tested_methods.untested_methods, SELF_tested_methods.inspect)
  end # untested_methods

  def test_tested_nonmethods
    assert_empty(SELF_tested_methods.tested_nonmethods, SELF_tested_methods.inspect)
  end # tested_nonmethods
end # TestMethod

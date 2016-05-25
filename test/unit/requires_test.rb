###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/requires.rb'
class RequireTest < TestCase
  # include DefaultTests
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_DefinitionalConstants
    Executing_requires.assert_relative(Require_line, Relative_regexp)
    assert_match(/require/ * /_relative/.capture(:relative) * /\s+/, Require_line)
    assert_match(/require/ * /_relative/.capture(:relative) * /\s+/ * /['"]/, Require_line)
    assert_match(FilePattern::Relative_pathname_included_regexp.capture(:required_path), Require_line)
    assert_match(/require/ * /_relative/.capture(:relative) * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path), Require_line)
    assert_match(Require_regexp, Require_line)
  end # DefinitionalConstants

  def test_parse_output
    assert_match(Require_regexp, Require_line)
    assert_match(Relative_regexp * /\s+/, Require_line)
    parse = code.capture?(Require_regexp, MatchCapture).output?
    parse_array = code.capture?(Require_regexp, SplitCapture).output?
    assert_equal({}, parse_output(Require_line, capture_class = MatchCapture))
    assert_equal({}, parse_output(Require_line, capture_class = SplitCapture))
    end # parse_output

  def test_scan
    ret = {}
    Unit::Executable.edit_files.each do |file|
      code = IO.read(file)
      parse = code.capture?(Require_regexp, SplitCapture)
      assert_instance_of(SplitCapture, parse, parse.output?)
      assert_instance_of(Array, parse.output?)
      parse.output?.each do |output|
        assert_equal('_relative', output[:relative], output)
      end # each
      assert_instance_of([:relative, :required_path], parse.output?.keys)
      ret = ret.merge(FilePattern.find_from_path(file)[:name] => parse)
    end # each
    assert_instance_of(Hash, ret)
    assert_instance_of(String, Executing_requires.requires[:model])
    assert_equal(ret, Executing_requires.requires)
  end # scan

  def test_scan_file
    path = 'test/unit/test_run_test.rb'
    unit = Unit.new_from_path(path)
    Require.scan(unit)
    assert_equal({}, Require.scan_file(path))
  end # scan_file

  def test_Require_attributes
    assert_instance_of(Hash, Executing_requires.requires)
    assert_includes(Executing_requires.requires.keys, :unit)
  end # values
end # Require

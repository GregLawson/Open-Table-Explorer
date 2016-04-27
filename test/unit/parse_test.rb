###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/parse.rb'
class CaptureTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples
  include GenericColumn::Examples
  # include DefaultTests
  def test_symbolize_keys
    message = ''
    hash_of_array = { a: [1, 2] }
    assert_equal(hash_of_array, Capture.symbolize_keys(hash_of_array), message)
    array_of_hash = [{ a: 1 }, { b: 2 }]
    assert_equal(array_of_hash, Capture.symbolize_keys(array_of_hash), message)
  end # symbolize_keys

  def test_initialize
  end # initialize

  def test_index
    capture = Match_capture
    message = 'capture = ' + capture.inspect
    message += "\n raw_capture = " + capture.raw_captures.inspect
    message += "\n named_captures = " + capture.regexp.named_captures.inspect
    assert_equal('1', Match_capture.raw_captures[1], message)
    assert_equal(['', "* 1\n", '  2'], Match_capture.to_a?, message)
    assert_equal('1', capture[1], message)
    assert_equal("* 1\n", capture.matched_characters?, message)
    assert_equal(nil, capture[2], message)
    assert_equal('1', capture[1], message)
    message += "\ncapture.output? = " + capture.output?.inspect
    assert_equal(Branch_column_answer, capture.named_hash(0), message)
  end # []

  def test_named_hash_variable
    variable = Branch_variable
    hash_offset = 0
    capture_name = variable.name
    message = 'Match_capture = ' + Match_capture.inspect
    indices = Match_capture.regexp.named_captures[capture_name.to_s]
    assert_kind_of(Capture, Match_capture, message)
    assert_instance_of(Regexp, Match_capture.regexp, message)
    assert_instance_of(Hash, Match_capture.regexp.named_captures, message)
    named_captures = Match_capture.regexp.named_captures
    message += "\nnamed_captures = " + named_captures.inspect
    assert_instance_of(Hash, Match_capture.regexp.named_captures, message)
    assert_instance_of(Array, indices, message)
    assert_equal(Branch_column_answer, Match_capture.named_hash_variable(variable, hash_offset))
  end # named_hash_variable

  def test_named_hash_column
    hash_offset = 0
    string = "* 1\n"
    regexp = Branch_regexp
    message = 'regexp.inspect = ' + regexp.inspect
    matchData = string.match(regexp)
    captures = matchData # [1..-1]
    parse_string = MatchCapture.new("* 1\n", Branch_regexp)
    #	column = GenericColumn.new(regexp_index: 0, variable: variable)
    assert_equal(Branch_column_answer, Match_capture.named_hash_column(Branch_column, hash_offset))
  end # named_hash_column

  def test_named_hash
    hash_offset = 0
    string = "* 1\n"
    regexp = Branch_regexp
    message = 'regexp.inspect = ' + regexp.inspect
    matchData = string.match(regexp)
    captures = matchData # [1..-1]
    parse_string = MatchCapture.new("* 1\n", Branch_regexp)
    assert_equal(3, Parse_string.to_a?.size, Parse_string.inspect)
    Parse_string.named_hash
    named_hash = {}
    regexp.names.each do |n| # return named subexpressions
      assert_instance_of(String, n, message)
      column = GenericColumn.new(regexp_index: 0, regexp_name: :branch)
      named_hash[n.to_sym] = captures[n]
    end # each
    assert_equal({ branch: '1' }, named_hash) # return matched subexpressions
    splitData = string.split(regexp)
    captures = splitData # [1..-1]
    named_hash = {}
    assert_equal({ 'branch' => [1] }, regexp.named_captures)
    regexp.named_captures.each_pair do |named_capture, indices| # return named subexpressions
      assert_instance_of(String, named_capture, message)
      #				named_hash = named_hash.merge(column.to_hash(parse_string[indices[0], hash_offset]))
      #		assert_equal(Branch_column_answer, named_hash)
      assert_equal(1, indices[0])
      assert_equal([1], [indices[0]])
      next unless indices.size > 1
      indices[1..-1].each_index do |capture_index, _i|
        named_hash = named_hash.merge(column.to_hash(self[indices[0], hash_offset]))
        assert_equal(named_hash[name], captures[capture_index])
      end # each_index
      # if
    end # each_pair
    assert_equal('', captures[0], regexp.named_captures.inspect + "\n" + captures.inspect)
    #		name=default_name(capture_index).to_sym
    #		named_hash[name]=captures[capture_index]
    #	end #each
    message += regexp.inspect + "\n" + captures.inspect
    assert_equal(Branch_column_answer, Match_capture.named_hash, message)
    #	assert_equal(Branch_hashes, Capture.new(captures, regexp).output?, captures.inspect) # return matched subexpressions
    regexp = /5/.capture(:a) * /6/.capture(:a)
    capture = '56'.capture?(regexp)
    message = 'capture = ' + capture.inspect
    message = 'capture.regexp.named_captures = ' + capture.regexp.named_captures.inspect
    assert_equal([1, 2], capture.regexp.named_captures['a'], message)
    assert_equal('6', capture[:a], message)
    assert_equal('6', capture[2], message)
    assert_equal('5', capture[1], message)
    output = capture.output?
    message += "\noutput = " + output.inspect
    assert_equal('5', Capture.symbolize_keys(output)[:a], message)
    assert_equal('6', capture[:a], message)
  end # named_hash

  def test_MatchCapture_output?
    assert_equal({ branch: '1' }, MatchCapture.new("* 1\n", Branch_regexp).output?) # return matched subexpressions
    assert(Match_capture.success?)
    assert_instance_of(MatchData, Match_capture.raw_captures)
    assert_equal(Branch_answer, Match_capture.output?, Match_capture.inspect)
  end # output?

  def test_SplitCapture_output?
    column_output = Split_capture.string.capture?(Split_capture.regexp, SplitCapture).column_output
    assert_equal([Branch_column_answer], column_output, Split_capture.inspect)
    assert_equal([Branch_answer], Split_capture.string.capture?(Split_capture.regexp, SplitCapture).output?, Split_capture.inspect)
    #	assert_equal([{:branch=>"1"}, {:branch=>"2"}], Parse_array.output?, Parse_array.inspect)
    #	assert_equal(Branch_hashes, Capture.new(captures, regexp).output?, captures.inspect) # return matched subexpressions
  end # output?

  def test_output_with_key_symbols
    assert_equal({ branch: '1' }, Match_capture.output?)
  end # output_with_key_symbols

  def test_MatchCapture_named_hash
    message = Match_capture.inspect
    message += "\n raw_capture = " + Match_capture.raw_captures.inspect
    message += "\n named_captures = " + Match_capture.regexp.named_captures.inspect
    assert_equal('1', Match_capture.raw_captures[1], message)
    assert_equal(Branch_column_answer.keys, Match_capture.named_hash(0).keys, message)
    assert_equal(Branch_column_answer.values, Match_capture.named_hash(0).values, message)
    assert_equal(Branch_column_answer.hash, Match_capture.named_hash(0).hash, message)
    assert_equal(Branch_column_answer, Match_capture.named_hash, message)
    assert_equal(Branch_column_answer, Match_capture.named_hash(0), message)
  end # named_hash

  def test_equal
    Match_capture.instance_variables.each do |iv_name|
      unless [:@raw_captures].include?(iv_name)
        #			assert_equal(Match_capture.instance_variable_get(iv_name), Limit_capture.instance_variable_get(iv_name), iv_name)
      end # if
    end # each
    #	assert(Match_capture == Limit_capture)
  end # equal

  def test_plus
  end # +

  # Capture::Assertions
  def test_assert_method
  end # assert_method

  def test_Capture_assert_pre_conditions
    #	Parse_string.assert_pre_conditions
    #	Parse_array.assert_pre_conditions
    assert_raises(AssertionFailedError) { assert(false) }
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions('test_Capture_assert_pre_conditions')}
  end # assert_pre_conditions

  def test_assert_success
    assert_raises(AssertionFailedError) { assert(false) }
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}
    MatchCapture.new(Newline_Delimited_String, Branch_line_regexp) # .assert_success
    MatchCapture.new('   ', /  /) # .assert_success
    MatchCapture.new('  ', /  /) # .assert_success
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_success}

    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}
    #	assert_raises(AssertionFailedError) {SplitCapture.new('cat', /fish/).assert_success}
    SplitCapture.new('cat', /cat/) # .assert_success
    SplitCapture.new('  ', /  /) # .assert_success
  end # assert_success

  def test_assert_left_match
  end # assert_left_match

  def test_Capture_assert_post_conditions
    #	refute_equal('', Parse_string.post_match)
    #	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
    #	assert_raises(AssertionFailedError) {Parse_delimited_array.assert_post_conditions}
    #	assert_equal('', Parse_delimited_array.post_match, Parse_delimited_array.inspect)
    #	Parse_array.assert_post_conditions
  end # assert_post_conditions

  def test_add_parse_message
    #	assert_match(/match\(/, Match_capture.add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
    #	assert_match(/test_add_parse_message/, Match_capture.add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
  end # add_parse_message

  def test_Capture_Examples
    Match_capture # .assert_pre_conditions
    Split_capture # .assert_pre_conditions
    Limit_capture # .assert_pre_conditions
    Parse_string # .assert_pre_conditions
    Parse_array # .assert_pre_conditions
    assert_raises(AssertionFailedError) { assert(false) }
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}

    Match_capture # .assert_left_match
    Split_capture # .assert_left_match
    Limit_capture # .assert_post_conditions
    #	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
    #	assert_raises(AssertionFailedError) {Parse_array.assert_post_conditions}
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_post_conditions}
  end # Examples

  def test_MatchData_raw_captures?
    assert_instance_of(MatchData, MatchCapture.new("* 1\n", Branch_regexp).raw_captures?)
  end # raw_captures?

  def test_MatchCapture_success?
    assert(Match_capture.success?)
    assert_equal(nil, MatchCapture.new('cat', /fish/).success?)
  end # success?

  def test_MatchCapture_repetitions?
    parse_string = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
    assert_equal(1, parse_string.repetitions?)
  end # repetitions?

  def test_MatchCapture_to_a?
  end # to_a?

  def test_MatchCapture_post_match?
  end # post_match?

  def test_MatchCapture_pre_match?
    assert_equal('', MatchCapture.new('a', /a/).pre_match?)
    assert_equal('b', MatchCapture.new('ba', /a/).pre_match?)
    assert_equal('', MatchCapture.new('a', /a/.capture(:a)).pre_match?)
    assert_equal('', MatchCapture.new('b', /a/).pre_match?)
  end # pre_match?

  def test_MatchCapture_matched_characters?
    assert_equal('a', MatchCapture.new('a', /a/).matched_characters?)
    assert_equal('a', MatchCapture.new('a', /a/).matched_characters?)
    assert_equal('a', MatchCapture.new('ab', /a/.capture(:a)).matched_characters?)
    assert_equal("* 1\n", Match_capture.matched_characters?)
  end # matched_characters?

  def test_MatchCapture_number_matched_characters?
    assert_equal(4, Match_capture.number_matched_characters?)
  end # number_matched_characters?

  def test_MatchCapture_column_output
  end # column_output

  def test_MatchCapture_delimiters?
    assert_equal([], Match_capture.delimiters?, Match_capture.inspect)
  end # delimiters?

  def test_MatchCapture_Examples
  end # Examples

  def test_SplitCapture_initialize
  end # initialize

  def test_DplitCapture_index
  end # []

  def test_SplitCapture_raw_captures?
    assert_equal(["\n"], Parse_delimited_array.raw_captures[2..2], Parse_string.to_a?.inspect)
    assert_equal("\n", Parse_delimited_array.raw_captures[2])
    assert_equal([2, 3], (2..Parse_array.raw_captures.size - 2).map { |i| i }, Parse_array.inspect)
    assert_equal([true, false], (2..Parse_array.raw_captures.size - 2).map(&:even?))
    assert_equal(%W(\n 2), (2..Parse_array.raw_captures.size - 2).map { |i| Parse_array.raw_captures[i] })
    assert_equal(["\n"], (2..Parse_array.raw_captures.size - 2).map { |i| (i.even? ? Parse_array.raw_captures[i] : nil) }.compact)

    assert_equal([2], (2..Parse_delimited_array.raw_captures.size - 2).map { |i| i }, Parse_delimited_array.inspect)
    assert_equal([true], (2..Parse_delimited_array.raw_captures.size - 2).map(&:even?))
    assert_equal(["\n"], (2..Parse_delimited_array.raw_captures.size - 2).map { |i| Parse_delimited_array.raw_captures[i] })
    assert_equal(["\n"], (2..Parse_delimited_array.raw_captures.size - 2).map { |i| (i.even? ? Parse_delimited_array.raw_captures[i] : nil) }.compact)
    assert_equal(4, Parse_delimited_array.raw_captures.size, Parse_delimited_array.inspect)
    assert_equal(false, Parse_delimited_array.raw_captures.size.odd?, Parse_delimited_array.inspect)
    assert_instance_of(Array, SplitCapture.new("* 1\n", Branch_regexp).raw_captures?)
    assert_match(Branch_regexp, Split_capture.string, Split_capture.inspect)
    assert_match(Branch_line_regexp, Split_capture.string, Split_capture.inspect)
    assert_match(Split_capture.regexp, Split_capture.string, Split_capture.inspect)
    assert_equal(['', '1', '  2'], Split_capture.string.split(Split_capture.regexp), Split_capture.inspect)
    assert_equal(['', '1', '  2'], Split_capture.raw_captures, Split_capture.inspect)
    assert_equal(3, Split_capture.raw_captures.size, Split_capture.inspect)
  end # raw_captures?

  def test_SplitCapture_success?
    raw_captures = Split_capture.raw_captures?
    assert(Split_capture.success?)
    assert(SplitCapture.new('  ', /  /).success?)
    '  '.assert_parse(/  /)
  end # success?

  def test_SplitCapture_repetitions?
    length_hash_captures = Parse_array.regexp.named_captures.values.flatten.size
    assert_equal(1, Parse_array.length_hash_captures, Parse_array.raw_captures.inspect + Parse_array.regexp.named_captures.inspect)
    repetitions = (Parse_array.raw_captures.size / length_hash_captures).ceil
    #	assert_equal(2, Parse_array.repetitions?)
    parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    #	assert_equal(0, .repetitions?)
    assert_equal(1, parse_delimited_array.repetitions?)
    assert_equal(2, SplitCapture.new(Newline_Delimited_String, Branch_regexp).repetitions?)
  end # repetitions?

  def test_SplitCapture_to_a?
    parse_string = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
    parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)

    #	assert_equal(parse_string.to_a?.join, parse_delimited_array.to_a?.join)
    #	assert_equal(parse_string.to_a?, parse_delimited_array.to_a?)
  end # to_a?

  def test_SplitCapture_post_match?
    assert_equal('', Parse_delimited_array.post_match?, Parse_delimited_array.inspect)

    #	assert_equal("\n  2", Parse_string.post_match?)
  end # post_match?

  def test_SplitCapture_pre_match?
  end # pre_match?

  def test_SplitCapture_matched_characters?
    assert_equal("* 1\n", Split_capture.matched_characters?)
  end # matched_characters?

  def test_SplitCapture_number_matched_characters?
    assert_equal(4, Split_capture.number_matched_characters?)
  end # number_matched_characters?

  def test_SplitCapture_column_output
    length_hash_captures = Parse_array.regexp.named_captures.values.flatten.size
    iterations = (Parse_array.raw_captures.size / length_hash_captures).ceil
    #	assert_equal(2, Parse_array.length_hash_captures, Parse_array.raw_captures.inspect+Parse_array.regexp.named_captures.inspect)
    #	assert_equal(["\n", "\n"], Parse_array.delimiters?, Parse_array.raw_captures.inspect)
    #	assert_equal(Branch_hashes.values, Parse_array.to_a?, Parse_array.raw_captures.inspect)
    #	assert_equal(Branch_hashes, Parse_array.raw_captures, Parse_array.raw_captures.inspect)
    output = if Parse_array.raw_captures.instance_of?(MatchData)
               Parse_array.named_hash(0)
             else
               (0..iterations - 1).map do |i|
                 Parse_array.named_hash(i * (length_hash_captures + 1))
               end # map
    end # if
    assert_instance_of(Array, output)
    assert_instance_of(Hash, output[0])
    #	assert_equal(Branch_hashes[0].keys, Capture.symbolize_keys(output[0]).keys, output.inspect)
    #	assert_equal(Branch_hashes, Capture.symbolize_keys(output), output.inspect)
    #	assert_equal(Branch_hashes[0], Capture.symbolize_keys(output[0]), output.inspect)
    #	assert_equal(output[0], Branch_hashes[0], output.inspect)
    message = 'Split_capture = ' + Split_capture.inspect
    column_output = Split_capture.string.capture?(Split_capture.regexp, SplitCapture).column_output
    message += 'column_output = ' + column_output.inspect
    assert_equal([Branch_column_answer], column_output, message)
    assert_equal([Branch_answer], Capture.symbolize_keys(column_output), message)
    #	assert_equal(output, Branch_hashes)
  end # column_output

  def test_SplitCapture_delimiters?
    #	assert_equal([], Parse_string.delimiters?)
    #	assert_equal(["\n"], Parse_array.delimiters?, Parse_array.inspect)
    assert_equal(["\n"], Parse_delimited_array.delimiters?, Parse_delimited_array.inspect)
    message = "Match_capture = #{Match_capture.inspect}\nSplit_capture = #{Split_capture.inspect}"
    assert_equal(3, Split_capture.raw_captures.size, message)
    assert_equal(2..1, (2..Split_capture.raw_captures.size - 2), message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }, message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }.compact, message)
    assert_equal([], Split_capture.delimiters?, message)
    assert_equal([], Limit_capture.delimiters?, message)
    assert_includes(Capture::Assertions::ClassMethods.instance_methods, :assert_method, message)
    assert_includes(Capture.methods, :assert_method, message)
    #	Capture::Assertions::ClassMethods.assert_method(Match_capture, Limit_capture, :delimiters?, message)
    Capture.assert_method(Match_capture, Limit_capture, :delimiters?, message)
  end # delimiters?

  def test_SplitCapture_Examples
  end # Examples

  def test_LimitCapture_raw_captures?
    assert_instance_of(Array, LimitCapture.new("* 1\n", Branch_regexp).raw_captures?)
  end # raw_captures?

  def test_LimitCapture_success?
    assert(Limit_capture.success?)
  end # success?

  def test_ParsedCapture_initialize
  end # ParsedCapture_initialize

  def test_ParsedCapture_raw_captures?
  end # raw_captures?

  def test_ParsedCapture_success?
  end # success?

  def test_ParsedCapture_post_match?
  end # post_match?

  def test_ParsedCapture_pre_match?
  end # pre_match?

  def test_ParsedCapture_matched_characters?
  end # matched_characters?

  def test_ParsedCapture_output?
  end # output?

  def test_ParsedCapture_delimiters?
  end # delimiters?

  # String
  def test_map_capture?
  end # map_capture?

  def test_capture
    assert_equal(Branch_answer, Match_capture.string.capture?(Match_capture.regexp, MatchCapture).output?, Match_capture.inspect)
    assert_equal([Branch_answer], Match_capture.string.capture?(Match_capture.regexp, SplitCapture).output?, Match_capture.inspect)
    assert_equal([Branch_answer], Match_capture.string.capture?(Match_capture.regexp, LimitCapture).output?, Match_capture.inspect)
    assert_equal(Branch_answer, Match_capture.string.capture?(Match_capture.regexp).output?, Match_capture.inspect)
  end # capture?

  def test_assert_parse_once
    pattern = Branch_line_regexp
    message = ''
    match_capture = MatchCapture.new(Newline_Delimited_String, pattern)
    split_capture = SplitCapture.new(Newline_Delimited_String, pattern)
    limit_capture = SplitCapture.new(Newline_Delimited_String[0, match_capture.number_matched_characters?], pattern)
    message = "match_capture = #{match_capture.inspect}\limit_capture = #{limit_capture.inspect}"
    assert_equal(match_capture.output?, limit_capture.output?[0], message)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)
  end # assert_parse_once
end # Capture

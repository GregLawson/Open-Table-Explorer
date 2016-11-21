###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
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

  def test_num_captures
    assert_equal(1, MatchCapture::Examples::Branch_line_capture.num_captures, MatchCapture::Examples::Branch_line_capture.inspect)
    assert_equal(2, MatchCapture::Examples::Branch_current_capture.num_captures, MatchCapture::Examples::Branch_current_capture.inspect)
  end # num_captures

  def test_Capture_to_hash
    capture = SplitCapture.new(Newline_Terminated_String, Branch_line_regexp)
    _hash_offset = 0
    assert_equal({ 'branch' => [2], 'current' => [1] }, MatchCapture::Examples::Branch_current_capture.regexp.named_captures)
    named_hash = {}
    capture.regexp.named_captures.each_pair do |named_capture, _indices| # return named subexpressions
      if _indices.size == 1
        assert_instance_of(Fixnum, _indices[0])
        assert_instance_of(Array, capture.to_a(_hash_offset))
        assert_operator(_indices[0] - 1, :<, capture.to_a(_hash_offset).size)
        assert_instance_of(String, capture.to_a(_hash_offset)[_indices[0] - 1])
        named_hash = named_hash.merge(named_capture.to_sym =>
             capture.to_a(_hash_offset)[_indices[0] - 1]) # one and only capture
      else
        named_hash = named_hash.merge(named_capture.to_sym =>
          _indices.map { |i| capture.to_a(_hash_offset)[i - 1] })
      end # if
    end # each_pair
    assert_equal({ branch: '1' }, named_hash, capture.inspect)
    assert_equal({ branch: '1' }, MatchCapture::Examples::Branch_line_capture.to_hash)
    assert_equal({ branch: '1' }, MatchCapture::Examples::Branch_capture.to_hash)
    assert_equal({ branch: '1', current: '*' }, MatchCapture::Examples::Branch_current_capture.to_hash)
    assert_equal({ branch: '1' }, Split_capture.to_hash)
    assert_equal(Branch_hashes[0], SplitCapture.new(Newline_Delimited_String, Branch_current_regexp).to_hash)
  end # to_hash

  def test_index
    capture = MatchCapture::Examples::Branch_line_capture
    message = 'capture = ' + capture.inspect
    message += "\n raw_capture = " + capture.raw_captures.inspect
    message += "\n named_captures = " + capture.regexp.named_captures.inspect
    assert_equal('1', MatchCapture::Examples::Branch_line_capture.raw_captures[1], message)
    #    assert_equal(['', "* 1\n", '  2'], MatchCapture::Examples::Branch_line_capture.to_a, message)
    #    assert_equal('1', capture[1], message)
    assert_equal("* 1\n", capture.matched_characters, message)
    assert_equal(nil, capture[2], message)
    #    assert_equal('1', capture[1], message)
    message += "\ncapture.output = " + capture.output.inspect
    #    assert_equal(Branch_column_answer, capture.named_hash(0), message)
  end # []

  def test_named_hash_variable
    variable = Branch_variable
    hash_offset = 0
    capture_name = variable.name
    message = 'MatchCapture::Examples::Branch_line_capture = ' + MatchCapture::Examples::Branch_line_capture.inspect
    indices = MatchCapture::Examples::Branch_line_capture.regexp.named_captures[capture_name.to_s]
    assert_kind_of(Capture, MatchCapture::Examples::Branch_line_capture, message)
    assert_instance_of(Regexp, MatchCapture::Examples::Branch_line_capture.regexp, message)
    assert_instance_of(Hash, MatchCapture::Examples::Branch_line_capture.regexp.named_captures, message)
    named_captures = MatchCapture::Examples::Branch_line_capture.regexp.named_captures
    message += "\nnamed_captures = " + named_captures.inspect
    assert_instance_of(Hash, MatchCapture::Examples::Branch_line_capture.regexp.named_captures, message)
    assert_instance_of(Array, indices, message)
    #    assert_equal(Branch_column_answer, MatchCapture::Examples::Branch_line_capture.named_hash_variable(variable, hash_offset))
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
    #    assert_equal(Branch_column_answer, MatchCapture::Examples::Branch_line_capture.named_hash_column(Branch_column, hash_offset))
  end # named_hash_column

  def test_named_hash
    hash_offset = 0
    string = "* 1\n"
    regexp = Branch_regexp
    message = 'regexp.inspect = ' + regexp.inspect
    matchData = string.match(regexp)
    captures = matchData # [1..-1]
    parse_string = MatchCapture.new("* 1\n", Branch_regexp)
    #    assert_equal(3, Parse_string.to_a.size, Parse_string.inspect)
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
    end # each_pair
    assert_equal('', captures[0], regexp.named_captures.inspect + "\n" + captures.inspect)
    #		name=default_name(capture_index).to_sym
    #		named_hash[name]=captures[capture_index]
    #	end #each
    message += regexp.inspect + "\n" + captures.inspect
    #    assert_equal(Branch_column_answer, MatchCapture::Examples::Branch_line_capture.named_hash, message)
    #	assert_equal(Branch_hashes, Capture.new(captures, regexp).output, captures.inspect) # return matched subexpressions
    regexp = /5/.capture(:a) * /6/.capture(:a)
    capture = '56'.capture?(regexp)
    message = 'capture = ' + capture.inspect
    message = 'capture.regexp.named_captures = ' + capture.regexp.named_captures.inspect
    assert_equal([1, 2], capture.regexp.named_captures['a'], message)
    #    assert_equal('6', capture[:a], message)
    #    assert_equal('6', capture[2], message)
    #    assert_equal('5', capture[1], message)
    output = capture.output
    message += "\noutput = " + output.inspect
    #    assert_equal('5', Capture.symbolize_keys(output)[:a], message)
    #    assert_equal('6', capture[:a], message)
  end # named_hash

  def test_MatchCapture_output
    assert_equal({ branch: '1' }, MatchCapture.new("* 1\n", Branch_regexp).output) # return matched subexpressions
    assert(MatchCapture::Examples::Branch_line_capture.success?)
    assert_instance_of(MatchData, MatchCapture::Examples::Branch_line_capture.raw_captures)
    assert_equal(Branch_answer, MatchCapture::Examples::Branch_line_capture.output, MatchCapture::Examples::Branch_line_capture.inspect)
  end # output

  def test_SplitCapture_output
    column_output = Split_capture.string.capture?(Split_capture.regexp, SplitCapture).column_output
    #    assert_equal([Branch_column_answer], column_output, Split_capture.inspect)
    assert_equal([Branch_answer], Split_capture.string.capture?(Split_capture.regexp, SplitCapture).output, Split_capture.inspect)
    #	assert_equal([{:branch=>"1"}, {:branch=>"2"}], Parse_array.output, Parse_array.inspect)
    #	assert_equal(Branch_hashes, Capture.new(captures, regexp).output, captures.inspect) # return matched subexpressions
  end # output

  def test_output_with_key_symbols
    assert_equal({ branch: '1' }, MatchCapture::Examples::Branch_line_capture.output)
  end # output_with_key_symbols

  def test_MatchCapture_named_hash
    message = MatchCapture::Examples::Branch_line_capture.inspect
    message += "\n raw_capture = " + MatchCapture::Examples::Branch_line_capture.raw_captures.inspect
    message += "\n named_captures = " + MatchCapture::Examples::Branch_line_capture.regexp.named_captures.inspect
    assert_equal('1', MatchCapture::Examples::Branch_line_capture.raw_captures[1], message)
    assert_equal(Branch_column_answer.keys, MatchCapture::Examples::Branch_line_capture.named_hash(0).keys, message)
    #    assert_equal(Branch_column_answer.values, MatchCapture::Examples::Branch_line_capture.named_hash(0).values, message)
    #    assert_equal(Branch_column_answer.hash, MatchCapture::Examples::Branch_line_capture.named_hash(0).hash, message)
    #    assert_equal(Branch_column_answer, MatchCapture::Examples::Branch_line_capture.named_hash, message)
    #    assert_equal(Branch_column_answer, MatchCapture::Examples::Branch_line_capture.named_hash(0), message)
  end # named_hash

  def test_equal
    MatchCapture::Examples::Branch_line_capture.instance_variables.each do |iv_name|
      unless [:@raw_captures].include?(iv_name)
        #			assert_equal(MatchCapture::Examples::Branch_line_capture.instance_variable_get(iv_name), Limit_capture.instance_variable_get(iv_name), iv_name)
      end # if
    end # each
    #	assert(MatchCapture::Examples::Branch_line_capture == Limit_capture)
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
    #	assert_raises(AssertionFailedError) {Branch_regexp_capture.assert_post_conditions}
    #	assert_equal('', Branch_regexp_capture.post_match, Branch_regexp_capture.inspect)
    #	Parse_array.assert_post_conditions
  end # assert_post_conditions

  def test_add_parse_message
    #	assert_match(/match\(/, MatchCapture::Examples::Branch_line_capture.add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
    #	assert_match(/test_add_parse_message/, MatchCapture::Examples::Branch_line_capture.add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
  end # add_parse_message

  def test_Capture_Examples
    MatchCapture::Examples::Branch_line_capture.assert_pre_conditions
    Split_capture.assert_pre_conditions
    #    Limit_capture.assert_pre_conditions
    Parse_string.assert_pre_conditions
    Parse_array.assert_pre_conditions
    assert_raises(AssertionFailedError) { assert(false) }
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}

    MatchCapture::Examples::Branch_line_capture.assert_left_match
    Split_capture.assert_left_match
    Limit_capture.assert_post_conditions
    #	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
    #	assert_raises(AssertionFailedError) {Parse_array.assert_post_conditions}
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_post_conditions}
  end # Examples
end # Capture

class RawCaptureTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples

  def test_MatchData_raw_captures
    assert_instance_of(MatchData, MatchCapture.new("* 1\n", Branch_regexp).raw_captures)
  end # raw_captures
end # RawCapture

class MatchCaptureTest < TestCase
  include MatchCapture::Examples
  include Capture::Examples

  def test_MatchCapture_success?
    assert(MatchCapture::Examples::Branch_line_capture.success?)
    assert_equal(nil, MatchCapture.new('cat', /fish/).success?)
  end # success?

  def test_MatchCapture_repetitions?
    parse_string = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
    assert_equal(1, parse_string.repetitions?)
  end # repetitions?

  def test_MatchCapture_to_a
  end # to_a

  def test_MatchCapture_to_tree
    assert_equal({ named_captures: { branch: '1' }, post_match: '  2', pre_match: '' }, MatchCapture::Examples::Branch_line_capture.to_tree)
    assert_equal({ named_captures: { branch: '1', current: '*' }, post_match: "\n  2", pre_match: '' }, MatchCapture::Examples::Branch_current_capture.to_tree)
    assert_equal({ named_captures: { branch: '1' }, post_match: "\n  2", pre_match: '' }, MatchCapture::Examples::Branch_capture.to_tree)
  end # to_tree

  def test_MatchCapture_post_match
  end # post_match

  def test_MatchCapture_pre_match
    assert_equal('', MatchCapture.new('a', /a/).pre_match)
    assert_equal('b', MatchCapture.new('ba', /a/).pre_match)
    assert_equal('', MatchCapture.new('a', /a/.capture(:a)).pre_match)
    assert_equal('', MatchCapture.new('b', /a/).pre_match)
  end # pre_match

  def test_MatchCapture_matched_characters
    assert_equal('a', MatchCapture.new('a', /a/).matched_characters)
    assert_equal('a', MatchCapture.new('a', /a/).matched_characters)
    assert_equal('a', MatchCapture.new('ab', /a/.capture(:a)).matched_characters)
    assert_equal("* 1\n", MatchCapture::Examples::Branch_line_capture.matched_characters)
  end # matched_characters

  def test_MatchCapture_number_matched_characters
    assert_equal(4, MatchCapture::Examples::Branch_line_capture.number_matched_characters)
  end # number_matched_characters

  def test_MatchCapture_column_output
  end # column_output

  def test_MatchCapture_delimiters
    assert_equal([], MatchCapture::Examples::Branch_line_capture.delimiters, MatchCapture::Examples::Branch_line_capture.inspect)
  end # delimiters

  def test_MatchCapture_Examples
  end # Examples
end # MatchCapture

class SplitCaptureTest < TestCase
  include SplitCapture::Examples
  include Capture::Examples
  include String::Examples

  def test_SplitCapture_initialize
  end # initialize

  def test_DplitCapture_index
  end # []

  def test_SplitCapture_raw_captures
    assert_equal(["\n"], Branch_regexp_capture.raw_captures[2..2], Branch_regexp_capture.to_a(0).inspect)
    assert_equal("\n", Branch_regexp_capture.raw_captures[2])
    assert_equal([2, 3], (2..Parse_array.raw_captures.size - 2).map { |i| i }, Parse_array.inspect)
    assert_equal([true, false], (2..Parse_array.raw_captures.size - 2).map(&:even?))
    assert_equal(%W(\n 2), (2..Parse_array.raw_captures.size - 2).map { |i| Parse_array.raw_captures[i] })
    assert_equal(["\n"], (2..Parse_array.raw_captures.size - 2).map { |i| (i.even? ? Parse_array.raw_captures[i] : nil) }.compact)

    assert_equal([2], (2..Branch_regexp_capture.raw_captures.size - 2).map { |i| i }, Branch_regexp_capture.inspect)
    assert_equal([true], (2..Branch_regexp_capture.raw_captures.size - 2).map(&:even?))
    assert_equal(["\n"], (2..Branch_regexp_capture.raw_captures.size - 2).map { |i| Branch_regexp_capture.raw_captures[i] })
    assert_equal(["\n"], (2..Branch_regexp_capture.raw_captures.size - 2).map { |i| (i.even? ? Branch_regexp_capture.raw_captures[i] : nil) }.compact)
    assert_equal(4, Branch_regexp_capture.raw_captures.size, Branch_regexp_capture.inspect)
    assert_equal(false, Branch_regexp_capture.raw_captures.size.odd?, Branch_regexp_capture.inspect)
    assert_instance_of(Array, SplitCapture.new("* 1\n", Branch_regexp).raw_captures)
    assert_match(Branch_regexp, Split_capture.string, Split_capture.inspect)
    assert_match(Branch_line_regexp, Split_capture.string, Split_capture.inspect)
    assert_match(Split_capture.regexp, Split_capture.string, Split_capture.inspect)
    assert_equal(['', '1', '  2'], Split_capture.string.split(Split_capture.regexp), Split_capture.inspect)
    assert_equal(['', '1', '  2'], Split_capture.raw_captures, Split_capture.inspect)
    assert_equal(3, Split_capture.raw_captures.size, Split_capture.inspect)
  end # raw_captures

  def test_SplitCapture_success?
    raw_captures = Split_capture.raw_captures
    assert(Split_capture.success?)
    assert(SplitCapture.new('  ', /  /).success?)
    '  '.assert_parse(/  /)
  end # success?

  def test_SplitCapture_repetitions?
    length_hash_captures = Parse_array.num_captures
    assert_equal(1, Parse_array.num_captures, Parse_array.raw_captures.inspect + Parse_array.regexp.named_captures.inspect)
    repetitions = (Parse_array.raw_captures.size / length_hash_captures).ceil
    #	assert_equal(2, Parse_array.repetitions?)
    parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    #	assert_equal(0, .repetitions?)
    assert_equal(1, parse_delimited_array.repetitions?)
    assert_equal(2, SplitCapture.new(Newline_Delimited_String, Branch_regexp).repetitions?)
  end # repetitions?

  def test_SplitCapture_to_a
    parse_string = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
    parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)

    #	assert_equal(parse_string.to_a.join, parse_delimited_array.to_a.join)
    #	assert_equal(parse_string.to_a, parse_delimited_array.to_a)
    assert_equal(['1'], SplitCapture.new(Newline_Delimited_String, Branch_line_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(Newline_Terminated_String, Branch_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(Newline_Terminated_String, Branch_line_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(Newline_Delimited_String, Branch_regexp).to_a(0))
    assert_equal(['2'], SplitCapture.new(Newline_Terminated_String, Branch_regexp).to_a(1))
    assert_equal(['2'], SplitCapture.new(Newline_Terminated_String, Branch_line_regexp).to_a(1))
    assert_equal(['2'], SplitCapture.new(Newline_Delimited_String, Branch_regexp).to_a(1))
    assert_equal([], SplitCapture.new(Newline_Delimited_String, Branch_line_regexp).to_a(1))
  end # to_a

  def test_SplitCapture_to_tree
    delimited_current = SplitCapture.new(Newline_Delimited_String, Branch_current_regexp * "\n")
    assert_equal(1..1, 1..delimited_current.repetitions?)
    assert_equal([0], (0..delimited_current.repetitions? - 1).map { |i| i })
    #    assert_equal(Branch_hashes[0], (0..delimited_current.repetitions? - 1).map { |i| delimited_current.to_hash(i) })
    assert_equal(Branch_answer, SplitCapture.new(Newline_Delimited_String, Branch_line_regexp).to_tree[:named_captures])
    assert_equal(Branch_hashes[0], SplitCapture.new(Newline_Delimited_String, Branch_current_regexp).to_hash)
    assert_equal(Branch_hashes, SplitCapture.new(Newline_Delimited_String, Branch_current_regexp).to_tree[:named_captures])
    #    assert_equal(Branch_answer, SplitCapture.new(Newline_Terminated_String, Branch_line_regexp).to_tree[:named_captures])
    assert_equal(Branch_hashes, SplitCapture.new(Newline_Terminated_String, Branch_current_regexp).to_tree[:named_captures])
    current_terminated = SplitCapture.new(Newline_Terminated_String, Branch_current_regexp)
    assert_equal({ named_captures: Branch_hashes, post_match: "\n", pre_match: '', delimiters: ['', "\n", "\n"] }, current_terminated.to_tree)
  end # to_tree

  def test_SplitCapture_post_match
    assert_equal('', Branch_regexp_capture.post_match, Branch_regexp_capture.inspect)

    #	assert_equal("\n  2", Parse_string.post_match)
  end # post_match

  def test_SplitCapture_pre_match
  end # pre_match

  def test_SplitCapture_matched_characters
    assert_equal("* 1\n", Split_capture.matched_characters)
  end # matched_characters

  def test_SplitCapture_number_matched_characters
    assert_equal(4, Split_capture.number_matched_characters)
  end # number_matched_characters

  def test_SplitCapture_column_output
    length_hash_captures = Parse_array.num_captures
    iterations = (Parse_array.raw_captures.size / length_hash_captures).ceil
    #	assert_equal(2, Parse_array.length_hash_captures, Parse_array.raw_captures.inspect+Parse_array.regexp.named_captures.inspect)
    #	assert_equal(["\n", "\n"], Parse_array.delimiters, Parse_array.raw_captures.inspect)
    #	assert_equal(Branch_hashes.values, Parse_array.to_a, Parse_array.raw_captures.inspect)
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
    #    assert_equal([Branch_column_answer], column_output, message)
    #    assert_equal([Branch_answer], Capture.symbolize_keys(column_output), message)
    #	assert_equal(output, Branch_hashes)
  end # column_output

  def test_SplitCapture_delimiters
    delimited_line = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    assert_equal(1, delimited_line.num_captures)
    delimiters = []
    delimited_line.raw_captures.each_with_index do |raw_capture, _i|
      assert_instance_of(String, raw_capture, delimited_line.inspect)
      assert_instance_of(Fixnum, _i, delimited_line.inspect)
      #			assert_equal(0, (_i ) % (delimited_line.num_captures + 1), _i)
      if (_i % (delimited_line.num_captures + 1)) == 0
        delimiters << raw_capture
      end # if
    end.compact # each_index
    assert_equal(['', '  2'], delimiters, delimited_line.inspect)
    assert_equal(['', '  2'], SplitCapture.new(Newline_Delimited_String, Branch_line_regexp).delimiters)
    assert_equal(['', ''], SplitCapture.new(Newline_Terminated_String, Branch_line_regexp).delimiters)
    assert_equal(['', "\n"], SplitCapture.new(Newline_Delimited_String, Branch_current_regexp).delimiters)
    assert_equal(['', "\n", "\n"], SplitCapture.new(Newline_Terminated_String, Branch_current_regexp).delimiters)
    #	assert_equal([], Parse_string.delimiters)
    #	assert_equal(["\n"], Parse_array.delimiters, Parse_array.inspect)
    assert_equal(['', "\n"], Branch_regexp_capture.delimiters, Branch_regexp_capture.inspect)
    message = "Split_capture = #{Split_capture.inspect}"
    assert_equal(3, Split_capture.raw_captures.size, message)
    assert_equal(2..1, (2..Split_capture.raw_captures.size - 2), message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }, message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }.compact, message)
    assert_includes(Capture::Assertions::ClassMethods.instance_methods, :assert_method, message)
    assert_includes(Capture.methods, :assert_method, message)
    #	Capture::Assertions::ClassMethods.assert_method(MatchCapture::Examples::Branch_line_capture, Limit_capture, :delimiters, message)
  end # delimiters

  def test_internal_delimiters
    assert_equal([], Split_capture.internal_delimiters)
  end # internal_delimiters

  def test_SplitCapture_Examples
  end # Examples
end # SplitCapture

class ParsedCaptureTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include ParsedCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples

	def test_remove_matches
		assert_equal([], ParsedCapture.remove_matches(['a'], [/a/]))
		assert_equal(['b'], ParsedCapture.remove_matches(['ab'], [/a/]))
		assert_equal(['b'], ParsedCapture.remove_matches(['ab'], [/a/, /b/]))
	end # remove_matches

	def test_priority_match
		unmatches = ['abc']
		regexp_array = [/a/.capture(:alpha), /b/.capture(:beta)]
		unmatched = unmatches[0] # pick one out
		regexp = regexp_array[1] # pick one out
		ret = regexp_array.map do |regexp|    
				matches = if unmatched.instance_of?(String)
					capture = unmatched.capture?(regexp, SplitCapture)
					assert_instance_of(SplitCapture, capture)
					assert(capture.success?, capture.inspect)
					match = if capture.success?
						delimiters = capture.delimiters.select {|delimiter| delimiter != ''}.uniq
						if delimiters == []
							[{ regexp => capture.output}]
						else
							assert_equal([Match_b.keys[0]], regexp_array[1..-1])
							if regexp_array.size == 1
								assert_equal(['c'], delimiters)
								[{ regexp => capture.output} ] + delimiters # out of regexps to try
							else
#								assert_equal(['bc'], delimiters)
								recurse_on_delimiters = delimiters.map do |delimiter|
									ParsedCapture.priority_match(delimiter, regexp_array[1..-1]) # one try in priority order
								end.flatten # map
								[{ regexp => capture.output} ] + recurse_on_delimiters
							end # if
						end # if
					else
							nil
					end # if
				else
					nil
				end # if
				matches.each do |match|
					message = 'matches = ' + matches.inspect
					message += "\n match = " + match.inspect
					message += "\n capture = " + capture.inspect
					message += "\n delimiters = " + delimiters.inspect
					assert_includes(Ordered_matches, match, message)
				end # each
#				assert_equal(['bc'], delimiters)
				matches
			end.flatten.uniq.compact.select {|um| um != ''}# map
			
			assert_includes(ret, Match_a)
			assert_includes(ret, Match_b)
			assert_includes(ret, Unmatched_c)
		assert_equal(Ordered_matches, ParsedCapture.priority_match(unmatched, regexp_array))
	end # priority_match
		
	def test_show_matches
		unmatches = ['abc']
		regexp_array = [/a/.capture(:alpha), /b/.capture(:beta)]
		unmatched = unmatches[0] # pick one out
		regexp = regexp_array[1] # pick one out
					capture = unmatched.capture?(regexp, SplitCapture)
		assert_instance_of(SplitCapture, capture)
		assert(capture.success?, capture.inspect)
		assert_equal([{:beta=>"b"}], capture.output, capture.inspect)
		ret = [ { regexp => capture.output}, ParsedCapture.show_matches(capture.delimiters, regexp_array) ]
		assert_equal([{/(?<beta>b)/=>[{:beta=>"b"}]}, [{/(?<alpha>a)/=>[{:alpha=>"a"}]}]], ret)
		assert_equal(Ordered_matches, ParsedCapture.show_matches(unmatches, regexp_array))
#		assert_equal(['b'], ParsedCapture.show_matches(['ab'], [/a/]))
#		assert_equal(['b'], ParsedCapture.show_matches(['ab'], [/a/, /b/]))
	end # show_matches

  def test_ParsedCapture_initialize
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + Parsed_a_capture.inspect
		assert_equal('a,a,', Parsed_a_capture.string, message)
		assert_equal(true, Parsed_a_capture.success?, message)
  end # ParsedCapture_initialize

  def test_ParsedCapture_raw_captures
		quantified_parse = Parsed_a_capture.parsed_regexp
		refute_includes(quantified_parse.instance_variables, :@quantifier)
		assert_instance_of(Array, quantified_parse.expressions)
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + quantified_parse.inspect
		assert_equal('a,a,', Parsed_a_capture.string, message)
		assert_instance_of(MatchCapture, ParsedCapture::Examples::Parsed_a_capture.raw_captures, message)
  end # raw_captures
	
	def test_ruby_lines_storage
		ruby_lines_storage = Parsed_a_capture.ruby_lines_storage
#		assert_match(/   a{2}/, ruby_lines_storage, ruby_lines_storage)
	end # ruby_lines_storage

  def test_ParsedCapture_success?
  end # success?

  def test_ParsedCapture_post_match
  end # post_match

  def test_ParsedCapture_pre_match
  end # pre_match

  def test_ParsedCapture_matched_characters
  end # matched_characters

  def test_ParsedCapture_column_output
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + Parsed_a_capture.inspect
#		assert_equal(',', Parsed_a_capture.column_output, message)
  end # output

  def test_ParsedCapture_delimiters
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + Parsed_a_capture.inspect
#		assert_equal(',', Parsed_a_capture.delimiters, message)
  end # delimiters
end # ParsedCapture

class LimitCaptureTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples

  def test_LimitCapture_raw_captures
    limit_capture = LimitCapture.new("* 1\n", Branch_regexp)
    assert_instance_of(Array, limit_capture.raw_captures)
    #    assert_equal(['*','1', "\n"], limit_capture.raw_captures)
    #    assert_equal(['*','1'], limit_capture.to_a)
  end # raw_captures

  def test_LimitCapture_success?
    assert(Limit_capture.success?)
  end # success?

  def test_LimitCapture_post_match
  end # post_match

  def test_LimitCapture_pre_match
  end # pre_match

  def test_LimitCapture_matched_characters
  end # matched_characters

  def test_LimitCapture_output
  end # output

  def test_LimitCapture_delimiters
    message = "MatchCapture::Examples::Branch_line_capture = #{MatchCapture::Examples::Branch_line_capture.inspect}\nSplit_capture = #{Split_capture.inspect}"
    assert_equal([], Limit_capture.delimiters, message)
    Capture.assert_method(MatchCapture::Examples::Branch_line_capture, Limit_capture, :delimiters, message)
  end # delimiters
end # LimitCapture

class StringTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples
  def test_map_capture?
  end # map_capture?

  def test_capture
    assert_equal(Branch_answer, MatchCapture::Examples::Branch_line_capture.string.capture?(MatchCapture::Examples::Branch_line_capture.regexp, MatchCapture).output, MatchCapture::Examples::Branch_line_capture.inspect)
    assert_equal([Branch_answer], MatchCapture::Examples::Branch_line_capture.string.capture?(MatchCapture::Examples::Branch_line_capture.regexp, SplitCapture).output, MatchCapture::Examples::Branch_line_capture.inspect)
    #    assert_equal([Branch_answer], MatchCapture::Examples::Branch_line_capture.string.capture?(MatchCapture::Examples::Branch_line_capture.regexp, LimitCapture).output, MatchCapture::Examples::Branch_line_capture.inspect)
    assert_equal(Branch_answer, MatchCapture::Examples::Branch_line_capture.string.capture?(MatchCapture::Examples::Branch_line_capture.regexp).output, MatchCapture::Examples::Branch_line_capture.inspect)
  end # capture?

  def test_assert_parse_once
    pattern = Branch_line_regexp
    message = ''
    match_capture = MatchCapture.new(Newline_Delimited_String, pattern)
    split_capture = SplitCapture.new(Newline_Delimited_String, pattern)
    limit_capture = SplitCapture.new(Newline_Delimited_String[0, match_capture.number_matched_characters], pattern)
    message = "match_capture = #{match_capture.inspect}\limit_capture = #{limit_capture.inspect}"
    assert_equal(match_capture.output, limit_capture.output[0], message)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)
  end # assert_parse_once
end # String

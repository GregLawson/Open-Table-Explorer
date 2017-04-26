###########################################################################
#    Copyright (C) 2013-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/parse.rb'
class MatchRefinementTest < TestCase
	
	module Examples
		A_mismatch = MatchRefinement['a']
		B_capture = MatchCapture.new(string: 'b', regexp: /b/)
		B_match = MatchRefinement[B_capture]
		AB = MatchRefinement['a', B_capture]
		ABC_match_b = MatchRefinement['a', B_capture, 'c']
		BA = MatchRefinement[B_capture, 'a']
		Scattered_match = MatchRefinement[B_capture, 'c', B_capture]
	end # Examples
	include Examples
	
	def test_to_literal
		assert_equal('"a"', 'a'.dump)
		assert_equal(3, 'a'.dump.size, 'a'.dump)
		assert_equal('"\n"', "\n".dump)
		assert_equal(4, "\n".dump.size, "\n".dump)
		assert_equal("'a'", 'a'.to_literal)
		assert_equal('"\n"', "\n".to_literal)
	end # to_literal
	
	def test_suggest
		string = 'a=1'
		name_regexp = /[A-Za-z]+/
		delimiter_regexp = /[ =,; \t\n]/
		value_regexp = /[0-9]+/
		assert_match(name_regexp, string)
		assert_match(delimiter_regexp, string)
		assert_match(value_regexp, string)
			name_value_pair_regexp = [name_regexp.capture(:name), delimiter_regexp.capture(:delimiter), value_regexp.capture(:value)]
			MatchCapture.new(string: string, regexp: name_value_pair_regexp).assert_refinement(:exact)
#			assert(string.match(name_value_pair_regexp))
#			assert_match(name_value_pair_regexp, string)
			name_value_pairs = SplitCapture.new(string: string, regexp: name_value_pair_regexp).output
			assert_equal({:delimiter=>"=", :name=>"a", :value=>"1"}, name_value_pairs[0], name_value_pairs.inspect)
			suggestion = name_value_pairs.map do |pair|
				name = pair[:name]
				value = pair[:value]
				value_regexp.inspect + '.capture(:' + name +')'
			end # map
		suggestion = MatchRefinement.suggest_name_value('a=1', /a/, /=/, /1/)
		assert_equal([name: 'a', delimiter: '=', value: '1'], suggestion)
	end # suggest
	
		def test_MatchRefinement_square_brackets
		assert_instance_of(MatchRefinement, A_mismatch)
		assert_instance_of(MatchRefinement, MatchRefinement[B_capture])
		assert_instance_of(MatchRefinement, AB)
		assert_equal(['a'], MatchRefinement['a'])
		end # MatchRefinement[]
  include GenericColumn::Examples
  # include DefaultTests

	def test_square_brackets
		assert_equal(AB, ABC_match_b[0..1])
		assert_instance_of(MatchRefinement, ABC_match_b[1..2])
		assert_equal(AB, ABC_match_b[0,2])
		assert_instance_of(MatchRefinement, ABC_match_b[0, 2])
		assert_equal(B_capture, ABC_match_b[1])
		assert_instance_of(MatchCapture, ABC_match_b[1])
	end # []

	def test_plus
		assert_equal(MatchRefinement[B_capture, 'a'],		MatchRefinement[B_capture] + MatchRefinement['a'])
	end # +
	
	def test_inspect
		assert_equal("MatchRefinement :no_matches\nsuggest: /a/", A_mismatch.inspect)
		assert_equal("MatchRefinement :exact\n'b' matched by /b/ captures {}", B_match.inspect)
		assert_equal("MatchRefinement :right\nsuggest: /a/,\n'b' matched by /b/ captures {}", AB.inspect)
	end # inspect
	
	def test_join
		assert_equal('a', A_mismatch.join)
		assert_equal('b', B_match.join)
		assert_equal('ab', AB.join)
	end # join
	
	def test_capture_indices
		assert_equal([0], B_match.capture_indices)
		assert_equal([], A_mismatch.capture_indices)
		assert_equal([1], AB.capture_indices)
		assert_equal([1], ABC_match_b.capture_indices, ABC_match_b.captures.inspect)
	end # capture_indices
		
	def test_captures
		assert_equal([B_capture], B_match.captures)
		assert_equal([], A_mismatch.captures)
		assert_equal([B_capture], AB.captures)
	end # captures

	def test_capture_span
		assert_equal(1, B_match.capture_span, B_match.capture_indices)
		assert_equal(0, A_mismatch.capture_span, A_mismatch.capture_indices)
		assert_equal(1, BA.capture_span)
		assert_equal(1, AB.capture_span, AB.capture_indices)
		assert_equal(1, ABC_match_b.capture_span, ABC_match_b.capture_indices)
		assert_equal(3, Scattered_match.capture_span, Scattered_match.capture_indices)
	end # capture_span

	def test_all_matches_consecutive?
	
		assert_equal(true, B_match.all_matches_consecutive?, B_match.captures)
		assert_equal(true, A_mismatch.all_matches_consecutive?)
		assert_equal(true, B_match.all_matches_consecutive?)
		assert_equal(true, BA.all_matches_consecutive?)
		assert_equal(true, AB.all_matches_consecutive?, AB.captures)
		assert_equal(true, ABC_match_b.all_matches_consecutive?, ABC_match_b.capture_indices)
		assert_equal(false, Scattered_match.all_matches_consecutive?, Scattered_match.capture_indices)
	end # all_matches_consecutive?
	
	def test_unmatched_indices
		assert_equal([0], A_mismatch.unmatched_indices)
		assert_equal(1, B_match.size, B_match.captures)
		assert_equal(true, B_match[0].instance_of?(MatchCapture), B_match.captures)
		assert_equal(true, B_match[0].success?, B_match.captures)
		assert_equal(B_capture, B_match[0], B_match.captures)

		[B_match].map do |match_refinement|
			match_refinement.each do |refinement|
				if refinement.kind_of?(MatchCapture)
					assert_instance_of(MatchCapture, refinement)
					if refinement.success?
						assert(refinement.success?, refinement.inspect)
					else
						refute(refinement.success?, refinement.inspect)
						assert_instance_of(String, refinement.string)
					 refinement.string
					end # if
				else
					assert_instance_of(String, refinement)
					refinement
				end # if
			end.compact # each
		end # each

		assert_equal(0, B_match.unmatched_indices.size, B_match.captures)
		assert_equal([], B_match.unmatched_indices, B_match.captures)
		assert_equal([1], BA.unmatched_indices, BA.inspect)
		assert_equal([0], AB.unmatched_indices, AB.captures)
		assert_equal([0, 2], ABC_match_b.unmatched_indices, ABC_match_b.capture_indices)
		assert_equal([], B_match.unmatched_indices)
		assert_equal([1], Scattered_match.unmatched_indices, Scattered_match.inspect)
	end # unmatched_indices

	def test_unmatches
		assert_equal(['a'], A_mismatch.unmatches)
		assert_equal(1, B_match.size, B_match.captures)
		assert_equal(true, B_match[0].instance_of?(MatchCapture), B_match.captures)
		assert_equal(true, B_match[0].success?, B_match.captures)
		assert_equal(B_capture, B_match[0], B_match.captures)

		[B_match].map do |match_refinement|
			match_refinement.each do |refinement|
				if refinement.kind_of?(MatchCapture)
					assert_instance_of(MatchCapture, refinement)
					if refinement.success?
						assert(refinement.success?, refinement.inspect)
					else
						refute(refinement.success?, refinement.inspect)
						assert_instance_of(String, refinement.string)
					 refinement.string
					end # if
				else
					assert_instance_of(String, refinement)
					refinement
				end # if
			end.compact # each
		end # each

		assert_equal(AB.unmatches, BA.unmatches, BA.inspect)
		assert_equal(0, B_match.unmatches.size, B_match.captures)
		assert_equal([], B_match.unmatches, B_match.captures)
		assert_equal(['a'], BA.unmatches, BA.inspect)
		assert_equal(['a'], AB.unmatches, AB.captures)
		assert_equal(['a', 'c'], ABC_match_b.unmatches, ABC_match_b.inspect)
		assert_equal([], B_match.unmatches)
		assert_equal(['c'], Scattered_match.unmatches)
	end # unmatches

	def test_kind
		assert_equal(:exact, B_match.kind, B_match.captures)
		assert_equal(:no_matches, A_mismatch.kind)
		assert_equal(:exact, B_match.kind)
		assert_equal(:left, BA.kind)
		assert_equal(:right, AB.kind, AB.captures)
		assert_equal([1], ABC_match_b.capture_indices)
		assert_equal(1, ABC_match_b.capture_span, ABC_match_b.capture_indices)
		assert_equal(:inside, ABC_match_b.kind, ABC_match_b.capture_indices)
	end # kind

	def test_error_message
			assert_match(/no res/, B_match.error_message(:exact))
			assert_match(/no reg/, A_mismatch.error_message(:no_matches))
			assert_match(/no res/, B_match.error_message(:exact))
			assert_match(/left res/, BA.error_message(:left))
			assert_match(/left and right res/, ABC_match_b.error_message(:inside))
			assert_match(/right res/, AB.error_message(:right))
	end # error_message
		
    def test_MatchRefinement_assert_pre_conditions
    end # assert_pre_conditions


    def test_assert_pre_conditions
			A_mismatch.assert_pre_conditions
			B_match.assert_pre_conditions
			AB.assert_pre_conditions
    end # assert_pre_conditions
		

		def test_assert_match_kind
			B_match.assert_match_kind(:exact)
			A_mismatch.assert_match_kind(:no_matches)
			B_match.assert_match_kind(:exact)
			BA.assert_match_kind(:left)
			ABC_match_b.assert_match_kind(:inside)
			AB.assert_match_kind(:right)
		end # assert_match_kind
		
end # MatchRefinement

class CaptureTest < TestCase
  include MatchRefinementTest::Examples
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples
	
	module Examples
		Reflog_timestamp = 'Sun, 21 Jun 2015 13:51:50 -0700'.freeze

	end # Examples
	include Examples

	def test_TimeTypes
		assert_includes(Time.instance_methods(false), :iso8601)
		test_time = Time.new(2016, 12, 13, 0, 41, Rational(10998838165, 1000000000), "-08:00")
		assert_equal('Tue, 13 Dec 2016 00:41:10 -0800', test_time.rfc2822, test_time.ruby_lines_storage)
		assert_equal('2016-12-13T00:41:10-08:00', test_time.iso8601)
		assert_equal('2016-12-13T00:41:10-08:00', test_time.xmlschema)
		assert_equal('Tue, 13 Dec 2016 00:41:10 -0800', test_time.rfc822)
		assert_equal('Tue, 13 Dec 2016 08:41:10 GMT', test_time.httpdate)
		assert_equal('Tue Dec 13 00:41:10 2016', test_time.asctime)

		show_matches = ParsedCapture.show_matches([Reflog_timestamp], Git_reflog_timestamp_regexp_array)
		assert_match(Git_reflog_timestamp_regexp, Reflog_timestamp, show_matches.ruby_lines_storage)
	end # TimeTypes
	
	module Examples
    Match_a = { /(?<alpha>a)/ => [{ alpha: 'a' }] }.freeze
    Match_b = { /(?<beta>b)/ => [{ beta: 'b' }] }.freeze
    Unmatched_c = 'c'.freeze
    Ordered_matches = [Match_a, Match_b, Unmatched_c].freeze
		Empty_capture = MatchCapture.new(string: '', regexp: /a/)
		
		include TimeTypes
		include ReflogRegexp
    SHA1_hex_7 = /[[:xdigit:]]{7}/.capture(:sha1_hex_7)
    Reflog_line = 'master@{123},refs/heads/master@{123},1234567,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Reflog_capture = Reflog_line.capture?(Reflog_line_regexp)
    No_ref_line = ',,911dea1,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Stash_line = 'stash@{0},refs/stash@{0},bec64c4cd,Mon, 20 Mar 2017 11:55:03 -0700'.freeze
		Regexp_array_capture = MatchCapture.new(string: Stash_line, regexp: Regexp_array)
		Fail_array = Regexp_array[0..3] + [SHA1_hex_7] + Regexp_array[5..-1]
		Fail_array_capture = MatchCapture.new(string: Stash_line, regexp: Fail_array)
	end # Examples
	include Examples
	
  def test_symbolize_keys
    message = ''
    hash_of_array = { a: [1, 2] }
    assert_equal(hash_of_array, Capture.symbolize_keys(hash_of_array), message)
    array_of_hash = [{ a: 1 }, { b: 2 }]
    assert_equal(array_of_hash, Capture.symbolize_keys(array_of_hash), message)
  end # symbolize_keys

		def test_sequential_match
			assert(nil.to_a.empty?)
#?			assert(''.to_a.empty?)
			assert([].to_a.empty?)
		end # sequential_match

		def test_sequential_matches
#			assert_equal([{/a/ => 'a'}, 'b'], Capture.sequential_matches(['ab'], [/a/]))
#			assert_equal([/a/ => 'a', /b/ => 'b'], Capture.sequential_matches(['ab'], [/a/, /b/]))
#			assert_equal(['d', /a/.capture(:alpha) => {:alpha=>"a"}, /b/.capture(:beta) => {:beta=>"b"}], Capture.sequential_matches('dab', [/a/.capture(:alpha), /b/.capture(:beta)]))
		end # sequential_match
		
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
									Capture.priority_match(delimiter, regexp_array[1..-1]) # one try in priority order
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
#!		Capture.assert_show_matches(['dab'], [/a/.capture(:alpha), /b/.capture(:beta)], unmatches: ['d'], captures: [{:alpha=>"a"}, {:beta=>"b"}])
		assert_equal(Ordered_matches, Capture.priority_match(unmatched, regexp_array))
	end # priority_match
		
	def test_Capture_show_matches
		unmatches = ['abc']
		regexp_array = [/a/.capture(:alpha), /b/.capture(:beta)]
		unmatched = unmatches[0] # pick one out
		regexp = regexp_array[1] # pick one out
					capture = unmatched.capture?(regexp, SplitCapture)
		assert_instance_of(SplitCapture, capture)
		assert(capture.success?, capture.inspect)
		assert_equal([{:beta=>"b"}], capture.output, capture.inspect)
		ret = [ { regexp => capture.output}, Capture.show_matches(capture.delimiters, regexp_array) ]
#!		assert_equal([{/(?<beta>b)/=>[{:beta=>"b"}]}, [{/(?<alpha>a)/=>[{:alpha=>"a"}]}]], ret)
		assert_equal(Ordered_matches, Capture.show_matches(unmatches, regexp_array))
#		assert_equal(['b'], Capture.show_matches(['ab'], [/a/]))
#		assert_equal(['b'], Capture.show_matches(['ab'], [/a/, /b/]))

#		Capture.assert_show_matches(['dab'], [/a/.capture(:alpha), /b/.capture(:beta)], unmatches: ['d'], captures: [{:alpha=>"a"}, {:beta=>"b"}])
	end # show_matches

  def test_initialize
  end # values
		
	def test_to_regexp
	end # to_regexp
	

  def test_plus
  end # +
		
		def test_show_matches
		end # show_matches

  # Capture::Assertions
			def test_assert_unmatches
			end # assert_unmatches
			
			def test_assert_show_matches
		Capture.assert_show_matches(['ab'], [/a/], unmatches: ['b'])
		Capture.assert_show_matches(['ab'], [/a/], unmatches: ['b'], captures: [])
		Capture.assert_show_matches(['abc'], [/a/.capture(:alpha), /b/.capture(:beta)], unmatches: ['c'], captures: [{:alpha=>"a"}, {:beta=>"b"}])

#!		Capture.assert_show_matches(['dab'], [/a/.capture(:alpha), /b/.capture(:beta)], unmatches: ['d'], captures: [{:alpha=>"a"}, {:beta=>"b"}])
#!		Capture.assert_show_matches(['da'], [/a/.capture(:alpha)], unmatches: ['d'], captures: [{:alpha=>"a"}])
#!		Capture.assert_show_matches(['ab'], [/a/.capture(:alpha), /b/.capture(:beta)], captures: [{:alpha=>"a"}, {:beta=>"b"}])
#!		Capture.assert_show_matches(['aa'], [/a/.capture(:alpha), /b/.capture(:beta)], captures: [alpha: 'a'])
		unmatches = ['daebfc']
		regexp_array = [/a/.capture(:alpha), /b/.capture(:beta)]
		expectations = { unmatches: ['d', 'e', 'fc'], captures: [{:alpha=>"a"}, {:beta=>"b"}] }
		show_matches = Capture.show_matches(unmatches, regexp_array)
		unmatches = show_matches.select{|match| match.instance_of?(String)}
		unless expectations[:unmatches].nil?
#!			assert_equal(expectations[:unmatches], unmatches, 'Unmatches not expected.')
		end # unless
#!		Capture.assert_show_matches(['daebfc'], [/a/.capture(:alpha), /b/.capture(:beta)], unmatches: ['d', 'e', 'fc'], captures: [{:alpha=>"a"}, {:beta=>"b"}])
			end # assert_show_matches
			
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
    MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp).assert_success
    MatchCapture.new(string: '   ', regexp: /  /).assert_success
    MatchCapture.new(string: '  ', regexp: /  /).assert_success
    #	assert_raises(AssertionFailedError) {Failed_capture.assert_success}

    #	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}
    #	assert_raises(AssertionFailedError) {SplitCapture.new(string: 'cat', regexp: /fish/).assert_success}
#!    SplitCapture.new(string: 'cat', regexp: /cat/).assert_success
#!    SplitCapture.new(string: '  ', regexp: /  /).assert_success
  end # assert_success

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
  include CaptureTest::Examples

  def test_num_captures
    assert_equal(1, MatchCapture::Examples::Branch_line_capture.num_captures, MatchCapture::Examples::Branch_line_capture.inspect)
    assert_equal(2, MatchCapture::Examples::Branch_current_capture.num_captures, MatchCapture::Examples::Branch_current_capture.inspect)
  end # num_captures

  def test_Capture_to_hash
    capture = SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_line_regexp)
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
    assert_equal(Branch_hashes[0], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_current_regexp).to_hash)
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
    parse_string = MatchCapture.new(string: "* 1\n", regexp: Branch_regexp)
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
    parse_string = MatchCapture.new(string: "* 1\n", regexp: Branch_regexp)
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
    #	assert_equal(Branch_hashes, Capture.new(string: captures, regexp: regexp).output, captures.inspect) # return matched subexpressions
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
    assert_equal({ branch: '1' }, MatchCapture.new(string: "* 1\n", regexp: Branch_regexp).output) # return matched subexpressions
    assert(MatchCapture::Examples::Branch_line_capture.success?)
    assert_instance_of(MatchData, MatchCapture::Examples::Branch_line_capture.raw_captures)
    assert_equal(Branch_answer, MatchCapture::Examples::Branch_line_capture.output, MatchCapture::Examples::Branch_line_capture.inspect)
  end # output

  def test_SplitCapture_output
    column_output = Split_capture.string.capture?(Split_capture.regexp, SplitCapture).column_output
    #    assert_equal([Branch_column_answer], column_output, Split_capture.inspect)
    assert_equal([Branch_answer], Split_capture.string.capture?(Split_capture.regexp, SplitCapture).output, Split_capture.inspect)
    #	assert_equal([{:branch=>"1"}, {:branch=>"2"}], Parse_array.output, Parse_array.inspect)
    #	assert_equal(Branch_hashes, Capture.new(string: captures, regexp: regexp).output, captures.inspect) # return matched subexpressions
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

	def test_MatchCapture_priority_refinements

		remaining_regexes = nil
		assert_instance_of(Array, Regexp_array_capture.regexp)
		assert_nil(remaining_regexes)
			remaining_regexes = Regexp_array_capture.regexp
		refute_empty(Regexp_array_capture.string)
		refute_empty(remaining_regexes.to_a)
		assert_equal([], MatchCapture.new(string: Regexp_array_capture.pre_match, regexp: remaining_regexes[1..-1]).priority_refinements )
#		assert_equal(Regexp_array_capture.string, Regexp_array_capture.post_match, Regexp_array_capture.inspect)
#		refute_equal('', Regexp_array_capture.post_match, Regexp_array_capture.inspect)

		assert_match(Regexp_array[0], Stash_line)
		assert_match(Regexp_array[1], Stash_line)
		assert_match(Regexp_array[2], Stash_line)
		assert_match(Regexp_array[3], Stash_line)
		assert_match(Regexp_array[4], Stash_line)
		assert_match(Regexp_array[5], Stash_line)
		assert_match(Regexp_array[6], Stash_line)
		
		priority_refinements = Fail_array_capture.priority_refinements
		assert_equal(:scattered, priority_refinements.kind)
		Fail_array_capture.assert_refinement(:scattered)

#		assert_match(Reflog_line_regexp, Stash_line, Regexp_array_capture.priority_refinements.inspect)
#		assert_equal([], MatchCapture.new(string: Regexp_array_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements.inspect )
#		assert_equal([], MatchCapture.new(string: Regexp_array_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements )
			inside_narrowed_capture = Regexp_array_capture.narrowed_capture(remaining_regexes[0])
		assert_equal(MatchRefinement[inside_narrowed_capture], Regexp_array_capture.priority_refinements[0, 1])
		assert_equal('', inside_narrowed_capture.pre_match, inside_narrowed_capture.inspect)
#!		assert_equal(inside_narrowed_capture.string, inside_narrowed_capture.post_match, inside_narrowed_capture.inspect)

		refute_equal([], MatchCapture.new(string: inside_narrowed_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements )

		
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1])
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1])
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1])
#!		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements)
		assert_equal(["\n  2"], MatchCapture::Examples::Parse_string.priority_refinements[1..-1])
		assert_equal(['  2'], MatchCapture::Examples::Branch_line_capture.priority_refinements[1..-1])
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_current_capture.priority_refinements[1..-1])
		assert_equal(['  2'], SplitCapture::Examples::Split_capture.priority_refinements[1..-1])
		assert_equal([], Empty_capture.priority_refinements)

		assert_equal(7, Regexp_array_capture.regexp.size,  Regexp_array_capture.inspect)
		assert_equal(Delimiter, Regexp_array_capture.regexp[1],  Regexp_array_capture.inspect)
		assert_equal(Delimiter, Regexp_array_capture.regexp[3],  Regexp_array_capture.inspect)
		assert_equal(Delimiter, Regexp_array_capture.regexp[5],  Regexp_array_capture.inspect)
#!		assert_equal("{:type=>[nil, nil], :maturity=>[\"stash\", \"stash\"], :test_topic=>[nil, nil], :age=>[\"0\", \"0\"], :ref=>nil, :sha1_hex_short=>\"bec64c4cd\", :weekday=>\"Mon\", :day_of_month=>\"20\", :month=>\"Mar\", :year=>\"2017\", :hour=>\"11\", :minute=>\"55\", :second=>\"03\", :timezone=>\"-0700\"}", Regexp_array_capture.output.inspect)
	end # priority_refinements

	def test_next_refinement
		assert_equal([], Empty_capture.next_refinement([]))
		assert_equal(['b'], MatchCapture.new(string: 'ab', regexp: /a/).next_refinement([]))
		assert_equal([], MatchCapture.new(string: 'ab', regexp: /a/).next_refinement([/b/]))
		assert_equal([], MatchCapture.new(string: 'ab', regexp: /b/).next_refinement([]))
		assert_equal([], MatchCapture.new(string: 'ab', regexp: /b/).next_refinement([/a/]))
		assert_equal([], MatchCapture.new(string: 'ab', regexp: /b/).next_refinement([/a/, /b/]))
	end # next_refinement
	
	def test_MatchCapture_sequential_refinements
			capture = MatchCapture.new(string: 'a', regexp: /a/)
			refute_empty(capture.string)
			assert(capture.success?)
			assert_equal(MatchRefinement[], MatchRefinement[] + MatchRefinement[])
			assert_instance_of(MatchRefinement, capture.next_refinement)
			compose = MatchRefinement[capture.pre_match, capture] + capture.next_refinement
			assert_instance_of(MatchRefinement, compose)
			ret = MatchRefinement.new(compose)
			sequential_refinements = capture.sequential_refinements
			assert_equal(sequential_refinements, ret)
			assert_instance_of(MatchRefinement, ret)
			assert_instance_of(MatchRefinement, sequential_refinements)
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements([])[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements()[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements([MatchCapture::Examples::Branch_capture.regexp])[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Parse_string.sequential_refinements[1..-1])
				assert_equal(['  2'], MatchCapture::Examples::Branch_line_capture.sequential_refinements[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_current_capture.sequential_refinements[1..-1])
	end # sequential_refinements

  def test_internal_delimiters
    assert_equal([], Split_capture.internal_delimiters)
  end # internal_delimiters

	def test_RawCapture_ruby_lines_storage
#!		assert_equal("SplitCapture.new(string: 'cat',\n   regexp: /fish/)\n", SplitCapture::Examples::Failed_capture.ruby_lines_storage)
#!		assert_reversible(SplitCapture::Examples::Failed_capture)
#!		assert_reversible(MatchCapture::Examples::Branch_capture)
	end # ruby_lines_storage

			def test_unmatches
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.unmatches)
				assert_equal(["\n  2"], MatchCapture::Examples::Parse_string.unmatches)
				assert_equal(['  2'], MatchCapture::Examples::Branch_line_capture.unmatches)
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_current_capture.unmatches)
				assert_equal(['  2'], SplitCapture::Examples::Split_capture.unmatches)
    assert_equal(%W(\n \n), SplitCapture::Examples::Parse_array.unmatches)
				assert_equal(['  2'], SplitCapture::Examples::Branch_line_capture.unmatches)
				assert_equal(["\n"], SplitCapture::Examples::Branch_regexp_capture.unmatches)
				assert_equal(['cat'], SplitCapture::Examples::Failed_capture.unmatches)
				assert_equal(['cat'], SplitCapture::Examples::Syntax_failed_capture.unmatches)
				assert_equal(["\n"], SplitCapture::Examples::Parse_delimited_array.unmatches)
#!				assert_equal([], ParsedCapture::Examples::Parsed_aa_capture.unmatches)
#!				assert_equal([], ParsedCapture::Examples::Parsed_a_capture.unmatches)
			end # assert_unmatches

	def test_MatchCapture_assert_refinement
				MatchCapture::Examples::Branch_capture.assert_refinement(:left)
				MatchCapture::Examples::Parse_string.assert_refinement(:left)
				MatchCapture::Examples::Branch_line_capture.assert_refinement(:left)
				MatchCapture::Examples::Branch_current_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Split_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Parse_array.assert_refinement(:left)
#!				SplitCapture::Examples::Branch_line_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Branch_regexp_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Failed_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Syntax_failed_capture.assert_refinement(:left)
#!				SplitCapture::Examples::Parse_delimited_array.assert_refinement(:left)
		Empty_capture.assert_refinement(:no_matches)
		Reflog_capture.assert_refinement(:exact)
#!		assert_equal('', Regexp_array_capture.priority_refinements[0].inspect)
#!		Regexp_array_capture.assert_refinement(:exact)
#!		MatchCapture.new(string: Reflog_line, regexp: Regexp_array).assert_refinement(:exact)
#!		MatchCapture.new(string: No_ref_line, regexp: Regexp_array).assert_refinement(:exact)
	end # assert_refinement

	def test_assert_sequential
		assert_equal(Branch_capture.string, Branch_capture.sequential_refinements.join, Branch_capture.inspect)
		assert_equal("* 1\n  2", Branch_capture.sequential_refinements.join, Branch_capture.sequential_refinements.inspect)
		assert_equal(Branch_capture.priority_refinements.join, Branch_capture.sequential_refinements.join, Branch_capture.inspect)
				MatchCapture::Examples::Branch_capture.assert_sequential(:left)
				MatchCapture::Examples::Parse_string.assert_sequential(:left)
				MatchCapture::Examples::Branch_line_capture.assert_sequential(:left)
				MatchCapture::Examples::Branch_current_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Split_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Parse_array.assert_sequential(:left)
#!				SplitCapture::Examples::Branch_line_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Branch_regexp_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Failed_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Syntax_failed_capture.assert_sequential(:left)
#!				SplitCapture::Examples::Parse_delimited_array.assert_sequential(:left)
		Empty_capture.assert_sequential(:no_matches)
		Reflog_capture.assert_sequential(:exact)
#!		assert_equal('', Regexp_array_capture.priority_refinements[0].inspect)
#!		Regexp_array_capture.assert_sequential(:exact)
#!		MatchCapture.new(string: Reflog_line, regexp: Regexp_array).assert_sequential(:exact)
#!		MatchCapture.new(string: No_ref_line, regexp: Regexp_array).assert_sequential(:exact)
		end # assert_sequential
end # RawCapture

class MatchCaptureTest < TestCase
  include MatchCapture::Examples
  include Capture::Examples

  def test_MatchData_raw_captures
    assert_instance_of(MatchData, MatchCapture.new(string: "* 1\n", regexp: Branch_regexp).raw_captures)
  end # raw_captures

  def test_MatchCapture_success?
    assert(MatchCapture::Examples::Branch_line_capture.success?)
    assert_equal(nil, MatchCapture.new(string: 'cat', regexp: /fish/).success?)
  end # success?

  def test_MatchCapture_repetitions
    parse_string = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    assert_equal(1, parse_string.repetitions)
  end # repetitions

  def test_MatchCapture_to_a
		assert_equal([], nil.to_a)
  end # to_a

  def test_MatchCapture_post_match
  end # post_match

  def test_MatchCapture_pre_match
    assert_equal('', MatchCapture.new(string: 'a', regexp: /a/).pre_match)
    assert_equal('b', MatchCapture.new(string: 'ba', regexp: /a/).pre_match)
    assert_equal('', MatchCapture.new(string: 'a', regexp: /a/.capture(:a)).pre_match)
    assert_equal('', MatchCapture.new(string: 'b', regexp: /a/).pre_match)
  end # pre_match

  def test_MatchCapture_matched_characters
    assert_equal('a', MatchCapture.new(string: 'a', regexp: /a/).matched_characters)
    assert_equal('a', MatchCapture.new(string: 'a', regexp: /a/).matched_characters)
    assert_equal('a', MatchCapture.new(string: 'ab', regexp: /a/.capture(:a)).matched_characters)
    assert_equal("* 1\n", MatchCapture::Examples::Branch_line_capture.matched_characters)
  end # matched_characters

  def test_MatchCapture_number_matched_characters
    assert_equal(4, MatchCapture::Examples::Branch_line_capture.number_matched_characters)
  end # number_matched_characters

  def test_MatchCapture_column_output
  end # column_output

  def test_MatchCapture_delimiters
    assert_equal(['', '  2'], MatchCapture::Examples::Branch_line_capture.delimiters, MatchCapture::Examples::Branch_line_capture.inspect)
		assert_equal(['', 'd'], 'ad'.capture?(/a/, MatchCapture).delimiters)
		assert_equal(['d', ''], 'da'.capture?(/a/, MatchCapture).delimiters)
  end # delimiters

	def test_narrowed_capture
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Parse_string.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_line_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_current_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Empty_capture.narrowed_capture)
	end # narrowed_capture

	def test_MatchCapture_priority_refinements

		remaining_regexes = nil
		assert_instance_of(Array, CaptureTest::Examples::Regexp_array_capture.regexp)
		assert_nil(remaining_regexes)
			remaining_regexes = CaptureTest::Examples::Regexp_array_capture.regexp
		refute_empty(CaptureTest::Examples::Regexp_array_capture.string)
		refute_empty(remaining_regexes.to_a)
		assert_equal([], MatchCapture.new(string: CaptureTest::Examples::Regexp_array_capture.pre_match, regexp: remaining_regexes[1..-1]).priority_refinements )
#		assert_equal(CaptureTest::Examples::Regexp_array_capture.string, CaptureTest::Examples::Regexp_array_capture.post_match, CaptureTest::Examples::Regexp_array_capture.inspect)
#		refute_equal('', CaptureTest::Examples::Regexp_array_capture.post_match, CaptureTest::Examples::Regexp_array_capture.inspect)

		assert_match(CaptureTest::Examples::Regexp_array[0], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[1], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[2], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[3], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[4], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[5], CaptureTest::Examples::Stash_line)
		assert_match(CaptureTest::Examples::Regexp_array[6], CaptureTest::Examples::Stash_line)
		
		priority_refinements = CaptureTest::Examples::Fail_array_capture.priority_refinements
		assert_equal(:scattered, priority_refinements.kind)
		CaptureTest::Examples::Fail_array_capture.assert_refinement(:scattered)

#		assert_match(Reflog_line_regexp, Stash_line, CaptureTest::Examples::Regexp_array_capture.priority_refinements.inspect)
#		assert_equal([], MatchCapture.new(string: CaptureTest::Examples::Regexp_array_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements.inspect )
#		assert_equal([], MatchCapture.new(string: CaptureTest::Examples::Regexp_array_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements )
			inside_narrowed_capture = CaptureTest::Examples::Regexp_array_capture.narrowed_capture(remaining_regexes[0])
		assert_equal(MatchRefinement[inside_narrowed_capture], CaptureTest::Examples::Regexp_array_capture.priority_refinements[0, 1])
		assert_equal('', inside_narrowed_capture.pre_match, inside_narrowed_capture.inspect)
#!		assert_equal(inside_narrowed_capture.string, inside_narrowed_capture.post_match, inside_narrowed_capture.inspect)

		refute_equal([], MatchCapture.new(string: inside_narrowed_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements )

		
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1], MatchCapture::Examples::Branch_capture.priority_refinements)
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1])
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements[1..-1])
#!		assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.priority_refinements)
		assert_equal(["\n  2"], MatchCapture::Examples::Parse_string.priority_refinements[1..-1])
		assert_equal(['  2'], MatchCapture::Examples::Branch_line_capture.priority_refinements[1..-1])
		assert_equal(["\n  2"], MatchCapture::Examples::Branch_current_capture.priority_refinements[1..-1])
		assert_equal(['  2'], SplitCapture::Examples::Split_capture.priority_refinements[1..-1])
		assert_equal([], Empty_capture.priority_refinements)

		assert_equal(7, CaptureTest::Examples::Regexp_array_capture.regexp.size,  CaptureTest::Examples::Regexp_array_capture.inspect)
		assert_equal(CaptureTest::Examples::Delimiter, CaptureTest::Examples::Regexp_array_capture.regexp[1],  CaptureTest::Examples::Regexp_array_capture.inspect)
		assert_equal(CaptureTest::Examples::Delimiter, CaptureTest::Examples::Regexp_array_capture.regexp[3],  CaptureTest::Examples::Regexp_array_capture.inspect)
		assert_equal(CaptureTest::Examples::Delimiter, CaptureTest::Examples::Regexp_array_capture.regexp[5],  CaptureTest::Examples::Regexp_array_capture.inspect)
#!		assert_equal("{:type=>[nil, nil], :maturity=>[\"stash\", \"stash\"], :test_topic=>[nil, nil], :age=>[\"0\", \"0\"], :ref=>nil, :sha1_hex_short=>\"bec64c4cd\", :weekday=>\"Mon\", :day_of_month=>\"20\", :month=>\"Mar\", :year=>\"2017\", :hour=>\"11\", :minute=>\"55\", :second=>\"03\", :timezone=>\"-0700\"}", CaptureTest::Examples::Regexp_array_capture.output.inspect)
	end # priority_refinements

  def test_MatchCapture_Examples
  end # Examples
end # MatchCapture

class SplitCaptureTest < TestCase
  include SplitCapture::Examples
  include Capture::Examples
  include String::Examples

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
    assert_instance_of(Array, SplitCapture.new(string: "* 1\n", regexp: Branch_regexp).raw_captures)
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
    assert(SplitCapture.new(string: '  ', regexp: /  /).success?)
    '  '.assert_parse(/  /)
  end # success?

  def test_SplitCapture_repetitions
    length_hash_captures = Parse_array.num_captures
    assert_equal(1, Parse_array.num_captures, Parse_array.raw_captures.inspect + Parse_array.regexp.named_captures.inspect)
    repetitions = (Parse_array.raw_captures.size / length_hash_captures).ceil
    #	assert_equal(2, Parse_array.repetitions)
    parse_delimited_array = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    #	assert_equal(0, .repetitions)
    assert_equal(1, parse_delimited_array.repetitions)

    Split_capture.assert_repetitions(1)
    Parse_array.assert_repetitions(2)
    Branch_line_capture.assert_repetitions(1)
    Branch_regexp_capture.assert_repetitions(2)
    Parse_delimited_array.assert_repetitions(2)
    Failed_capture.assert_repetitions(0)
    Syntax_failed_capture.assert_repetitions(0)

    assert_equal(2, SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp).repetitions)
  end # repetitions

  def test_SplitCapture_to_a
    parse_string = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    parse_delimited_array = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)

    #	assert_equal(parse_string.to_a.join, parse_delimited_array.to_a.join)
    #	assert_equal(parse_string.to_a, parse_delimited_array.to_a)
    assert_equal(['1'], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_line_regexp).to_a(0))
    assert_equal(['1'], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp).to_a(0))
    assert_equal(['2'], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_regexp).to_a(1))
    assert_equal(['2'], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_line_regexp).to_a(1))
    assert_equal(['2'], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp).to_a(1))
    assert_equal([], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp).to_a(1))
  end # to_a
	
	def test_narrowed_capture
			assert_instance_of(SplitCapture, SplitCapture::Examples::Split_capture.narrowed_capture)
			assert_instance_of(SplitCapture, Empty_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Parse_string.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_line_capture.narrowed_capture)
			assert_instance_of(MatchCapture, MatchCapture::Examples::Branch_current_capture.narrowed_capture)
	end # narrowed_capture
	
	def test_SplitCapture_sequential_refinements
			capture = MatchCapture.new(string: 'a', regexp: /a/)
			refute_empty(capture.string)
			assert(capture.success?)
			assert_equal(MatchRefinement[], MatchRefinement[] + MatchRefinement[])
			assert_instance_of(MatchRefinement, capture.next_refinement)
			compose = MatchRefinement[capture.pre_match, capture] + capture.next_refinement
			assert_instance_of(MatchRefinement, compose)
			ret = MatchRefinement.new(compose)
			sequential_refinements = capture.sequential_refinements
			assert_equal(sequential_refinements, ret)
			assert_instance_of(MatchRefinement, ret)
			assert_instance_of(MatchRefinement, sequential_refinements)
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements([])[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements()[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_capture.sequential_refinements([MatchCapture::Examples::Branch_capture.regexp])[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Parse_string.sequential_refinements[1..-1])
				assert_equal(['  2'], MatchCapture::Examples::Branch_line_capture.sequential_refinements[1..-1])
				assert_equal(["\n  2"], MatchCapture::Examples::Branch_current_capture.sequential_refinements[1..-1])
				assert_equal(['  2'], SplitCapture::Examples::Split_capture.sequential_refinements[1..-1])
#!				assert_equal(["\n", "\n"], SplitCapture::Examples::Parse_array.sequential_refinements[1..-1], SplitCapture::Examples::Parse_array.inspect)
				assert_equal(['  2'], SplitCapture::Examples::Branch_line_capture.sequential_refinements[1..-1])
#!				assert_equal(["\n"], SplitCapture::Examples::Branch_regexp_capture.sequential_refinements[1..-1])
#!				assert_equal(['cat'], SplitCapture::Examples::Failed_capture.sequential_refinements[1..-1])
#!				assert_equal(['cat'], SplitCapture::Examples::Syntax_failed_capture.sequential_refinements[1..-1])
#!				assert_equal(["\n"], SplitCapture::Examples::Parse_delimited_array.sequential_refinements[1..-1])
	end # sequential_refinements

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
	
	def test_raw_capture_size_state
		capture = 'da'.capture?(/a/, SplitCapture)
#!		assert_equal(capture.raw_capture_size_state[:expected_raw_size], capture.raw_capture_size_state[:raw_captures_size], capture.raw_capture_size_state)
		capture.assert_post_conditions
	end # raw_capture_size_state
	
	def test_terminations # last match at end of string
		assert_equal(0, Split_capture.raw_capture_size_state[:terminations], Split_capture.raw_capture_size_state)
		capture = 'da'.capture?(/a/, SplitCapture)
		assert_equal(1, capture.raw_captures.size, capture.inspect)
		assert_equal(0, capture.num_captures, capture.inspect)
		assert_equal(0, ( capture.raw_captures.size  % (capture.num_captures + 1)), capture.inspect)
		capture = 'ad'.capture?(/a/, SplitCapture)
		assert_equal(2, capture.raw_captures.size, capture.inspect)
		assert_equal(0, capture.num_captures, capture.inspect)
		capture.assert_terminations(0)
		assert_equal(0, capture.terminations, capture.inspect)
	end # terminations

  def test_SplitCapture_delimiters
    delimited_line = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
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
		capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    assert_equal(['', '  2'], capture.delimiters, capture.inspect)
#!    assert_equal(['', ''], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_line_regexp).delimiters)
#!    assert_equal(['', "\n"], SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_current_regexp).delimiters)
    assert_equal(['', "\n", "\n"], SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_current_regexp).delimiters)
    #	assert_equal([], Parse_string.delimiters)
    #	assert_equal(["\n"], Parse_array.delimiters, Parse_array.inspect)
#!    assert_equal(['', "\n"], Branch_regexp_capture.delimiters, Branch_regexp_capture.inspect)
    message = "Split_capture = #{Split_capture.inspect}"
    assert_equal(3, Split_capture.raw_captures.size, message)
    assert_equal(2..1, (2..Split_capture.raw_captures.size - 2), message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }, message)
    assert_equal([], (2..Split_capture.raw_captures.size - 2).map { |i| (i.even? ? raw_captures[i] : nil) }.compact, message)
    assert_includes(Capture::Assertions::ClassMethods.instance_methods, :assert_method, message)
    assert_includes(Capture.methods, :assert_method, message)
    #	Capture::Assertions::ClassMethods.assert_method(MatchCapture::Examples::Branch_line_capture, Limit_capture, :delimiters, message)
		assert_equal(['', 'd'], 'ad'.capture?(/a/, SplitCapture).delimiters)
		capture = 'da'.capture?(/a/, SplitCapture)
		assert_equal(['d', ''], capture.delimiters, capture.inspect)
  end # delimiters

	def test_assert_post_conditions
    Split_capture.assert_post_conditions
    Parse_array.assert_post_conditions
    Branch_line_capture.assert_post_conditions
    Branch_regexp_capture.assert_post_conditions
    Failed_capture.assert_post_conditions
    Syntax_failed_capture.assert_post_conditions
    Parse_delimited_array.assert_post_conditions
	end #assert_post_conditions
	
	def test_assert_terminations
    Split_capture.assert_terminations(0)
    Parse_array.assert_terminations(0)
    Branch_line_capture.assert_terminations(0)
    Branch_regexp_capture.assert_terminations(1)
    Failed_capture.assert_terminations(1)
    Syntax_failed_capture.assert_terminations(1)
    Parse_delimited_array.assert_terminations(1)
	end # assert_terminations
	
	def test_assert_repetitions
    Split_capture.assert_repetitions(1)
    Parse_array.assert_repetitions(2)
    Branch_line_capture.assert_repetitions(1)
    Branch_regexp_capture.assert_repetitions(2)
    Parse_delimited_array.assert_repetitions(2)
    Failed_capture.assert_repetitions(0)
    Syntax_failed_capture.assert_repetitions(0)
	end # assert_repetitions

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

  def test_ParsedCapture_initialize
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + Parsed_a_capture.inspect
		assert_equal('a,a,', Parsed_a_capture.string, message)
		assert_equal(true, Parsed_a_capture.success?, message)
  end # ParsedCapture_initialize

  def test_ParsedCapture_raw_captures
		quantified_parse = Parsed_a_capture.parsed_regexp
#!		assert_includes(quantified_parse.instance_variables, :@quantifier, quantified_parse.inspect)
#		refute_includes(quantified_parse.instance_variables, :@quantifier)
		assert_instance_of(Array, quantified_parse.expressions)
		message = Parsed_a_capture.parsed_regexp.inspect
		message += "\n" + quantified_parse.inspect
		assert_equal('a,a,', Parsed_a_capture.string, message)
		assert_instance_of(MatchCapture, ParsedCapture::Examples::Parsed_a_capture.raw_captures, message)

		assert_instance_of(MatchCapture, ParsedCapture.new(string: 'a,a,', regexp: /a{2}/.capture(:label)).raw_captures)

  end # raw_captures

	def test_to_nested_array
	end # to_nested_array
		
	def test_ruby_lines_storage
#!		ruby_lines_storage = Parsed_a_capture.ruby_lines_storage
#!		assert_match(/   a{2}/, ruby_lines_storage, ruby_lines_storage)
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
#!		assert_equal([','], Parsed_a_capture.delimiters, message)
  end # delimiters
			
			def test_assert_post_conditions
			end #assert_post_conditions
			
end # ParsedCapture

class LimitCaptureTest < TestCase
  include MatchCapture::Examples
  include SplitCapture::Examples
  include LimitCapture::Examples
  include Capture::Examples
  include String::Examples

  def test_LimitCapture_raw_captures
    limit_capture = LimitCapture.new(string: "* 1\n", regexp: Branch_regexp)
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
#!    Capture.assert_method(MatchCapture::Examples::Branch_line_capture, Limit_capture, :delimiters, message)
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
    match_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: pattern)
    split_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: pattern)
    limit_capture = SplitCapture.new(string: Newline_Delimited_String[0, match_capture.number_matched_characters], regexp: pattern)
    message = "match_capture = #{match_capture.inspect}\nlimit_capture = #{limit_capture.inspect}"
#!    assert_equal(match_capture.output, limit_capture.output, message)
    #	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)
  end # assert_parse_once
end # String

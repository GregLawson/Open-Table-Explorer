###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/parse.rb'
class ParseTest < TestCase
include Capture::Examples
include String::Examples
include DefaultTests
def test_default_name
	index=11
	prefix='Col_'
	prefix+index.to_s
	assert_equal('Col_1', Capture.default_name(1))
	assert_equal('name', Capture.default_name(0, 'name'))
	assert_equal('name3', Capture.default_name(3, 'name'))
	assert_equal('Var_1', Capture.default_name(1, 'Var_', :numbered))
end #default_name
def test_Capture_initialize
	length_hash_captures=Parse_array.regexp.named_captures.values.flatten.size
	repetitions=(Parse_array.captures.size/length_hash_captures).ceil
	assert_equal(1, Parse_array.length_hash_captures, Parse_array.captures.inspect+Parse_array.regexp.named_captures.inspect)
	assert_equal(2, Parse_array.repetitions)
	assert_equal(["\n"], Parse_delimited_array.captures[2..2], Parse_string.captures.inspect)
	assert_equal("\n", Parse_delimited_array.captures[2])
	assert_equal([], Parse_string.delimiters)
	assert_equal([2, 3], (2..Parse_array.captures.size - 2).map {|i| i}, Parse_array.inspect)
	assert_equal([true, false], (2..Parse_array.captures.size - 2).map {|i| i.even?})
	assert_equal(["\n", '2'], (2..Parse_array.captures.size - 2).map {|i| Parse_array.captures[i]})
	assert_equal(["\n"], (2..Parse_array.captures.size - 2).map {|i| (i.even? ? Parse_array.captures[i] : nil)}.compact)
	assert_equal(["\n"], Parse_array.delimiters, Parse_array.inspect)

	assert_equal([2], (2..Parse_delimited_array.captures.size - 2).map {|i| i}, Parse_delimited_array.inspect)
	assert_equal([true], (2..Parse_delimited_array.captures.size - 2).map {|i| i.even?})
	assert_equal(["\n"], (2..Parse_delimited_array.captures.size - 2).map {|i| Parse_delimited_array.captures[i]})
	assert_equal(["\n"], (2..Parse_delimited_array.captures.size - 2).map {|i| (i.even? ? Parse_delimited_array.captures[i] : nil)}.compact)
	assert_equal(["\n"], Parse_delimited_array.delimiters, Parse_array.inspect)
	assert_equal(4, Parse_delimited_array.captures.size, Parse_delimited_array.inspect)
	assert_equal(false, Parse_delimited_array.captures.size.odd?, Parse_delimited_array.inspect)
	assert_equal('', Parse_delimited_array.post_match, Parse_delimited_array.inspect)


	assert_equal("\n  2", Parse_string.post_match)
	assert_equal(["\n"], Parse_delimited_array.delimiters, Parse_delimited_array.inspect)
	assert_equal({:branch => '1'}, Capture.new(Branch_regexp.match("* 1\n"), Branch_regexp).output) # return matched subexpressions
	assert_equal([{:branch=>"1"}, {:branch=>"2"}], Parse_array.output, Parse_array.inspect)
#	assert_equal(Array_answer, Capture.new(captures, regexp).output, captures.inspect) # return matched subexpressions
end #initialize
def test_all_capture_indices
#	Parse_string
	string="* 1\n"
	regexp=Branch_regexp
	matchData=string.match(regexp)
	captures=matchData
	assert_equal(2, captures.size, captures.inspect)
	message="matchData="+matchData.inspect
	puts message
	if captures.instance_of?(MatchData) then
		possible_unnamed_capture_indices=(1..captures.size-1).to_a
	else
		possible_unnamed_capture_indices=(1..captures.size-1).to_a
	end #if
	assert_equal(possible_unnamed_capture_indices, Capture.new(matchData, regexp).all_capture_indices)
	splitData=string.split(regexp)
	captures=splitData
	assert_instance_of(Array, captures)
	if captures.instance_of?(MatchData) then
		possible_unnamed_capture_indices=(1..captures.captures.size-1).to_a
	else
		possible_unnamed_capture_indices=(1..captures.size-1).to_a
	end #if
	assert_equal((1..captures.size-1).to_a, possible_unnamed_capture_indices)
	named_hash={}
	assert_equal(possible_unnamed_capture_indices, Capture.new(splitData, regexp).all_capture_indices)
	assert_equal([1], Parse_string.all_capture_indices, Parse_string.all_capture_indices)
#	assert_equal([1], Parse_array.all_capture_indices, Parse_array.inspect)
end #all_capture_indices
def test_named_hash
	string="* 1\n"
	regexp=Branch_regexp
	message = 'regexp.inspect = ' + regexp.inspect
	matchData=string.match(regexp)
	captures=matchData #[1..-1]
#	parse_string=Capture.new("* 1\n", Branch_regexp)
	assert_equal(2, Parse_string.captures.size, Parse_string.inspect)
	possible_unnamed_capture_indices=Parse_string.all_capture_indices
	Parse_string.named_hash
	named_hash={}
	assert_equal([1], possible_unnamed_capture_indices, captures.inspect+"\n"+captures.captures.inspect)
	regexp.names.each do |n| # return named subexpressions
		assert_instance_of(String, n, message)
		named_hash[n.to_sym]=captures[n]
	end # each
	named_hash
	assert_equal({:branch => '1'}, named_hash) # return matched subexpressions
	splitData=string.split(regexp)
	captures=splitData #[1..-1]
	possible_unnamed_capture_indices=Parse_array.all_capture_indices
#	assert_equal([1], possible_unnamed_capture_indices, Parse_array.all_capture_indices)
#	assert_equal([1], Parse_array.all_capture_indices, Parse_array.all_capture_indices)
	named_hash={}
	assert_equal({'branch' => [1]}, regexp.named_captures)
	regexp.named_captures.each_pair do |named_capture, indices| # return named subexpressions
		assert_instance_of(String, named_capture, message)
		name=Capture.default_name(0, named_capture).to_sym
		assert_equal(:branch, name)
		named_hash[name]=captures[indices[0]]
		assert_equal({:branch => '1'}, named_hash)
#		assert_equal(possible_unnamed_capture_indices, Parse_array.all_capture_indices, )
#		assert_equal([1], possible_unnamed_capture_indices, Parse_array.all_capture_indices)
		assert_equal(1, indices[0])
		assert_equal([1], [indices[0]])
#		possible_unnamed_capture_indices-=[indices[0]]
#		assert_not_equal(possible_unnamed_capture_indices, Parse_array.all_capture_indices, )
#		assert_equal([], possible_unnamed_capture_indices, possible_unnamed_capture_indices.inspect)
		if indices.size>1 then
			indices[1..-1].each_index do |capture_index,i|
				name= Capture.default_name(i, named_capture).to_sym
				named_hash[name]=captures[capture_index]
				assert_equal(named_hash[name], captures[capture_index])
#				possible_unnamed_capture_indices-=[capture_index]
#				assert_not_equal(possible_unnamed_capture_indices, Parse_array.all_capture_indices, )
			end #each_index
		end #if
	end # each_pair
#	assert_equal([], possible_unnamed_capture_indices, possible_unnamed_capture_indices.inspect)
	assert_equal('', captures[0], regexp.named_captures.inspect+"\n"+captures.inspect)
#	assert_equal([], possible_unnamed_capture_indices, regexp.named_captures.inspect+"\n"+captures.inspect)
#	possible_unnamed_capture_indices.each do |capture_index|
#		name=Capture.default_name(capture_index).to_sym
#		named_hash[name]=captures[capture_index]
#	end #each
	assert_equal({:branch => '1'}, named_hash, regexp.inspect+"\n"+captures.inspect)
#	assert_equal(Array_answer, Capture.new(captures, regexp).output, captures.inspect) # return matched subexpressions
end #named_hash

# Capture::Assertions
def test_Capture_assert_pre_conditions
	Parse_string.assert_pre_conditions
	Parse_array.assert_pre_conditions
end # assert_pre_conditions
def test_Capture_assert_post_conditions
	assert_not_equal('', Parse_string.post_match)
	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
	assert_raises(AssertionFailedError) {Parse_delimited_array.assert_post_conditions}
	assert_equal('', Parse_delimited_array.post_match, Parse_delimited_array.inspect)
#	Parse_array.assert_post_conditions
end # assert_post_conditions

def test_Capture_Examples
	Parse_string.assert_pre_conditions
	Parse_array.assert_pre_conditions
	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
	assert_raises(AssertionFailedError) {Parse_array.assert_post_conditions}
end # Examples
# String
def test_parse_unrepeated
	assert_equal(Hash_answer, Newline_Delimited_String.parse_unrepeated(Terminated_line))
	assert_equal(Hash_answer, Newline_Terminated_String.parse_unrepeated(Terminated_line))
end # parse_unrepeated
def test_String_parse_repetition
#	assert_parse_string(Hash_answer, Newline_Delimited_String, Terminated_line, '')
#	assert_parse_string(Hash_answer, Newline_Terminated_String, Terminated_line, "")
#	string=Newline_Terminated_String
	pattern=Terminated_line
#	assert_equal(Hash_answer, parse_string(string, pattern), "string.match(pattern)=#{string.match(pattern).inspect}")

	assert_equal(Array_answer, Newline_Terminated_String.parse_repetition(Terminated_line))
	assert_equal([Hash_answer], Newline_Delimited_String.parse_repetition(Terminated_line))
end # parse_repetition
def test_String_match?
	assert_equal([Hash_answer], Newline_Delimited_String.parse_repetition(Terminated_line))
	pattern = Terminated_line
	ret = Newline_Delimited_String.parse_repetition(pattern)
	assert_instance_of(Array, ret)
	assert_not_equal(1, Array_answer.size, Array_answer)
	assert_equal(1, ret.size, ret)
	
		match_unrepeated = Newline_Delimited_String.match_unrepeated(pattern)
		split = Newline_Delimited_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
	assert_equal([match_unrepeated.output], split.output)

		match_unrepeated = Newline_Terminated_String.match_unrepeated(pattern)
		split = Newline_Terminated_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
	assert_equal([match_unrepeated.output], split.output)
end # match?
def test_String_parse
	assert_equal(Hash_answer, Newline_Delimited_String.parse(Terminated_line), self.inspect)
#	assert_equal(Array_answer, Newline_Terminated_String.parse(Terminated_line.group*'*'), self.inspect)
#	assert_equal(Array_answer, Newline_Terminated_String.parse(Terminated_line), self.inspect)
end # parse
def test_add_parse_message
#	assert_match(/match\(/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
#	assert_match(/test_add_parse_message/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
end #add_parse_message
end #Parse

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
include MatchCapture::Examples
#include SplitCapture::Examples
#include LimitCapture::Examples
include Capture::Examples
include String::Examples
include DefaultTests
include Parse::ClassMethods # treat class methods like module methods as local to test class
include Parse::Examples
include Parse::Assertions::ClassMethods
def test_Constants
#	assert_equal(LINES, LINES_cryptic)
#	assert_equal(Terminated_line, Terminated_line_cryptic)
	assert_parse_string(Hash_answer, Newline_Delimited_String, Terminated_line, '')
	assert_parse_string(Hash_answer, Newline_Terminated_String, Terminated_line, "")
#	assert_parse_sequence(Hash_answer, Newline_Terminated_String, Terminated_line, Terminated_line*End_string, "assert_parse_sequence")
#	assert_parse_sequence(Hash_answer, Newline_Terminated_String, Start_string*Terminated_line, Terminated_line*End_string, "assert_parse_sequence")
	string=Newline_Terminated_String
	pattern=Parse::Terminated_line
	assert_equal(Hash_answer, parse_string(string, pattern), "string.match(pattern)=#{string.match(pattern).inspect}")
end #Constants


def test_parse_string
	string="* 1\n"
	pattern=Branch_regexp
	matchData=string.match(Branch_regexp)
	assert_equal(['1'], matchData[1..-1], matchData.inspect) # return matched subexpressions
	assert_equal({:branch => '1'}, parse_string(string, Branch_regexp)) # return matched subexpressions
	assert_parse_string({:branch => '1'}, string, Branch_regexp) # return matched subexpressions
	assert_equal(["branch"], Branch_regexp.names, matchData)
	ret=if matchData.nil? then
    []
	elsif matchData.names==[] then
		assert_equal(Hash_answer, matchData[1..-1], matchData) # return unnamed subexpressions
	else
		nc=pattern.named_captures
		assert_not_nil(nc)
		assert_not_empty(nc)
		named_hash={}
		matchData.names.each do |n| # return named subexpressions
			named_hash[n.to_sym]=matchData[n]
		end # each
		named_hash
	end #if
	assert_equal(Hash_answer, parse_string(string, Parse::Terminated_line), "matchData=#{matchData.inspect}")
	assert_equal(Hash_answer, parse_string(string), "matchData=#{matchData.inspect}")
#	assert_equal(Hash_answer, parse_string("1 2", Parse::WORD))
#	assert_equal({:a => "1", :b => "2"}, '12'.match(/\d/.capture(:a)*/\d+/.capture(:b)))
#	assert_equal({:a => "1", :b => "2"}, parse_string(string, Parse::Terminated_line.capture(:a)*Parse::Terminated_line.capture(:b)))
end #parse_string
def test_parse_into_array
	string=Newline_Terminated_String
	pattern=Terminated_line
	options={:ending => :delimiter}
	parse_into_array=parse_into_array(string, pattern, options)
	assert_equal(Hash_answer, parse_into_array[0])
	parse_into_array=parse_into_array(string, Branch_regexp, options)
	assert_equal(Array_answer, parse_into_array)
end #parse_into_array
def test_parse_array
	string_array=name2array(parse(Nested_string, Terminated_line), :line)
	pattern=WORD
	answer=Nested_answer
	assert_equal(["1", "2"], Parse.name2array(parse("1 2", WORD), :word))
	assert_equal(["3", "4"], Parse.name2array(parse("3 4", WORD), :word))
	assert_equal(Nested_answer, name2array(parse_array(name2array(parse(Nested_string, Terminated_line), :line), WORD), :word))
	ret=string_array.map do |string|
		parse_into_array(string,pattern)
	end #map
	assert_equal(ret, parse_array(string_array, WORD))	
end #parse_array
def test_parse
	string_or_array=Nested_string
	answer=Nested_answer
	pattern=WORD
	if string_or_array.instance_of?(String) then
		parse_string(string_or_array, pattern)
	else
		parse_array(string_or_array, pattern)
	end #if
	assert_equal(["1", "2"], Parse.name2array(parse("1 2", WORD), :word))
	assert_equal(["3", "4"], Parse.name2array(parse("3 4", WORD), :word))
#	assert_equal(["1 2", "3 4"], parse_string(string_or_array, Terminated_line))
#	assert_equal(["1 2", "3 4"], parse(string_or_array, Terminated_line))
	assert_equal([{:line=>"1 2", :terminator=>"\n"}, {:line=>"3 4", :terminator=>"\n"}], parse(string_or_array, Terminated_line))
	assert_equal(["1 2", "3 4"], name2array(parse(string_or_array, Terminated_line), :line))
	assert_equal(answer, name2array(parse(name2array(parse(string_or_array, Terminated_line), :line), WORD), :word))
end #parse
def test_default_name
	index=11
	prefix='Col_'
	prefix+index.to_s
	assert_equal('Col_1', Capture.default_name(1))
	assert_equal('name', Capture.default_name(0, 'name'))
	assert_equal('name3', Capture.default_name(3, 'name'))
	assert_equal('Var_1', Capture.default_name(1, 'Var_', :numbered))
end #default_name
def test_parse_name_values
	array=[]
	pairs=[]
	new_names=[]
	pattern=//
	ret={}
	next_pair=pairs.pop
	next_name=new_names.pop
	array.each_index do |string, i|
		if i==next_pair then
			ret[array[next_pair].to_sym]=array[next_pair+1]
			next_pair=pairs.pop
		else
			matchData=string.match(pattern)
			if matchData then
				ret[matchData[1].to_sym]=matchData[2]			
			else
				if next_name.nil? then
				else
					ret[next_name.to_sym]=string			
					next_name=new_names.pop
				end #if
			end #if
		end #if
	end #map
end #parse_name_values
def test_name2array
	assert_equal(["1", "2"], Parse.name2array(parse("1 2", WORD), :word))
	assert_equal(Nested_answer, name2array(parse(name2array(parse(Nested_string, Terminated_line), :line), WORD), :word))
end #name2array
def test_rows_and_columns
	column_delimiter=';'
	row_delimiter="\n"
#	name_tag=nil
#	assert_equal(['1 2', '3 4'], parse(EXAMPLE.output, Parse.delimiter_regexp(row_delimiter))) 
#	assert_equal(Nested_answer,EXAMPLE.rows_and_columns(column_delimiter))
end #rows_and_columns
def test_initialize
	length_hash_captures=Parse_array.regexp.named_captures.values.flatten.size
	iterations=(Parse_array.captures.size/length_hash_captures).ceil
	assert_equal(1, Parse_array.length_hash_captures, Parse_array.captures.inspect+Parse_array.regexp.named_captures.inspect)
	assert_equal(2, Parse_array.iterations)
	output=if Parse_array.captures.instance_of?(MatchData) then
			Parse_array.named_hash(0)
	else
		(0..iterations-1).map do |i|
			Parse_array.named_hash(i*(length_hash_captures+1))
		end #map
	end #if
	assert_equal({:branch => '1'}, Parse.new(Branch_regexp.match("* 1\n"), Branch_regexp).output) # return matched subexpressions
	assert_equal(Array_answer, Parse_array.output, Parse_array.inspect)
#	assert_equal(Array_answer, Parse.new(captures, regexp).output, captures.inspect) # return matched subexpressions
end #initialize
def test_all_capture_indices
	Parse_string
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
	assert_equal(possible_unnamed_capture_indices, Parse.new(matchData, regexp).all_capture_indices)
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
	assert_equal(possible_unnamed_capture_indices, Parse.new(splitData, regexp).all_capture_indices)
	assert_equal([1], Parse_string.all_capture_indices, Parse_string.all_capture_indices)
#	assert_equal([1], Parse_array.all_capture_indices, Parse_array.inspect)
end #all_capture_indices
def test_named_hash
	string="* 1\n"
	regexp=Branch_regexp
	matchData=string.match(regexp)
	captures=matchData #[1..-1]
	parse_string=Parse.new("* 1\n", Branch_regexp)
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
		name=Parse.default_name(0, named_capture).to_sym
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
				name=default_name(i, named_capture).to_sym
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
#		name=default_name(capture_index).to_sym
#		named_hash[name]=captures[capture_index]
#	end #each
	assert_equal({:branch => '1'}, named_hash, regexp.inspect+"\n"+captures.inspect)
#	assert_equal(Array_answer, Parse.new(captures, regexp).output, captures.inspect) # return matched subexpressions
end #named_hash
include Parse::Constants
include Parse::Constants
def test_add_parse_message
	assert_match(/match\(/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
	assert_match(/test_add_parse_message/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
end #add_parse_message
def test_assert_parse_string
	assert_equal(['1', '2'], parse_string("1\n2", Terminated_line))
	assert_parse_string(['1', '2'], "1\n2", Terminated_line, 'test_assert_parse')
end #parse_string
def test_assert_parse_sequence
	assert_equal(Hash_answer, parse_string(Newline_Terminated_String, LINE*Line_terminator))
	assert_equal([], ['2']-['1', '2'])

	assert_empty(['2']-['1', '2'])
#	assert_parse_sequence(['1', '2'], Newline_Terminated_String,  Terminated_line, Terminated_line, 'test_assert_parse_sequence')
#	assert_parse_sequence(['1', '2'], Newline_Terminated_String,  Terminated_line, Terminated_line*End_string, 'test_assert_parse_sequence')
end #parse_sequence
def test_parse_repetition
	answer=Hash_answer
	string=Newline_Terminated_String
	pattern=Terminated_line
	repetition_range=Any
	message='message'
	match1=parse_string(string, pattern)
#	assert_equal(match1, answer[0, match1.size], add_parse_message(string, pattern, message))
	match_any=parse_string(string, pattern*Regexp::Any)
#	assert_equal(answer, match_any[-answer.size..-1], add_parse_message(string, pattern*Regexp::Any, message))
	match=parse_string(string, pattern*repetition_range)
	if match==[] || match=={} then
		message+="match1=#{match1.inspect}\n"
		message+="match2=#{match2.inspect}\n"
		message+="match12=#{match12.inspect}\n"
		message+="string.match(#{pattern*repetition_range})=#{string.match(pattern*repetition_range).inspect}"
		assert_equal(answer, parse_string(string, pattern*repetition_range), message)
	end #if
#	assert_equal(['1'], parse_string("1\n2", Terminated_line*Any))
#	assert_parse_repetition(['1','2'], Newline_Terminated_String,  Terminated_line, Any, 'test_assert_parse_sequence')
end #parse_repetition
def test_assert_parse_string
	answer=Hash_answer
	string=Newline_Delimited_String
	pattern=Terminated_line
	message=''
	assert_parse_string(answer, string, pattern, message='')
end #parse
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
	assert_equal(["\n"], Parse_delimited_array.captures[2..2], Parse_string.captures.inspect)
	assert_equal("\n", Parse_delimited_array.captures[2])
	assert_equal([2, 3], (2..Parse_array.captures.size - 2).map {|i| i}, Parse_array.inspect)
	assert_equal([true, false], (2..Parse_array.captures.size - 2).map {|i| i.even?})
	assert_equal(["\n", '2'], (2..Parse_array.captures.size - 2).map {|i| Parse_array.captures[i]})
	assert_equal(["\n"], (2..Parse_array.captures.size - 2).map {|i| (i.even? ? Parse_array.captures[i] : nil)}.compact)

	assert_equal([2], (2..Parse_delimited_array.captures.size - 2).map {|i| i}, Parse_delimited_array.inspect)
	assert_equal([true], (2..Parse_delimited_array.captures.size - 2).map {|i| i.even?})
	assert_equal(["\n"], (2..Parse_delimited_array.captures.size - 2).map {|i| Parse_delimited_array.captures[i]})
	assert_equal(["\n"], (2..Parse_delimited_array.captures.size - 2).map {|i| (i.even? ? Parse_delimited_array.captures[i] : nil)}.compact)
	assert_equal(4, Parse_delimited_array.captures.size, Parse_delimited_array.inspect)
	assert_equal(false, Parse_delimited_array.captures.size.odd?, Parse_delimited_array.inspect)
	assert_equal({:branch => '1'}, Capture.new("* 1\n", Branch_regexp).output?) # return matched subexpressions
#	assert_equal([{:branch=>"1"}, {:branch=>"2"}], Parse_array.output?, Parse_array.inspect)
#	assert_equal(Array_answer, Capture.new(captures, regexp).output?, captures.inspect) # return matched subexpressions
end #initialize
def test_equal
	Match_capture.instance_variables.each do |iv_name|
		if !([:@method_name, :@raw_captures,:@captures].include?(iv_name)) then
#			assert_equal(Match_capture.instance_variable_get(iv_name), Limit_capture.instance_variable_get(iv_name), iv_name)
		end # if
	end # each
#	assert(Match_capture == Limit_capture)
end # equal
def test_raw_captures?
	assert_equal(:limit, Capture.new("* 1\n", Branch_regexp).method_name) 
	assert_instance_of(MatchData, Capture.new("* 1\n", Branch_regexp).raw_captures?) 
	assert_match(Branch_regexp, Split_capture.string, Split_capture.inspect)
	assert_match(Branch_line, Split_capture.string, Split_capture.inspect)
	assert_match( Split_capture.regexp, Split_capture.string, Split_capture.inspect)
	assert_equal(['', '1', '  2'], Split_capture.string.split(Split_capture.regexp), Split_capture.inspect)
	assert_equal(['', '1', '  2'], Split_capture.raw_captures, Split_capture.inspect)
	assert_equal(3, Split_capture.raw_captures.size, Split_capture.inspect)

end # raw_captures?
def test_raw_capture_class?
	assert_equal(:match, Match_capture.raw_capture_class?)
	assert_equal(:split, Split_capture.raw_capture_class?)
	assert_include([:split, :match], Limit_capture.raw_capture_class?)
	assert_equal(:no_match, Capture.new('cat', /fish/, :match).raw_capture_class?)
	assert_equal(:no_match, Failed_capture.raw_capture_class?, Failed_capture.inspect)
end # raw_raw_capture_class?
def test_success?
	raw_captures = Split_capture.raw_captures?
	assert(Match_capture.success?)
	assert(Split_capture.success?)
	assert(Limit_capture.success?)
	assert_equal(nil, Capture.new('cat', /fish/, :match).success?)
	assert_equal(nil, Failed_capture.success?, Failed_capture.inspect)
	assert(Capture.new('  ', /  /, :split).success?)
	'  '.assert_parse(/  /)
end # success?
def test_repetitions?
	length_hash_captures=Parse_array.regexp.named_captures.values.flatten.size
	assert_equal(1, Parse_array.length_hash_captures, Parse_array.captures.inspect+Parse_array.regexp.named_captures.inspect)
	repetitions=(Parse_array.captures.size/length_hash_captures).ceil
#	assert_equal(2, Parse_array.repetitions?)
	parse_string=Capture.new(Newline_Delimited_String, Branch_line , :match)
	parse_delimited_array= Capture.new(Newline_Delimited_String, Branch_line, :split)
#	assert_equal(0, .repetitions?)
	assert_equal(1, parse_string.repetitions?)
	assert_equal(1, parse_delimited_array.repetitions?)
	assert_equal(2, Capture.new(Newline_Delimited_String, Branch_regexp, :split).repetitions?)
end # repetitions?
def test_to_a?
	parse_string=Capture.new(Newline_Delimited_String, Branch_line , :match)
	parse_delimited_array=Capture.new(Newline_Delimited_String, Branch_line, :split)
	Newline_Delimited_String.assert_parse_once(Branch_line)

	assert_equal(parse_string.to_a?.join, parse_delimited_array.captures.join)
	assert_equal(parse_string.to_a?, parse_delimited_array.captures)
end # to_a?
def test_post_match?
	assert_equal('', Parse_delimited_array.post_match?, Parse_delimited_array.inspect)


#	assert_equal("\n  2", Parse_string.post_match?)
end # post_match?
def test_pre_match?
	assert_equal('', Capture.new('a', /a/, :match).pre_match?)
	assert_equal('b', Capture.new('ba', /a/, :match).pre_match?)
	assert_equal('', Capture.new('a', /a/.capture(:a),:match).pre_match?)
	assert_equal(nil, Capture.new('b', /a/, :match).pre_match?)
end # pre_match?
def test_matched_characters?
	assert_equal(1, Capture.new('a', /a/, :match).matched_characters?)
	assert_equal(1, Capture.new('a', /a/, :match).matched_characters?)
	assert_equal(1, Capture.new('ab', /a/.capture(:a), :match).matched_characters?)
end # matched_characters?
def test_output?
	assert_equal({branch: '1'}, Split_capture.string.capture?(Split_capture.regexp).output?, Split_capture.inspect)
end # output?
def test_delimiters?
#	assert_equal([], Parse_string.delimiters?)
#	assert_equal(["\n"], Parse_array.delimiters?, Parse_array.inspect)
	assert_equal(["\n"], Parse_delimited_array.delimiters?, Parse_delimited_array.inspect)
	message = "Match_capture = #{Match_capture.inspect}\nSplit_capture = #{Split_capture.inspect}"
	assert_equal([], Match_capture.delimiters?, message)
	assert_equal(3, Split_capture.raw_captures.size, message)
	assert_equal(2..1, (2..Split_capture.raw_captures.size - 2), message)
	assert_equal([], (2..Split_capture.raw_captures.size - 2).map {|i| (i.even? ? raw_captures[i] : nil)}, message)
	assert_equal([], (2..Split_capture.raw_captures.size - 2).map {|i| (i.even? ? raw_captures[i] : nil)}.compact, message)
	assert_equal([], Split_capture.delimiters?, message)
	assert_equal([], Limit_capture.delimiters?, message)
	assert_include(Capture::Assertions::ClassMethods.instance_methods, :assert_method, message)
	assert_include(Capture.methods, :assert_method, message)
#	Capture::Assertions::ClassMethods.assert_method(Match_capture, Limit_capture, :delimiters?, message)
	Capture.assert_method(Match_capture, Limit_capture, :delimiters?, message)
end # delimiters?
def test_plus
end # +
# Capture::Assertions
def test_assert_method
end # assert_method
def test_Capture_assert_pre_conditions
#	Parse_string.assert_pre_conditions
#	Parse_array.assert_pre_conditions
	assert_raises(AssertionFailedError) {fail}
#	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions('test_Capture_assert_pre_conditions')}
end # assert_pre_conditions
def test_assert_success
	assert_raises(AssertionFailedError) {fail}
#	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}
	Capture.new(Newline_Delimited_String, Branch_line, :match).assert_success
	Capture.new('   ', /  /, :match).assert_success
	Capture.new('  ', /  /, :match).assert_success
	assert_equal(:no_match, Failed_capture.raw_capture_class?, Failed_capture.inspect)
#	assert_raises(AssertionFailedError) {Failed_capture.assert_success}

#	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}
#	assert_raises(AssertionFailedError) {Capture.new('cat', /fish/, :split).assert_success}
	Capture.new('cat', /cat/, :split).assert_success
	Capture.new('  ', /  /, :split).assert_success
end # assert_success
def test_assert_left_match
end # assert_left_match
def test_Capture_assert_post_conditions
#	assert_not_equal('', Parse_string.post_match)
#	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
#	assert_raises(AssertionFailedError) {Parse_delimited_array.assert_post_conditions}
#	assert_equal('', Parse_delimited_array.post_match, Parse_delimited_array.inspect)
#	Parse_array.assert_post_conditions
end # assert_post_conditions

def test_Capture_Examples
	Match_capture.assert_pre_conditions
	Split_capture.assert_pre_conditions
	Limit_capture.assert_pre_conditions
#	Parse_string.assert_pre_conditions
#	Parse_array.assert_pre_conditions
	assert_raises(AssertionFailedError) {fail}
#	assert_raises(AssertionFailedError) {Failed_capture.assert_pre_conditions}

	Match_capture.assert_left_match
	Split_capture.assert_left_match
#	Limit_capture.assert_post_conditions
#	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
#	assert_raises(AssertionFailedError) {Parse_array.assert_post_conditions}
#	assert_raises(AssertionFailedError) {Failed_capture.assert_post_conditions}
end # Examples
# String
def test_String_capture?
#	assert_equal([Hash_answer], Newline_Delimited_String.parse(Terminated_line))
	pattern = Terminated_line
	ret = Newline_Delimited_String.parse(pattern)
#	assert_instance_of(Array, ret)
	assert_not_equal(1, Array_answer.size, Array_answer)
#	assert_equal(1, ret.size, ret)
	
#		match_unrepeated = Newline_Delimited_String.match_unrepeated(pattern)
#		split = Newline_Delimited_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
#	assert_equal([match_unrepeated.output?], split.output?)

#		match_unrepeated = Newline_Terminated_String.match_unrepeated(pattern)
#		split = Newline_Terminated_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
#	assert_equal([match_unrepeated.output?], split.output?)
end # capture?
def test_String_parse
	assert_equal(Hash_answer, Newline_Delimited_String.parse(Terminated_line), self.inspect)
	message = 'unimlemented corect mapping of regexp Repetition to parse'
#	pend(message)
#	assert_equal(Array_answer, Newline_Terminated_String.parse(Terminated_line.group*'*'), self.inspect)
	answer=Hash_answer
	string=Newline_Terminated_String
	pattern=Terminated_line
	repetition_range = Any
	match1=string.parse(pattern)
	match1=string.parse([pattern])
end # parse
def test_add_message
end #add_message
def test_add_parse_message
end #add_parse_message
def test_assert_parse_once
	assert_include(String.included_modules, String::Assertions)
	explain_assert_respond_to(Newline_Delimited_String, :assert_parse_once)
	Newline_Delimited_String.assert_parse_once(Branch_regexp)
end # assert_parse_once
def test_assert_left_parse
	ls_octet_pattern = /r|w|x/
	ls_permission_pattern = [/1/,
					ls_octet_pattern.capture(:system),
					ls_octet_pattern.capture(:group), 
					ls_octet_pattern.capture(:owner)] 
	filename_pattern = /[-_0-9a-zA-Z\/]+/
	driver_pattern = [
							'  ', /[0-9]+/.capture(:number), /    /,
							'  ', /[0-9]+/.capture(:number), /    /,
							ls_permission_pattern,
							'/sys/devices',
							filename_pattern.capture(:device),
							' -> ', 
							filename_pattern.capture(:driver)]
	drivers = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'
	assert_match(/ /, drivers)
	assert_match(/\s/, drivers)
	assert_match('  ', drivers)
	assert_match(/  /, drivers)
	assert_match(/\ \ /, drivers)
	'  '.assert_parse(/  /)
	Driver_string[0..1].assert_left_parse(Driver_pattern[0..0])
	Driver_string.assert_left_parse(Driver_pattern[0..0])
end # assert_left_parse
def test_assert_parse
	string = Driver_string
	pattern = Driver_pattern
	capture = string.capture?(pattern)
	assert_instance_of(Array, capture)
	puts capture.inspect
	capture_runs = capture.enumerate(:chunk) do |c|
		c.success?
	end # chunk
	puts capture_runs.inspect
	parse_string=Capture.new(Newline_Delimited_String, Branch_regexp)
	parse_delimited_array=Capture.new(Newline_Delimited_String, Branch_regexp)

	assert_equal(parse_string.to_a?.join, parse_delimited_array.captures.join)
	assert_equal(parse_string.to_a?, parse_delimited_array.captures)
	assert_equal(parse_string, parse_delimited_array)
#	Driver_string[0..1].assert_parse(Driver_pattern[0..0])
	Driver_string.assert_left_parse(Driver_pattern[0..0])
	first_capture = Driver_string[2..-1].capture?(Driver_pattern[1], :match)
	assert_equal(first_capture.method_name, :match)
	assert_instance_of(Capture, first_capture)
	assert_equal(4, first_capture.matched_characters?, first_capture.inspect)
#	Driver_string[2..-1].assert_parse(Driver_pattern[1..-1])
#	Driver_string.assert_parse(Driver_pattern)
end # assert_parse
end #Parse

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
include Regexp::Expression::Base::Examples
include String::Examples
#include Parse::ClassMethods # treat class methods like module methods as local to test class
#include Parse::Assertions::ClassMethods
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
def test_equal
	MatchCapture::Examples::Branch_line_capture.instance_variables.each do |iv_name|
		if !([:@method_name, :@raw_captures,:@captures].include?(iv_name)) then
			assert_equal(MatchCapture::Examples::Branch_line_capture.instance_variable_get(iv_name), LimitCapture::Examples::Branch_line_capture.instance_variable_get(iv_name), iv_name)
		end # if
	end # each
	assert(MatchCapture::Examples::Branch_line_capture == LimitCapture::Examples::Branch_line_capture)
end # equal
def test_raw_captures?
	assert_equal(['1'], '1aa'.split(/a/))
	assert_equal(['1', 'a', '', 'a'], '1aa'.split(/(a)/))
	assert_equal(['1','2'], '1a2a'.split(/a/))
	assert_equal(['', 'a', '', 'a'], 'aa'.split(/(a)/))
	assert_equal(['', 'a', '', 'a', '2'], 'aa2'.split(/(a)/))
	assert_equal(LimitCapture, LimitCapture.new("* 1\n", Branch_regexp).class) 
	assert_instance_of(Array, LimitCapture.new("* 1\n", Branch_regexp).raw_captures?) 
	assert_match(Branch_regexp, SplitCapture::Examples::Branch_line_capture.string, SplitCapture::Examples::Branch_line_capture.inspect)
	assert_match(Branch_line_regexp, SplitCapture::Examples::Branch_line_capture.string, SplitCapture::Examples::Branch_line_capture.inspect)
	assert_match( SplitCapture::Examples::Branch_line_capture.regexp, SplitCapture::Examples::Branch_line_capture.string, SplitCapture::Examples::Branch_line_capture.inspect)
	assert_equal(['', '1', '  2'], SplitCapture::Examples::Branch_line_capture.string.split(SplitCapture::Examples::Branch_line_capture.regexp), SplitCapture::Examples::Branch_line_capture.inspect)
	assert_equal(['', '1', '  2'], SplitCapture::Examples::Branch_line_capture.raw_captures, SplitCapture::Examples::Branch_line_capture.inspect)
	assert_equal(3, SplitCapture::Examples::Branch_line_capture.raw_captures.size, SplitCapture::Examples::Branch_line_capture.inspect)

end # raw_captures?
def test_success?
	raw_captures = SplitCapture::Examples::Branch_line_capture.raw_captures?
	assert(MatchCapture::Examples::Branch_line_capture.success?)
	assert(SplitCapture::Examples::Branch_line_capture.success?)
	assert_equal(nil, MatchCapture.new('cat', /fish/).success?)
	assert_equal(nil, SplitCapture::Examples::Failed_capture.success?, SplitCapture::Examples::Failed_capture.inspect)
	assert(SplitCapture.new('  ', /  /).success?)
	'  '.assert_parse(/  /)
end # success?
def test_repetitions?
	length_hash_captures=Parse_array.regexp.named_captures.values.flatten.size
	assert_equal(1, Parse_array.length_hash_captures, Parse_array.captures.inspect+Parse_array.regexp.named_captures.inspect)
	repetitions=(Parse_array.captures.size/length_hash_captures).ceil
	assert_equal(2, Parse_array.repetitions?)
	parse_string= MatchCapture.new(Newline_Delimited_String, Branch_line_capture)
	parse_delimited_array= SplitCapture.new(Newline_Delimited_String, Branch_line_capture)
#	assert_equal(0, .repetitions?)
	assert_equal(1, parse_string.repetitions?)
	assert_equal(1, parse_delimited_array.repetitions?)
	assert_equal(2, SplitCapture.new(Newline_Delimited_String, Branch_regexp).repetitions?)
end # repetitions?
def test_to_a?
	parse_string = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
	parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
	Newline_Delimited_String.assert_parse_once(Branch_line_regexp)

	assert_equal(parse_string.to_a?.join, parse_delimited_array.captures.join)
	assert_equal(parse_string.to_a?, parse_delimited_array.captures)
end # to_a?
def test_post_match?
	assert_equal('', Parse_delimited_array.post_match?, Parse_delimited_array.inspect)


	assert_equal("\n  2", Parse_string.post_match?)
end # post_match?
def test_pre_match?
	assert_equal('', MatchCapture.new('a', /a/).pre_match?)
	assert_equal('b', MatchCapture.new('ba', /a/).pre_match?)
	assert_equal('', MatchCapture.new('a', /a/.capture(:a)).pre_match?)
	assert_equal(nil, MatchCapture.new('b', /a/).pre_match?)
end # pre_match?
def test_matched_characters?
	assert_equal(1, MatchCapture.new('a', /a/).matched_characters?)
	assert_equal(1, MatchCapture.new('a', /a/).matched_characters?)
	assert_equal(1, MatchCapture.new('ab', /a/.capture(:a)).matched_characters?)
end # matched_characters?
def test_output?
	assert_equal({branch: '1'}, SplitCapture::Examples::Branch_line_capture.string.capture?(SplitCapture::Examples::Branch_line_capture.regexp).output?, SplitCapture::Examples::Branch_line_capture.inspect)
end # output?
def test_delimiters?
	assert_equal([], Parse_string.delimiters?)
	assert_equal(["\n"], Parse_array.delimiters?, Parse_array.inspect)
	assert_equal(["\n"], Parse_delimited_array.delimiters?, Parse_delimited_array.inspect)
	message = "MatchCapture::Examples::Branch_line_capture = #{MatchCapture::Examples::Branch_line_capture.inspect}\nSplitCapture::Examples::Branch_line_capture = #{SplitCapture::Examples::Branch_line_capture.inspect}"
	assert_equal([], MatchCapture::Examples::Branch_line_capture.delimiters?, message)
	assert_equal(3, SplitCapture::Examples::Branch_line_capture.raw_captures.size, message)
	assert_equal(2..1, (2..SplitCapture::Examples::Branch_line_capture.raw_captures.size - 2), message)
	assert_equal([], (2..SplitCapture::Examples::Branch_line_capture.raw_captures.size - 2).map {|i| (i.even? ? raw_captures[i] : nil)}, message)
	assert_equal([], (2..SplitCapture::Examples::Branch_line_capture.raw_captures.size - 2).map {|i| (i.even? ? raw_captures[i] : nil)}.compact, message)
	assert_equal([], SplitCapture::Examples::Branch_line_capture.delimiters?, message)
	assert_include(Capture::Assertions::ClassMethods.instance_methods, :assert_method, message)
	assert_include(Capture.methods, :assert_method, message)
#	Capture::Assertions::ClassMethods.assert_method(MatchCapture::Examples::Branch_line_capture, LimitCapture::Examples::Branch_line_capture, :delimiters?, message)
	Capture.assert_method(MatchCapture::Examples::Branch_line_capture, LimitCapture::Examples::Branch_line_capture, :delimiters?, message)
end # delimiters?
def test_plus
end # +
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
	assert_equal(possible_unnamed_capture_indices, LimitCapture.new(matchData, regexp).all_capture_indices)
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
	assert_equal(possible_unnamed_capture_indices, LimitCapture.new(splitData, regexp).all_capture_indices)
	assert_equal([1], Parse_string.all_capture_indices, Parse_string.all_capture_indices)
#	assert_equal([1], Parse_array.all_capture_indices, Parse_array.inspect)
end #all_capture_indices
def test_named_hash
	string="* 1\n"
	regexp=Branch_regexp
	message = 'regexp.inspect = ' + regexp.inspect
	matchData=string.match(regexp)
	captures=matchData #[1..-1]
#	parse_string = LimitCapture.new("* 1\n", Branch_regexp)
	assert_equal(3, Parse_string.captures.size, Parse_string.inspect)
	Parse_string.named_hash
	named_hash={}
	regexp.names.each do |n| # return named subexpressions
		assert_instance_of(String, n, message)
		named_hash[n.to_sym]=captures[n]
	end # each
	assert_equal({:branch => '1'}, named_hash) # return matched subexpressions
	splitData=string.split(regexp)
	captures=splitData #[1..-1]
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
	possible_unnamed_capture_indices = Parse_string.all_capture_indices
#	assert_equal([1], possible_unnamed_capture_indices, captures.inspect+"\n"+captures.captures.inspect)
	possible_unnamed_capture_indices=Parse_array.all_capture_indices
#	assert_equal([1], possible_unnamed_capture_indices, Parse_array.all_capture_indices)
#	assert_equal([1], Parse_array.all_capture_indices, Parse_array.all_capture_indices)
#	assert_equal([], possible_unnamed_capture_indices, possible_unnamed_capture_indices.inspect)
	assert_equal('', captures[0], regexp.named_captures.inspect+"\n"+captures.inspect)
#	assert_equal([], possible_unnamed_capture_indices, regexp.named_captures.inspect+"\n"+captures.inspect)
#	possible_unnamed_capture_indices.each do |capture_index|
#		name=Capture.default_name(capture_index).to_sym
#		named_hash[name]=captures[capture_index]
#	end #each
	assert_equal({:branch => '1'}, named_hash, regexp.inspect+"\n"+captures.inspect)
#	assert_equal(Array_answer, LimitCapture.new(captures, regexp).output?, captures.inspect) # return matched subexpressions
end #named_hash

# Capture::Assertions
def test_assert_method
end # assert_method
def test_Capture_assert_pre_conditions
	Parse_string.assert_pre_conditions
	Parse_array.assert_pre_conditions
end # assert_pre_conditions
def test_assert_success
	MatchCapture.new(Newline_Delimited_String, _regexp).assert_success
	MatchCapture.new('   ', /  /).assert_success
	MatchCapture.new('  ', /  /).assert_success
	assert_equal(:no_match, SplitCapture::Examples::Failed_capture.raw_capture_class?, SplitCapture::Examples::Failed_capture.inspect)
	assert_raises(AssertionFailedError) {SplitCapture::Examples::Failed_capture.assert_pre_conditions}
	assert_raises(AssertionFailedError) {SplitCapture::Examples::Failed_capture.assert_success}
	assert_raises(AssertionFailedError) {SplitCapture.new('cat', /fish/).assert_success}
	SplitCapture.new('cat', /cat/).assert_success
	SplitCapture.new('  ', /  /).assert_success
end # assert_success
def test_assert_left_match
end # assert_left_match
def test_Capture_assert_post_conditions
	assert_not_equal('', Parse_string.post_match)
	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
	assert_raises(AssertionFailedError) {Parse_delimited_array.assert_post_conditions}
	assert_equal('', Parse_delimited_array.post_match, Parse_delimited_array.inspect)
#	Parse_array.assert_post_conditions
end # assert_post_conditions

def test_Capture_Examples
	MatchCapture::Examples::Branch_line_capture.assert_pre_conditions
	SplitCapture::Examples::Branch_line_capture.assert_pre_conditions
	Parse_string.assert_pre_conditions
	Parse_array.assert_pre_conditions
	assert_raises(AssertionFailedError) {SplitCapture::Examples::Failed_capture.assert_pre_conditions}

	MatchCapture::Examples::Branch_line_capture.assert_left_match
	SplitCapture::Examples::Branch_line_capture.assert_left_match
	assert_raises(AssertionFailedError) {Parse_string.assert_post_conditions}
	assert_raises(AssertionFailedError) {Parse_array.assert_post_conditions}
	assert_raises(AssertionFailedError) {SplitCapture::Examples::Failed_capture.assert_post_conditions}
end # Examples
# LimitCapture
def test_LimitCapture_raw_captures?
	string = 'a\na'
	regexp = /a/.capture(:label)
	answer = []
	assert_equal('a', MatchCapture.new(string, regexp).raw_captures?[0])
	assert_equal(['', 'a'], SplitCapture.new('a\na', regexp).raw_captures?)
	assert_equal(['', 'a'], LimitCapture.new('a\na', regexp).raw_captures?)
	assert_equal(['', 'a', 'a'], LimitCapture.new('a\na', /a\n/.group).raw_captures?)
	assert_equal([], LimitCapture::Examples::Branch_line_capture.raw_captures?)
end # raw_captures?
def test_LimitCapture_Examples
	assert_instance_of(LimitCapture, LimitCapture::Examples::Branch_line_capture)
	assert(LimitCapture::Examples::Branch_line_capture.success?)
	assert_equal([], LimitCapture::Examples::Branch_line_capture.delimiters?)
	LimitCapture::Examples::Branch_line_capture.assert_pre_conditions
	LimitCapture::Examples::Branch_line_capture.assert_post_conditions
end # Examples
# class ParsedCapture
def test_ParsedCapture_initialize
	assert_include(Module.constants, :MatchCapture)
	assert_include(MatchCapture.constants, :Examples)
	assert_include(MatchCapture::Examples.constants, :Branch_line_regexp)
	assert_scope_path(:MatchCapture, :Examples, :Branch_line_regexp)
	assert_path_to_constant(:MatchCapture, :Examples, :Branch_line_regexp)
	parsed_capture = ParsedCapture.new(Newline_Terminated_String, Branch_line_regexp)
	parsed_display = parsed_capture.parsed_regexp.inspect_recursive(:expressions, &Mx_dump_format)
	assert_equal('', parsed_display, parsed_display + "\n" + parsed_capture.inspect)
end # ParsedCapture_initialize
def test_ParsedCapture_raw_captures?
	string = 'a\na'
	regexp = /a/.capture(:label)
	answer = []
	assert_equal('a', MatchCapture.new(string, regexp).raw_captures?[0])
	assert_equal(["", "a", "\\n", "a"], SplitCapture.new('a\na', regexp).raw_captures?)
	assert_equal(['', 'a'], ParsedCapture.new('a\na', regexp).raw_captures?)
	assert_equal(['', 'a', 'a'], ParsedCapture.new('a\na', /a\n/.group).raw_captures?)
	assert_equal([], LimitCapture::Examples::Branch_line_capture.raw_captures?)
end # raw_captures?
def test_output?
	assert_equal([], ParsedCapture::Examples::Branch_line_capture.output?)
end # output?
def test_delimiters?
	assert_equal([], ParsedCapture::Examples::Branch_line_capture.delimiters?)
end # delimiters?
def test_ParsedCapture_Examples
	assert_instance_of(ParsedCapture, ParsedCapture::Examples::Branch_line_capture)
	explain_assert_respond_to(ParsedCapture::Examples::Branch_line_capture, :success?)
	assert(ParsedCapture::Examples::Branch_line_capture.success?)
	ParsedCapture::Examples::Branch_line_capture.assert_pre_conditions
	ParsedCapture::Examples::Branch_line_capture.assert_post_conditions
end # Examples
# String
def test_map_captures?
	string = 'a'
	regexp_array = [/a/]
	ret = []
	capture = string.capture?(regexp_array[0])
	if capture.success? then
		remaining_string = capture.post_match?
	else
		remaining_string = string # no advance in string yet
	end # if
	assert_equal('', remaining_string )
	ret += [capture]
	if remaining_string.empty? || regexp_array.size == 1 then
		assert_equal([], ret )
	else
		ret += remaining_string.map_captures?(regexp_array[1..-1])
	end # if
	assert_instance_of(MatchCapture, 'a'.map_captures?([/a/])[0]) # no recursion
	map_captures = 'ab'.map_captures?([/a/,/b/])
	assert_instance_of(MatchCapture, map_captures[0])
	assert_instance_of(MatchCapture, map_captures[1])
	assert_equal(string, map_captures.reduce('', :+) {|c| c.string})
	assert_parse(string, regexp_array)
	assert_parse('ab', [/a/, /b/])
end # map_capture
def test_String_capture?
	assert_equal([Hash_answer], Newline_Delimited_String.parse(Terminated_line))
	pattern = Terminated_line
	ret = Newline_Delimited_String.parse(pattern)
	assert_instance_of(Array, ret)
	assert_not_equal(1, Array_answer.size, Array_answer)
	assert_equal(1, ret.size, ret)
	
		match_unrepeated = Newline_Delimited_String.match_unrepeated(pattern)
		split = Newline_Delimited_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
	assert_equal([match_unrepeated.output?], split.output?)

		match_unrepeated = Newline_Terminated_String.match_unrepeated(pattern)
		split = Newline_Terminated_String[0, match_unrepeated.matched_characters].match_repetition(pattern)
	assert_equal([match_unrepeated.output?], split.output?)
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
	captures = string.capture?(pattern)
	assert_instance_of(Array, captures)
	captures.map do |capture| 
		puts capture.regexp.inspect + ' matches ' + capture.matched_characters?
	end # map
	puts capture.inspect
	capture_runs = capture.enumerate(:chunk) do |c|
		c.success?
	end # chunk
	puts capture_runs.inspect
	parse_string=LimitCapture.new(Newline_Delimited_String, Branch_regexp)
	parse_delimited_array = LimitCapture.new(Newline_Delimited_String, Branch_regexp)

	assert_equal(parse_string.to_a?.join, parse_delimited_array.captures.join)
	assert_equal(parse_string.to_a?, parse_delimited_array.captures)
	assert_equal(parse_string, parse_delimited_array)
	Driver_string[0..1].assert_parse(Driver_pattern[0..0])
	Driver_string.assert_left_parse(Driver_pattern[0..0])
	first_capture = Driver_string[2..-1].capture?(Driver_pattern[1], :match)
	assert_equal(first_capture.class, MatchCapture)
	assert_instance_of(Capture, first_capture)
	assert_equal(4, first_capture.matched_characters?, first_capture.inspect)
	Driver_string[2..-1].assert_parse(Driver_pattern[1..-1])
	Driver_string.assert_parse(Driver_pattern)
end # assert_parse
end #String

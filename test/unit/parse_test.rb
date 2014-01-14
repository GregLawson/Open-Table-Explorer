###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/parse.rb'
class ParseTest < TestCase
include Parse
include Parse::Examples
def test_Constants
#	assert_equal(LINES, LINES_cryptic)
	assert_parse_string(['1', '2'], "1\n2", LINES, '')
	assert_parse_string(['1'], Newline_Terminated_String, Terminated_line, "")
	assert_parse_sequence(['1', '2'], Newline_Terminated_String, Terminated_line, Terminated_line*End_string, "assert_parse_sequence")
	assert_parse_sequence(['1', '2'], Newline_Terminated_String, Start_string*Terminated_line, Terminated_line*End_string, "assert_parse_sequence")
	string="1\n2"
	pattern=Parse::LINES
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
#	assert_equal(Hash_answer, parse_string("1 2", Parse::WORDS))
#	assert_equal({:a => "1", :b => "2"}, '12'.match(/\d/.capture(:a)*/\d+/.capture(:b)))
#	assert_equal({:a => "1", :b => "2"}, parse_string(string, Parse::LINES.capture(:a)*Parse::LINES.capture(:b)))
end #parse_string
def test_parse_delimited
	string=Newline_Delimited_String
	item_pattern=LINE
	delimiter=Line_terminator
	ending=:delimiter
	array=string.split(delimiter)
	delimiters=string.split((item_pattern*delimiter).group)
	message="item_pattern="+item_pattern.inspect
	message="\n array="+array.inspect
	message="\n delimiters="+delimiters.inspect
	ret=case ending
	when :optional then 
		assert_operator(delimiters.size, :<=, array.size)
		assert_operator(delimiters.size+1, :>=, array.size)
		array
	when :delimiter then 
		assert_equal(delimiters.size-1, array.size)
		array
	when :terminator then
		assert_equal(delimiters.size, array.size)
		array
	else
		raise 'bad ending symbol.'
	end #case
	items=ret.map do |l|
		parse_string(l, item_pattern)
	end #map
	assert_equal([{}], ret, message)
	assert_equal([{}], parse_delimited(string, item_pattern, delimiter, ending), message)
end #parse_delimied
def test_parse_split
	string=Newline_Terminated_String
	pattern=LINE*Line_terminator
	ending=:terminator
	ret=string.split(pattern)
	assert_equal(['', '1', '', '2'], ret)
	assert_equal(['', '1', '2'], parse_split("1\n2", Terminated_line))
	assert_equal(['', '1', '', '2'], parse_split(Newline_Terminated_String, Terminated_line))
	assert_equal(['', '1', "\n", '2'], parse_split("1\n2", LINE))
	assert_equal(['', '1', "\n", '2', "\n"], parse_split(Newline_Terminated_String, LINE))
	assert_equal(['1', '2'], parse_split("1\n2", Line_terminator))
	assert_equal(['1', '2'], parse_split(Newline_Terminated_String, Line_terminator))
	assert_equal(['', '1', '2'], parse_split("1\n2", LINES))
	assert_equal(['', '2'], parse_split(Newline_Terminated_String, LINES))
	assert_match(Newline_Terminated_String, Terminated_line, "assert_match")
	assert_equal(['', '1', '', '2'], parse_split(Newline_Terminated_String, Terminated_line))
	assert_equal(['', '1', '2'], parse_split("1\n2", Terminated_line))
end #parse_split
def test_parse_into_array
	string="1\n2"
	pattern=Terminated_line
	ending=:delimiter
	ret=case ending
	when :optional then 
		split=string.split(pattern)
		if split[-1].nil? then
			split[0..-2] #drop empty
		else
			split
		end #if 
	when :delimiter then string.split(pattern) 
	when :terminator then
		split=string.split(pattern)
		if split[-1].nil? then
			split[0..-2] #drop empty
		else
			split
		end #if 
	else
	end #case
#	assert_equal(['1', '2'], ret)
#	assert_equal(Example_Answer, parse_into_array(string, pattern, ending))
end #parse_into_array
def test_parse_array
	string_array=["1 2","3 4"]
	pattern=WORDS
	answer=[['1', '2'], ['3', '4']]
	assert_equal(['1', '2'], parse_string(string_array[0], Parse::WORDS))
	assert_equal(['3', '4'], parse_string(string_array[1], Parse::WORDS))
	string_array.map do |string|
		string.match(pattern)
	end #map
	assert_equal(answer, parse_array(string_array))	
end #parse_array
def test_parse
	string_or_array="1 2\n3 4"
	answer=[['1', '2'], ['3', '4']]
	pattern=WORDS
	if string_or_array.instance_of?(String) then
		parse_string(string_or_array, pattern)
	else
		parse_array(string_or_array, pattern)
	end #if
	assert_equal(["1", "2"], parse("1 2", WORDS))
	assert_equal(['3', '4'], parse_string('3 4', WORDS))
#	assert_equal(["1 2", "3 4"], parse_string(string_or_array, LINES))
#	assert_equal(["1 2", "3 4"], parse(string_or_array, LINES))
	assert_equal(answer, parse(parse(string_or_array, LINES), WORDS))
end #parse
def test_default_name
	index=11
	prefix='Col_'
	prefix+index.to_s
	assert_equal('Col_1', default_name(1))
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
def test_rows_and_columns
	column_delimiter=';'
	row_delimiter="\n"
#	name_tag=nil
#	assert_equal(['1 2', '3 4'], parse(EXAMPLE.output, Parse.delimiter_regexp(row_delimiter))) 
#	assert_equal([['1', '2'], ['3', '4']],EXAMPLE.rows_and_columns(column_delimiter))
end #rows_and_columns
include Parse::Constants
include Parse::Constants
def test_add_parse_message
	assert_match(/match\(/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
	assert_match(/test_add_parse_message/, add_parse_message("1\n2", Terminated_line, 'test_add_parse_message'))
end #add_parse_message
def test_assert_parse_string
	assert_equal(['1', '2'], parse_string("1\n2", LINES))
	assert_parse_string(['1', '2'], "1\n2", LINES, 'test_assert_parse')
end #assert_parse_string
def test_assert_parse_sequence
	assert_equal(['1'], parse_string("1\n2", LINE*Line_terminator))
	assert_equal([], ['2']-['1', '2'])

	assert_empty(['2']-['1', '2'])
	assert_parse_sequence(['1', '2'], Newline_Terminated_String,  Terminated_line, Terminated_line, 'test_assert_parse_sequence')
	assert_parse_sequence(['1', '2'], Newline_Terminated_String,  Terminated_line, Terminated_line*End_string, 'test_assert_parse_sequence')
end #parse_sequence
def test_parse_repetition
	answer=Example_Answer
	string=Newline_Terminated_String
	pattern=Terminated_line
	repetition_range=Any
	message='message'
	match1=parse_string(string, pattern)
	assert_equal(match1, answer[0, match1.size], add_parse_message(string, pattern, message))
	match_any=parse_string(string, pattern*Regexp::Any)
	assert_equal(answer, match_any[-answer.size..-1], add_parse_message(string, pattern*Regexp::Any, message))
	match=parse_string(string, pattern*repetition_range)
	if match==[] || match=={} then
		message+="match1=#{match1.inspect}\n"
		message+="match2=#{match2.inspect}\n"
		message+="match12=#{match12.inspect}\n"
		message+="string.match(#{pattern*repetition_range})=#{string.match(pattern*repetition_range).inspect}"
		assert_equal(answer, parse_string(string, pattern*repetition_range), message)
	end #if
	assert_equal(['1'], parse_string("1\n2", Terminated_line*Any))
	assert_parse_repetition(['1','2'], Newline_Terminated_String,  Terminated_line, Any, 'test_assert_parse_sequence')
end #parse_repetition
def test_assert_parse_string
	answer=Hash_answer
	string=Newline_Delimited_String
	pattern=LINES
	message=''
	assert_parse_string(answer, string, pattern, message='')
end #parse
end #Parse

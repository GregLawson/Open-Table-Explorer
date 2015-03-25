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
include String::Examples
include Parse::ClassMethods # treat class methods like module methods as local to test class
include Parse::Examples
include Parse::Assertions::ClassMethods
def test_parse_array
	string_array=fetch_recursive(parse(Nested_string, Terminated_line), :line)
	pattern=WORD
	answer=Nested_answer
	assert_equal(["1", "2"], Parse.fetch_recursive(parse_into_array("1 2", WORD), :word))
	assert_equal(["3", "4"], Parse.fetch_recursive(parse_into_array("3 4", WORD), :word))
	assert_equal(Nested_answer, fetch_recursive(parse_array(fetch_recursive(parse(Nested_string, Terminated_line), :line), WORD), :word))
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
	assert_equal(["1", "2"], Parse.fetch_recursive(parse_into_array("1 2", WORD), :word))
	assert_equal(["3", "4"], Parse.fetch_recursive(parse_into_array("3 4", WORD), :word))
#	assert_equal(["1 2", "3 4"], parse_string(string_or_array, Terminated_line))
#	assert_equal(["1 2", "3 4"], parse(string_or_array, Terminated_line))
	assert_equal([{:line=>"1 2", :terminator=>"\n"}, {:line=>"3 4", :terminator=>"\n"}], parse(string_or_array, Terminated_line))
	assert_equal(["1 2", "3 4"], fetch_recursive(parse(string_or_array, Terminated_line), :line))
	assert_equal(answer, fetch_recursive(parse_into_array(fetch_recursive(parse(string_or_array, Terminated_line), :line), WORD), :word))
end #parse
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
def test_fetch_recursive
	assert_equal(["1", "2"], Parse.fetch_recursive([{word: "1"}, {word: "2"}], :word))
	assert_equal(["1", "2"], Parse.fetch_recursive(parse_into_array("1 2", WORD), :word))
	assert_equal(Nested_answer, Parse.fetch_recursive(parse_into_array(fetch_recursive(parse(Nested_string, Terminated_line), :line), WORD), :word))
end #fetch_recursive
def test_rows_and_columns
	column_delimiter=';'
	row_delimiter="\n"
#	name_tag=nil
#	assert_equal(['1 2', '3 4'], parse(EXAMPLE.output, Parse.delimiter_regexp(row_delimiter))) 
#	assert_equal(Nested_answer,EXAMPLE.rows_and_columns(column_delimiter))
end #rows_and_columns
end #Parse

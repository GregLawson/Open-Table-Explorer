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
include Parse::Constants
def test_Constants
#	assert_equal(LINES, LINES_cryptic)
	string="1\n2"
	pattern=Parse::LINES
	answer=['1', '2']
	assert_equal(answer, parse_string(string, pattern), "string.match(pattern)=#{string.match(pattern).inspect}")
	assert_equal(['1', '2'], parse_string("1\n2\n", LINES), "string.match(pattern)=#{string.match(pattern).inspect}")
end #Constants
def test_parse_string
	string="1\n2"
	pattern=Parse::LINES
	answer=['1', '2']
	ret=string.match(pattern)
	assert_equal(answer, ret[1..-1]) # return matched subexpressions
	matchData=string.match(pattern)
	assert_equal(matchData.names, [])
  if matchData.nil? then
    []
	elsif matchData.names==[] then
		assert_equal(answer, matchData[1..-1], matchData) # return unnamed subexpressions
	else
		nc=pattern.named_captures
		assert_not_nil(nc)
		assert_not_empty(nc)
		named_hash={}
		matchData.names.each do |n| # return named subexpressions
			named_hash[n.to_sym]=matchData[n]
		end # each
	end #if
	assert_equal(answer, parse_string(string, Parse::LINES), "matchData=#{matchData.inspect}")
	assert_equal(answer, parse_string(string), "matchData=#{matchData.inspect}")
	assert_equal(['1', '2'], parse_string("1 2", Parse::WORDS))
#	assert_equal({:a => "1", :b => "2"}, '12'.match(/\d/.capture(:a)*/\d+/.capture(:b)))
#	assert_equal({:a => "1", :b => "2"}, parse_string(string, Parse::LINES.capture(:a)*Parse::LINES.capture(:b)))
end #parse_string
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
	assert_equal(["1 2", "3 4"], parse_string(string_or_array, LINES))
	assert_equal(["1 2", "3 4"], parse(string_or_array, LINES))
	assert_equal(answer, parse(parse(string_or_array, LINES), WORDS))
end #parse
def test_default_name
	index=11
	prefix='Col_'
	prefix+index.to_s
end #
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
end #ParseTest

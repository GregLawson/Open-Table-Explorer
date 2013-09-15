###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/shell_command.rb'
class ParseTest < TestCase
def test_terminator_regexp
	assert_equal(['1', '2', '3'], parse("1\n2\n3\n", LINES), "")
	assert_equal(LINES, Parse.terminator_regexp('\n'))
end #terminator_regexp
include ShellCommands::Examples
def test_delimiter_regexp
	assert_equal(['1', '2'], parse("1,2", Parse.delimiter_regexp(",")))
	assert_equal(['2', '3'], parse("2,3", Parse.delimiter_regexp(",")))
	assert_equal(['2', ''], parse("2,", Parse.delimiter_regexp(",")))
	assert_equal(WORDS, Parse.delimiter_regexp('\s'))
	assert_equal(['2'], parse("2", Parse::CSV), "matchData=#{CSV.match('2').inspect}")
	assert_equal(['2'], parse("2", Parse.delimiter_regexp(",")))
	assert_equal(['1', '2', '3'], parse("1 2 3", Parse.delimiter_regexp('\s')))
	assert_equal(CSV, Parse.delimiter_regexp(","))
end #delimiter_regexp
def test_parse_string
	string="1\n2"
	pattern=Parse::LINES
	answer=['1', '2']
	ret=string.match(pattern)
	assert_equal(answer, ret[1..-1]) # return matched subexpressions
	assert_equal(answer, parse_string(string), "ret=#{ret.inspect}")
	assert_equal(['1', '2'], parse_string("1 2", Parse::WORDS))
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
	column_delimiter=' '
	row_delimiter="\n"
	name_tag=nil
	assert_equal(['1 2', '3 4'], parse(EXAMPLE.output, Parse.delimiter_regexp(';'))) 
	assert_equal([['1', '2'], ['3', '4']],EXAMPLE.rows_and_columns)
end #rows_and_columns
include Parse::Constants
def test_NetworkInterface
	lines=parse(NetworkInterface::IFCONFIG.output, LINES)
	double_lines=NetworkInterface::IFCONFIG.output.split("\n\n")
	assert_instance_of(Array, double_lines)
	assert_operator(2, :<, double_lines.size)
	assert_equal('eth0', double_lines[0].split(' ')[0])
	words=parse(double_lines[0], WORDS)
	assert_equal('eth0', words[0])
	assert_equal('Link', words[1], "words=#{words.inspect}, lines=#{lines.inspect}")
	puts "words=#{words.inspect}, double_lines=#{double_lines.inspect}"
	words=double_lines.map do |row|
		words=parse(row, WORDS)
		puts "words=#{words.inspect}, row=#{row.inspect}"
		assert_match(words[0], /eth0|lo|wlan0/, "row=#{row.inspect}, words=#{words.inspect}")
	end #map
	rc=parse(NetworkInterface::IFCONFIG.output, LINES).map  do |row| 
		parse(row, WORDS)
	end #map
	assert_equal('', NetworkInterface::IFCONFIG.rows_and_columns)
	assert_equal('eth0,', NetworkInterface::IFCONFIG.inspect)
	assert_equal('', NetworkInterface::IFCONFIG.output)
end #NetworkInterface
end #ParseTest
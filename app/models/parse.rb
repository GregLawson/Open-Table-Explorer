###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'

module Parse
module Constants
LINE=/[^\n]*/.capture
Line_delimiter=/\n/
Delimited_line=(LINE*Line_delimiter).group
LINES_cryptic=/([^\n]*)(?:\n([^\n]*))*/
LINES=(Delimited_line*Regexp::Any)*LINE
WORDS=/([^\s]*)(?:\s([^\s]*))*/
CSV=/([^,]*)(?:,([^,]*?))*?/
end #Constants
include Constants
def parse_string(string, pattern=LINES)
	matchData=string.match(pattern)
  if matchData.nil? then
    []
  elsif matchData.names==[] then
		matchData[1..-1] # return unnamed subexpressions
	else
		named_hash={}
		matchData.names.each do |n| # return named subexpressions
			named_hash[n.to_sym]=matchData[n]
		end # each
		named_hash
	end #if
end #parse_string
def parse_array(string_array, pattern=WORDS)
	string_array.map do |string|
		parse(string,pattern)
	end #map
end #parse_array
# parse takes an input string or possibly nested array of strings and returns an array of regexp captures per string.
# The array of captures replacing the input strings adds one additional layer of Array nesting.
def parse(string_or_array, pattern=WORDS)
	if string_or_array.instance_of?(String) then
		parse_string(string_or_array, pattern)
	elsif string_or_array.instance_of?(Array) then
		parse_array(string_or_array, pattern)
	else
		nil
	end #if
end #parse
def default_name(index, prefix='Col_')
	prefix+index.to_s
end #
def parse_name_values(array, pairs, new_names, pattern)
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
def rows_and_columns(column_pattern=Parse::WORDS, row_pattern=Parse::LINES)
	parse(@output, row_pattern).map  do |row| 
		parse(row, column_pattern)
	end #map
end #rows_and_columns
end #Parse

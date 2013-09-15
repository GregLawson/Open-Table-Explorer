require_relative '../../app/models/shell_command.rb'
module Parse
module Constants
LINES=/([^\n]*)(?:\n([^\n]*))*/
WORDS=/([^\s]*)(?:\s([^\s]*))*/
CSV=/([^,]*)(?:,([^,]*?))*?/
end #Constants
include Constants
# A terminator is a delimiter that is at the end (like new line)
def Parse.terminator_regexp(delimiter)
	raise "delimiter must be single characters not #{delimiter}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #terminator_regexp
# A delimiter is generally not at the end (like commas)
def Parse.delimiter_regexp(delimiter)
	raise "delimiters must be single characters not #{delimiter.inspect}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #delimiter_regexp
def parse_string(string, pattern=LINES)
	ret=string.match(pattern)
	ret[1..-1] # return matched subexpressions
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
require_relative '../../app/models/parse.rb'
include Parse
def rows_and_columns(column_pattern=Parse::WORDS, row_pattern=Parse::LINES)
	parse(@output, row_pattern).map  do |row| 
		parse(row, column_pattern)
	end #map
end #rows_and_columns
end #Parse

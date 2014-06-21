###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
# options include delimiter, and ending
class Parse
module ClassMethods
include Constants
# Input Array of Strings, Output Array of Hash
def parse_array(string_array, pattern)
	string_array.map do |string|
		parse_into_array(string,pattern)
	end #map
end #parse_array
# parse takes an input string or possibly nested array of strings and returns an array of regexp captures per string.
# The array of captures replacing the input strings adds one additional layer of Array nesting.
def parse(string_or_array, pattern)
	if string_or_array.instance_of?(String) then
		parse_string(string_or_array, pattern)
	elsif string_or_array.instance_of?(Array) then
		parse_array(string_or_array, pattern)
	else
		nil
	end #if
end #parse

# promote named value,
# Nested Array structure maintained, Hashed collaped to one named value
# Consider another version that collapses only is key present or only if single key
def fetch_recursive(node, name)
	if node.instance_of?(Array) then
		node.map do |element|
			fetch_recursive(element, name)
		end #map
	elsif node.instance_of?(Hash) then
		node[name]
	else
		node
	end #if
end #fetch_recursive
def rows_and_columns(column_pattern=Parse::WORD, row_pattern=Parse::Terminated_line)
	parse(@output, row_pattern).map  do |row| 
		parse(row, column_pattern)
	end #map
end #rows_and_columns
end #ClassMethods
extend ClassMethods
end #Parse

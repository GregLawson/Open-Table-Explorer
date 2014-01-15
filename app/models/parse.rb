###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
class Parse
module Constants
LINE=/[^\n]*/.capture(:line)
Line_terminator=/\n/ #.capture(:terminator)
Terminated_line=(LINE*Line_terminator).group
LINES_cryptic=/([^\n]*)(?:\n([^\n]*))*/
LINES=(Terminated_line*Regexp::Any)*LINE*(Line_terminator*Regexp::Optional)
WORDS=/([^\s]*)(?:\s([^\s]*))*/
CSV=/([^,]*)(?:,([^,]*?))*?/
end #Constants
include Constants
module ClassMethods
# Input String, Output Hash
def parse_string(string, pattern=Terminated_line)
	matchData=string.match(pattern)
  if matchData.nil? then
    []
  elsif matchData.names==[] then
		matchData[1..-1] # return unnamed subexpressions
	else
#     named_captures for captures.size > names.size
		Parse.new(matchData, pattern, options).output
	end #if
end #parse_string
def parse_delimited(string, item_pattern, delimiter, options={:ending => :optional})
	items=string.split(delimiter)
	delimiters=string.split(item_pattern, options)
end #parse_delimied
# Splits pattern match captures into an array of parses
# Uses Regexp capture mechanism in String#split
def parse_split(string, pattern=Terminated_line)
	ret=string.split(pattern)
end #parse_split
# Input String, Output Array
def parse_into_array(string, pattern=Terminated_line, ending=:optional)
	ret=parse_split(string, pattern)
	case ending
	when :optional then 
		if ret[-1].nil? then
			ret[0..-2] #drop empty
		else
			ret
		end #if 
	when :delimiter then string.split(pattern) 
	when :terminator then
		if ret[-1].nil? then
			ret[0..-2] #drop empty
		else
			ret
		end #if 
	end #case
	
end #parse_into_array
# Input Array of Strings, Output Array of Hash
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
def default_name(index, prefix=nil, numbered=nil)
	if prefix.nil? then
		'Col_'+index.to_s
	elsif numbered.nil? && index==0 then
		prefix
	else
		prefix+index.to_s
	end #if
end #default_name
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
end #ClassMethods
extend ClassMethods
# encapsulates the difference between parsing from MatchData and from Array#split
attr_reader :captures, :regexp, :length_hash_captures, :iterations, :output
def initialize(captures, regexp, options=nil)
	@captures=captures
	@regexp=regexp
#     named_captures for captures.size > names.size
	@length_hash_captures=@regexp.named_captures.values.flatten.size
	@iterations=(@captures.size/(@length_hash_captures+1)).ceil
	@output=if @captures.instance_of?(MatchData) then
			named_hash(0)
	else
		array=(0..iterations-1).map do |i|
			named_hash(i*(length_hash_captures+1))
		end #map
		ret=case options[:ending]
		when :optional then 
			array
		when :delimiter then 
			array
		when :terminator then
			array
		else
			raise 'bad ending symbol.'
		end #case
		end #if
end #initialize
def all_capture_indices
	if @captures.instance_of?(MatchData) then
		(1..@captures.size-1).to_a
	else
		(1..@captures.size-1).to_a #skip delimiter
	end #if
end #all_capture_indices
def named_hash(hash_offset=0)
	named_hash={}
	@regexp.named_captures.each_pair do |named_capture, indices| # return named subexpressions
		name=Parse.default_name(0, named_capture).to_sym
		named_hash[name]=@captures[hash_offset+indices[0]]
		if indices.size>1 then
			indices[1..-1].each_index do |capture_index,i|
				name=default_name(i, named_capture).to_sym
				named_hash[name]=@captures[capture_index]
			end #each_index
		end #if
	end # each_pair
	# with the current ruby Regexp implementation, the following is impossible
	# If there is a named capture in match or split, all unnamed captures are ignored
#	possible_unnamed_capture_indices.each do |capture_index|
#		name=default_name(capture_index).to_sym
#		named_hash[name]=@captures[capture_index]
#	end #each
	named_hash
end #named_hash
module Assertions
include Test::Unit::Assertions
def newline_if_not_empty(message)
	if message.empty? then
		message
	else
		message+"\n"
	end #if
end #newline_if_not_empty
def add_parse_message(string, pattern, message='')
	newline_if_not_empty(message)+"\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
end #add_parse_message
def assert_parse_string(answer, string, pattern, message='')
	message=add_parse_message(string, pattern, message)+"\nnames=#{pattern.names.inspect}"
	message+="\nnamed_captures=#{pattern.named_captures.inspect}"
	assert_match(pattern, string, message)
	matchData=pattern.match(string)
	assert_equal(pattern.names.size, matchData.size-1, "All string parse captures should be named.\n"+message)
	assert_equal(answer, parse_string(string, pattern), add_parse_message(string, pattern, message))

end #parse_string
def assert_parse_sequence(answer, string, pattern1, pattern2, message='')
	match1=parse_string(string, pattern1)
	assert_not_nil(match1)
	assert_not_nil(answer[0, match1.size])
	assert_equal(answer[0, match1.size], match1, add_parse_message(string, pattern1, message))
	match2=parse_string(string, pattern2)
	assert_empty(match2-answer, add_parse_message(string, pattern2, message))
	match12=parse_string(pattern1.match(string).post_match, pattern2)
	assert_equal(match12, answer[-match12.size..-1], add_parse_message(pattern1.match(string).post_match, pattern2, message))
	match=parse_string(string, pattern1*pattern2)
	if match==[] || match=={} then
		message+="match1=#{match1.inspect}\n"
		message+="match2=#{match2.inspect}\n"
		message+="match12=#{match12.inspect}\n"
		message+="string.match(#{pattern1*pattern2})=#{string.match(pattern1*pattern2).inspect}"
		assert_equal(answer, parse_string(string, pattern1*pattern2), message)
	end #if
end #parse_sequence
def assert_parse_repetition(answer, string, pattern, repetition_range, message='')
	assert_parse_string(answer, string, pattern*repetition_range, message)
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
end #parse_repetition
end #Assertions
include Assertions
module Examples
include Constants
include Regexp::Constants
Newline_Delimited_String="* 1\n  2"
Newline_Terminated_String=Newline_Delimited_String+"\n"
Hash_answer={:line=>"* 1", :terminator=>"\n"}
Branch_regexp=/[* ]/.capture*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
Array_answer=[{:branch => '1'}, {:branch => '2'}]
Parse_string=Parse.new(Newline_Delimited_String.match(Branch_regexp), Branch_regexp)
Parse_array=Parse.new(Newline_Terminated_String.split(Branch_regexp), Branch_regexp)
end #Examples
end #Parse

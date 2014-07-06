###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
class Capture
# encapsulates the difference between parsing from MatchData and from Array#split
module ClassMethods
def default_name(index, prefix=nil, numbered=nil)
	if prefix.nil? then
		'Col_'+index.to_s
	elsif numbered.nil? && index==0 then
		prefix
	else
		prefix+index.to_s
	end #if
end #default_name
end # ClassMethods
extend ClassMethods
attr_reader :captures, :regexp # arguments
attr_reader :length_hash_captures, :repetitions, :matched_characters
attr_reader :output, :pre_match, :post_match, :delimiters  # outputs
def initialize(captures, regexp)
	@captures=captures
	@regexp=regexp
#     named_captures for captures.size > names.size
	@length_hash_captures=@regexp.named_captures.values.flatten.size
	if @captures.nil? || @captures == [] then
		@output= {}
		@pre_match = ''
		@post_match = ''
		@delimiters = []
		@matched_characters = 0
		@repetitions = 0
	elsif @captures.instance_of?(MatchData) then
		if @captures.names==[] then
			@output = matchData[1..-1] # return unnamed subexpressions
		else
			@output=named_hash(0)
		end # if
		@pre_match = @captures.pre_match
		@post_match = @captures.post_match
		@delimiters = []
		@matched_characters = @captures[0].length
		@repetitions=(@captures.size/(@length_hash_captures+1)).ceil
	else # from split
		@repetitions=(@captures.size/(@length_hash_captures+1)).ceil
		@output = (0..@repetitions-1).map do |i|
			named_hash(i*(length_hash_captures+1))
		end #map
		@pre_match = @captures[0]
		if @captures.size.odd? then
			@post_match = @captures[-1]
		else
			@post_match = ''
		end # if
		@delimiters = (2..@captures.size - 2).map {|i| (i.even? ? @captures[i] : nil)}.compact
		raise self.inspect if @captures[0].nil?
		@matched_characters = @captures.reduce(0){|sum, s| sum + s.length} - @captures[0].length
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
		name=Capture.default_name(0, named_capture).to_sym
		named_hash[name]=@captures[hash_offset+indices[0]]
		if indices.size>1 then
			indices[1..-1].each_index do |capture_index,i|
				name=Capture.default_name(i, named_capture).to_sym
				named_hash[name]=@captures[capture_index]
			end #each_index
		end #if
	end # each_pair
	# with the current ruby Regexp implementation, the following is impossible
	# If there is a named capture in match or split, all unnamed captures are ignored
#	possible_unnamed_capture_indices.each do |capture_index|
#		name=Capture.default_name(capture_index).to_sym
#		named_hash[name]=@captures[capture_index]
#	end #each
	named_hash
end #named_hash
require_relative '../../test/assertions.rb'

# Capture::Assertions
require_relative '../../test/assertions.rb'
module Assertions

# Any match at all
def assert_pre_conditions(message='')
	assert_not_nil(@captures, 'no match at all.')
	if @output == {} then

#		assert_equal({}. @captures, 'MatchData but no captures.')
	elsif @output == [] then
		assert_not_empty(@captures, 'split but no captures.')
	end # if

end # assert_pre_conditions

# exact match, no left-overs
def assert_post_conditions(message='')
	assert_empty(@pre_match, add_default_message(message))
	assert_empty(@post_match, add_default_message(message))
	assert_empty(@delimiters, self.inspect)
end # assert_post_conditions
def repetition_options?
	if @regexp.respond_to?(:repetition_options) then
		@regexp.repetition_options
	else
		nil
	end # if
end # repetition_options?
def assert_repetition_options(repetition_options = repetition_options?)
	if repetition_options.nil? then
		assert_pre_conditions
	else
		delimiter = repetition_options.fetch(:delimiter, "\n")
		assert_empty(@delimiters.compact.uniq - [delimiter])
		assert_empty([@post_match] - [delimiter] - [''])
		case repetition_options[:ending]
		when :optional then 
		when :delimiter then 
			assert_not_match(Regexp.new(delimiter), @post_match)
			assert_empty(@delimiters.compact.uniq - [delimiter])
		when :terminator then
			assert_match(delimiter, @post_match)
		else
			raise 'bad ending symbol.'
		end #case
	end # if
end # assert_repetition_options
def add_parse_message(string, pattern, message='')
	message = add_default_message(message)
	newline_if_not_empty(message)+"\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
end #add_parse_message
def assert_parse_string(answer, string, pattern, message='')
	message = add_parse_message(string, pattern, message)+"\nnames=#{pattern.names.inspect}"
	message+="\nnamed_captures=#{pattern.named_captures.inspect}"
	assert_match(pattern, string, message)
	matchData=pattern.match(string)
	assert_operator(pattern.named_captures.values.flatten.size, :<=, matchData.size-1, "All string parse captures should be named.\n"+message)
	assert_equal(answer, parse_string(string, pattern), add_parse_message(string, pattern, message))

end #parse_string
module ClassMethods
end #ClassMethods
end #Assertions
include Assertions
module Examples
Newline_Delimited_String="* 1\n  2"
Newline_Terminated_String=Newline_Delimited_String+"\n"
Branch_regexp=/[* ]/.capture*/ /*/[-a-z0-9A-Z_]+/.capture(:branch)
Parse_string=Capture.new(Newline_Delimited_String.match(Branch_regexp), Branch_regexp)
Parse_delimited_array=Capture.new(Newline_Delimited_String.split(Branch_regexp), Branch_regexp)
Parse_array=Capture.new(Newline_Terminated_String.split(Branch_regexp), Branch_regexp)
end # Examples
end # Capture

# String
class String
# Match pattern without repetition
def match_unrepeated(pattern)
	matchData=self.match(pattern)
	Capture.new(matchData, pattern)
end # parse_unrepeated
def parse_unrepeated(pattern)
	match_unrepeated(pattern).output
end # parse_unrepeated
# Handle repetion and returns an Array
# Splits pattern match captures into an array of parses
# Uses Regexp capture mechanism in String#split
# Input String, Output Array
def match_repetition(item_pattern)
	captures = self.split(item_pattern)
	Capture.new(captures, item_pattern)
end # parse_repetition
def parse_repetition(item_pattern)
	match_repetition(item_pattern).output
end # parse_repetition
# Try to unify parse_repetition and parse_unrepeated
# What is the difference between an Object and an Array of size 1?
# Should difference be derived from recursive analysis of RegexpParse?
# Where repetitions produce Array, others produe Hash
# complicated by fact regular expressions simulate repetitions with recursive alternatives
def match?(pattern)
	if pattern.instance_of?(Array) then
		pos = 0
		pattern.map do |p|
			ret = self[pos..-1].match?(p) # recurse
			pos += ret.matched_characters
			ret
		end # map
	else
		@match_unrepeated = match_unrepeated(pattern)
		# limit repetitions to pattern, get all captures
		@split = self[0, @match_unrepeated.matched_characters].match_repetition(pattern)
		if @split.repetitions == 1 then
			@match_unrepeated
		elsif @match_unrepeated.output == @split.output[-1] then # over-written captures
			@split
		else
			@match_unrepeated
		end # if
	end # if
end # match?
def parse(regexp)
	match?(regexp).output
end # parse
module Constants
end #Constants
include Constants
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods

def add_parse_message(string, pattern, message='')
	newline_if_not_empty(message)+"\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
end #add_parse_message
def assert_parse_string(answer, string, pattern, message='')
	message=add_parse_message(string, pattern, message)+"\nnames=#{pattern.names.inspect}"
	message+="\nnamed_captures=#{pattern.named_captures.inspect}"
	assert_match(pattern, string, message)
	matchData=pattern.match(string)
	assert_operator(pattern.named_captures.values.flatten.size, :<=, matchData.size-1, "All string parse captures should be named.\n"+message)
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
end #ClassMethods
end #Assertions
include Assertions
module Examples
include Constants
include Regexp::Constants
LINE=/[^\n]*/.capture(:line)
Line_terminator=/\n/.capture(:terminator)
Terminated_line=(LINE*Line_terminator).group
LINES_cryptic=/([^\n]*)(?:\n([^\n]*))*/
WORD=/([^\s]*)/.capture(:word)
CSV=/([^,]*)(?:,([^,]*?))*?/
Hash_answer={:line=>"* 1", :terminator=>"\n"}
Array_answer=[{:line=>"* 1", :terminator=>"\n"}, {:line=>"  2", :terminator=>"\n"}]
Nested_string="1 2\n3 4\n"
Nested_answer=[['1', '2'], ['3', '4']]
end #Examples
end # String

# Parse
# repetition_options include delimiter, and ending
class Parse < Regexp
module Constants
end #Constants
include Constants
module ClassMethods
include Constants
# Input String, Output Hash
def parse_string(string, pattern)
	string.parse_unrepeated(pattern)
end #parse_string

# Splits pattern match captures into an array of parses
# Uses Regexp capture mechanism in String#split

# Input String, Output Array
def parse_into_array(string, item_pattern)
	string.parse_repetition(item_pattern)


end #parse_into_array
end #ClassMethods
extend ClassMethods
attr_reader :repetition_options
def initialize(regexp, repetition_options = nil)
	super(regexp)
	@repetition_options = repetition_options
end # initialize
require_relative '../../test/assertions.rb';module Assertions
module ClassMethods

def add_parse_message(string, pattern, message='')
	newline_if_not_empty(message)+"\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
end #add_parse_message
def assert_parse_string(answer, string, pattern, message='')
	message=add_parse_message(string, pattern, message)+"\nnames=#{pattern.names.inspect}"
	message+="\nnamed_captures=#{pattern.named_captures.inspect}"
	assert_match(pattern, string, message)
	matchData=pattern.match(string)
	assert_operator(pattern.named_captures.values.flatten.size, :<=, matchData.size-1, "All string parse captures should be named.\n"+message)
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
end #ClassMethods
end #Assertions
include Assertions
module Examples
include Constants
include Regexp::Constants
include Capture::Examples
include String::Examples
end #Examples
end #Parse

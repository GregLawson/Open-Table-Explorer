###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/stream_tree.rb'
require_relative '../../app/models/regexp_parse.rb'
# encapsulates the difference between parsing from MatchData and from Array#split
# regexp are Regexp not Arrays or Strings (see String#parse)
class Capture
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
attr_reader :string, :regexp, :method_name # arguments
# attr_reader :captures, :length_hash_captures, :repetitions, :matched_characters
attr_reader :raw_captures
# attr_reader :output, :pre_match, :post_match, :delimiters  # outputs
def initialize(string, regexp, method_name = :split)
	@string = string
	@regexp=regexp
	@method_name = method_name
	@length_hash_captures = @regexp.named_captures.values.flatten.size
	@raw_captures = raw_captures?
	@captures = to_a?(@raw_captures) # standardize captures
#     named_captures for captures.size > names.size
end #initialize
def raw_captures?(method_name = self.method_name)
	@string.method(method_name).call(@regexp)
end # raw_captures?
def success?(raw_captures = self.raw_captures?)
	if raw_captures.nil? || raw_captures == [] then
		false
	else
		true
	end #if
end # success?
def repetitions?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		0
	elsif raw_captures.instance_of?(MatchData) then
		1
	else # from split, already in nomalize form
		(raw_captures.size/(@length_hash_captures+1)).ceil
	end #if
end # repetitions?
# Tranform split and MatchData captures into single form
def to_a?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		[]
	elsif raw_captures.instance_of?(MatchData) then
		[raw_captures.pre_match] + raw_captures[1..-1]
	else # from split, already in nomalize form
		raw_captures
	end #if
end # normalize_captures?
def post_match?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		nil
	elsif raw_captures.instance_of?(MatchData) then
		raw_captures.post_match
	else # from split, already in nomalize form
			if raw_captures.size.odd? then
				raw_captures[-1]
			else
				''
			end # if
#		raw_captures?(:match).post_match
	end #if
end # post_match?
def pre_match?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		nil
	elsif raw_captures.instance_of?(MatchData) then
		raw_captures.pre_match
	else # from split, already in nomalize form
			raw_captures[0]
	end #if
end # pre_match?
def matched_characters?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		0
	elsif raw_captures.instance_of?(MatchData) then
		raw_captures[0].length
	else # 
		@string.length - raw_captures?(:match).post_match.length
	end #if
end # matched_characters?
def output?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		{}
	elsif raw_captures.instance_of?(MatchData) then
		if raw_captures.names==[] then
			raw_captures[1..-1] # return unnamed subexpressions
		else
			named_hash(0)
		end # if
	else # 
		@output = (0..repetitions?(raw_captures)-1).map do |i|
			named_hash(i*(length_hash_captures+1))
		end #map
	end # if
end # output?
def delimiters?(raw_captures = self.raw_captures?)
	if !success?(raw_captures) then
		[]
	elsif raw_captures.instance_of?(MatchData) then
		[]
	else # from split
		(2..raw_captures.size - 2).map {|i| (i.even? ? raw_captures[i] : nil)}.compact
		raise self.inspect if raw_captures[0].nil?
	end #if
end # delimiters
# return a capture object for two Capture instances (assumed consecutive)
def +(other_capture)
	raise "Only Capture instances can be added." if !other_capture.instance_of?(Capture)
	Capture.new(self.string + other_capture.string, [self.regexp, other_capture.regexp])
		
end # +
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
def assert_method(match_capture, limit_capture, argumentless_method_name = :output?, message = '')
	message += "match_capture = #{match_capture.inspect}\limit_capture = #{limit_capture.inspect}"
	match_method_object = match_capture.method(argumentless_method_name)
	limit_method_object = limit_capture.method(argumentless_method_name)
	assert_equal(match_method_object.call, limit_method_object.call, message)
end # assert_method
end #ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
Newline_Delimited_String="* 1\n  2"
Newline_Terminated_String=Newline_Delimited_String+"\n"
#Branch_regexp = /[* ]/.capture(:current) * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
Branch_line = Branch_regexp * "/n"
Parse_string=Capture.new(Newline_Delimited_String, Branch_regexp, :match)
Parse_delimited_array=Capture.new(Newline_Delimited_String, Branch_regexp, :split)
Parse_array=Capture.new(Newline_Terminated_String, Branch_regexp, :split)
	Match_capture = Capture.new(Newline_Delimited_String, Branch_line, :match)
	Split_capture = Capture.new(Newline_Delimited_String, Branch_line, :split)
	Limit_capture = Capture.new(Newline_Delimited_String[0, Match_capture.matched_characters?], Branch_line, :split)
end # Examples
end # Capture

# String
class String
# Match pattern without repetition
def match_unrepeated(pattern)
	Capture.new(self, pattern, :match)
end # parse_unrepeated
def parse_unrepeated(pattern)
	match_unrepeated(pattern).output
end # parse_unrepeated
# Handle repetion and returns an Array
# Splits pattern match captures into an array of parses
# Uses Regexp capture mechanism in String#split
# Input String, Output Array
def match_repetition(item_pattern)
	Capture.new(self, item_pattern, :split)
end # parse_repetition
def parse_repetition(item_pattern)
	match_repetition(item_pattern).output
end # parse_repetition
# Try to unify parse_repetition and parse_unrepeated
# What is the difference between an Object and an Array of size 1?
# Should difference be derived from recursive analysis of RegexpParse?
# Where repetitions produce Array, others produe Hash
# complicated by fact regular expressions simulate repetitions with recursive alternatives
# match? returns a tree of Capture objects while parse returns only the output Hash
def match?(pattern)
	if pattern.instance_of?(Array) then
		pos = 0
		pattern.map do |p|
			ret = self[pos..-1].match?(p) # recurse returning Capture
			
			pos += ret.matched_characters
			ret
		end # map
	elsif pattern.instance_of?(String) then
		# see http://stackoverflow.com/questions/3518161/another-way-instead-of-escaping-regex-patterns
		match?(Regexp.new(Regexp.quote(pattern)))
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
	match = match?(regexp)
	match.enumerate(:map) {|e| e.output}
end # parse
module Constants
end #Constants
include Constants
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def add_message(message='')
	newline_if_not_empty(message)+"\n#self.inspect = #{self.inspect}"
end #add_message

def add_parse_message(string, pattern, message='')
	add_message("\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}")
end #add_parse_message
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
# pattern matches only once in both match and split
def assert_parse_once(pattern, message='')
	match_capture = Capture.new(self, pattern, :match)
	split_capture = Capture.new(self, pattern, :split)
	limit_capture = Capture.new(self[0, match_capture.matched_characters?], pattern, :split)
	message = "match_capture = #{match_capture.inspect}\nsplit_capture = #{split_capture.inspect}"
	assert_equal(match_capture.output?, limit_capture.output?[0], message)
	assert_equal(match_capture.to_a?, limit_capture.captures, message)
	assert_equal(match_capture.to_a?.join, limit_capture.captures.join, message)
#	assert_method(match_capture, limit_capture, :string, message)
	assert_method(match_capture, limit_capture, :regexp, message)
	assert_method(match_capture, limit_capture, :length_hash_captures, message)
	assert_method(match_capture, limit_capture, :captures, message)
	assert_method(match_capture, limit_capture, :repetitions?, message)
	assert_method(match_capture, limit_capture, :matched_characters?, message)
	assert_method(match_capture, limit_capture, :pre_match?, message)
#	assert_method(match_capture, limit_capture, :post_match?, message)
	assert_method(match_capture, limit_capture, :delimiters?, message)
	assert_method(match_capture, limit_capture, :to_a?, message)
end # assert_parse_once
def assert_parse_string(answer, string, pattern, message='')
	message=add_parse_message(string, pattern, message)+"\nnames=#{pattern.names.inspect}"
	message+="\nnamed_captures=#{pattern.named_captures.inspect}"
	assert_match(pattern, string, message)
	matchData=pattern.match(string)
	assert_operator(pattern.named_captures.values.flatten.size, :<=, matchData.size-1, "All string parse captures should be named.\n"+message)
	assert_equal(answer, parse_string(string, pattern), add_parse_message(string, pattern, message))

end #parse_string
def assert_parse(pattern, message='')
	match_capture=Capture.new(self, Branch_regexp, :match)
	split_capture=Capture.new(self, Branch_regexp, :split)
	capture = capture?(pattern)
	match = match?(pattern)
	if match.nil? || match == [] then
		if pattern.instance_of?(Array) then
			pos = 0
			pattern.map do |p|
				ret = self[pos..-1].assert_parse(p) # recurse
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
	end # if
end # assert_parse
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

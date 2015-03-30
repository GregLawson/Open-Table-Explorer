###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
#require_relative '../../app/models/stream_tree.rb'
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
end # default_name
end # ClassMethods
extend ClassMethods
attr_reader :string, :regexp # arguments
attr_reader :captures, :length_hash_captures
attr_reader :raw_captures
def initialize(string, regexp)
	@string = string
	@regexp = Regexp.promote(regexp)
	@length_hash_captures = @regexp.named_captures.values.flatten.size
#     named_captures for captures.size > names.size
end #initialize
def [](capture_index, hash_offset = 0)
	if self.raw_captures.instance_of?(MatchData) then
		@raw_captures[capture_index]
	else
		@raw_captures[hash_offset + capture_index * @regexp.names.size]
	end # if
end # []
def named_hash(hash_offset=0)
	named_hash={}
	@regexp.named_captures.each_pair do |named_capture, indices| # return named subexpressions
		name=Capture.default_name(0, named_capture).to_sym
		named_hash[name]= self[indices[0], hash_offset]
		if indices.size>1 then
			indices[1..-1].each_index do |capture_index,i|
				name=Capture.default_name(i, named_capture).to_sym
				named_hash[name]= self[capture_index]
			end #each_index
		end #if
	end # each_pair
	# with the current ruby Regexp implementation, the following is impossible
	# If there is a named capture in match or split, all unnamed captures are ignored
#	possible_unnamed_capture_indices.each do |capture_index|
#		name=Capture.default_name(capture_index).to_sym
#		named_hash[name]= to_a?[capture_index]
#	end #each
	named_hash
end #named_hash
def ==(other)
	instance_variables.all? do |iv_name|
		if !([:@raw_captures].include?(iv_name)) then
			self.instance_variable_get(iv_name) == other.instance_variable_get(iv_name)
		else
			true # pass all? for cetain instance variables
		end # if
	end # All?
end # equal
# return a capture object for two Capture instances (assumed consecutive)
def +(other_capture)
	raise "Only Capture instances can be added." if !other_capture.instance_of?(Capture)
	Capture.new(self.string + other_capture.string, [self.regexp, other_capture.regexp])
		
end # +
#     named_captures for captures.size > names.size

# Capture::Assertions
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
end # assert_pre_conditions
def assert_method(match_capture, limit_capture, argumentless_method_name = :output?, message = '')
	message += "match_capture = #{match_capture.inspect}\limit_capture = #{limit_capture.inspect}"
	match_method_object = match_capture.method(argumentless_method_name)
	limit_method_object = limit_capture.method(argumentless_method_name)
	assert_equal(match_method_object.call, limit_method_object.call, message)
end # assert_method
end #ClassMethods
# Any match at all
def assert_pre_conditions(message='')
	assert_not_nil(to_a?, 'no match at all.')
	if output? == {} then

#		assert_equal({}. to_a?, 'MatchData but no captures.')
	elsif output? == [] then
		assert_not_empty(to_a?, 'split but no captures.')
	end # if
	assert(success?)
end # assert_pre_conditions
def assert_success
	if raw_captures.nil? then 
		assert(false, self.inspect)
	elsif raw_captures.instance_of?(MatchData) then
		true
	else # :split
		if @length_hash_captures == 0 then # no captures
			match_capture = MatchCapture.new(string, regexp)
			match_capture.assert_success
		else # captures
			if raw_captures.size < 2 then # split failed
				assert(false, self.inspect)
			else # split succeeded
				true
			end #if
		end # if
	end #if
	assert(success?, self.inspect)
end # assert_success
def assert_left_match(message = '')
#	message = add_default_message(message)
	assert(success?, message)
	message += "\nregexp = " + regexp.inspect
	message += "\nstring... = " + string[0..50].inspect
	assert_not_match(regexp, pre_match?)
	assert_empty(pre_match?, message + "\nA left match requires pre_match? = #{pre_match?.inspect} to be empty.")
	assert_empty(delimiters?.join("\n")[0..100], message + "\nDelimiters were found in a split match = "+delimiters?.inspect)
	assert_success
end # assert_left_match
# exact match, no left-overs
def assert_post_conditions(message = '')
#	assert_left_match(add_default_message(message))
#	assert_empty(post_match?, 'Only a left match.' + add_default_message(message))
end # assert_post_conditions
def repetition_options?
	if @regexp.respond_to?(:repetition_options) then
		@regexp.repetition_options
	else
		nil
	end # if
end # repetition_options?
def add_parse_message(string, pattern, message='')
	message = add_default_message(message)
	newline_if_not_empty(message)+"\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
end #add_parse_message
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
Newline_Delimited_String="* 1\n  2"
Newline_Terminated_String=Newline_Delimited_String+"\n"
#Branch_regexp = /[* ]/.capture(:current) * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
Branch_line_regexp = Branch_regexp * "\n"
LINE=/[^\n]*/.capture(:line)
Line_terminator=/\n/.capture(:terminator)
Terminated_line=(LINE*Line_terminator).group
Hash_answer={:line=>"* 1", :terminator=>"\n"}
Array_answer=[{:line=>"* 1", :terminator=>"\n"}, {:line=>"  2", :terminator=>"\n"}]

WORD=/([^\s]*)/.capture(:word)
end # Examples
end # Capture
# encapsulates the difference between parsing from MatchData and from Array#split
class RawCapture < Capture
def initialize(string, regexp)
	super(string, regexp)
	@raw_captures = raw_captures?
#     named_captures for captures.size > names.size
end #initialize
end # RawCapture

class MatchCapture < RawCapture
attr_reader :string, :regexp # arguments
attr_reader :captures, :length_hash_captures
attr_reader :raw_captures
def initialize(string, regexp)
	super(string, regexp)
end #initialize
def raw_captures?
	@string.match(@regexp)
end # raw_captures?
def success?
	if @raw_captures.nil? then 
		nil
	else
		true
	end #if
end # success?
def repetitions?
	if @raw_captures.nil? then 
		0
	else
		1
	end #if
	 1
	
end # repetitions?
# Tranform split and MatchData captures into single form
def to_a?
	raise @raw_captures.inspect unless @raw_captures.nil? || @raw_captures.instance_of?(MatchData)
		[pre_match?] + 
		[@raw_captures[0]] + 
		[post_match?]
end # to_a?
def post_match?
	raw_captures.post_match
	

end # post_match?
def pre_match?
	if !success? then
		''
	else
		raw_captures.pre_match

	end #if

end # pre_match?
def matched_characters?
	if @raw_captures.nil? then
		''
	else
		@raw_captures[0]
	end #if
end # matched_characters?
def number_matched_characters?
	matched_characters?.length
end # number_matched_characters?
def output?
	if !success? then
		{}
	elsif raw_captures.instance_of?(MatchData) then
		if raw_captures.names==[] then
			raw_captures[1..-1] # return unnamed subexpressions
		else
			named_hash(0)
		end # if
	end # if
end # output?
def delimiters?
		[]
end # delimiters?
module Examples
include Capture::Examples
Parse_string = MatchCapture.new(Newline_Delimited_String, Branch_regexp)
Branch_line_capture  = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
Match_capture = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
end # Examples
end # MatchCapture

class SplitCapture < RawCapture
attr_reader :string, :regexp # arguments
attr_reader :captures, :length_hash_captures
attr_reader :raw_captures
def initialize(string, regexp)
	super(string, regexp)
end #initialize
def raw_captures?
	@string.split(@regexp)
end # raw_captures?
def success?
	if @length_hash_captures == 0 then # no captures
		match_capture = MatchCapture.new(string, regexp)
		match_capture.success?
	else # captures
		if raw_captures.size < 2 then # split failed
			false
		else # split succeeded
			true
		end #if
	end # if
end # success?
def repetitions?
	if @raw_captures.nil? then
		0
	else
		(@raw_captures.size/(@length_hash_captures+1)).ceil
	end # if
end # repetitions?
# Tranform split and MatchData captures into single form
def to_a?
	raw_captures
end # to_a?
def post_match?
	if raw_captures.size.odd? then
		raw_captures[-1]
	else
		''
	end # if

end # post_match?
def pre_match?
	raw_captures[0]
end # pre_match?
def matched_characters?
	@string[0,number_matched_characters?]
end # matched_characters?
def number_matched_characters?
	@string.length - pre_match?.length - post_match?.length
end # number_matched_characters?
def output?
	(0..repetitions?-1).map do |i|
		named_hash(i*(@length_hash_captures+1))
	end #map
end # output?
def delimiters?
	(2..@raw_captures.size - 2).map {|i| (i.even? ? @raw_captures[i] : nil)}.compact
end # delimiters?
module Examples
include Capture::Examples
Split_capture = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
Parse_array = SplitCapture.new(Newline_Terminated_String, Branch_regexp)
	Failed_capture = SplitCapture.new('cat', /fish/)
	Syntax_failed_capture = SplitCapture.new('cat', 'f)i]s}h')
Branch_line_capture = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
Branch_regexp_capture = SplitCapture.new(Newline_Delimited_String, Branch_regexp)
Failed_capture = SplitCapture.new('cat', /fish/)
Syntax_failed_capture = SplitCapture.new('cat', 'f)i]s}h')
Parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_regexp)
end # Examples
end # SplitCapture

# LimitCapture
class LimitCapture < SplitCapture
# limit match to :match length of string
def raw_captures?
	fail Exception.new('@string is not String but '+@string.class.name) if !@string.instance_of?(String)
	method = @string.method(:match)
	match = method.call(@regexp)
	if match.nil? then
		match
	else
		string =  match[0] # regexp matched string
		@string.method(:split).call(@regexp) # after string shortened
	end # if
end # raw_captures?
module Examples
include Capture::Examples
Branch_line_capture = LimitCapture.new(Newline_Delimited_String, Branch_line_regexp)
Limit_capture = LimitCapture.new(Newline_Delimited_String, Branch_line_regexp)
end # Examples
end # LimitCapture

# class ParsedCapture
class ParsedCapture < RawCapture
attr_reader :string, :regexp # arguments
attr_reader :parsed_regexp, :length_hash_captures
attr_reader :raw_captures
def initialize(string, regexp)
	super(string, regexp)
#	@parsed_regexp = Regexp::Parser.parse( regexp.to_s, 'ruby/1.8')
end # ParsedCapture_initialize
def raw_captures?
#	Regexp::Parser.parse(@regexp.to_s, 'ruby/1.8').raw_capture?(@string)
end #raw_captures?
def success?
	@raw_captures[0][:raw_capture].success?
end # success?
def post_match?
	@raw_captures[0][:raw_capture].post_match?

end # post_match?
def pre_match?
	@raw_captures[0][:raw_capture].pre_match?
end # pre_match?
def matched_characters?
	@raw_captures.reduce('', :+) {|c| c[:raw_capture].matched_characters?}
end # matched_characters?
def output?
	@raw_captures.reduce({}, :merge) {|c| c[:raw_capture].output?}
end # output?
def delimiters?
	@raw_captures.reduce('', :+) {|c| c[:raw_capture].delimiters?}
end # delimiters?
module Examples
include Capture::Examples
#Branch_line_capture = ParsedCapture.new(Newline_Delimited_String, Branch_line_regexp)
Parsed_a_capture = ParsedCapture.new('a\na', /a/.capture(:label))
end # Examples
end # ParsedCapture
# String
class String
def map_captures?(regexp_array)
	ret = []
	capture = self.capture?(regexp_array[0])
	if capture.success? then
		remaining_string = capture.post_match?
	else
		remaining_string = string # no advance in string yet
	end # if
	if remaining_string.empty? || regexp_array.size == 1 then
		return ret # return array of exact captures including failures
	else
		ret += [capture]
		ret += remaining_string.map_captures?(regexp_array[1..-1])
	end # if
end # map_capture?
# Try to unify match and split (with Regexp delimiter)
# What is the difference between an Object and an Array of size 1?
# Should difference be derived from recursive analysis of RegexpParse?
# Where repetitions produce Array, others produe Hash
# complicated by fact regular expressions simulate repetitions with recursive alternatives
# capture? returns a tree of Capture objects while parse returns only the output Hash
# capture_class default should be best parse capture; currently LimitCapture
def capture?(pattern, capture_class = LimitCapture)
	if pattern.instance_of?(Array) then
		pos = 0
		pattern.map do |p|
			ret = self[pos..-1].capture?(p) # recurse returning Capture
			if ret.instance_of?(Array) then
				pos += ret.reduce(0) {|sum, c| sum + c.number_matched_characters?}
			else
				pos += ret.number_matched_characters?
			end # if
			ret
		end # map
	elsif pattern.instance_of?(String) then
		# see http://stackoverflow.com/questions/3518161/another-way-instead-of-escaping-regex-patterns
		capture?(Regexp.new(Regexp.quote(pattern)), capture_class)
	else
		capture = capture_class.new(self, pattern)
	end # if
end # capture?
def parse(regexp)
	regexp.enumerate(:map) do |reg|
		capture?(reg).enumerate(:map) {|c| c.output?}
	end # enumerate
end # parse
module Constants
end #Constants
include Constants
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
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
	match_capture = MatchCapture.new(self, pattern)
	split_capture = SplitCapture.new(self, pattern)
	limit_capture = SplitCapture.new(self[0, match_capture.number_matched_characters?], pattern)
	message = "match_capture = #{match_capture.inspect}\nsplit_capture = #{split_capture.inspect}"
#	Capture.assert_method(match_capture, limit_capture, :string, message)
	Capture.assert_method(match_capture, limit_capture, :regexp, message)
	Capture.assert_method(match_capture, limit_capture, :length_hash_captures, message)
#	Capture.assert_method(match_capture, split_capture, :captures, message)
	Capture.assert_method(match_capture, limit_capture, :repetitions?, message)
	Capture.assert_method(match_capture, limit_capture, :matched_characters?, message)
	Capture.assert_method(match_capture, limit_capture, :pre_match?, message)
#	Capture.assert_method(match_capture, limit_capture, :post_match?, message)
	Capture.assert_method(match_capture, limit_capture, :delimiters?, message)
#	Capture.assert_method(match_capture, limit_capture, :to_a?, message)
	assert_equal(match_capture.output?, limit_capture.output?[0], message)
	common_capture = match_capture.to_a?[0..-2]
	last_common_capture = common_capture.size - 1
	assert_equal(common_capture.join, split_capture.to_a?[0..last_common_capture].join, message)
	assert_equal(common_capture, split_capture.to_a?[0..last_common_capture], message)
	assert_equal(common_capture, limit_capture.to_a?[0..last_common_capture], message)
	assert_equal(common_capture, limit_capture.to_a?, message)
end # assert_parse_once
def assert_left_parse(pattern, message='')
	if pattern.instance_of?(Array) then
		pos = 0
		pattern.map do |p|
			ret = self[pos..-1].assert_left_parse(p) # recurse
			pos += ret.number_matched_characters?
			ret
		end # map
	else
		match_capture = MatchCapture.new(self, pattern)
		split_capture = SplitCapture.new(self, pattern)
		limit_capture = LimitCapture.new(self, pattern)
		match_capture.assert_left_match
#		split_capture.assert_left_match
		limit_capture.assert_left_match
		# limit repetitions to pattern, get all captures
		if split_capture.repetitions? == 1 then
			match_capture
		elsif match_capture.output? == split_capture.output?[-1] then # over-written captures
			split_capture
		else
			match_capture
		end # if
	end # if
end # assert_left_parse
def assert_parse(pattern, message='')
	capture = capture?(pattern)
	capture_runs = capture.enumerate(:chunk) do |c|
		success = c.success?
	end # chunk
	capture_runs.each do |success, run|
		case success
		when true then message+= ' matched'
		when nil then message+= ' unmatched'
		end # case
	end # each
		match_capture = MatchCapture.new(self, pattern)
		split_capture = SplitCapture.new(self, pattern)
		limit_capture = LimitCapture.new(self, pattern)
		match_capture.assert_post_conditions(message)
		split_capture.assert_post_conditions(message)
		limit_capture.assert_post_conditions(message)
		# limit repetitions to pattern, get all captures
		if split_capture.repetitions? == 1 then
			puts message + "\n" + match_capture.inspect
		elsif match_capture.output? == split_capture.output?[-1] then # over-written captures
			puts message + "\n" + split_capture.inspect
		else
			puts message + "\n" + match_capture.inspect
		end # if
end # assert_parse
end #Assertions
include Assertions
module Examples
include Constants
include Regexp::Constants
LINES_cryptic=/([^\n]*)(?:\n([^\n]*))*/
CSV=/([^,]*)(?:,([^,]*?))*?/
Ls_octet_pattern = /rwx/
Ls_permission_pattern = [/1|l/,
					Ls_octet_pattern.capture(:system_permissions),
					Ls_octet_pattern.capture(:group_permissions), 
					Ls_octet_pattern.capture(:owner_permissions)] 
Filename_pattern = /[-_0-9a-zA-Z\/]+/
Driver_pattern = [
							/\s+/, /[0-9]+/.capture(:permissions),
							/\s+/, /[0-9]+/.capture(:size),
							/ /, Ls_permission_pattern,
							/\s+/, /[a-z]+/.capture(:owner),
							/\s+/, /[a-z]+/.capture(:group),
							/\s+/, /[0-9]+/.capture(:size_2),
							/\s+/, /[A-Za-z]+/.capture(:month),
							/\s+/, /[0-9]+/.capture(:date),
							/\s+/, /[0-9]+/.capture(:time),
							/\s+/, '/sys/devices',
							Filename_pattern.capture(:device),
							' -> ', 
							Filename_pattern.capture(:driver)]
Driver_string = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'
end #Examples
end # String


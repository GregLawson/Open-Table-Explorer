###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Regexp
#include Comparable
module ClassMethods
def promote(node)
	if node.instance_of?(String) then 
		Regexp.new(Regexp.new(Regexp.escape(node)))
	elsif node.instance_of?(Regexp) then 
		node
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #promote
# Rescue bad regexp and return nil
# Example regexp with unbalanced bracketing characters
def regexp_rescued(regexp_string, options=Default_options)
	raise "expecting regexp_string=#{regexp_string}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue RegexpError
	return nil
end #regexp_rescued
def regexp_error(regexp_string, options=Default_options)
	raise "expecting regexp_string=#{regexp_string.inspect}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue RegexpError => exception
	return exception
end #regexp_error
# A terminator is a delimiter that is at the end (like new line)
def terminator_regexp(delimiter)
#	raise "delimiter must be single characters not #{delimiter}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #terminator_regexp
# A delimiter is generally not at the end (like commas)
def delimiter_regexp(delimiter)
	raise "delimiters must be single characters not #{delimiter.inspect}." if delimiter.length!=1
	/([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
end #delimiter_regexp
end #ClassMethods
extend ClassMethods
def unescaped_string
	"#{source}"
end #unescape
def *(other)
	case other
	when Regexp then return Regexp.new(self.source + other.source)
	when String then return Regexp.new(self.source + other)
	when Fixnum then return Regexp.new(self.source*other)
	else
		raise "other.class=#{other.class.inspect}"
	end #case
end #sequence
def |(other) # |
	return Regexp.union(self.source, Regexp.promote(other).source)
end #alterative
def capture(key=nil)
	if key.nil? then
		/(#{self.source})/
	else
		/(?<#{key.to_s}>#{self.source})/
	end #if
end #capture
def group
	/(?:#{self.source})/
end #group
def capture_name_array
	names=[] # empty till added to
	named_captures.each_pair do |key, index_array|
		index_array.each do |index|
			names[index-1]=key.to_sym # delete zero index (not a capture)
		end #each
	end #each_pair
	names
end #capture_names
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
def assert_pre_conditions
end #assert_pre_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Constants
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
Any_binary_char_string='[\000-\377]'
end #Constants
include Constants
module Examples
include Constants
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
Any_binary_char_string='[\000-\377]'
Line_terminator=/\n/
Line_pattern=/([^\n]*)/
LINES=/([^\n]*)(?:\n([^\n]*))*/
WORDS=/([^\s]*)(?:\s([^\s]*))*/
Ip_number_pattern=/\d{1,3}/
end #Examples
include Examples
end #Regexp

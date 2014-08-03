###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_model/naming'
require 'active_model/errors'
class Regexp
# @see http://en.wikipedia.org/wiki/Kleene_algebra
#include Comparable
extend ActiveModel::Naming # allow ActiveModel / ActiveRecord style error attributes. Naming clash?
module Constants
Default_options = 0 # Regexp::EXTENDED | Regexp::MULTILINE # only make sense for literals
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
Any_binary_char_string='[\000-\377]'
Any = 0..Float::INFINITY
Many = 1..Float::INFINITY
Optional='?'
Start_string=/\A/
End_string=/\z/
End_string_less_newline=/\Z/
US_ASCII_encoding = Encoding::US_ASCII # Encoding.find('US-ASCII')
Binary_encoding = Encoding::ASCII_8BIT
end #Constants
include Constants
module ClassMethods
def [](*array_form)
	array_form.reduce(//, :*) do |regexp|
		case regexp.class.to_s
		when 'Regexp' then regexp
		when 'String' then Regexp.new(Regexp.escape(node))
		else
			raise "unexpected node = #{regexp.inspect}"
		end # case
	end # reduce
end # []
def to_regexp_escaped_string(alternative_form)
		case alternative_form.class.to_s
		when 'Regexp' then alternative_form.source
		when 'String' then Regexp.escape(alternative_form)
		when 'Fixnum' then '{' + alternative_form.to_s + '}'
		when 'Range' then '{' + alternative_form.begin.to_s + ',' + alternative_form.end.to_s + '}'
		else raise "unexpected regexp alternative_form = #{alternative_form.inspect}\nalternative_form.class = #{alternative_form.class.to_s}"
		end # case
end # to_regexp_escaped_string
def promote(alternative_form)
	case alternative_form.class.to_s
	when 'Regexp' then alternative_form
	when 'String' then Regexp.new(to_regexp_escaped_string(alternative_form))
	else
		raise "unexpected regexp alternative_form = #{alternative_form.inspect}\nalternative_form.class = #{alternative_form.class.to_s}"
	end # case
end #promote
# Rescue bad regexp and return nil
# Example regexp with unbalanced bracketing characters
def regexp_rescued(regexp_string, options=Regexp::Default_options)
	raise "expecting regexp_string=#{regexp_string}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue  RegexpError => exception_raised
	@regexp_string = regexp_string
	@errors = {:RegexpError => exception_raised}
	return nil
end #regexp_rescued
def regexp_error(regexp_string)
	raise "Argument to regexp_error is expected to be a String; but regexp_string=#{regexp_string.inspect}" unless regexp_string.instance_of?(String)
	Regexp.new(regexp_string) # test
	return nil # if no RegexpError
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
def propagate_options(regexp)
	if regexp.instance_of?(Regexp) then
		ret= [(regexp.casefold? ? Regexp::CASE_FOLD : 0)]
		ret += [regexp.encoding]
	else
		[Regexp::Default_options, Encoding::US_ASCII]
	end # if
end #propagate_options
end #ClassMethods
extend ClassMethods
# Modeled on Numeric.coerce
# If a +alternative_form is the same type as self, returns an array containing alternative_form and self.
# Otherwise, returns an array with both a alternative_form and self represented as Regexp objects or to_regexp_escaped_string.
# This coercion mechanism is modeled on Ruby's handleing of mixed-type numeric operations: 
# it is intended to find a compatible common type between the two operands of the operator.
# 1.coerce(2.5)   #=> [2.5, 1.0]
# 1.2.coerce(3)   #=> [3.0, 1.2]
# 1.coerce(2)     #=> [2, 1]
def coerce_escaped_string(alternative_form)
	if self.class == alternative_form.class then
		[alternative_form, self]
	else
		[Regexp.to_regexp_escaped_string(alternative_form), Regexp.to_regexp_escaped_string(self)]
	end # if
end # coerce_escaped_string
def unescaped_string
	"#{source}"
end #unescape
def *(other)
	coerced_arguments = coerce_escaped_string(other)
	options = [Regexp.propagate_options(other), Regexp.propagate_options(self)]
	case other
	when Regexp then return Regexp.new(self.unescaped_string + other.unescaped_string)
	when String then return Regexp.new(self.unescaped_string + Regexp.escape(other))
	when Fixnum then return Regexp.new(self.unescaped_string  + '{' + other.to_s + '}')
	when Range then return Regexp.new(self.unescaped_string + '{' + other.begin.to_s + ',' + other.end.to_s + '}')
	when NilClass then raise "Right argument of :* operator evaluated to nil."+
		"\nPossibly add parenthesis to control operator versus method precedence."+
		"\nIn order to evaluate left to right, place parenthesis around operator expressions."
		"\nself=#{self.inspect}"
	else
		raise "other.class=#{other.class.inspect}"
	end #case
end #sequence
def |(other) # |
	return Regexp.new(self.unescaped_string + '|' + other.unescaped_string)
#	return Regexp.union(Regexp.new(self.unescaped_string), Regexp.promote(other).unescaped_string)
end #alterative
def capture(key=nil)
	if key.nil? then
		/(#{self.source})/
	else
		/(?<#{key.to_s}>#{self.source})/
	end #if
end #capture
# capture backreferences must be all numbered or all named.
def back_reference(key)
		/#{self.source}\k<#{key.to_s}>/
rescue RegexpError => exception
	warn "back_reference regexp=/#{self.source}\k<#{key.to_s}>/ failed."+
		"\nPossibly add parenthesis to control operator versus method precedence."+
		"\nIn order to evaluate left to right, place parenthesis around operator expressions."
end #back_reference
def group
	/(?:#{self.source})/
end #group
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_post_conditions
end #assert_post_conditions
def assert_pre_conditions
end #assert_pre_conditions
end #ClassMethods
def assert_pre_conditions
# by definition 	assert_match(Regexp.new(Regexp.escape(str), str)
	assert_equal(self, Regexp.promote(self))
	assert_equal(self, /#{self.unescaped_string}/)
#	assert_equal(self, Regexp.promote(self).unescaped_string)
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_no_exception(message)
end # assert_no_exception
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
include Constants
Ip_number_pattern=/\d{1,3}/
Escape_string='\d'
Back_reference=((/[aeiou]/.capture(:vowel)*/./).back_reference(:vowel)*/./).back_reference(:vowel)
Regexp_exception = Regexp.regexp_error('[')
end #Examples
end #Regexp
class RegexpError
def assert_pre_conditions
	assert_instance_of(RegexpError, Regexp.regexp_error('['))
	assert_instance_of(String, backtrace[0])
	assert_match(/regexp/, backtrace[0])
	assert_instance_of(Thread::Backtrace::Location, backtrace_locations[0])
	assert_equal('initialize', backtrace_locations[0].base_label)
	assert_equal('initialize', backtrace_locations[0].label)
	assert_instance_of(Fixnum, backtrace_locations[0].lineno)
	assert_match(/[a-z.]+/, backtrace_locations[0].path)
	assert_match(/[a-z.\/]+/, backtrace_locations[0].absolute_path)
	assert_equal(message, self.message)
end #assert_pre_conditions
end # RegexpError

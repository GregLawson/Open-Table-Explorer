###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
require_relative 'nested_array.rb'
require_relative 'regexp_parse.rb'
#require_relative 'regexp_alternative.rb'
#require_relative 'regexp_sequence.rb'
class RegexpTree < NestedArray
include Comparable
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
#raise "" unless self.constants.include?('Default_options')
# Parse regexp_string into parse tree for editing
def initialize(regexp=[], probability_space_regexp='[[:print:]]+', options=Default_options)
	if regexp.kind_of?(Array) then #nested Arrays
		super(regexp)
		
	elsif regexp.instance_of?(String) then 
		super(RegexpParse.new(regexp).to_a)
	elsif regexp.instance_of?(RegexpParse) then 
		super(regexp.to_a)
	elsif regexp.instance_of?(Regexp) then 
		super()
		super(RegexpParse.new(regexp.source).to_a)
	else
		raise "unexpected regexp=#{regexp.inspect}"
	end #if
	@probability_space_regexp=probability_space_regexp
#	@anchor=Anchoring.new(self) infinite recursion
end #initialize
def RegexpTree.promote(node)
	if node.kind_of?(RegexpTree) then #nested Arrays
		node
	elsif node.kind_of?(Array) then #nested Arrays
		RegexpTree.new(node)
		
	elsif node.instance_of?(String) then 
		RegexpTree.new(RegexpParse.new(node).to_a)
	elsif node.instance_of?(RegexpParse) then 
		RegexpTree.new(node.to_a)
	elsif node.instance_of?(Regexp) then 
		RegexpTree.new(RegexpParse.new(node.source).to_a)
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #RegexpTree.promote
def self.canonical_regexp(regexp)
	if regexp.instance_of?(String) then
		regexp=RegexpTree.regexp_rescued(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch) then
		regexp=RegexpTree.regexp_rescued(regexp.to_s)
	elsif regexp.nil? then
		return //
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class}."
	end #if
	return regexp
end #canonical_regexp
def self.canonical_regexp_tree(regexp)
	if regexp.instance_of?(String) then
		regexp=RegexpTree.new(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch) then
		regexp=RegexpTree.new(regexp.to_s)
	elsif regexp.nil? then
		return //
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class.inspect}."
	end #if
	return regexp
end #canonical_regexp_tree
#include Inline_Assertions
def probability_space_regexp
	RegexpTree.new(@probability_space_regexp)
end #probability_space_regexp
def probability_space_size
	probability_space_regexp.repeated_pattern.string_of_matching_chars.size
end #probability_space_size
def compare_repetitions?(other)
	return nil if other.instance_of?(String)
	my_repeated_pattern=self.repeated_pattern
	other_repeated_pattern=other.repeated_pattern
	if my_repeated_pattern!=other_repeated_pattern then
		return nil # 
	else
		my_repetition_length=self.repetition_length
		other_repetition_length=other.repetition_length
		if my_repetition_length==other_repetition_length then
			return 0
		elsif my_repetition_length.begin<=other_repetition_length.begin then
			if my_repetition_length.end.nil? then
			elsif my_repetition_length.end>=other_repetition_length.end then
				return 1
			end #if
		elsif my_repetition_length.end<=other_repetition_length.end &&  my_repetition_length.begin>=other_repetition_length.begin then
			return -1
		else
			return nil
		end #if
	end #if

end #compare_repetitions
# intersetion should be interpreted as
# the intersection of the Languages (sets of possible matches)
# that can be matched by each regexp
# I == L & R
# then L >= I && R >= I
# if no intersetion: I==[]
# then L >= [] and R >= []
def &(rhs)
	repetition_length=self.repetition_length & rhs.repetition_length
	repetition_node=repetition_length.concise_repetition_node(repetition_length.begin, repetition_length.end)
	RegexpTree.new([self.repeated_pattern.sequence_intersect(rhs.repeated_pattern), repetition_node])
end #intersection
def <=>(other)
	anchor_comparison=compare_anchors?(other)
	if self.to_s==other.to_s then # avoid recursion
		return 0
	else
		cc_comparison=compare_character_class?(other)
		if !cc_comparison.nil? then
			return cc_comparison
		else
			repetition_comparison=compare_repetitions?(other)
			if !repetition_comparison.nil? then
				return repetition_comparison
			end #if
			sequence_comparison=compare_sequence?(other)
			if !sequence_comparison.nil? then
				return sequence_comparison
			else
				return nil
			end #if
		end #if
	end #if
end #<=>
def +(other)
	return RegexpTree.new(self.to_a+other.to_a)
end #+
def to_a
	return NestedArray.new(self)
end #to_a
# file name glob (suitible for Dir[]) most like regexp.
# often matches more filenames than regexp (see pathnames)
def to_pathname_glob
	ret=RegexpParse.new(map_branches{|b| (b[0]=='('?RegexpTree.new(b[1..-2]):RegexpTree.new(b))})
	ret=ret.postfix_operator_walk{|p| '*'}
	if ret.instance_of?(RegexpParse) then
		ret=ret.parse_tree.flatten.join
	elsif ret.kind_of?(Array) then
		ret=ret.flatten.join
	end #if
	return ret
end #to_pathname_glob
def pathnames
	Dir[to_pathname_glob].select do |pathname|
		to_regexp.match(pathname)
	end #select
end #pathnames
def grep(pattern, delimiter="\n")
	pathnames.files_grep(pattern, delimiter="\n")
end #grep
def to_s
	to_a.join
end #to_s
def to_regexp(options=Default_options)
	regexp_string=to_s
	regexp=RegexpTree.regexp_rescued(regexp_string, options)

	return regexp
end #to_regexp
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
# Rescue bad regexp and return nil
# Example regexp with unbalanced bracketing characters
def RegexpTree.regexp_rescued(regexp_string, options=Default_options)
	raise "expecting regexp_string=#{regexp_string}" unless regexp_string.instance_of?(String)
	return Regexp.new(regexp_string, options)
rescue RegexpError
	return nil
end #regexp_rescued
def regexp_error(regexp_string, options=Default_options)
	return Regexp.new(regexp_string, options)
rescue RegexpError => exception
	return exception
end #regexp_error
# returns pair of min and end repetitions of a RegexpTree
# end can be nil to signify unlimited repetitions
end #RegexpTree

###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
require 'app/models/inlineAssertions.rb'
class RegexpAlternative < RegexpTree
include Comparable
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
def RegexpAlternative.promote(node)
	if node.kind_of?(RegexpTree) then #nested Arrays
		node
	elsif node.kind_of?(Array) then #nested Arrays
		RegexpAlternative.new(node)
		
	elsif node.instance_of?(String) then 
		RegexpAlternative.new(RegexpParse.new(node).to_a)
	elsif node.instance_of?(RegexpParse) then 
		RegexpAlternative.new(node.to_a)
	elsif node.instance_of?(Regexp) then 
		RegexpAlternative.new(RegexpParse.new(node.source).to_a)
	else
		raise "unexpected node=#{node.inspect}"
	end #if
end #RegexpAlternative.promote
def self.canonical_regexp(regexp)
	if regexp.instance_of?(String) then
		regexp=RegexpAlternative.regexp_rescued(regexp)
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
		regexp=RegexpAlternative.new(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpAlternative) || regexp.instance_of?(RegexpMatch) then
		regexp=RegexpAlternative.new(regexp.to_s)
	elsif regexp.nil? then
		return //
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class.inspect}."
	end #if
	return regexp
end #canonical_regexp_tree
def probability_of_alternatives(branch=self)
	if branch.instance_of?(String) then
		return 1.0/probability_space_size
	else
	end #if
	bulk_length=branch.reduce(0) {|sum, e| sum + e.size } 
	if bulk_length==branch.size then #character class
		branch.size/probability_space_size
	elsif branch.size==2 then # recursion termination
		intersection=branch[0] & branch[1]
		(branch[0].size+branch[1].size-intersection.size)/probability_space_size
	elsif branch.size==1 then # recursion termination
		branch[0].size/probability_space_size

	else # alternatives
	
	end #if
end #probability_of_alternatives
def compare_character_class?(other)
	return nil if other.instance_of?(String)
	my_cc=self.character_class?
	return nil if my_cc.nil?
	my_chars=my_cc
	other_cc=other.character_class?
	return nil if other_cc.nil?
	other_chars=other_cc
	intersection=my_chars & other_chars
	if my_chars.to_s==other_chars.to_s then
		return 0
	elsif intersection==my_chars then
		return -1
	elsif intersection==other_chars then
		return 1
	else
		return nil
	end #if
end #compare_character_class
# inputs are RegexpTree
# pass only alternatives not sequences or repetitions
# return alternative Array not RegexpTree
def alternatives_intersect(rhs)
	lhs_alternatives=self.alternatives?
	rhs_alternatives=rhs.alternatives?
	alternatives=lhs_alternatives & rhs_alternatives
	alternatives
end #alternatives_intersect
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
# Returns flattened(?) Array of alternatives
# flattening removes the tree structure of the | operator
# since | (choice like addition) is associative and transitive
# Does not change distribution of sequence over choice
# as that could lead to combinoric explosion
# Or nil if no alternatives
# If passed a non-array recursion terminates and branch is returned.
# Converts character classes to alternatives
def alternatives?(branch=self)
	if branch.kind_of?(String) then
		[branch]
	elsif !branch.kind_of?(Array) then
		nil # no alternatives possible
	else
		cc_comparison=branch.character_class?
		if cc_comparison then
			cc_comparison
		elsif branch[0].size==2 && branch[0][-1]=='|' then
			lhs=branch[0][0]
			rhs=alternatives?(branch[1..-1])
			if rhs.nil? then
				[lhs] 
			else
				([lhs] + rhs).sort
			end #if
		else
			if branch.instance_of?(String) && branch.length==1 then
				branch # # terminate recursion with last alternative
			else
				nil
			end #if
		end #if
	end #if
end #alternatives
# is RegexpTree a character class?
# compatible with alternatives? and string_of_matching_chars
def character_class?(branch=self)
	if branch.kind_of?(Array) && branch[0]=='['  && branch[-1]==']' then
		return branch.string_of_matching_chars 
	elsif branch.kind_of?(Array)  && branch.size==1 && branch[0].instance_of?(String) && branch[0].size==1then
		return branch.string_of_matching_chars(branch) # single character
	elsif branch.kind_of?(String) && branch.length==1 then
		return branch.string_of_matching_chars(branch) # single character
	else
		return nil	
	end #if
end #character_class
def to_s
	to_a.join
end #to_s
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
#y caller
# 
def string_of_matching_chars(regexp=self)
	char_array=Binary_bytes.select do |char|
		if RegexpMatch.match_data?(regexp, char) then
			char
		else
			nil
		end #if
	end #select
	
	return char_array
end #string_of_matching_chars
end #RegexpTree

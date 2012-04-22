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
class Anchoring < ActiveSupport::HashWithIndifferentAccess
include Comparable
attr_reader :start_base, :end_base
def initialize(regexp_tree)
	@start_base=0
	@end_base=-1
	self[:start_anchor]=if regexp_tree[0]=='^' then
		@start_base=1
		'^'
	else
		nil
	end #if
	self[:end_anchor]=if regexp_tree[-1]=='$' then
		@end_base=-2
		'$'
	else
		nil
	end #if
	self[:base_regexp]=regexp_tree[@start_base..@end_base]
end #initialize
def compare_anchor(other, key)
	if self[key]==other[key] then
		return 0
	elsif other[key] then 
		return 1
	elsif self[key] then 
		return -1
	else
		return nil
	end #if
end #compare_anchor
def <=>(other)
	comparison_case=[compare_anchor(other, :start_anchor), compare_anchor(other, :end_anchor)]
	case comparison_case
	when [0,0]
		return 0
	when [0,1], [1,1], [1,0] #specialized and equal
		return 1
	when [0,-1], [-1,-1] #specialized and equal
		return -1
	when [-1,1], [1,-1] #disagreement
		nil
	else
		raise "In Anchoring.<=> Unexpected case=#{comparison_case.inspect},self=#{self.inspect}, other=#{other.inspect}"
	end #case
end #<=>
end #Anchoring
class RepetitionLength < ActiveSupport::HashWithIndifferentAccess
include Comparable
def initialize(min, max)
	self[:min]=min
	self[:max]=max
	raise "min must not be nil." if min.nil? 
	raise "min=#{min} must be less than or equal to max=#{max}." if !max.nil? && min > max
end #initialize
def <=>(other)
 	if self[:min]==other[:min] && self[:max]==other[:max] then
		return 0
	elsif self[:min]<=other[:min] && (self[:max].nil? || self[:max]>=other[:max]) then
		return 1
	elsif other[:min]<=self[:min] && (other[:max].nil? || other[:max]>=self[:max]) then
		return -1
	else
		return nil
	end #if
end #compare
# calculate sum for merging sequential repetitions
def +(other)
	if self[:max].nil? || other[:max].nil? then
		max=nil # infinity+ anything == infinity
	else
		max=self[:max]+other[:max]
	end #if
	return RepetitionLength.new(self[:min]+other[:min], max)
end #plus
# intersection. If neither is a subset of the other return nil 
def &(other)
	min= [self[:min], other[:min]].max
	max=if self[:max].nil? then
		other[:max]
	else
		case self[:max] <=> other[:max]
		when 1,0
			other[:max]
		when -1
			self[:max]
		when nil
			return nil	
		end #case
	end #if
	RepetitionLength.new(min, max)
end #intersect
# Union. Unlike set union disjoint sets return a spanning set.
def |(other)
	min= [self[:min], other[:min]].min
	max=if self[:max].nil? then
		nil
	else
		case self[:max] <=> other[:max]
		when 1,0
			self[:max]
		when -1
			other[:max]
		when nil
			max=[self[:max], ther[:max]].max	
		end #case
	end #if
	RepetitionLength.new(min, max)
end #union / generalization
def canonical_repetition_tree(min=self[:min], max=self[:max])
	return RegexpTree.new(['{', [min.to_s, ',', max.to_s], '}'])
end #canonical_repetition_tree
# Return a RegexpTree node for self
# Concise means to use abbreviations like '*', '+', ''
# rather than the canonical {n,m}
# If no repetition returns '' equivalent to {1,1}
def concise_repetition_node(min=self[:min], max=self[:max])
	if min==0 then
		if max==1 then
			return '?'
		elsif max.nil? then
			return '*'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min==1 then
		if max==1 then
			return ''
		elsif max.nil? then
			return '+'
		else
			return canonical_repetition_tree(min, max)
		end #if
	elsif min==max then
		return RegexpTree.new(['{', [min.to_s], '}'])
	else
		return canonical_repetition_tree(min, max)
	end #if
	return RegexpTree.new(['{', [min.to_s, max.to_s], '}'])
end #concise_repetition_node
end #RepetitionLength
class RegexpTree < NestedArray
include Comparable
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
include Inline_Assertions
def probability_space_regexp
	RegexpTree.new(@probability_space_regexp)
end #probability_space_regexp
def probability_space_size
	probability_space_regexp.repeated_pattern.string_of_matching_chars.size
end #probability_space_size
def self.OpeningBrackets
	return '({['
end #OpeningBrackets
def self.ClosingBrackets
	return ')}]'
end #ClosingBrackets
def self.PostfixOperators
	return '+*?|'
end #def
#raise "" unless self.constants.include?('Default_options')
# Parse regexp_string into parse tree for editing
def initialize(regexp=[], options=Default_options)
	if regexp.kind_of?(Array) then #nested Arrays
		super(regexp)
		
	elsif regexp.instance_of?(String) then 
		super(RegexpParser.new(regexp).to_a)
	elsif regexp.instance_of?(RegexpParser) then 
		super(regexp.to_a)
	elsif regexp.instance_of?(Regexp) then 
		super()
		super(RegexpParser.new(regexp.source).to_a)
	else
		raise "unexpected regexp=#{regexp.inspect}"
	end #if
	@probability_space_regexp='[[:print:]]+'
end #initialize
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
		elsif my_repetition_length[:min]<=other_repetition_length[:min] then
			if my_repetition_length[:max].nil? then
			elsif my_repetition_length[:max]>=other_repetition_length[:max] then
				return 1
			end #if
		elsif my_repetition_length[:max]<=other_repetition_length[:max] &&  my_repetition_length[:min]>=other_repetition_length[:min] then
			return -1
		else
			return nil
		end #if
	end #if

end #compare_repetitions
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
def compare_anchors?(other)
	if self.to_s == other.to_s then
		return 0
	else
		Anchoring.new(self) <=> Anchoring.new(other)
	end #if
end #anchoring
def compare_sequence?(other)
	return nil if other.instance_of?(String)
	if self.length==1 || other.length==1 then
		comparison=self[0] <=> other[0]
		if self.length > other.length then
			return -1
		elsif self.length == other.length then
			return comparison
		else
			return 1
		end #if
	else
		comparison=self[0] <=> other[0]
		comparison1=self[1..-1] <=> other[1..-1]
		if comparison.nil? || comparison1.nil? then
			return nil # part incomparable
		else case [comparison, comparison1]
		when [0,0]
			0
		when [1,1], [0,1], [1,0]
			1
		when [-1,-1], [0,-1], [-1,0]
			-1
		when  [1,-1], [-1,1]
			nil
		else
			raise "bad case"
		end #case
		end #if
	end #if
end #sequence_comparison
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
# Takes embedded array format parsed tree and displays equivalent to_s string 
def postfix_expression?(branch=self)
	if branch.postfix_operator?(branch[-1]) then
		return branch[-1]
	else
		return nil #not postfix chars
	end #if
end #postfix_expression
def bracket_operator?(parseTree=self)
	if parseTree.kind_of?(Array) && parseTree[-1]=='}' then
		return parseTree 
	else
		return nil	
	end #if
end #bracket_operator
# returns node such as ['*'] or ["{", "3", ",", "4", "}"]
def postfix_operator?(parseTree=self)
	if parseTree.instance_of?(String) then
		RegexpTree.PostfixOperators.index(parseTree)	
	else
		bracket_operator?(parseTree)
	end #if
end #postfix_operator
def postfix_operator_walk(&visit_proc)
	# recurse on subtrees first so transformations ripple up generally
	# postfix expresion should not change operator
	branching=RegexpTree.new(self.map do |sub_tree|
		if sub_tree.kind_of?(Array) then
			RegexpTree.new(sub_tree).postfix_operator_walk(&visit_proc)
		else # leaf string
			sub_tree
		end #if
	end) #map and RegexpTree.new
#OK	raise "Unexpected #{self.inspect}.postfix_expression?=#{postfix_expression?} != #{branching.inspect}.postfix_expression?=#{RegexpTree.new(branching).postfix_expression?}"  unless postfix_expression? == RegexpTree.new(branching).postfix_expression?
	if postfix_expression? then #postfixes trickle up
		new_branching=visit_proc.call(branching)
			
	else
		new_branching=branching
	end
	new_branching
	
	return new_branching
end #postfix_operator_walk
def macro_call?(macro=self)
	return false if '[' != macro[0]
	return false if ']' != macro[-1]
	inner_colons=macro[1..-2] # not another nested array
	return false if ':' != inner_colons[0]
	return false if ':' != inner_colons[-1]
	return	inner_colons[1..-2].join
end #macro_call?
# file name glob (suitible for Dir[]) most like regexp.
# often matches more filenames than regexp (see pathnames)
def to_pathname_glob
	ret=map_branches{|b| (b[0]=='('?RegexpTree.new(b[1..-2]):RegexpTree.new(b))}
	ret=ret.postfix_operator_walk{|p| '*'}
	if ret.kind_of?(Array) then
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
# the useful inverse function of new. String to regexp
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
		raise "Unexpected regexp.class=#{regexp.class}."
	end #if
	return regexp
end #canonical_regexp_tree
def to_regexp(options=Default_options)
	regexp_string=to_s
	regexp=RegexpTree.regexp_rescued(regexp_string, options)

	return regexp
end #to_regexp
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_range='\000-\377'
Binary_bytes=(0..255).to_a.map { |i| i.chr}
#y caller
# 
# Returns a RegexpTree object
def repeated_pattern(node=self)
	if !node.kind_of?(Array) then # argument is not an Array
		return RegexpTree.new([node])
	elsif post_op=node.postfix_expression? then
		return RegexpTree.new([node[0]])
	elsif node[-1]=='}' then
		node[0]
	else
		node
	end #if
end #repeated_pattern
# returns pair of min and max repetitions of a RegexpTree
# max can be nil to signify unlimited repetitions
def repetition_length(node=self)
	if !node.kind_of?(Array) then
		if node=='' then
			return RepetitionLength.new(1, 1)
		elsif node=='*' then
			return RepetitionLength.new(0, nil)
		elsif node=='+' then
			return RepetitionLength.new(1, nil)
		elsif node=='?' then
			return RepetitionLength.new(0, 1)
		elsif node.length==1 then
			return RepetitionLength.new(1, 1)
		else
			raise "unexpected node=#{node}"
		end #if
	elsif post_op=node.postfix_expression? then
		if post_op=='*' then
			return RepetitionLength.new(0, nil)
		elsif post_op=='+' then
			return RepetitionLength.new(1, nil)
		elsif post_op=='?' then
			return RepetitionLength.new(0, 1)
		else
			raise "unexpected post_op=#{post_op}"
		end #if
	elsif node[-1]=='}' then
		RepetitionLength.new(node[1][0].to_i, node[1][1].to_i)
	else
		RepetitionLength.new(node.length, node.length)
	end #if
end #repetition_length
# recursive merging of consecutive identical pairs
def merge_to_repetition(branch=self)
	if branch.instance_of?(Array) then
		branch=RegexpTree.new(branch)
	end #if
	if branch.size<2 then # terminate recursion
		return branch
	else
# puts "branch=#{branch}"
		first=branch[0]
		second=branch[1]
		if branch.repeated_pattern(first)==branch.repeated_pattern(second) then
			first_repetition=first.repetition_length
			second_repetition=branch.repetition_length(second)
			merged_repetition=(first_repetition+second_repetition).concise_repetition_node
			merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1])
		else # couldn't merge first element
			[first]+merge_to_repetition(branch[1..-1])	# shorten string to ensure recursion termination
		end #if
	end #if
end #merge_to_repetition
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
end #RegexpTree

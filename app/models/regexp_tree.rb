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
#require 'app/models/nested_array.rb'
class RegexpTree < NestedArray
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
include Inline_Assertions
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
end #initialize
def <=>(other)
	if self==other then
		return 0
	else
	end #if
	return self.to_a==other.to_a # self.to_a==other.to_a &&self.tokenIndex==other.tokenIndex
end #<=>
def +(other)
	return RegexpTree.new(self.to_a+other.to_a)
end #+
def to_a
	return Array.new(self)
end #to_a

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
def to_regexp(options=Default_options)
	regexp_string=to_s
	regexp=RegexpTree.regexp_rescued(regexp_string, options)

	return regexp
end #to_regexp
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
#y caller
# 
# Returns a RegexpTree object
def repeated_pattern(node=self)
	if !node.kind_of?(Array) then # argument is not an Array
		return RegexpTree.new([node])
	elsif post_op=node.postfix_expression? then
		return [node[0]]
	elsif node[-1]=='}' then
		node[0]
	else
		node
	end #if
end #repeated_pattern
# returns pair of min and max repetitions of a RegexpTree
def repetition_length(node=self)
	if !node.kind_of?(Array) then
		if node=='' then
			return [0, 0]
		elsif node=='*' then
			return [0, nil]
		elsif node=='+' then
			return [1, nil]
		elsif node=='?' then
			return [0, 1]
		else
			[1,1]
		end #if
	elsif post_op=node.postfix_expression? then
		if post_op=='*' then
			return [0, nil]
		elsif post_op=='+' then
			return [1, nil]
		elsif post_op=='?' then
			return [0, 1]
		else
			[4,5]
		end #if
	elsif node[-1]=='}' then
		[node[1][0].to_i, node[1][1].to_i]
	else
		[node.length, node.length]
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
			first_repetition=branch.repetition_length(first)
			second_repetition=branch.repetition_length(second)
			merged_repetition=RegexpTree.concise_repetion_node(first_repetition[0]+second_repetition[0], first_repetition[1]+second_repetition[1])
			merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1])
		else # couldn't merge first element
			[first]+merge_to_repetition(branch[1..-1])	# shorten string to ensure recursion termination
		end #if
	end #if
end #merge_to_repetition
def self.canonical_repetion_tree(min, max)
	return RegexpTree.new(['{', [min.to_s, ',', max.to_s], '}'])
end #canonical_repetion_tree
def self.concise_repetion_node(min, max)
	if min==0 then
		if max==1 then
			return '?'
		elsif max.nil? then
			return '*'
		else
			return canonical_repetion_tree(min, max)
		end #if
	elsif min==1 then
		if max==1 then
			return ''
		elsif max.nil? then
			return '+'
		else
			return canonical_repetion_tree(min, max)
		end #if
	else
		return canonical_repetion_tree(min, max)
	end #if
	return RegexpTree.new(['{', [min.to_s, max.to_s], '}'])
end #concise_repetion_node
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
end #class

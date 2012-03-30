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
require 'app/models/nested_array.rb'
class RegexpTree < NestedArray
Default_options=Regexp::EXTENDED | Regexp::MULTILINE
end #RegexpTree
class RegexpTree < NestedArray # reopen
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
def [](index)
	if super(index).kind_of?(Array) then
		return RegexpTree.new(super(index))
	else
		return at(index)
	end #if
end #[]index
#def ==(other)
#	return self.to_a==other.to_a # self.to_a==other.to_a &&self.tokenIndex==other.tokenIndex
#end #==
def +(other)
	return RegexpTree.new(self.to_a+other.to_a)
end #+
def to_a
	return Array.new(self)
end #to_a

# Takes embedded array format parsed tree and displays equivalent to_s string 
def postfix_expression?
	if RegexpTree.postfix_operator?(self[-1]) then
		return true
	else
		return false #not postfix chars
	end #if
end #postfix_expression
def RegexpTree.postfix_operator?(parseTree)
	if parseTree.instance_of?(String) then
		RegexpTree.PostfixOperators.index(parseTree)	
	else
		return false
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
def self.macro_call?(parseTree)
	macro=parseTree #first and only in test case list
	return false if '[' != macro[0]
	return false if ']' != macro[-1]
	inner_brackets=macro[1..-2][0]
	return false if '[' != inner_brackets[0]
	return false if ']' != inner_brackets[-1]
	inner_colons=inner_brackets[1..-2] # not another nested array
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
def to_regexp(options=Default_options)
	regexp_string=to_s
	regexp=RegexpTree.regexp_rescued(regexp_string, options)

	return regexp
end #to_regexp
Ascii_characters=(0..127).to_a.map { |i| i.chr}
Binary_bytes=(0..255).to_a.map { |i| i.chr}
#y caller
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

###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets start embeddded arrays
require 'app/models/inlineAssertions.rb'
class RegexpParser
attr_reader :regexp_string,:tokenIndex,:parseTree
def initialize(regexp_string)
	raise "RegexpParser.new currently only handles String arguments. regexp_string=#{regexp_string.inspect}" unless regexp_string.kind_of?(String)
	@regexp_string=regexp_string
	restartParse!
	@parseTree=regexpTree!
end #initialize
def to_a
	return @parseTree
end #to_a
def to_s
	return to_a.join
end #to_s
def restartParse! # primarily for testing
	if @regexp_string.nil? then
		@tokenIndex=-1 # start at end
	else
		@tokenIndex=@regexp_string.length-1 # start at end
	end #if
	@parseTree=[]
end #def
def nextToken!
	if beyondString? then
		raise RuntimeError, "method nextToken! called after end of regexp_string."
	elsif @tokenIndex>1 && @regexp_string[@tokenIndex-1..@tokenIndex-1]=='\\' then
		ret='\\'+@regexp_string[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-2
	else
		ret=@regexp_string[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-1
	end
	return ret
end #nextToken!
def rest
	if beyondString? then
		return ''
	else
		return @regexp_string[0..@tokenIndex]
	end #if
end #rest
def advanceToken!(increment)
	@tokenIndex=@tokenIndex+increment
end #advanceToken!
# test if parsing has gone beyond end of string and should stop
def beyondString?(testPos=@tokenIndex)
	@regexp_string.nil? || testPos<0 || testPos>@regexp_string.length-1
end
# handle {2,3}-style specification of repetitions
# not currently used, since numbers are not interpreted
# currently handled identically to parenthesis and square brackets
def curlyTree!(regexp_string)
	remaining=rest
	matchData=/\{(\d*)(,(\d*))?\}/.match(remaining)
	increment=matchData[1].length+matchData[2].length+1
	advanceToken!(increment)
	return ['{',[matchData[1],matchData[2]],'}']
end #curlyTree
# parse matching brackets, postfix operator, or single character
def parseOneTerm!
	ch=nextToken!
	index=RegexpTree.ClosingBrackets.index(ch)
	if index then
		return  regexpTree!(RegexpTree.OpeningBrackets[index].chr) << ch
	else
		index=RegexpTree.PostfixOperators.index(ch)
		if index then
			return  [parseOneTerm!, ch]
		else
			return ch
		end #if
	end #if
end #parseOneTerm!
def regexpTree!(terminator=nil)
	ret=[]
	begin
		if !beyondString? then
			term=parseOneTerm!
			ret << term
		else
			return ret.reverse
		end #if
	end until term==terminator
#not recursive	conservationOfCharacters(ret.reverse)
	return ret.reverse
end #regexpTree!
# test 
def conservationOfCharacters
	message="Regexp parse error: regexp_string=#{@regexp_string},rest=#{rest},parseTree.inspect=#{parseTree.inspect}."
	raise message if @regexp_string!=(rest+@parseTree.to_s)
	puts "message=#{message}"
end #conservationOfCharacters

end #RegexpParser
require 'app/models/nested_array.rb'
class RegexpTree < NestedArray
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

# Parse regexp_string into parse tree for editing
def initialize(initial_value=[])
	if initial_value.kind_of?(Array) then #nested Arrays
		super(initial_value)
		
	elsif initial_value.instance_of?(String) then 
		super(RegexpParser.new(initial_value).to_a)
	elsif initial_value.instance_of?(RegexpParser) then 
		super(initial_value.to_a)
	else
		raise "unexpected initial_value=#{initial_value.inspect}"
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
	if branching.postfix_expression? then #postfixes trickle up
		new_branching=visit_proc.call(branching)
			
	else
		new_branching=branching
	end
	new_branching
	
	return new_branching
end #postfix_operator_walk
def to_filename_glob
	ret=postfix_operator_walk{|p| '*'}
	if ret.kind_of?(Array) then
		ret=ret.flatten.join
	end #if
	return ret
end #to_filename_glob
def to_s
	to_a.join
end #to_s
# the useful inverse function of new. String to regexp
def to_regexp
	ret=to_s
	ret=Regexp.new(ret)
	return ret
end #to_regexp
# not used
end #class

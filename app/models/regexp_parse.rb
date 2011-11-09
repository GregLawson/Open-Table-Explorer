###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets are stat embeddded arrays
require 'app/models/inlineAssertions.rb'
class RegexpParse
attr_reader :regexp,:tokenIndex,:parseTree
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

def restartParse! # primarily for testing
	@tokenIndex=@regexp.length-1 # start at end
	@parseTree=[]
end #def
# Parse regexp into parse tree for editing
def initialize(regexp=nil,preParse=true)
	@regexp=regexp.to_s #string, canonical by new?
	if !regexp.nil? then
		restartParse!
		@parseTree=regexpTree! if preParse
	end #if
end #initialize
# Takes embedded array format parsed tree and displays equivalent regexp string 
def RegexpParse.to_s(parseTree)
	if parseTree.nil? then
		return ''
	elsif parseTree.length==2 && parseTree[0].instance_of?(String) && RegexpParse.PostfixOperators.index(parseTree[0]) then
		puts "parseTree.inspect=#{parseTree.inspect}"
		puts "parseTree[1..1].inspect=#{parseTree[1..1].inspect}"
		puts "parseTree[0..0].inspect=#{parseTree[0..0].inspect}"
		puts "to_s(parseTree[1..1]).inspect=#{to_s(parseTree[1..1]).inspect}"
		puts "to_s(parseTree[1..1])+parseTree[0]=#{to_s(parseTree[1..1])+parseTree[0]}"
		return to_s(parseTree[1..1])+parseTree[0]
	elsif parseTree.instance_of?(Array) then
		return parseTree.collect do |pt| 
			if pt.instance_of?(Array) then
				to_s(pt)
			else
				pt
			end
		end.join('')
	else
		return parseTree
	end
end #to_s
def to_s
	return RegexpParse.to_s(@parseTree)
end #to_s
# the useful inverse function of new. String to regexp
def to_regexp
	ret=to_s
	ret=Regexp.new(ret)
	return ret
end #to_regexp
def nextToken!
	if beyondString? then
		raise RuntimeError, "method nextToken! called after end of regexp."
	elsif @tokenIndex>1 && @regexp[@tokenIndex-1..@tokenIndex-1]=='\\' then
		ret='\\'+@regexp[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-2
	else
		ret=@regexp[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-1
	end
	return ret
end #nextToken!
def rest
	if beyondString? then
		return ''
	else
		return @regexp[0..@tokenIndex]
	end #if
end #rest
def advanceToken!(increment)
	@tokenIndex=@tokenIndex+increment
end #def
# test if parsing has gone beyond end of string and should stop
def beyondString?(testPos=@tokenIndex)
	testPos<0 || testPos>@regexp.length-1
end
# handle {2,3}-style specification of repetitions
# not currently used, since numbers are not interpreted
# currently handled identically to parenthesis and square brackets
def curlyTree!(regexp)
	remaining=rest
	matchData=/\{(\d*)(,(\d*))?\}/.match(remaining)
	increment=matchData[1].length+matchData[2].length+1
	advanceToken!(increment)
	return ['{',[matchData[1],matchData[2]],'}']
end #curlyTree
# parse matching brackets, postfix operator, or single character
def parseOneTerm!
	ch=nextToken!
	index=self.class.ClosingBrackets.index(ch)
	if index then
		return  regexpTree!(self.class.OpeningBrackets[index].chr) << ch
	else
		index=self.class.PostfixOperators.index(ch)
		if index then
			return  [ch,parseOneTerm!]
		else
			return ch
		end #if
	end #if
end #parseOneTerm!
def regexpTree!(terminator=nil)
	ret=[]
	begin
		term=parseOneTerm!
		ret << term
	end until beyondString? || term==terminator
#not recursive	conservationOfCharacters(ret.reverse)
	return ret.reverse
end #regexpTree!
def conservationOfCharacters(parseTree)
	message="Regexp parse error: regexp=#{@regexp},rest=#{rest},parseTree.inspect=#{parseTree.inspect}."
	assert_equal(@regexp,rest+RegexpParse.to_s(parseTree),message)
	puts "message=#{message}"
end #def
# not used
def removeParens!(regexp)
	regexp.gsub(/([^\\])([)()])/,'\1')
end #def
end #class

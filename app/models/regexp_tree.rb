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
class RegexpTree
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
	if regexp.instance_of?(Array) then
		@regexp=regexp.to_s #nested Arrays
		restartParse!
		@parseTree=regexp
		
	else
		@regexp=regexp.to_s #string
		if !regexp.nil? then
			restartParse!
			@parseTree=regexpTree! if preParse
		end #if
	end #if
end #initialize
def [](index)
	return RegexpTree.new(@parseTree[index])
end #[]index
def ==(other)
	return self.parseTree==other.parseTree # self.regexp==other.regexp &&self.tokenIndex==other.tokenIndex
end #==
def +(other)
	return RegexpTree.new(self.parseTree+other.parseTree)
end #+
# Takes embedded array format parsed tree and displays equivalent regexp string 
def postfix_operator?
	if @parseTree.nil? then
		return false
	else
		return @parseTree.length==2 && @parseTree[0].instance_of?(String) && RegexpTree.PostfixOperators.index(@parseTree[0])	
	end #if
end #postfix_operator
def to_s
	if @parseTree.nil? then
		return ''
	elsif postfix_operator? then
#		puts "@parseTree.inspect=#{@parseTree.inspect}"
#		puts "@parseTree[1..1].inspect=#{@parseTree[1..1].inspect}"
#		puts "@parseTree[0..0].inspect=#{@parseTree[0..0].inspect}"
#		puts "@parseTree[1..1].inspect=#{@parseTree[1..1].inspect}"
#		puts "to_s(@parseTree[1..1])+@parseTree[0]=#{to_s(@parseTree[1..1])+@parseTree[0]}"
		return RegexpTree.new(@parseTree[1..-1]).to_s+@parseTree[0]
	elsif @parseTree.instance_of?(Array) then
		return @parseTree.collect do |pt| 
			if pt.instance_of?(Array) then
				RegexpTree.new(pt).to_s
			else
				pt
			end
		end.join('')
	else
		return @parseTree
	end
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
		if !beyondString? then
			term=parseOneTerm!
			ret << term
		else
			return ret
		end #if
	end until term==terminator
#not recursive	conservationOfCharacters(ret.reverse)
	return ret.reverse
end #regexpTree!
# test 
def conservationOfCharacters
	message="Regexp parse error: regexp=#{@regexp},rest=#{rest},parseTree.inspect=#{parseTree.inspect}."
	assert_equal(@regexp,(RegexpTree.new(rest)+RegexpTree.new(@parseTree)).to_s,message)
	puts "message=#{message}"
end #conservationOfCharacters
# not used
def removeParens!(regexp)
	regexp.gsub(/([^\\])([)()])/,'\1')
end #def
end #class

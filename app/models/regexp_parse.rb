###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/inlineAssertions.rb'
class RegexpParse
attr_reader :regexp,:tokenIndex,:parseTree
include Inline_Assertions
def self.OpeningBrackets
	return '({['
end #def
def self.ClosingBrackets
	return ')}]'
end #def
def self.PostfixOperators
	return '+*?|'
end #def

def restartParse # primarily for testing
	@tokenIndex=@regexp.length-1
	@parseTree=[]
end #def
# Parse regexp into 
def initialize(regexp=nil,preParse=true)
	@regexp=regexp
	if !regexp.nil? then
		restartParse
		@parseTree=regexpTree if preParse
		puts "@parseTree.inspect=#{@parseTree.inspect}" if regexp.size>5
	end #if
end #initialize
# Takes embedded array format parsed tree and displays equivalent regexp string 
def parsedString(parseTree=@parseTree)
	if parseTree.nil? then
		return ''
	elsif parseTree.length==2 && parseTree[0].instance_of?(String) && self.class.PostfixOperators.index(parseTree[0]) then
		puts "parseTree.inspect=#{parseTree.inspect}"
		puts "parseTree[1..1].inspect=#{parseTree[1..1].inspect}"
		puts "parseTree[0..0].inspect=#{parseTree[0..0].inspect}"
		puts "parsedString(parseTree[1..1]).inspect=#{parsedString(parseTree[1..1]).inspect}"
		puts "parsedString(parseTree[1..1])+parseTree[0]=#{parsedString(parseTree[1..1])+parseTree[0]}"
		return parsedString(parseTree[1..1])+parseTree[0]
	else
		return parseTree.collect do |pt| 
			if pt.instance_of?(Array) then
				parsedString(pt)
			else
				pt
			end
		end.join('')
	end
end #parsedString

def nextToken
	if beyondString? then
		raise RuntimeError, "method nextToken called after end of regexp."
	elsif @tokenIndex>1 && @regexp[@tokenIndex-1..@tokenIndex-1]=='\\' then
		ret='\\'+@regexp[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-2
	else
		ret=@regexp[@tokenIndex..@tokenIndex]
		@tokenIndex=@tokenIndex-1
	end
	return ret
end #def
def rest
	if beyondString? then
		return ''
	else
		return @regexp[0..@tokenIndex]
	end #if
end #def
def advanceToken(increment)
	@tokenIndex=@tokenIndex+increment
end #def
def beyondString?(testPos=@tokenIndex)
	testPos<0 || testPos>@regexp.length-1
end
def curlyTree(regexp)
	remaining=rest
	matchData=/(\d*)(,(\d*))?\}/.match(regexp)
	increment=matchData[1].length+matchData[2].length+1
	advanceToken(increment)
	return ['{',[matchData[1],matchData[2]],'}']
end #def
def parseOneTerm
	ch=nextToken
	index=self.class.ClosingBrackets.index(ch)
	if index then
		return  regexpTree(self.class.OpeningBrackets[index].chr) << ch
	else
		index=self.class.PostfixOperators.index(ch)
		if index then
			return  [ch,parseOneTerm]
		else
			return ch
		end #if
	end #if
end #def
def regexpTree(terminator=nil)
	ret=[]
	begin
		term=parseOneTerm
		ret << term
	end until beyondString? || term==terminator
#not recursive	conservationOfCharacters(ret.reverse)
	return ret.reverse
end
def conservationOfCharacters(parseTree)
	message="Regexp parse error: regexp=#{@regexp},rest=#{rest},parseTree.inspect=#{parseTree.inspect}."
	assert_equal(@regexp,rest+parsedString(parseTree),message)
	puts "message=#{message}"
end #def
def removeParens(regexp)
	regexp.gsub(/([^\\])([)()])/,'\1')
end #def
end #class

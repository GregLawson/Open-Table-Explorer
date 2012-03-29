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
class RegexpParser
attr_reader :regexp_string,:tokenIndex,:parseTree
def initialize(regexp_string)
	raise "RegexpParser.new currently only handles String arguments. regexp_string=#{regexp_string.inspect}" unless regexp_string.kind_of?(String)
	@regexp_string=regexp_string
	restartParse!
	@parseTree=regexpTree!
	@parseTree=@parseTree.map_branches do |branch|
		if branch.size==1 && branch[0].kind_of?(Array) then
			NestedArray.new(branch[0]) # remove redundant brankets
		else
			NestedArray.new(branch)
		end #if
	end #map_branches
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
	@parseTree=NestedArray.new([])
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
			return  NestedArray.new([parseOneTerm!, ch])
		else
			return ch
		end #if
	end #if
end #parseOneTerm!
def regexpTree!(terminator=nil)
	ret=NestedArray.new([])
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
end #conservationOfCharacters

end #RegexpParser

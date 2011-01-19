###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'regexp_Parse.rb'
module Squeeze_Display
@@Max_Context=100
@@Max_Lines=5
def maxedDisplay(str,maxLength=@@Max_Context)
	if str.length>maxLength then
		return str[0,maxLength]+' ...'
	else
		return str
	end #if	
end #def
def squeezeDisplay(str)
	if str.nil? then
		return 'nil'
	elsif str.empty? then
		return ''
	elsif str.length<2*@@Max_Context then
		return str
	else
		return 'Starts with:'+str[0,@@Max_Context]+'\nand ends with: ... '+str[-@@Max_Context,str.length]
	end
end #def
def matchDisplay(regexp)
	matchData=matchRescued(regexp)
#	assert_instance_of(matchData,MatchData)
	if matchData.nil? then
		Global::log.info("For /#{regexp}/ no matches.")
	else
		Global::log.info("regexp=/#{regexp}/ has #{matchData.size} matches.")
		for i in 0..matchData.size-1
			Global::log.info("matchData[#{i}]=#{squeezeDisplay(matchData[i]).inspect}")
		end
	end
end #def
end #module
module Match_Addressng
def matchRescued(regexp)
	begin
		matchData=Regexp.new(regexp,Regexp::MULTILINE).match(@dataToParse)
	rescue RegexpError
		Global::log.info("bad  regexp=#{regexp}")
		return nil
	end
end
def numMatches(parseTree)
	matchData=Regexp.new(parseTree[0,i],Regexp::MULTILINE).match(@dataToParse)
	if matchData.nil? then 
		return 0
	else
		return matchData.size
	end #if
end #def
end #module
class Regexp_Edit < Regexp_Parse
attr_reader :dataToParse
include Squeeze_Display
include Match_Addressng
def initialize(regexp,dataToParse,preParse=true)
	super(regexp,preParse)
	@dataToParse=dataToParse
end #def
def matchSubTree(parseTree=@parseTree)
	if parseTree.nil? then
		return ''
	elsif matchRescued(parsedString(parseTree)) then
		return parseTree
	elsif parseTree.instance_of?(Array) then 
		matchedTreeArray(parseTree)
	else
		return nil
	end #if
end #def
def mergeMatches(parseTree,matches)
	if matches.size==0 then
		return nil
	elsif matches.size==1 then
		return parseTree[matches[0]]
	elsif matches[0].end>matches[1].begin then #overlap
		prefix=matches[0].begin..matches[1].begin-1
		suffix=matches[0].end+1..matches[1].end
		overlap= matches[1].begin..matches[0].end
		return [parseTree[prefix],['|',parseTree[overlap]],parseTree[suffix],mergeMatches(parseTree,matches[1..-1])]
	else #gap
		merged=parseTree[matches[0]]+mergeMatches(parseTree,matches[1..-1])
		if matchRescued(parsedString(merged))then
			return merged
		else
			return [parseTree[matches[0]],['*','.'],mergeMatches(parseTree,matches[1..-1])]
		end
	end #end	
end #def
def matchedTreeArray(parseTree=@parseTree)
	Global::log.info("parsing matchedTreeArray #{parseTree.inspect}")
	if @@PostfixOperators.index(parseTree[0]) then
		Global::log.info("parseTree.inspect=#{parseTree.inspect}")
		Global::log.info("parseTree[1..1].inspect=#{parseTree[1..1].inspect}")
		Global::log.info("parseTree[0..0].inspect=#{parseTree[0..0].inspect}")
		Global::log.info("parsedString(parseTree[1..1]).inspect=#{parsedString(parseTree[1..1]).inspect}")
		Global::log.info("parsedString(parseTree[1..1])+parseTree[0]=#{parsedString(parseTree[1..1])+parseTree[0]}")
		return parsedString(parseTree[1..1])+parseTree[0]
	else
		matches= consecutiveMatches(parseTree,+1,0,0)
		if matches.size==0 then
			return nil
		elsif matches.size==1 then
			return parseTree[matches[0]]
		else
			return mergeMatches(parseTree,matches)
		end
	end
end #def

def consecutiveMatches(parseTree,increment,startPos,endPos)
	Global::log.info("consecutiveMatches begins with parseTree=#{parseTree},increment=#{increment},startPos=#{startPos},endPos=#{endPos}")
#	assert(startPos<=endPos)
	ret=[] # nothing found yet
	begin
		matchRange=consecutiveMatch(parseTree,increment,startPos,endPos)
		if matchRange then
			startPos=endPos=matchRange.end+1
			ret << matchRange
		else
			startPos=endPos=endPos+1
		end
		increment=increment*-1 #reverse scan
#	assert(startPos<=endPos)
	end until startPos<0 || endPos>=parseTree.size
	Global::log.info("ret=#{ret.inspect}")# if $DEBUG
	if ret==[] then
		return nil
	else
		return ret
	end #if
end #def
def consecutiveMatch(parseTree,increment,startPos,endPos)
	Global::log.info("consecutiveMatch begins with parseTree.inspect=#{parseTree.inspect},increment=#{increment},startPos=#{startPos},endPos=#{endPos}")
#	assert(startPos<=endPos)
	ret=[] # nothing found yet
	begin
		matchData=matchRescued(parsedString(parseTree[startPos..endPos]))
		matchDisplay(parsedString(parseTree[startPos..endPos])) #if $VERBOSE
		if matchData then
			Global::log.info("matchData startPos=#{startPos}, endPos=#{endPos}")
			lastMatch=(startPos..endPos) # best so far
			if increment>0 then
				endPos=endPos+increment
			else
				startPos=startPos+increment
			end
		else
			Global::log.info("not matched. ret=#{ret.inspect}, matchData.inspect=#{matchData.inspect}")
			return lastMatch
		end
#	assert(startPos<=endPos)
	end until startPos<0 || endPos>=parseTree.size
	Global::log.info("end loop. ret=#{ret.inspect}, matchData.inspect=#{matchData.inspect}")
	Global::log.info("startPos=#{startPos}")# if $DEBUG
	Global::log.info("endPos=#{endPos}") #if $DEBUG
	if lastMatch.nil? then
		return nil
	else
		return lastMatch
	end #if
end #def


end #class
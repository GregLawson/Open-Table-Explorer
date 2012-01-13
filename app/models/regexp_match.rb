###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# There is a rails method that does this; forgot name
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
		# Global::log.info("For /#{regexp}/ no matches.")
	else
		# Global::log.info("regexp=/#{regexp}/ has #{matchData.size} matches.")
		for i in 0..matchData.size-1
			# Global::log.info("matchData[#{i}]=#{squeezeDisplay(matchData[i]).inspect}")
		end
	end
end #def
end #module
module Match_Addressing
# Rescue bad regexp and return nil
def matchRescued(regexp)
	begin
		matchData=Regexp.new(regexp.to_s,Regexp::MULTILINE).match(@dataToParse)
	rescue RegexpError
		# Global::log.info("bad  regexp=#{regexp}")
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
# For a fixed string compute parse tree or sub trees that match
class RegexpMatch < RegexpTree
attr_reader :dataToParse
include Squeeze_Display
include Match_Addressing
def initialize(regexp,dataToParse)
	super(regexp)
	@dataToParse=dataToParse
end #initialize
def RegexpMatch.explain_assert_match(regexp, string, message=nil)
	message="regexp=#{regexp}, string='#{string}'"
	match_data=regexp.match(string)
	if match_data.nil? then
		regexp_tree=RegexpMatch.new(regexp, string)
		message=message+"regexp_tree.matchSubTree=#{regexp_tree.matchSubTree.inspect}"
	end #if
	assert_match(regexp, string, message)
end #assert_match
def RegexpMatch.assert_match_array(regexp, string, message=nil)
	 string.instance_of?(Enumeration)
end #
# Top level incremental match of regexp tree to data
# parseTree - array of parsed tree to test for match
# calls matchRescued, matchedTreeArray depending
def matchSubTree
	if empty? then
		return ''
	elsif matchRescued(to_regexp) then
		return self
	elsif kind_of?(Array) then 
		matchedTreeArray
	else
		return nil
	end #if
end #matchSubTree
# Combines match alternatives?
# returns a parse tree that should match
# parseTree - array of parsed tree to test for match
def mergeMatches(matches)
	if matches.size==0 then
		return nil
	elsif matches.size==1 then
		return self[matches[0]]
	elsif matches[0].end>=matches[1].begin then #overlap
		prefix=matches[0].begin..matches[1].begin-1
		suffix=matches[0].end+1..matches[1].end
		overlap= matches[1].begin..matches[0].end
		return [self[prefix],['|',self[overlap]],self[suffix],mergeMatches(matches[1..-1])]
	elsif matches.size==2 then # no overlap w/2 matches
		return self[matches[0]]+[['.','*']]+self[matches[1]]
	else # no overlap w/ 3 or more matches
		 return self[matches[0]]+[['.','*']]+mergeMatches(self,matches[1..-1]) # recursive for >2 matches
	end #end	

end #mergeMatches
# accounts for arrays (subtrees) in parse tree
# calls consecutiveMatches, mergeMatches
# self - array of parsed tree to test for match
def matchedTreeArray
	if self.class.PostfixOperators.index(self[0]) then
		# Global::log.info("self.inspect=#{self.inspect}")
		# Global::log.info("self[1..1].inspect=#{self[1..1].inspect}")
		# Global::log.info("self[0..0].inspect=#{self[0..0].inspect}")
		return (self[1..1]+self[0]).to_s
	else
		matches= consecutiveMatches(+1,0,0)
		if matches.size==0 then
			return nil
		elsif matches.size==1 then
			return self[matches[0]]
		else
			return mergeMatches(matches)
		end
	end
end #matchedTreeArray
# Searches for all subregexp that matches
# calls consecutiveMatch
# increment - usually +1 or -1 to deterine direction and start/end
# startPos - array index into parsedTree to start (inclusive)
# endPos - array index into parsedTree to end (inclusive)
def consecutiveMatches(increment,startPos,endPos)
	# Global::log.info("consecutiveMatches begins with self=#{self},increment=#{increment},startPos=#{startPos},endPos=#{endPos}")
#	assert(startPos<=endPos)
	ret=[] # nothing found yet
	begin
		matchRange=consecutiveMatch(increment,startPos,endPos)
		if matchRange then
			startPos=endPos=matchRange.end+1
			ret << matchRange
		else
			startPos=endPos=endPos+1
		end #if
		increment=increment*-1 #reverse scan
#	assert(startPos<=endPos)
	end until startPos<0 || endPos>=self.size
	# Global::log.info("ret=#{ret.inspect}")# if $DEBUG
	if ret==[] then
		return nil
	else
		return ret
	end #if
end #consecutiveMatches
# Find one consecutive match
# returns lastMatch (matching range in parseTree) or nil (no match)
# calls matchRescued, matchDisplay
# parseTree - array of parsed tree to test for match
# increment - usually +1 or -1 to deterine direction and start/end
# startPos - array index into parsedTree to start (inclusive)
# endPos - array index into parsedTree to end (inclusive)
def consecutiveMatch(increment,startPos,endPos)
#	# Global::log.info("consecutiveMatch begins with self.inspect=#{self.inspect},increment=#{increment},startPos=#{startPos},endPos=#{endPos}")
#	assert(startPos<=endPos)
	begin # until
		matchData=matchRescued(self[startPos..endPos])
#		matchDisplay(self[startPos..endPos]to_s) #if $VERBOSE
		if matchData then
			# Global::log.info("matchData startPos=#{startPos}, endPos=#{endPos}")
			lastMatch=(startPos..endPos) # best so far
			if increment>0 then
				endPos=endPos+increment
			else
				startPos=startPos+increment
			end
		else
			return lastMatch
		end
#	assert(startPos<=endPos)
	end until startPos<0 || endPos>=self.size
	# Global::log.info("startPos=#{startPos}")# if $DEBUG
	# Global::log.info("endPos=#{endPos}") #if $DEBUG
	if lastMatch.nil? then
		return nil
	else
		return lastMatch
	end #if
end #consecutiveMatch


end #class
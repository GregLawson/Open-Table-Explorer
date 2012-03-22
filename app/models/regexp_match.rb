###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class String
def to_exact_regexp
	return Regexp.new(Regexp.escape(self))
end #to_exact_regexp
end #String
# Class methods
module Match_Addressing
# Rescue bad regexp and return nil
def matchRescued(regexp, string_to_match)
	if regexp.instance_of?(String) then
		regexp=regexp_rescued(regexp)
	elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch) then
		regexp=regexp_rescued(regexp.to_s)
	elsif !regexp.instance_of?(Regexp) then
		raise "Unexpected regexp.class=#{regexp.class}."
	end #if
	raise "string_to_match=#{string_to_match.inspect} must be String." unless string_to_match.instance_of?(String)
	if regexp.nil? then
		return false
	else
		raise "regexp=#{regexp.inspect} must be Regexp." unless regexp.instance_of?(Regexp)
		begin
			matchData=regexp.match(string_to_match)
		rescue RegexpError
			raise "is this ever executed? regexp=#{regexp.inspect}, string_to_match=#{string_to_match.inspect}"
			return nil
		end #begin/rescue
	end #if
end
# Rescue bad regexp and return nil
# Example regexp with unbalanced bracketing characters
def regexp_rescued(regexp_string, options=Regexp::EXTENDED | Regexp::MULTILINE)
	return Regexp.new(regexp_string, options)
rescue RegexpError
	return nil
end #regexp_rescued
end #module
# For a fixed string compute parse tree or sub trees that match
class RegexpMatch < RegexpTree
attr_reader :dataToParse
extend Match_Addressing
def initialize(regexp,dataToParse)
	super(regexp)
	@dataToParse=dataToParse
end #initialize
# Top level incremental match of regexp tree to data
# self - array of parsed tree to test for match
# calls matchRescued, matchedTreeArray depending
def matchSubTree
	if empty? then
		return ['.','*']
	elsif RegexpMatch.matchRescued(to_regexp, @dataToParse) then
		return self
	elsif kind_of?(Array) then 
		matchedTreeArray
	else
		raise "How did I get here?"
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
		puts "matches=#{matches.inspect}"
		 return self[matches[0]]+[['.','*']]+mergeMatches(matches[1..-1]) # recursive for >2 matches
	end #end	

end #mergeMatches
# accounts for arrays (subtrees) in parse tree
# returns regexp string that should match
# calls consecutiveMatches to find matches
# calls mergeMatches to reduce multiple matches to one regexp string
def matchedTreeArray
	if self.class.PostfixOperators.index(self[0]) then
		return (self[1..1]+self[0]).to_s
	else
		matches= consecutiveMatches(+1,0,0)
		if matches.nil? || matches.empty? then
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
# returns when incremented from startPos/endPos past endPos/startPos
def consecutiveMatch(increment,startPos,endPos)
#	# Global::log.info("consecutiveMatch begins with self.inspect=#{self.inspect},increment=#{increment},startPos=#{startPos},endPos=#{endPos}")
#	assert(startPos<=endPos)
	begin # until
		matchData=RegexpMatch.matchRescued(self[startPos..endPos], @dataToParse)
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
def self.string_of_matching_chars(regexp)
	Ascii_characters.select do |char|
		if RegexpMatch.matchRescued(regexp, char) then
			char
		else
			nil
		end #if
	end #select
	
end #string_of_matching_chars
end #class
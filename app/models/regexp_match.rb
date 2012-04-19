###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# Class methods
# For a fixed string compute parse tree or sub trees that match
class RegexpMatch < RegexpTree #file context
attr_reader :dataToParse, :matched_data
def initialize(regexp,dataToParse)
	super(regexp)
	@dataToParse=dataToParse
	@match_data=self.to_regexp.match(@dataToParse)
end #initialize
# Rescue bad regexp and return nil
def RegexpMatch.match_data?(regexp, string_to_match=@dataToParse)
	regexp=canonical_regexp(regexp)
	raise "string_to_match='#{string_to_match.inspect}' of class #{string_to_match.class.name} must be String." unless string_to_match.instance_of?(String)
	if regexp.nil? then
		return false
	else
		raise "regexp=#{regexp.inspect} must be Regexp." unless regexp.instance_of?(Regexp)
		begin
			regexp.match(string_to_match)
		rescue RegexpError
			raise "is this ever executed? regexp=#{regexp.inspect}, string_to_match=#{string_to_match.inspect}"
			return nil
		end #begin/rescue
	end #if
end #match_data?
# return superclass instance converted to RegexpMatch
# Used by [] and other methods shared with superclasses
def promote(value)
	return RegexpMatch.new(value, @dataToParse)
end #promote
# Top level incremental match of regexp tree to data
# self - array of parsed tree to test for match
# calls match_data?, matchedTreeArray depending
def matchSubTree
	if empty? then
		return ['.','*']
	elsif RegexpMatch.match_data?(to_regexp, @dataToParse) then
		return self
	elsif kind_of?(Array) then 
		matchedTreeArray
	else
		raise "How did I get here?"
		return nil
	end #if
end #matchSubTree
# Combines match alternatives?
# returns a RegexpMatch parse tree that should match
# matches - array of Range matches
def mergeMatches(matches)
	if matches.size==0 then
		return RegexpMatch.new(['.', '*'], dataToParse)
	elsif matches.size==1 then
		return RegexpMatch.new(self[matches[0]], dataToParse)
	elsif matches[0].end>=matches[1].begin then #overlap
		prefix=matches[0].begin..matches[1].begin-1
		suffix=matches[0].end+1..matches[1].end
		overlap= matches[1].begin..matches[0].end
		return RegexpMatch.new([self[prefix],[self[overlap], '|'],self[suffix],mergeMatches(matches[1..-1])], dataToParse)
	elsif matches.size==2 then # no overlap w/2 matches
		return self[matches[0]]+[['.','*']]+self[matches[1]]
	else # no overlap w/ 3 or more matches
		puts "matches=#{matches.inspect}"
		 return self[matches[0]]+[['.','*']]+mergeMatches(matches[1..-1]) # recursive for >2 matches
	end #end	

end #mergeMatches
# accounts for arrays (subtrees) in parse tree
# returns RegexpMatch that should match
# calls consecutiveMatches to find matches
# calls mergeMatches to reduce multiple matches to one regexp string
def matchedTreeArray
	if self.class.PostfixOperators.index(self[0]) then
		return self.to_s
	else
		matches= consecutiveMatches(+1,0,0)
		if matches.nil? || matches.empty? then
			return ['.', '*']
		elsif matches.size==1 then
			return self[matches[0]]
		else
			return mergeMatches(matches)
		end #if
	end #if
end #matchedTreeArray
# Generalize RegexpTree branch so that it matches dataToMatch
# with as fewer generalizations as possible.
def generalize(branch=self, data_to_match=@dataToParse)
	if branch.kind_of?(Array) then
		branches=branch.map do |sub_tree| # look at each character
			map_matches(sub_tree, data_to_match)
			# should shorten data_to_match!
		end #map
		return 	RegexpMatch.new([branches, concise_repetion_node(branch.repetition_length[0], data_to_match.size)], data_to_match)
	else # not Array, probably single character Strings
		most_specialized=[GenericType.find_by_name('ascii')]
			data_to_match.each_char do |c|
				ret=most_specialized.each do |m|
					most_specialized=m.most_specialized?(c)
				end #
			end #each_char
		return 	RegexpMatch.new(['[[:print:]]', concise_repetion_node(branch.repetition_length[0], data_to_match.size)], data_to_match)
	end #if
end #generalize
def inspect
	if @match_data then
		"RegexpMatch: #{self.to_regexp} matches '#{@dataToParse}'."
	else
		if self[0].kind_of?(RegexpMatch) then
			map do |match| 
				if kind_of?(RegexpMatch) then
					match.inspect+"\n"
				else
					match
				end #if
			end #map
		else
			"RegexpMatch: #{self.to_regexp} does not match '#{@dataToParse}'."
		end #if
	end #if
end #inspect
		end #if
	else
	end #if
# Rescues bad regexps, returns {:regexp => nil}
def match_branch(branch=self, data_to_match=@dataToParse)
	if branch.instance_of?(String) then
		regexp=branch.to_exact_regexp
	else
		regexp=branch.to_regexp
	end #if
	@match_data=regexp.match(data_to_match)
	if @match_data then
		ret=RegexpMatch.new(branch, @match_data[0])
	else #no match
		ret=RegexpMatch.new(branch, data_to_match)
	end #if
#	ret={:regexp => regexp, :data_to_match => data_to_match}
#	if match_data.nil? then
#		ret[:matched_data]= nil

#	else
#		ret[:matched_data]= match_data
#		data_to_match=match_data.post_match
#	end #if
	ret
end #match_branch
def map_consecutiveMatches(matches, data_to_match=@dataToParse)
	matched_regexp=matches.map do |m|
		regexp=self[m].to_regexp
		matchData=regexp.match(data_to_match)
		ret={:regexp => regexp, :data_to_match => data_to_match}
		if matchData.nil? then
			ret[:matched_data]= nil
		else
			ret[:matched_data]= matchData[0]
			data_to_match=matchData.post_match
		end #if
		ret
	end #map
end #map_consecutiveMatches

# Searches for all subregexp that matches
# returns Array of Ranges of those subregexps ([] if no matches)
# calls consecutiveMatch
# increment - usually +1 or -1 to deterine direction and start/end
# startPos - array index into parsedTree to start (inclusive)
# endPos - array index into parsedTree to end (inclusive)
def consecutiveMatches(increment,startPos,endPos)
#	assert(startPos<=endPos)
	ret=[] # nothing found yet
	begin
		matchRange=consecutiveMatch(increment,startPos,endPos)
		if matchRange then
			startPos=endPos=matchRange.end+1
			ret << matchRange
		else #nil = no match
			startPos=endPos=endPos+1 
		end #if
		increment=increment*-1 #reverse scan. even/odd scans in different directions
# 		can a backward scan ever find a match?
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	end until startPos<0 || endPos>=self.size
	return ret
end #consecutiveMatches
# Find one consecutive match
# returns lastMatch (matching range in parseTree) or nil (no match)
# calls match_data?, matchDisplay
# parseTree - array of parsed tree to test for match
# increment - usually +1 or -1 to deterine direction and start/end
# startPos - array index into parsedTree to start (inclusive)
# endPos - array index into parsedTree to end (inclusive)
# returns when incremented from startPos/endPos past endPos/startPos
def consecutiveMatch(increment=+1,startPos=0,endPos=self.size)
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	begin # until
		matchData=RegexpMatch.match_data?(self[startPos..endPos], @dataToParse)
		if matchData then
			lastMatch=(startPos..endPos) # best so far
			if increment>0 then
				endPos=endPos+increment
			else
				startPos=startPos+increment
			end
		else
			if !lastMatch.nil? then
				raise "startPos=#{startPos}>endPos=#{endPos}" if lastMatch.begin<startPos || lastMatch.end>endPos
			end #if
			return lastMatch
		end
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	end until startPos<0 || endPos>=self.size
	if lastMatch.nil? then
		return nil
	else
		return lastMatch
	end #if
end #consecutiveMatch
end #RegexpMatch
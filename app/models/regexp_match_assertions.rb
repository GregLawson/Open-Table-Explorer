###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
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
module RegexpMatchAssertions
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'
include Squeeze_Display
include Match_Addressing
def assert_regexp_match(regexp_match=self)
	assert_respond_to(regexp_match,:consecutiveMatches)
	assert_not_nil(regexp_match.consecutiveMatches(+1,0,0))
	assert(regexp_match.consecutiveMatches(+1,0,0).size>0)
	assert_respond_to(regexp_match,:matchedTreeArray)
	assert_not_nil(regexp_match.matchedTreeArray)
	assert_operator(regexp_match.matchedTreeArray.size,:>,0)
	assert_respond_to(regexp_match,:matchedTreeArray)
	assert_not_nil(regexp_match.matchSubTree)
	assert_operator(regexp_match.matchSubTree.size,:>,0)
end #def
module ClassMethods
def RegexpMatch.explain_assert_match(regexp, string, message=nil)
	message="regexp=#{regexp}, string='#{string}'"
	assert_not_nil(regexp, message)
	regexp=RegexpTree.canonical_regexp(regexp)
	assert_not_nil(string, message)
	match_data=regexp.match(string)
	if match_data.nil? then
		regexp_tree=RegexpMatch.new(regexp, string)
		new_regexp_tree=regexp_tree.matchSubTree
		assert_not_empty(new_regexp_tree)
		regexp=RegexpMatch.canonical_regexp(new_regexp_tree)
		assert_match(regexp, string, message)
		message=build_message(message, "regexp.source=? did not match ? but new_regexp_tree=? should match", regexp.source, string, new_regexp_tree.to_s)
	end #if
	assert_match(regexp, string, message)
end #explain_assert_match
def RegexpMatch.assert_match_array(regexp, string, message=nil)
	 string.instance_of?(Enumeration)
end #assert_match_array
def assert_mergeable(string1, string2)
	regexp=string1.to_exact_regexp
	RegexpMatch.explain_assert_match(regexp, string2)
# now try the reverse
	regexp=string2.to_exact_regexp
	RegexpMatch.explain_assert_match(regexp, string1)
end #assert_mergeable
end #ClassMethods
def assert_match_branch(branch=self, data_to_match=@dataToParse, message=nil)
	ret=match_branch(branch, data_to_match)
	message=build_message(message, "ret=?", ret)
	assert_not_nil(ret[:data_to_match], message)
end #match_branch
def assert_consecutiveMatches(matches)
	assert_instance_of(Array, matches)
	previous_match=nil
	matched_regexp=matches.map do |m|
		assert_consecutiveMatch(m, previous_match)
		previous_match=m # save for next iteration
	end #map
end #consecutiveMatches
def assert_consecutiveMatch(match, previous_match=nil)
	assert_instance_of(Range, match)
	
	assert_operator(match.begin, :<=, match.end)
	if !previous_match.nil? then
		assert_operator(previous_match.end, :<=, match.begin)
		assert_match(self[match].to_regexp, @dataToParse)
	else
	end #if
end #consecutiveMatch
end #RegexpMatch
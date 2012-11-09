###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp_match.rb'
class RegexpMatch
module Assertions
require 'test/unit'
include Test::Unit::Assertions
# Assertions (validations)
module ClassMethods
def assert_invariant

end #def assert_invariant
def assert_pre_conditions
	assert_invariant
end #assert_pre_conditions

def assert_post_conditions
	assert_invariant
end #assert_post_conditions
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
def assert_regexp_match(regexp_match=self)
	assert_respond_to(regexp_match,:consecutiveMatches)
	assert_not_nil(regexp_match.consecutiveMatches(+1,0,0))
	assert(regexp_match.consecutiveMatches(+1,0,0).size>0)
end #assert_regexp_match
end #ClassMethods
def assert_pre_conditions
	self.class.assert_pre_conditions
	assert_invariant
end #assert_pre_conditions
def assert_invariant
	self.class.assert_invariant
	assert_instance_of(RegexpMatch, self)
	assert_instance_of(RegexpTree, @regexp_tree)
	assert_instance_of(String, @dataToParse)
	assert_block("@match_data=#{@match_data}") {@match_data.nil? || @match_data.instance_of?(MatchData)}

end #def assert_invariant

def assert_post_conditions
	self.class.assert_post_conditions
	assert_invariant
end #assert_post_conditions
def assert_match_branch(branch=self, data_to_match=@dataToParse, message=nil)
	branch_match=match_branch(branch, data_to_match)
	message=build_message(message, "branch_match=?", branch_match)
	assert_not_nil(branch_match.dataToParse, message)
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
end #Assertions
end #RegexpMatch

# Ensure assertions are included in classes.
#class GenericType < ActiveRecord::Base
#include GenericTypeAssertions
#extend GenericTypeAssertions::ClassMethods
#end #class GenericType < ActiveRecord::Base

class RegexpMatch # reopen class to add assertions
include RegexpMatch::Assertions
extend RegexpMatch::Assertions::ClassMethods
end #RegexpMatch

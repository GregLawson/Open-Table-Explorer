###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp_tree.rb'
#require_relative '../../config/initializers/monkey/String.rb'
# For a fixed string compute parse tree or sub trees that match
class RegexpMatch
# Normal new- 
#	regexp_tree is a RegexpTree and 
#	dataToParse is a String that may or may not match
# Partial match
#	regexp_tree is an Array of RegexpMatches that partially match dataToParse and 
#	dataToParse is the String union of that may or may not match
# better explanation needed here, see tests.
# Class methods
module ClassMethods
def match_data?(regexp, string_to_match)
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
def promote(value, dataToParse)
	return RegexpMatch.new(value, dataToParse)
end #promote
end #ClassMethods
extend ClassMethods
# Rescue bad regexp and return nil
# Good regexp returns MatchData type or nil for no match

# Instance methods
attr_reader :regexp_tree, :dataToParse, :matched_data, :errors
def initialize(regexp_tree,dataToParse)
	@errors=[]
	@regexp_tree=RegexpTree.promote(regexp_tree)
	@dataToParse=dataToParse
	if @regexp_tree.to_regexp.nil? then
		@errors=['@regexp_tree.to_regexp.nil?']
		@match_data= nil
	else
		@match_data=@regexp_tree.to_regexp.match(@dataToParse)
		if @match_data.nil? then
			exact_match_regexp= Regexp.new(Regexp.escape(@dataToParse), RegexpParse::Default_options)
			@regexp_tree=RegexpAlternative.new(@regexp_tree, exact_match_regexp)
		else
		end #if
	end #if
end #initialize
#force match by adding alternative to regexp
def force
	force_match=clone
	if modification.match_data.nil? then
#		force_match.regexp_tree=RegexpAlternative.new(@regexp_tree, @dataToParse.to_exact_regexp)
		force_match.regexp_tree=RegexpParse.new(@regexp_tree.to_s+'|'+ @dataToParse.to_exact_regexp.to_s)
	else
	end #if
	force_match
end #force
def ==(other)
	@regexp_tree=other.regexp_tree && @dataToParse=other.dataToParse
end #==
# display match or not but does not search for maximum sub match
def inspect
	if @match_data then
		"#{@regexp_tree.to_regexp} matches '#{@dataToParse}'"
	else
		"#{@regexp_tree.to_regexp} does not match '#{@dataToParse}'"
	end #if
end #inspect
# checks if complete match, If not tries to find maximal sub match.
# recursive call on unmatched subtrees
def map_matches(branch=self, data_to_match=@dataToParse)
	branch_match=match_branch(branch, data_to_match)
	matched_data=branch_match.matched_data
	if matched_data.nil? || matched_data.size==0 then
		if branch.kind_of?(Array) then
			start_match=-1 #preincrement to 0
			ret=branch.map do |subTree|
				start_match=start_match+1
				map_matches(subTree, data_to_match[start_match..-1])
			end #map
			RegexpMatch.new(ret, data_to_match)
		else # end recursion
			branch_match
		end #if
	else
		data_to_match=matched_data.post_match
		return branch_match # successful match
	end #if
end #map_matches
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
# +1 searches for prefixes (if they exist) or first match
# -1 searches for suffixes (if they exist) or last match
# other values can speed the search at the cost of granularity (could implement binary search?)
# The next two parameters are only useful to limit search
# start_limit - array index into parsedTree to start (inclusive)
# end_limit - array index into parsedTree to end (inclusive)
# returns when incremented from startPos/endPos past endPos/startPos
def consecutiveMatches(increment=+1, start_limit=0, end_limit=self.size-1)
	if increment==1 then
		startPos=endPos=start_limit
	else
		startPos=endPos=end_limit
	end #if
	ret=[] # nothing found yet
	begin
		matchRange=consecutiveMatch(increment,startPos,end_limit)
		if matchRange then
			startPos=endPos=matchRange.end+1
			ret << matchRange
		else #nil = no match
			return ret 
		end #if
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	end until startPos<0 || startPos>end_limit || endPos>self.size
	return ret
end #consecutiveMatches
# Find one consecutive match in one direction
# returns lastMatch (matching range in parseTree) or nil (no match)
# calls match_data?
# self - assumed to be a sequence. array of parsed tree to test for match
# increment - usually +1 or -1 to deterine direction and start/end
# +1 searches for prefixes (if they exist) or first match
# -1 searches for suffixes (if they exist) or last match
# other values can speed the search at the cost of granularity (could implement binary search?)
# The next two parameters are only useful to limit search
# start_limit - array index into parsedTree to start (inclusive)
# end_limit - array index into parsedTree to end (inclusive)
# returns when incremented from startPos/endPos past endPos/startPos
def consecutiveMatch(increment=+1, start_limit=0, end_limit=self.size-1)
	if increment==1 then
		startPos=endPos=start_limit
	else
		startPos=endPos=end_limit
	end #if
	raise "start_limit=#{start_limit}>end_limit=#{end_limit}" if start_limit>end_limit
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	begin # until
		matchData=RegexpMatch.match_data?(self[startPos..endPos], @dataToParse)
		if matchData then # expand selection
			lastMatch=(startPos..endPos) # best so far
			if increment>0 then
				endPos=endPos+increment
			else
				startPos=startPos+increment
			end
		else # non-match
			if lastMatch.nil? then # no matches yet
				if increment>0 then
					startPos=endPos=startPos+increment
				else
					startPos=endPos=endPos+increment
				end
			else #after match
				return lastMatch
			end #if
		end
	raise "startPos=#{startPos}>endPos=#{endPos}" if startPos>endPos
	end until startPos<start_limit || endPos>end_limit
	if lastMatch.nil? then
		return nil
	else
		return lastMatch
	end #if
end #consecutiveMatch
require_relative '../../test/assertions.rb';module Assertions
def assert_pre_conditions
	assert_instance_of(Class, self)
end #assert_pre_conditions
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module Examples #  Namespace
#include Constants
#Digit=GenericType.find_by_name('digit')
#Lower=GenericType.find_by_name('lower')
string1='a'
string2='b'
Alternative=RegexpMatch.new(string1, string2)
Matches=RegexpMatch.new(string1, string1)
string1=%{<Url:0xb5f22960>}
string2=%{<Url:0xb5ce4e3c>}
Addresses=RegexpMatch.new(string1, string2)
Deletion=RegexpMatch.new('KxC', 'KC')
Insertion=RegexpMatch.new('KC', 'KxC')

WhiteSpacePattern=' '
WhiteSpace=' '
White_Match=RegexpMatch.new(WhiteSpacePattern,WhiteSpace)	

Keditor=RegexpMatch.new('K','K')
RowsRegexp='(<tr.*</tr>)'
Rows_Match=RegexpMatch.new(RowsRegexp,'')
RowsEdtor2=RegexpMatch.new('\s*(<tr.*</tr>)',' <tr height=14>
  <td height=14 class=xl33 width=39>&nbsp;</td>
  <td class=xl32 width=68>Date</td>
  <td class=xl33 width=106>Time</td>
  <td class=xl33 width=60>Series</td>
  <td class=xl33 width=54>Show #</td>
  <td class=xl33 width=200>Title</td>
 </tr>')
#Macaddr_Column=GenericType.find_by_name('Macaddr_Column')
end #Examples
end #RegexpMatch

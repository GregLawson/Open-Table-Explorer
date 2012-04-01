###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# 1a) a regexp should match all examples from itself down the specialization tree.
# 1b) an example should match its regexp and all generalization regexps above if
# 2) an example should not match at least one of its specialization regexps
# 3) example  strings should not equal specialization examples
# 4) specialization regexps have fewer choices (including case) or more restricted repetition
class GenericType < ActiveRecord::Base
include Generic_Table
has_many :example_types
has_many :specialize, :class_name => "GenericType",
    :foreign_key => "generalize_id"
belongs_to :generalize, :class_name => "GenericType",
    :foreign_key => "generalize_id"
require 'test/assertions/ruby_assertions.rb'
#def initialize(generic_type)
#end #initialize
def GenericType.find_by_name(name)
	return GenericType.find_by_import_class(name)
end #find_by_name
# Define some constants, after find_by_name redefinition
Text=find_by_name('Text_Column')
Ascii=find_by_name('ascii')
def self.logical_primary_key
	return [:import_class]
end #logical_primary_key
def name
	return self[:import_class]
end #name
def generalizations
	if generalize==self then
		return []
	else
		return generalize.generalizations << generalize
	end #if
end #generalizations
def most_general?
	return generalize==self || generalize.nil?
end #most_general
def unspecialized?
	return specialize.empty?
end #unspecialized
# find Array of more specific types (tree children)
def one_level_specializations
	if most_general? then
		return specialize-[self]
	elsif unspecialized? then
		return []
	else
		specialize
	end #if
end #one_level_specializations
def specializations
	if most_general? then
		return (specialize-[self]).map{|s| s.specializations}.flatten + one_level_specializations
	elsif unspecialized? then
		return []
	else
		return specialize.map{|s| s.specializations}.flatten + one_level_specializations
	end #if
end #specializations
def expansion_termination?
	regexp=self[:data_regexp]
	parse=RegexpTree.new(regexp)
	macro_name=parse.macro_call?
	self.name==macro_name
end #expansion_termination
def expand
	parse=RegexpTree.new(self[:data_regexp])
	if expansion_termination? then
		return parse[0] # terminates recursion
	else # possible expansions
		parse.map_branches do |branch|
			macro_name=parse.macro_call?(branch)
			if macro_name then
				macro_generic_type=GenericType.find_by_name(macro_name)
				macro_call=macro_generic_type[:data_regexp]
				macro_generic_type.expand
			else
				branch
			end #if
		end #map_branches
	end #if possible expansions
end #expand
# Matches expanded regexp against full string
# Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
# Calls expand above.
def match_exact?(string_to_match)
	regexp=Regexp.new('^'+expand.join+'$',Regexp::EXTENDED | Regexp::MULTILINE)
	return RegexpMatch.matchRescued(regexp, string_to_match)
end #match
# Matches string from beginning against expanded Regexp
# Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
# Calls expand above.
def match_start?(string_to_match)
	regexp=Regexp.new('^'+expand.join,Regexp::EXTENDED | Regexp::MULTILINE)
	return RegexpMatch.matchRescued(regexp, string_to_match)
end #match_start
# Matches expanded regexp from start of string
# Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
# Calls expand above.
def match_end?(string_to_match)
	regexp=Regexp.new(expand.join+'$',Regexp::EXTENDED | Regexp::MULTILINE)
	return RegexpMatch.matchRescued(regexp, string_to_match)
end #match_end
# Matches expanded regexp anywhere in string
# Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
# Calls expand above.
def match_any?(string_to_match)
	regexp=Regexp.new(expand.join,Regexp::EXTENDED | Regexp::MULTILINE)
	return RegexpMatch.matchRescued(regexp, string_to_match)
end #match_any
# Find specializations that match recursively
# Returns an (nested?) Array of GenericType
# Least specialized comes first
# Multiple specializations that match at the same level are probably not handled correcly yet.
def specializations_that_match?(string_to_match)
	ret=[]
	one_level_specializations.map do |specialization|
		if specialization.match_exact?(string_to_match) then
			if specialization.unspecialized? then
				ret.push(specialization)
			else
				ret.push(specialization)
				specializations=specialization.specializations_that_match?(string_to_match)
				if !specializations.empty? then
					ret.push(specializations)
				end #if
			end #if
		else
			nil
		end #if
	end .compact.uniq #map
	return NestedArray.new(ret)
end #specializations_that_match
def possibilities?(common_matches)
	if common_matches.instance_of?(GenericType) then
		common_matches
	elsif common_matches.kind_of?(Array) then
		if common_matches[1].kind_of?(Array) then
			Array.new(possibilities?(common_matches[1])+possibilities?(common_matches[2..-1]))
		else
			Array.new(common_matches)
		end #if
	end #if
end #possibilities
def most_specialized?(string_to_match, common_matches=common_matches?(string_to_match))
	if common_matches.include?(self) then
		possibilities?(common_matches)
	else
		possibilities?([self, common_matches])
	end#if
end #most_specialized
# Recursively search where in the tree a string matches
# Returns an array of GenericType instances.
# The last element of the array matched.
# The receiving object is a GenericType instance used as an starting place in the tree.
# If the receiving object matched it will be the first element in returned array.
# If the string doesn't match the receiving object, generalize is returned.
# If start matches, the returned array will be the ordered array of matching specializations.
# Calls match_exact? and specializations_that_match? above
def common_matches?(string_to_match)
	if match_exact?(string_to_match) then
		if unspecialized? then
			return NestedArray.new([self])
		else
			specializations=specializations_that_match?(string_to_match)
			if specializations.empty? then
				NestedArray.new([self])
			else
				NestedArray.new([self] << specializations)
			end #if
		end #if
	else
		generalize.common_matches?(string_to_match)
	end #if
end #common_matches
end #GenericType

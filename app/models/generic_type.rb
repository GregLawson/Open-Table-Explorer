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
def self.logical_primary_key
	return [:import_class]
end #logical_primary_key
def GenericType.find_by_name(name)
	return GenericType.find_by_import_class(name)
end #find_by_name
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
	parse=RegexpTree.new(regexp)[0]
	macro_name=RegexpTree.macro_call?(parse)
	self[:import_class]==macro_name
end #expansion_termination
def expand
	parse=RegexpTree.new(self[:data_regexp])
	if expansion_termination? then
		return parse[0] # terminates recursion
	else # possible expansions
		parse.map_branches do |branch|
			macro_name=RegexpTree.macro_call?(branch)
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
# Matches string from beginning against expanded Regexp
# Sets EXTENDED format (whitespace and comments) and MULTILINE (newlines are just another character)
# Calls expand above.
def match?(string_to_match)
	regexp=Regexp.new('^'+expand.join+'$',Regexp::EXTENDED | Regexp::MULTILINE)
	return regexp.match(string_to_match)
end #match
# Find specializations that match recursively
# Multiple specializations that match at the same level are probably not handled correcly yet.
def specializations_that_match?(string_to_match)
	one_level_specializations.map do |specialization|
		if specialization.match?(string_to_match) then
			[specialization, specialization.specializations_that_match?(string_to_match)]
		else
			nil
		end #if
	end .compact.uniq.flatten #map
end #specializations_that_match
# Recursively search where in the tree a string matches
# Returns an array of GenericType instances.
# The last element of the array matched.
# The receiving object is a GenericType instance used as an starting place in the tree.
# If the receiving object matched it will be the first element in returned array.
# If the string doesn't match the receiving object, generalize is returned.
# If start matches, the returned array will be the ordered array of matching specializations.
# Calls match? and specializations_that_match? above
def most_specialized?(string_to_match)
	if match?(string_to_match) then
		specializations_that_match?(string_to_match)
	else
		generalize.most_specialized?(string_to_match)
	end #if
end #most_specialized?
end #GenericType

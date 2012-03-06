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
def self.most_specialized(string_to_match, start=GenericType.find_by_name('text'))
	if start.match(string_to_match) then
		one_level_specializations.map do |specialization|
			specialization.most_specialized(string_to_match, specialization)
		end #map
	end #if
end #most_specialized
end #GenericType

###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# 1a) a regexp should match all examples from itself down the specialization tree.
# 1b) an example should match its regexp and all generalization regexps above if
# 2) an example should not match at least one of its specialization regexps
# 3) example  strings should not equal specialization examples
# 4) specialization regexps have fewer choices (including case) or more restricted repetition
module GenericTypeAssertions
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'
module ClassMethods
end #module ClassMethods
def assert_specializations_that_match(names, search_string)
	if names.instance_of?(Array) then
		names=NestedArray.new(names)
	end #if
	assert_instance_of(String, search_string)
	common_matches=specializations_that_match?(search_string)
	common_names=common_matches.map_recursive{|m|m.name.to_sym}
#	assert_equal(names.flatten.compact, common_names.flatten.compact)
	assert_equal(names, common_names)
end #specializations_that_match
def assert_possibilities(names, string)
	common_matches=common_matches?(string)
	assert_instance_of(NestedArray, common_matches)
	message="common_matches=#{common_matches.inspect}"
	possibilities=possibilities?(common_matches)
	assert_instance_of(Array, possibilities)
	possibility_names=possibilities.map{|p|p.name.to_sym}
	assert_equal(names, possibility_names, message)
end #possibilities
def assert_most_specialized(names, string)
	most_specialized=self
	message="most_specialized=#{most_specialized.inspect}"
	message+="\n most_specialized.most_specialized?(string)=#{most_specialized.most_specialized?(string).inspect}"
	message+="\n string=#{string}"
	assert_not_nil(most_specialized, message)
	assert_not_nil(most_specialized.most_specialized?(string), message)
	assert_kind_of(Array, most_specialized.most_specialized?(string), message)
	assert_not_nil(most_specialized.most_specialized?(string), message)
	most_specialized=most_specialized.most_specialized?(string)
	assert_equal(names, most_specialized.map{|m| m.name.to_sym}, message)
end #most_specialized
def assert_common_matches(names, search_string)
	common_matches=common_matches?(search_string)
	assert_not_nil(common_matches, "search_string=#{search_string}, name=#{name}")
	common_names=common_matches.map_recursive{|m|m.name.to_sym}
	assert_equal(names.flatten.compact, common_names.flatten.compact)
	assert_equal(names, common_names)
end #common_matches
# Specialization should have fewer choices and match fewer sequential characters
# To support automatic testing example should distinguish specializations by
# 1a) a regexp should match all examples from itself down the specialization tree.
def assert_specialized_examples
	assert_regexp(self[:data_regexp])
	specializations.each do |s|
		s.example_types.each do |e|
			regexp=self[:data_regexp]
			assert_regexp(regexp)
			suggestions= RegexpMatch.string_of_matching_chars(regexp)
			message= "self[:data_regexp]=#{self[:data_regexp].inspect}, s.example_types=#{e[:example_string].inspect} of #{e.generic_type.inspect}, suggestions=#{suggestions.inspect}"
			assert_match(Regexp.new(self[:data_regexp]), e[:example_string], message)
		end #each
	end #each
end #assert_specialized_examples
end #GenericTypeAssertions
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
def assert_most_specialized(string, name)
	most_specialized=self
	message="most_specialized=#{most_specialized.inspect}"
	message+="\n most_specialized.most_specialized?(string)=#{most_specialized.most_specialized?(string).map{|s|s.import_class}.inspect}"
	message+="\n string=#{string}"
	assert_not_nil(most_specialized, message)
	assert_not_nil(most_specialized.most_specialized?(string), message)
	assert_instance_of(Array, most_specialized.most_specialized?(string), message)
	assert_not_empty(most_specialized.most_specialized?(string), message)
	assert_not_nil(most_specialized.most_specialized?(string)[-1], message)
	most_specialized=most_specialized.most_specialized?(string)[-1]
	assert_equal(name, most_specialized[:import_class], message)
end #most_specialized
end #GenericTypeAssertions
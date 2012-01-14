###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
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
class GenericType < ActiveRecord::Base
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'

# Specialization should have fewer choices and match fewer sequential characters
# To support automatic testing example should distinguish specializations by
# 1a) a regexp should match all examples from itself down the specialization tree.
def assert_specialized_examples
	specializations.each do |s|
		s.example_types.each do |e|
			suggestions= RegexpTree.string_of_matching_chars(self[:data_regexp])
			message= "self[:data_regexp]=#{self[:data_regexp].inspect}, s.example_types=#{e[:example_string].inspect}, suggestions=#{suggestions.inspect}"
			assert_match(Regexp.new(self[:data_regexp]), e[:example_string], message)
		end #each
	end #each
end #assert_specialized_examples
end #GenericType
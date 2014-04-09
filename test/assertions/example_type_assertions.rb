# 1a) a regexp should match all examples from itself down the specialization tree.
# 1b) an example should match its regexp and all generalization regexps above if
# 2) an example should match zero or one of its specialization regexps
# 2b) 
# 3) example  strings should not equal specialization examples
# 4) specialization regexps have fewer choices (including case) or more restricted repetition
require 'test/test_helper'
class ExampleType < ActiveRecord::Base
# Assertions (validations)
include Minitest::Assertions
require 'rails/test_help'
# 2) an example should not match at least one of its specialization regexps

# Specialization should have fewer choices and match fewer sequential characters
# To support automatic testing example should distinguish specializations by
def assert_specialization_does_not_match
	specializations=generic_type.one_level_specializations
	assert_not_nil(specializations)
	if !specializations.empty? then
		suggestions=RegexpTree.string_of_matching_chars(Regexp.new(generic_type[:data_regexp]))-specializations.map{|s| RegexpTree.string_of_matching_chars(Regexp.new(s[:data_regexp]))}.flatten.sort.uniq
		assert(specializations.any? do |s|
			if Regexp.new(s[:data_regexp]).match(self[:example_string]) then
				$~[0]!=self[:example_string] #full match
			else
				true #no match
			end #if
		end, "example_string=#{self[:example_string].inspect} of import_class=#{generic_type[:import_class]},should not match at least one of specializations=#{specializations.inspect}, sugestions=#{suggestions}") #any
	end #if
end #assert_specialization_does_not_match
# 3) example  strings should not equal specialization examples
def assert_no_example_duplicates
	specializations=generic_type.one_level_specializations
	assert_not_nil(specializations)
	if !specializations.empty? then
		suggestions=RegexpTree.string_of_matching_chars(Regexp.new(generic_type[:data_regexp]))-specializations.map{|s| RegexpTree.string_of_matching_chars(Regexp.new(s[:data_regexp]))}.flatten.sort.uniq
		specializations.each do |s|
			s.example_types.each do |e|
				assert_not_equal(e[:example_string], self[:example_string], "example_string=#{self[:example_string].inspect} of import_class=#{generic_type[:import_class]},should not match at least one of specializations=#{specializations.inspect}, sugestions=#{suggestions}") #any
			end #each
		end #each
	end #if
end #assert_no_example_duplicates
def assert_generic_type(association=nil, message=nil)
	message=build_message(message, "example_type=?, association=?", self, association.inspect) 
	case association
	when nil
		; # DO NOTHING
	when :generalize, :specialize
#need more code		assert_associations(generic_type.class, association, message)
	else
		raise "Unexpected value for association=#{association}"
	end #case
	generic_type=which_generic_type(association)
	assert_not_nil(generic_type, message)
	if generic_type.is_a?(Array) then
		generic_type.each do |gt|
			assert_not_empty(gt[:data_regexp], "gt=#{gt}")
		end #each
	else
		assert_not_empty(generic_type[:data_regexp], message)
	end #if
end #generic_type
def assert_example_type_valid(association=nil, message=nil)
	message=ActiveSupport::TestCase::build_message(message, "example_type=?, association=?", self, association.inspect) 
#	assert_not_nil(example_type)
	assert_not_empty(self[:example_string], message)
	assert_generic_type(association, message)
	assert(valid?(association), message)
end #example_type_valid
end #ExampleType
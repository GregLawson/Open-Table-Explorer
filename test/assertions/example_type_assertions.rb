require 'test/test_helper'
class ExampleType < ActiveRecord::Base
# Assertions (validations)
include Test::Unit::Assertions
require 'rails/test_help'

# Specialization should have fewer choices and match fewer sequential characters
# To support automatic testing example should distinguish specializations by
def assert_specialization_does_not_match
	generalization=generic_type.generalize
	assert_not_nil(generalization)
		Regexp.new(generic_type[:data_regexp]).match(self[:example_string])
		assert_not_equal($~[0], self[:example_string], "self=#{self.inspect} is a specialization that does not match #{generic_type.inspect}")

end #assert_specialization_does_not_match
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
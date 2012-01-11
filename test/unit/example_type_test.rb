require 'test/test_helper'
require 'test/assertions/example_type_assertions.rb'
class ExampleTypeTest < ActiveSupport::TestCase
def test_generic_type
	ExampleType.all.each do |t|
		assert_not_nil(t.generic_type)
	end #each
end #generic_type
def test_valid_context
	ExampleType.all.each do |t|
		assert(t.valid_context?, "t=#{t.inspect}")
	end #each
end #valid_context
def test_valid
	example_type=ExampleType.all[2]
	assert_not_nil(example_type)
	assert_association(ExampleType, :generic_type)
	assert_not_nil(example_type.generic_type, "example_type=#{example_type.inspect}")
	assert_not_nil(example_type.generic_type.generalize)
	assert_not_nil(example_type.generic_type.generalize[:data_regexp])
	assert_not_nil(example_type[:example_string])
	assert_match(Regexp.new(example_type.generic_type[:data_regexp]), example_type[:example_string])
	assert(example_type.valid?)
	assert(example_type.valid?(:generalize))
	assert_not_nil(example_type.which_generic_type(:specialize))
	assert_instance_of(Array, example_type.which_generic_type(:specialize))
	ExampleType.all.any? do |t|
		specialized_types=t.which_generic_type(:specialize)
		assert_not_nil(specialized_types)
		specialized_types.each do |s|
			assert_match(Regexp.new(s[:data_regexp]), t[:example_string])
			puts "s[:data_regexp]=#{s[:data_regexp]}, t[:example_string]=#{t[:example_string]}"
		end #each
		!specialized_types.empty?
	end #any
	assert(example_type.valid?(:specialize))
	assert(example_type.valid_context?)
	ExampleType.all.each do |t|
		assert_match(Regexp.new(t.generic_type[:data_regexp]), t[:example_string])
		generic_type=t.which_generic_type
		assert_not_nil(generic_type)
		assert_match(Regexp.new(t.generic_type[:data_regexp]), t[:example_string])
		assert_match(Regexp.new(t.generic_type[:data_regexp]), t[:example_string])
		assert_not_nil(t.valid?, "t=#{t.inspect}")
		assert_not_nil(t.valid?(:generalize), "t=#{t.inspect}")
		assert_not_nil(t.valid?(:specialize), "t=#{t.inspect}")
		assert_not_nil(t.which_generic_type(:specialize))
		assert_instance_of(Array, t.which_generic_type(:specialize))
		specialized_types=t.which_generic_type(:specialize)
		specialized_types.each do |st|
			assert_not_nil(st)
			assert_not_nil(st[:data_regexp])
			assert_not_nil(t[:example_string])
			assert_not_match(Regexp.new(st[:data_regexp]), t[:example_string])
			assert_match(Regexp.new(st[:data_regexp]), t[:example_string])
		end #each
	end #each
end #valid
def test_which_generic_type
	ExampleType.all.each do |t|
		message= "t=#{t.inspect}"
		assert_not_nil(t.which_generic_type, message)
		assert_not_nil(t.which_generic_type(:generalize), message)
		assert_not_nil(t.which_generic_type(:specialize), message)
		assert_not_nil(t.generic_type.specialize, message)
		assert_instance_of(Array, t.generic_type.specialize, message)
		assert_respond_to(t.generic_type.specialize, :class, message)
		assert_not_nil(t.generic_type.specialize.class, message)
		assert_not_nil(t.generic_type.specialize.class.name, message)
#		assert_not_empty(t.generic_type.specialize, message)
#		assert_not_empty(t.which_generic_type(:specialize), message)
		assert_instance_of(GenericType, t.which_generic_type, message)
		assert_instance_of(GenericType, t.which_generic_type(:generalize), message)
		assert_instance_of(Array, t.which_generic_type(:specialize), message)
#		t.assert_generic_type(nil, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
#		t.assert_generic_type(:generalize, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
#		t.assert_generic_type(:specialize, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
	end #each
end #which_generic_type
def test_assert_generic_type
	ExampleType.all.each do |t|
		t.assert_generic_type(nil, 'example not valid')
		t.assert_generic_type(:generalize, 'generalize not valid')
		t.assert_generic_type(:specialize, 'specialize not valid')
	end #each
end #generic_type
def test_assert_example_type_valid
	ExampleType.all.each do |t|
		message= "t=#{t.inspect}"
		t.assert_example_type_valid(nil, message)
		t.assert_example_type_valid(:generalize, message)
		t.assert_example_type_valid(:specialize, message)
	end #each
end #example_type_valid
end #ExampleType

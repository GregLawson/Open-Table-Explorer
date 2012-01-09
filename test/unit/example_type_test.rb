require 'test/test_helper'

class ExampleTypeTest < ActiveSupport::TestCase
def test_generic_type
	ExampleType.all.each do |t|
		assert_not_nil(t.generic_type)
	end #each
end #generic_type
def test_valid_context
	ExampleType.all.each do |t|
		assert_not_nil(t.valid_context?, "t=#{t.inspect}")
	end #each
end #valid_context
def test_valid
	example_type=ExampleType.all[0]
	assert_not_nil(example_type)
	assert_not_nil(example_type.generic_type, "example_type=#{example_type.inspect}")
	assert_not_nil(example_type.generic_type.generalize)
	assert_not_nil(example_type.generic_type.generalize[:data_regexp])
	assert_not_nil(example_type[:example_string])
	assert(example_type.valid?(example_type[:example_string]))
	ExampleType.all.each do |t|
		assert_not_nil(t.valid?, "t=#{t.inspect}")
	end #each
end #valid
def test_which_generic_type
	ExampleType.all.each do |t|
		t.assert_generic_type(:generalize, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}")
	end #each
end #which_generic_type
def test_assert_generic_type
	ExampleType.all.each do |t|
		t.assert_generic_type(nil, 'example not valid')
		t.assert_generic_type(:generalize, 'generalize not valid')
		t.assert_generic_type(:specialize, 'specialize not valid')
	end #each
end #generic_type
def test_example_type_valid
	ExampleType.all.each do |t|
		t.assert_example_type_valid(:specialize, "t=#{t.inspect}")
	end #each
end #example_type_valid
end #ExampleType

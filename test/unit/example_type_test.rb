require 'test/test_helper'

class ExampleTypeTest < ActiveSupport::TestCase
def test_generic_type
	ExampleType.all.each do |t|
		assert_not_nil(t.generic_type)
	end #each
end #generic_type
def test_valid?
	ExampleType.all.each do |t|
		assert_not_nil(t.valid?, "t=#{t.inspect}")
	end #each
end #valid?
def test_valid_self
	example_type=ExampleType.all[0]
	assert_not_nil(example_type)
	assert_not_nil(example_type.generic_type, "example_type=#{example_type.inspect}")
	assert_not_nil(example_type.generic_type.generalize)
	assert_not_nil(example_type.generic_type.generalize[:data_regexp])
	assert_not_nil(example_type[:example_string])
	assert(example_type.valid_self?(example_type[:example_string]))
	ExampleType.all.each do |t|
		assert_not_nil(t.valid_self?, "t=#{t.inspect}")
	end #each
end #valid_self?
def test_valid_generalization
	ExampleType.all.each do |t|
		assert_instance_of(String, t[:example_string])
		assert_not_nil(t.generic_type)
		assert_not_nil(t.generic_type.generalize)
		assert_not_nil(t.generic_type.generalize[:data_regexp])
		assert(Regexp.new(t.generic_type.generalize[:data_regexp]).match(t[:example_string]), "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type.generalize=#{t.generic_type.generalize.inspect}")
		assert_not_nil(t.valid_generalization?, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}")
	end #each
end #valid_generalization?
def test_valid_specialization
	ExampleType.all.each do |t|
		assert_not_nil(t.valid_specialization?, "t=#{t.inspect}")
	end #each
end #valid_specialization?
end #ExampleType

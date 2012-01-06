require 'test/test_helper'

class GenericTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
def test_example_types
    assert_not_nil(GenericType.all)
    assert_not_nil(GenericType.all[0])
    
    GenericType.all.each do |t| 
    	assert_not_nil(t.example_types)
	t.example_types.each do |e|
		assert_match(Regexp.new(t.data_regexp), e.example_string)
	end #each
#	assert_equal([], t.example_types.map{|t| t.attributes})
    end #each
end #test_example_types
end #GenericType

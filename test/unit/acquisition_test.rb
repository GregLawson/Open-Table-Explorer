require 'test_helper'

class AcquisitionTest < ActiveSupport::TestCase
def setup
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
def test_id_equal
	@my_fixtures.each do |my_fixture|
		assert_equal(Fixtures::identify(my_fixture.model_class_name),my_fixture.id,"identify != id")
	end
end #def
test "specific, stable and working" do
end #test
def test_associatons
	assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interface)
	assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
end #def
end #class

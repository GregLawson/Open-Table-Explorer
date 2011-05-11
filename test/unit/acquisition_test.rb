require 'test_helper'

class AcquisitionTest < ActiveSupport::TestCase
test "basic includes" do
end #test
def setup
	explain_assert_respond_to(Acquisition.new,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")
	assert_respond_to(Acquisition.new,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
def test_id_equal
	if @model_class.new.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,"identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}")
		end
	end
end #def
test "specific, stable and working" do
end #test
def test_associations
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
end #def
test "acquisition_stream_spec" do
	    assert_not_nil(acquisitions(:one))
	    assert_association(acquisitions(:one),:acquisition_stream_spec)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec_id)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec)
end #test
end #class

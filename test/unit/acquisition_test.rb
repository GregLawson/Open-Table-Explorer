require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class AcquisitionStreamSpecTest < ActiveSupport::TestCase
def setup
	define_model_of_test
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
end #test
def test_associations
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
end #test
def test_acquisition_stream_spec
	    assert_not_nil(acquisitions(:one))
	    assert_association(acquisitions(:one),:acquisition_stream_spec)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec_id)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec)
end #test
end #class

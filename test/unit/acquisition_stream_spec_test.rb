require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class AcquisitionStreamSpecTest < ActiveSupport::TestCase
def setup
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.new.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
test "specific, stable and working" do
end #test
test "aaa test new assertions" do  # aaa to output first
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:cabbage) }
	assert_association(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface.scheme)
	testCall(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
end #test

test "associations" do
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
end #test
test "acquisition_stream_spec" do
	    assert_not_nil(acquisitions(:one))
	    assert_association(acquisitions(:one),:acquisition_stream_spec)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec_id)
#	    assert_not_nil(acquisitions(:one).acquisition_stream_spec)
end #test
def test_acquisition_interface_not_nil
		assert_not_nil(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface,"Weird. Doesn't this work fine in test above")
end #def
def test_acquisition_interface
	assert_instance_of(AcquisitionInterface,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface)
end #def
def test_acquisition_stream_specs_not_nil
		assert_not_nil(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym))
end
def test_acquisition_interface_id_not_nil
	assert_not_nil(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id)
end #def 
def test_schemeFromInterface
   assert_equal('http',acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).schemeFromInterface)
end #test
def test_scheme
	testAnswer(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:scheme,'http')
end #test

end #class

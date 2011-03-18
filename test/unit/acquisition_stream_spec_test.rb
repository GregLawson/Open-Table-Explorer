require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place n order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class AcquisitionStreamSpecTest < ActiveSupport::TestCase
def test_aaa
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs(:one),:cabbage) }
	assert_association(acquisition_stream_specs(:one),:acquisition_interface)
	assert_equal(Fixtures::identify(:one),acquisition_interfaces(:one).id)
	assert_equal(Fixtures::identify(:one),acquisition_stream_specs(:one).acquisition_interface_id)
	assert_equal(acquisition_stream_specs(:one).acquisition_interface_id,acquisition_interfaces(:one).id)
	assert_equal(acquisition_stream_specs(:one).scheme,acquisition_interfaces(:one).scheme)
	assert_equal(acquisition_stream_specs(:one).scheme,acquisition_stream_specs(:one).acquisition_interface.scheme)
	testCall(acquisition_stream_specs(:one),:acquisition_interface)
end
def test_acquisition_interface_id_equal
#	assert_raise(Test::Unit::AssertionFailedError) do
		assert_equal(Fixtures::identify(:one),acquisition_stream_specs(:one).acquisition_interface_id,"identify != acquisition_interface_id")
#	end #assert_raise
end #def
def test_id_equal
#	assert_raise(Test::Unit::AssertionFailedError) do
		assert_equal(acquisition_interfaces(:one).id,acquisition_stream_specs(:one).acquisition_interface_id,"id != acquisition_interface_id")
#	end #assert_raise
end #def
def test_table_spec_id_equal
#	assert_raise(Test::Unit::AssertionFailedError) do
		assert_equal(acquisition_stream_specs(:one).table_spec_id,acquisition_stream_specs(:one).acquisition_interface_id,"table_spec_id != acquisition_interface_id")
#	end #assert_raise
end #def
def test_acquisition_interface_not_nil
		assert_not_nil(acquisition_stream_specs(:one).acquisition_interface,"Weird. Doesn't this work fine in test above")
end #def
def test_acquisition_interface
	assert_instance_of(AcquisitionInterface,acquisition_stream_specs(:one).acquisition_interface)
end #def
def test_acquisition_interface_inspect
	assert_equal('#<AcquisitionStreamSpec id: 980190962, acquisition_interface: nil, url: "http://www.weather.gov/xml/current_obs/KHHR.xml", table_spec_id: 980190962, required_order: nil, acquisition_interface_id: 980190962>',acquisition_stream_specs(:one).inspect)
end #def
def test_acquisition_stream_specs_not_nil
		assert_not_nil(acquisition_stream_specs(:one))
end
def test_acquisition_interface_id_not_nil
	assert_not_nil(acquisition_stream_specs(:one).acquisition_interface_id)
end #def
def test_associatons
	assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interface)
	assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
end #def
def test_acquisition_interfaces_name
	assert_equal('HTTP',acquisition_stream_specs(:one).acquisition_interface.name)
end #def
def test_nameFromInterface
    assert_equal('HTTP',acquisition_stream_specs(:one).nameFromInterface)
end
def test_nameFromInterface_String
    assert_instance_of(String,acquisition_stream_specs(:one).nameFromInterface)
end
def test_nameFromInterface_downcase_nil
	assert_not_nil(acquisition_stream_specs(:one).nameFromInterface)
end
def test_nameFromInterface_downcase
	assert_equal('http',acquisition_stream_specs(:one).nameFromInterface.downcase)
end #test
 
def test_schemeFromInterface
   assert_equal('http',acquisition_stream_specs(:one).schemeFromInterface)
end #test
def test_scheme
	testAnswer(acquisition_stream_specs(:one),:scheme,'http')
 end #test
end

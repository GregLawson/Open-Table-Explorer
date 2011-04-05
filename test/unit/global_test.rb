require 'test_helper'
class GlobalTest < ActiveSupport::TestCase
def test_aaa
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs(:one),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs(:one),:cabbage) }
	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_specs(:one).acquisition_interface_id)
	assert_equal(acquisition_stream_specs(:one).acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_specs(:one).scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_specs(:one).scheme,acquisition_stream_specs(:one).acquisition_interface.scheme)
	testCall(acquisition_stream_specs(:one),:acquisition_interface)
	assert_association(acquisition_stream_specs(:one),:acquisition_interface)
	acquisition_stream_specs(:one).associated_to_s(:acquisition_interface,:name)
	assert_instance_of(String,acquisition_stream_specs(:one).associated_to_s(:acquisition_interface,:name))
	assert_respond_to(acquisition_stream_specs(:one),:associated_to_s)
end

end #test class

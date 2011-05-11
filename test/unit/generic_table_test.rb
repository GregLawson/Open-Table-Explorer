require 'test_helper'
class GenericTableTest < ActiveSupport::TestCase
def test_aaa
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:cabbage) }
#syntax	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id)
#syntax	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id,acquisition_interfaces(:HTTP).id)
#syntax	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_interfaces(:HTTP).scheme)
#syntax	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface.scheme)
	testCall(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_association(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name)
	assert_instance_of(String,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name))
	assert_respond_to(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:associated_to_s)
end

end #test class

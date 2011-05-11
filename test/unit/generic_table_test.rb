require 'test_helper'
class GenericTableTest < ActiveSupport::TestCase
def test_aaa
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:cabbage) }
	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface.scheme)
	testCall(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_association(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name)
	assert_instance_of(String,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name))
	assert_respond_to(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:associated_to_s)
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=nil
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=0
#	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
end
test "associated_to_s" do
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)
	assert_not_nil(acquisition_stream_spec)
	puts acquisition_stream_spec.matching_methods(/table_spec/).inspect
	puts acquisition_stream_spec.similar_methods(:table_spec).inspect
	assert_respond_to(acquisition_stream_spec,:table_spec)
	meth=acquisition_stream_spec.method(:table_spec)
#	assert_not_nil(meth.call)
#	ass=acquisition_stream_spec.send(:table_spec)
#	if ass.nil? then
#		return ''
#	else
#		return ass.send(:model_class_name,*args).to_s
#	end
#	puts "acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)=#{acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)}"
end #test
end #test class

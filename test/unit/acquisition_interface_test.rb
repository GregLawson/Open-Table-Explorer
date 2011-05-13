require 'test_helper'

class AcquisitionInterfaceTest < ActiveSupport::TestCase
def test_scheme
	testAnswer(acquisition_interfaces(:HTTP),:scheme,'http')
end #test
def test_acquisition_class_name
	  testAnswer(acquisition_interfaces(:HTTP),:acquisition_class_name,'HTTP_Acquisition')
end #test
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,Fixtures::identify(:HTTP),"id != Fixtures::identify(:one)")
end #def
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym).acquisition_interface_id,"id != acquisition_stream_spec_id")
end #def	  
test "acquisition" do
	stream=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym)
	assert_not_nil(stream)
	acq=acquisition_interfaces(:HTTP)
	assert_instance_of(AcquisitionInterface,acq)
	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	puts "acq.classDefinition=#{acq.classDefinition}"
	assert_instance_of(String,acq.codeBody)
	acq.setup
	assert_not_nil(acq)
	assert_instance_of(String,acq.codeBody)
	assert_respond_to(acq,:acquire)
#	assert_not_nil(acq.acquire(stream))

	acq.delta(stream)
	assert_raise(NoMethodError){acq.acquire_method}
	acq.acquire_data=''
	acq.codeBody # recompile eval code
	assert_nothing_raised{acq.acquire_method}
#	acq.error_return
#		acq.rescue_method
#		@acquisition.save


end #test
end

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
class HTTP_Acquisition  
include Generic_Table
require 'net/http'
def acquire(stream)
@previousAcq=self[:acquisition_data]
self[:acquisition_data] =nil
@uri=URI.parse(URI.escape(@stream.url))
self[:acquisition_data]= Net::HTTP.get(@uri)
if $?==0 then
	self[:error]=nil
else
	self[:error]=self[:acquisition_data]
	self[:acquisition_data]=nil
end
rescue StandardError => exception_raised
#self[:error]= 'Error: ' + exception_raised.inspect + 'could not get data from '+stream.url
return self

end

end
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
	assert_respond_to(acq.classReference.new,:acquire)
	HTTP_Acquisition.new.acquire(stream)
	assert_not_nil(acq.acquire(stream))
end #test
end

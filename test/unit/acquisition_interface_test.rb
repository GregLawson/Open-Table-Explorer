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
def acq_and_rescue
	stream=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym)
	acq=acquisition_interfaces(:HTTP)
	acq.acquire_method
	assert(!acq.acquisition.error.nil? || !acq.acquisition.acquisition_data.nil?)
rescue  StandardError => exception_raised
	puts 'Error: ' + exception_raised.inspect + ' could not get data from '+stream.url
	puts "$!=#{$!}"
end #def	  
test "acquisition" do
	stream=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym)
	assert_not_nil(stream)
	acq=acquisition_interfaces(:HTTP)
	assert_instance_of(AcquisitionInterface,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.setup
	assert_not_nil(acq)
	assert_respond_to(acq,:acquire)

	acq.delta(stream)
	assert_not_nil(acq.acquisition)
	assert_instance_of(Acquisition,acq.acquisition)
	assert_instance_of(AcquisitionStreamSpec,acq.acquisition.acquisition_stream_spec)
	assert_instance_of(ActiveModel::Errors,acq.acquisition.errors)
	assert_nil(acq.acquisition.error)
	assert_nil(acq.acquisition.acquisition_data)
	acq_and_rescue
	assert_nothing_raised{acq.acquire_method}
	assert_not_nil(acq.acquisition)
	assert_equal({},acq.acquisition.errors)
	assert_not_nil(acq.acquisition)
	assert_not_nil(acq.acquisition)
#	assert_not_nil(acq.instance_variable_get(:stream))
	assert_not_nil(acq.acquisition_stream_specs)
#	assert_not_nil(acq.acquisition_stream_specs_ids)
#	assert_equal(acq.acquisition_stream_spec.id,acq.acquisition_stream_spec_id)
	assert_not_nil(acq.acquire(stream))
end #test
test "default acquisition" do
	stream=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym)
	acq=acquisition_interfaces(:HTTP)
	acq.delta(stream)

	acq.acquire_data='@acquisition[:acquisition_data]=Net::HTTP.get(@stream.uri)'
	acq.codeBody # recompile eval code
	assert_nothing_raised{acq.acquire_method}
	assert(!acq.acquisition.error.nil? || !acq.acquisition.acquisition_data.nil?)

	acq.return_error_code=''
	acq.codeBody # recompile eval code
	assert_nothing_raised{acq.error_return}

	acq.rescue_code=''
	acq.codeBody # recompile eval code
	assert_nothing_raised{acq.rescue_method}
	assert_difference('Acquisition.count') do
		acq.acquisition.save
	end #assert
	puts "Acquisition.count=#{Acquisition.count}"
	acq=acquisition_interfaces(:Shell)
	stream=acquisition_stream_specs('/sbin/ifconfig'.to_sym)
	acq.delta(stream)

	acq.acquire_data='@acquisition[:acquisition_data]=`#{@stream.schemelessUrl} 2>&1`'
	acq.codeBody # recompile eval code
	assert_nothing_raised{acq.acquire_method}
	assert(!acq.acquisition.error.nil? || !acq.acquisition.acquisition_data.nil?)

	assert_difference('Acquisition.count') do
		acq.acquisition.save
	end #assert
	puts "Acquisition.count=#{Acquisition.count}"

end #test
end

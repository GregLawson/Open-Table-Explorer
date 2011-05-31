require 'test_helper'

class AcquisitionInterfaceTest < ActiveSupport::TestCase
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
end #def
def test_scheme
	testAnswer(acquisition_interfaces(:HTTP),:scheme,'http')
end #test
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,Fixtures::identify(:HTTP),"id != Fixtures::identify(:HTTP)")
end #def
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,acquisition_stream_specs(@testURL.to_sym).acquisition_interface_id,"id != acquisition_stream_spec_id")
end #def
def acq_and_rescue
	stream=acquisition_stream_specs(@testURL.to_sym)
	acq=acquisition_interfaces(:HTTP)
	acq.interface_method
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.nil?)
rescue  StandardError => exception_raised
	puts 'Error: ' + exception_raised.inspect + ' could not get data from '+stream.url
	puts "$!=#{$!}"
end #def	  
test "acquisition" do
	stream=acquisition_stream_specs(@testURL.to_sym)
	assert_not_nil(stream)
	acq=acquisition_interfaces(:HTTP)
	assert_instance_of(AcquisitionInterface,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.compile_code
	assert_not_nil(acq)
	assert_respond_to(acq,:acquire)

	acq.delta(stream)
	assert_not_nil(acq.interaction)
	assert_instance_of(Acquisition,acq.interaction)
	assert_instance_of(AcquisitionStreamSpec,acq.interaction.acquisition_stream_spec)
	assert_not_nil(acq.interaction.acquisition_stream_spec_id)
	assert_equal(stream.id,acq.interaction.acquisition_stream_spec_id)
	assert_instance_of(ActiveModel::Errors,acq.interaction.errors)
	assert_nil(acq.interaction.error)
	assert_nil(acq.interaction.acquisition_data)
	acq_and_rescue
	assert_nothing_raised{acq.interface_method}
	assert_not_nil(acq.interaction)
	assert_equal({},acq.interaction.errors)
	assert_not_nil(acq.interaction)
#	assert_not_nil(acq.instance_variable_get(:stream))
	assert_not_nil(acq.acquisition_stream_specs)
#	assert_not_nil(acq.acquisition_stream_specs_ids)
#	assert_equal(acq.acquisition_stream_spec.id,acq.acquisition_stream_spec_id)
	assert_not_nil(acq.acquire(stream))
	assert_not_nil(acq.interaction.acquisition_stream_spec_id)
	assert_equal(stream.id,acq.interaction.acquisition_stream_spec_id)
	
	assert_association(stream,:acquisition_interface)
	assert_respond_to(stream,:associated_to_s)
	assert_equal(stream.associated_to_s(:acquisition_interface,:name),"HTTP")
end #test
test "stream acquire" do
	stream=acquisition_stream_specs(@testURL.to_sym)
	assert_not_nil(stream.acquire)
	assert_not_nil(stream.id)
	assert_instance_of(Fixnum,stream.id)

	acquisition=stream.acquire
	assert_instance_of(Acquisition,acquisition)
	assert_not_nil(acquisition.acquisition_stream_spec_id)
	assert_instance_of(Fixnum,acquisition.acquisition_stream_spec_id)
	assert_equal(stream.id,acquisition.acquisition_stream_spec_id)
	
	acquisition=stream.acquisition_interface.acquire(stream)
	assert_instance_of(Acquisition,acquisition)
	assert_not_nil(acquisition.acquisition_stream_spec_id)
	assert_instance_of(Fixnum,acquisition.acquisition_stream_spec_id)
	assert_equal(stream.id,acquisition.acquisition_stream_spec_id)
	
	acquisition.acquisition_stream_spec_id=stream.id # not clear why this is nil after being set in acquisition_interface
	assert_not_nil(acquisition.acquisition_stream_spec_id)
	assert_instance_of(Fixnum,acquisition.acquisition_stream_spec_id)
	assert_equal(stream.id,acquisition.acquisition_stream_spec_id)
end #test
test "default acquisition" do
	stream=acquisition_stream_specs(@testURL.to_sym)
	acq=acquisition_interfaces(:HTTP)
	acq.delta(stream)

	acq.interface_code='@interaction[:acquisition_data]=Net::HTTP.get(@stream.uri)'
	acq.compile_code # recompile eval code
	assert_nothing_raised{acq.interface_method}
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.nil?)

	acq.return_code=''
	acq.compile_code # recompile eval code
	assert_nothing_raised{acq.error_return}

	acq.rescue_code=''
	acq.compile_code # recompile eval code
	assert_nothing_raised{acq.rescue_method}
	assert_difference('Acquisition.count') do
		acq.interaction.save
	end #assert
	puts "Acquisition.count=#{Acquisition.count}"

	assert_not_nil(acq.interaction.acquisition_stream_spec_id)
	assert_equal(stream.id,acq.interaction.acquisition_stream_spec_id)
	acq=acquisition_interfaces(:Shell)
	stream=acquisition_stream_specs('/sbin/ifconfig'.to_sym)
	acq.delta(stream)

	acq.interface_code='@interaction[:acquisition_data]=`#{@stream.schemelessUrl} 2>&1`'
	acq.compile_code # recompile eval code
	assert_nothing_raised{acq.interface_method}
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.nil?)

	assert_difference('Acquisition.count') do
		acq.interaction.save
	end #assert
	puts "Acquisition.count=#{Acquisition.count}"

	assert_not_nil(acq.interaction.acquisition_stream_spec_id)
	assert_equal(stream.id,acq.interaction.acquisition_stream_spec_id)

end #test
end

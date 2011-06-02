require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class RubyInterfaceTest < ActiveSupport::TestCase
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test
	explain_assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class.new,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end
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
def acq_and_rescue
	stream=acquisition_stream_specs(@testURL.to_sym)
	acq=ruby_interfaces(:HTTP)
	acq.interface_method
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.empty?)
rescue  StandardError => exception_raised
	puts 'Error: ' + exception_raised.inspect + ' could not get data from '+stream.url
	puts "$!=#{$!}"
end #def	  
test "interaction" do
	acq=acquisition_interfaces(:HTTP)
	assert_instance_of(AcquisitionInterface,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.compile_code
	assert_not_nil(acq)
	@my_fixtures.each_value do |acq|
		assert_instance_of(RubyInterface,acq)
#		puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
		acq.compile_code
		#~ if acq.errors.empty? then
			#~ puts "No error in acq=#{acq.interface_code.inspect}"
		#~ else
			#~ puts "acq.errors=#{acq.errors.inspect} for acq=#{acq.interface_code.inspect}"
		#~ end #if
		assert_not_nil(acq)
		assert(!acq.respond_to?(:syntax_check_temp_method),"syntax_check_temp_method is a method of #{canonicalName}.")
	end #each_value

end #test
end

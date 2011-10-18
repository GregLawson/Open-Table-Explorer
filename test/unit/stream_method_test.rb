###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamMethodTest < ActiveSupport::TestCase
fixtures :stream_methods
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
	acq=stream_methods(:HTTP)
	assert_instance_of(StreamMethod,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.compile_code
	assert_not_nil(acq)
	@my_fixtures.each_value do |acq|
		assert_instance_of(StreamMethod,acq)
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
test "code sizes" do
	acq=stream_methods(:HTTP)
	code=acq.interface_code
	if code.nil? || code.empty? then
		rows=0
		cols=0
	else
		code_lines=code.split("\n")
		rows=code_lines.size
		cols=code_lines.map {|l|l.length}.max
	end #if
	assert_operator(rows,:>,0)
	assert_operator(cols,:>,0)
	explain_assert_respond_to(acq,:interface_code_method)
	assert_include('interface_code_method',acq.methods(true))
#	acq.eval_method(:interface_code,'')
	assert_include('interface_code_rows',acq.methods(true))
	assert_include('interface_code_rows',acq.singleton_methods(true))
	explain_assert_respond_to(acq,:interface_code_rows)
	assert_not_nil(acq.interface_code_rows)
end #test
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
#	assert_general_associations(@table_name)
end
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def

end

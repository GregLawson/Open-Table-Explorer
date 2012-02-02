###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamLinkTest < ActiveSupport::TestCase
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@model_class=@@model_name.constantize
@@table_name=@@model_name.tableize
fixtures @@table_name.to_sym
fixtures :stream_method_arguments
#assert_fixture_name(@@table_name)
@@my_fixtures=fixtures(@@table_name)
def test_association_names
  	assert_generic_table('StreamLink')
	assert_equal_sets([:input_stream_method_argument_id,:output_stream_method_argument_id,:store_method_id,:next_method_id], StreamLink.foreign_key_names)
	assert_equal_sets(["output_stream_method_argument", "next_method", "input_stream_method_argument", "store_method"],StreamLink.association_names)
	assert_not_empty(StreamLink.all)
	assert_not_empty(StreamMethodArgument.all)
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
	end #each
end #association_names
def test_output_stream_method_argument
	assert_not_empty(@@association_patterns)
	assert_not_empty(StreamLink.association_patterns(:output_stream_method_argument))
	assert_equal(@@association_patterns, StreamLink.association_patterns(:output_stream_method_argument))

	assert_foreign_key_name(StreamLink,:output_stream_method_argument_id)
	assert_association(StreamLink, :output_stream_method_argument)
	explain_assert_respond_to(StreamLink, :association_macro_type)
	assert_equal(:belongs_to,StreamLink.association_macro_type(:output_stream_method_argument))
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
		assert_not_nil(StreamMethodArgument.where("id=?",sl.output_stream_method_argument_id))
		if !sl.association_has_data(:output_stream_method_argument) then
			assert_equal("",sl.association_state(:output_stream_method_argument))
		end #if
		assert_equal("Output",StreamMethodArgument.where("id=?",sl.output_stream_method_argument_id).first.direction)
		assert_not_nil(sl.output_stream_method_argument)
	end #each
end #output_stream_method_argument
def test_input_stream_method_argument
	assert_equal(@@association_patterns, StreamLink.association_patterns(:input_stream_method_argument))
	assert_foreign_key_name(StreamLink,:output_stream_method_argument_id)
	assert_association(StreamLink, :input_stream_method_argument)
	assert_equal(:belongs_to,StreamLink.association_macro_type(:input_stream_method_argument))
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
		if !sl.association_has_data(:input_stream_method_argument) then
			assert_equal('Input',input_stream_method_argument.where("id=?",sl.input_stream_method_argument_id).first.direction, message)
			assert_equal("",sl.association_state(:input_stream_method_argument))
		end #if
		message="StreamMethodArgument.where('id=?',#{sl.input_stream_method_argument_id})=#{StreamMethodArgument.where('id=?',sl.input_stream_method_argument_id).inspect}, sl.input_stream_method_argument_id=#{sl.input_stream_method_argument_id}, "
		assert_not_nil(sl.input_stream_method_argument)
	end #
end #input_stream_method_argument
def test_store_method
end #store_method
def test_next_method
end #next_method
def setup
	ActiveSupport::TestCase::fixtures :stream_method_arguments
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #def
def test_id_equal
	assert_fixture_name(@@table_name)
	assert(!@model_class.sequential_id?, "@model_class=#{@model_class}, should not be a sequential_id.")
	assert_instance_of(Hash, fixtures(@@table_name))
	assert_instance_of(Array, @@my_fixtures)
	@@my_fixtures=fixtures(@@table_name)
	assert_instance_of(Hash, @@my_fixtures)
	if @model_class.sequential_id? then
	else
		fixtures(:stream_method_arguments).each_pair do |key, ar_from_fixture|
			assert(Fixtures::identify(key), ar_from_fixture.id)
			puts "'#{key}', #{ar_from_fixture.id}"
		end #each
		@@my_fixtures.each_pair do |key, ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.class.logical_primary_key.inspect}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label(#{key}) for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			puts "'#{key}', #{ar_from_fixture.inspect}"
			assert(Fixtures::identify(key), ar_from_fixture.id)
			assert_equal(ar_from_fixture.logical_primary_key_recursive_value.join(','), key.to_s,message)
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_recursive_value),ar_from_fixture.id,message)
		end #each_pair
	end #if
end #id_equal
end #StreamLink

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
class StreamLinkTest < ActiveSupport::TestCase
def setup
	ActiveSupport::TestCase::fixtures :stream_links
	ActiveSupport::TestCase::fixtures :stream_method_arguments
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #def
  # Replace this with your real tests.
test 'association_names' do
  	assert_generic_table('StreamLink')
	assert_equal_sets([:input_stream_method_argument_id,:output_stream_method_argument_id,:store_method_id,:next_method_id], StreamLink.foreign_key_names)
	assert_equal_sets(["output_stream_method_argument", "next_method", "input_stream_method_argument", "store_method"],StreamLink.association_names)
	assert_not_empty(StreamLink.all)
	assert_not_empty(StreamMethodArgument.all)
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
	end #each
end #association_names
test "output_stream_method_argument" do
	assert_equal(@@association_patterns, StreamLink.association_patterns(:output_stream_method_argument))

	assert_foreign_key_name(StreamLink,:output_stream_method_argument_id)
	assert_association(StreamLink, :output_stream_method_argument)
	assert_equal(:to_one,StreamLink.association_to_type(:output_stream_method_argument))
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
test "input_stream_method_argument" do
	assert_equal(@@association_patterns, StreamLink.association_patterns(:input_stream_method_argument))
	assert_foreign_key_name(StreamLink,:output_stream_method_argument_id)
	assert_association(StreamLink, :input_stream_method_argument)
	assert_equal(:to_one,StreamLink.association_to_type(:input_stream_method_argument))
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
		if !sl.association_has_data(:input_stream_method_argument) then
			assert_equal('Input',input_stream_method_argument.where("id=?",sl.input_stream_method_argument_id).first.direction, message)
			assert_equal("",sl.association_state(:input_stream_method_argument))
		end #if
		message="StreamMethodArgument.where('id=?',#{sl.input_stream_method_argument_id})=#{StreamMethodArgument.where('id=?',sl.input_stream_method_argument_id).inspect}, sl.input_stream_method_argument_id=#{sl.input_stream_method_argument_id}, "
		assert_equal('Input',StreamMethodArgument.where("id=?",sl.input_stream_method_argument_id).first.direction, message)
		assert_not_nil(sl.input_stream_method_argument)
	end #
end #input_stream_method_argument
end #class

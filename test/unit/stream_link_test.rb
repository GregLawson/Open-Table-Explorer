###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'

class StreamLinkTest < ActiveSupport::TestCase
  # Replace this with your real tests.
test 'association_names' do
  	assert_generic_table('StreamLink')
	assert_equal_sets([:input_stream_method_argument_id,:output_stream_method_argument_id,:store_method_id,:next_method_id], StreamLink.foreign_key_names)
	assert_equal_sets(["output_stream_method_argument", "next_method", "input_stream_method_argument", "store_method"],StreamLink.association_names)
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
		assert_equal([],StreamMethodArgument.where("id=?",sl.output_stream_method_argument_id))
		assert_equal("",sl.association_state(:output_stream_method_argument))
		assert_not_nil(sl.output_stream_method_argument)
		assert_not_empty(sl.output_stream_method_argument.exists?)
	end #each
end #output_stream_method_argument
test "input_stream_method_argument" do
	assert_equal(@@association_patterns, StreamLink.association_patterns(:input_stream_method_argument))
	assert_foreign_key_name(StreamLink,:output_stream_method_argument_id)
	assert_association(StreamLink, :input_stream_method_argument)
	assert_equal(:to_one,StreamLink.association_to_type(:input_stream_method_argument))
	StreamLink.find(:all).each do |sl|	
		assert_not_nil(sl)
		assert_not_nil(StreamMethodArgument.where("id=?",sl.input_stream_method_argument_id))
		assert_equal([],StreamMethodArgument.where("id=?",sl.input_stream_method_argument_id))
		assert_equal("",sl.association_state(:input_stream_method_argument))
		assert_not_nil(sl.input_stream_method_argument)
		assert_not_empty(sl.input_stream_method_argument.exists?)
	end #
end #input_stream_method_argument
end

###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class StreamMethodCallTest < ActiveSupport::TestCase
set_class_variables
def test_stream_links
	streamCall=StreamMethodCall.first
	assert_equal(64810937,streamCall.id)
	assert_equal_sets(["stream_method","stream_links"], StreamMethodCall.association_names)
	assert_equal('', StreamLink.all)
	assert_equal('', streamCall)
	assert_not_empty(streamCall.stream_links)
	StreamMethodCall.find(:all).each do |smc|
		assert_not_empty(smc.stream_links)
	end #each
end #stream_links
def test_inputs
	StreamMethodCall.find(:all).each do |smc|
		assert(smc.inputs.exists?,"smc=#{smc.inspect}, smc.stream_links=#{smc.inputs.inspect} ")
	end #each
end #inputs
def test_outputs
end #outputs
def test_fire
	StreamMethodCall.find(:all).each do |smc|
		smc.fire
	end #each
end #fire
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #id_equal
end #StreamMethodCall

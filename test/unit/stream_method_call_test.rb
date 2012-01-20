###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class StreamMethodCallTest < ActiveSupport::TestCase
  # Replace this with your real tests.
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
end #StreamMethodCall

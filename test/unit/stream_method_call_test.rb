###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class StreamMethodCallTest < ActiveSupport::TestCase
  # Replace this with your real tests.
def test_stream_links
	StreamMethodCall.find(:all).each do |smc|
		assert(smc.inputs.exists?,"smc=#{smc.inspect}, smc.stream_links=#{smc.inputs.inspect} ")
	end #each
end #stream_links
def test_EEG
	streamCall=StreamMethodCall.first
	assert_equal(64810937,streamCall.id)
	assert_equal_sets(["stream_method","stream_links"], StreamMethodCall.association_names)
	assert_equal("695672806",StreamPattern.find_by_name('Acquisition').id.inspect)
	assert_equal('File',StreamMethod.find_by_name('File').name)
	assert_equal('Acquisition',StreamPatternArgument.where("name='Acquisition'").name)
#	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
	assert_equal('File',StreamMethod.first.name)
  end
def test_fire
	StreamMethodCall.find(:all).each do |smc|
		smc.fire
	end #each
end #find
end #fire

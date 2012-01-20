###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class EEGTest < ActiveSupport::TestCase

def test_initialize
end #initialize
def test_all
end #all
def test_EEG
	file=Url.where("href='EEG2'").first.url
	assert_not_empty(file)
	assert_equal("695672806",StreamPattern.find_by_name('Acquisition').id.inspect)
	assert_equal('File',StreamMethod.find_by_name('File').name)
	streamCall=StreamMethodCall.first
	assert_equal(64810937,streamCall.id)
	assert_equal_sets(["stream_method","stream_links"], StreamMethodCall.association_names)
	assert()
	assert_equal('Acquisition',StreamPatternArgument.where("name='Acquisition'").first[:name])
#	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
end
end #EEG

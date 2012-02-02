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
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
fixtures @@table_name.to_sym
def test_initialize
end #initialize
def test_all
	assert_include('href', Url.column_names)
	file=Url.first.url
	assert_not_empty(file)
	assert_not_empty(Url.where("href='EEG2'"),"Url.all=#{Url.all.inspect}")
	assert_not_nil(Url.where("href='EEG2'").first)
	assert_not_empty(Url.where("href='EEG2'").first.url)
	file=Url.where("href='EEG2'").first.url
	assert_not_empty(file)
	assert_equal('File',StreamMethod.find_by_name('File').name)
end #all
def test_associations
	assert_equal("695672806",StreamPattern.find_by_name('Acquisition').id.inspect)
	streamCall=StreamMethodCall.first
	assert_equal(64810937,streamCall.id)
	assert_equal_sets(["stream_method","stream_links"], StreamMethodCall.association_names)
	assert_equal('Acquisition',StreamPatternArgument.where("name='Acquisition'").first[:name])
#	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
end #test_associations
end #EEG

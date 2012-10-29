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
class BatteryTest < ActiveSupport::TestCase
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
#nodb fixtures @@table_name.to_sym
def test_initialize
end #initialize
def test_all
end #all
def test_Battery
	assert_include('href', Url.column_names)
	assert_not_nil(Url.where("href='EEG2'"))
	assert_not_nil(Url.where("href='EEG2'").first)
	file=Url.where("href='EEG2'").first.url
	assert_not_empty(file)
	assert_equal('File',StreamMethod.find_by_name('File').name)
	streamCall=StreamMethodCall.first
	assert()
	assert_equal('Acquisition',StreamPatternArgument.where("name='Acquisition'").first[:name])
#	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
end #Battery
end #BatteryTest

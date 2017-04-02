###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class BatteryTest < TestCase
  @@test_name = name
  @@model_name = @@test_name.sub(/Test$/, '').sub(/Controller$/, '')
  @@table_name = @@model_name.tableize
  # nodb fixtures @@table_name.to_sym
  def test_initialize
  end # initialize

  def test_all
  end # all

  def test_Battery
    assert_includes('href', Url.column_names)
    refute_nil(Url.where("href='EEG2'"))
    refute_nil(Url.where("href='EEG2'").first)
    file = Url.where("href='EEG2'").first.url
    refute_empty(file)
    assert_equal('File', StreamMethod.find_by_name('File').name)
    streamCall = StreamMethodCall.first
    assert
    assert_equal('Acquisition', StreamPatternArgument.where("name='Acquisition'").first[:name])
    #	assert_equal([],StreamMethodArgument.where("stream_pattern='Acquisition'").name)
  end # Battery
end # BatteryTest

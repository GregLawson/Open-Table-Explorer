###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative 'test_environment.rb'
class BatteryMeasurementTest < TestCase
  def test_initialize
  end # initialize

  def test_all
    records = model_class?.all
    refute_empty(records)
    assert_instance_of(Array, records)
    assert_kind_of(Hash, records.first)
    BatteryMeasurement.all.each do |r|
      assert_instance_of(Hash, r)
    end # each
  end # all

  def test_dump
    BatteryMeasurement.dump
  end # test_dump
end # BatteryTest

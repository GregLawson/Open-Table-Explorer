###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/battery_type.rb'
class BatteryTypeTest < TestCase
  def test_initialize
  end # initialize

  def test_standardize_keys
    assert_equal([:Size, :Chemistry, :Brand, :Rated_capacity_mAh].sort, BatteryType.all[0].standardize_keys?.keys.sort)
  end # standardize_keys!

  def test_all
    records = model_class?.all
    refute_empty(records)
    assert_instance_of(Array, records)
    assert_kind_of(BatteryType, records.first)
    BatteryType.all.each do |r|
      assert_instance_of(BatteryType, r)
    end # each
  end # all

  def test_chemistries
    BatteryType.all.map do |r|
      assert_kind_of(BatteryType, r)
      assert_instance_of(BatteryType, r)
      refute_nil(r)
      refute_nil(r[:Chemistry], r)
    end # map
    assert_equal(['NiMH', 'NiCd', 'NiMH low self-discharge'], BatteryType.chemistries)
  end # chemistries

  def test_brands
    assert_equal(['Duracell', 'Kenwood', 'NEXcell', 'Panasonic', 'PowerRock', 'SAFT America', 'Sony', 'Spike', 'Power2000', 'Sanyo', 'energyON', 'Chicago Electric', 'Sanyo Cadalca', 'SAFT America-Nicad Brand', 'SAFT America-Infinity Brand'], BatteryType.brands)
  end # brands

  def test_form_factors
    assert_equal(%w(AA AAA C D), BatteryType.form_factors)
  end # form_factors

  def test_get_field_names
    assert_equal([:Size, :Chemistry, :Brand, :Rated_capacity_mAh].sort, BatteryType.get_field_names.sort)
  end # field_names

  def test_logical_primary_key
  end # logical_primary_key
end # BatteryType

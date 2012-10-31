###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
class BatteryTypeTest < ActiveSupport::TestCase
set_class_variables
def test_initialize
end #initialize
def test_all
	records=@@model_class.all
	assert_not_empty(records)
	assert_instance_of(Array, records)
	assert_kind_of(Hash, records.first)
	BatteryType.all.each do |r|
		assert_instance_of(Hash, r)
	end #each
end #all
def test_get_field_names
	assert_equal(["Size", "Chemistry", "Brand", "Rated_capacity_mAh"], BatteryType.get_field_names)
end #field_names
def test_logical_primary_key
end #logical_primary_key
end #BatteryType

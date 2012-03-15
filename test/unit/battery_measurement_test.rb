###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
class BatteryMeasurementTest < ActiveSupport::TestCase
set_class_variables
def test_initialize
end #initialize
def test_all
	records=@@model_class.all
	assert_not_empty(records)
	assert_instance_of(Array, records)
	assert_kind_of(Hash, records.first)
	BatteryMeasurement.all.each do |r|
		assert_instance_of(Hash, r)
	end #each
end #all
end #BatteryTest

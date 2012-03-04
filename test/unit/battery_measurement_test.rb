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
end #all
def test_column_symbols
	assert_include('sample', BatteryMeasurement.methods)
	wanted_columns=[:multimeter_id, :id, :created_at, :updated_at, :load_current_ma, :battery_id, :load_current_mA, :voltage, :status, :closed_circuit_current_ma]
	column_names=@@model_class.column_symbols
	assert_equal([], column_names-wanted_columns, "Unwanted columns:")
end #column_symbols
end #BatteryTest

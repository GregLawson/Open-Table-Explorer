###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
class BatteryMeasurement
include NoDB
def self.all
	fixtures = YAML::load( File.open( 'test/data_sources/battery_measurements.yml' ) )
	fixtures.values #map
end #all
def self.sample(samples_wanted=100, sample_type=:first)
	size=all.size
	samples_returned=[samples_wanted, size].min
	case sample_type
	when :first
		return all[0..samples_returned-1]
	when :last
		return all[size-samples_returned..size-1]
	when :random
		return all[0..samples_returned-1]
	when :stratified
		return all[0..samples_returned-1]
	else
		raise "Unknown sample type=#{sample_type}. Expected values are :sequential, :random, :stratified"
	end #case
end #sample
def self.columns_present
	column_names=sample.map do |r|
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
end #columns_present
def self.column_remap
end #column_remap
end #BatteryMeasurement
class BatteryMeasurementTest < ActiveSupport::TestCase
set_class_variables
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
def test_initialize
end #initialize
def test_all
end #all
def test_Battery_Measurement
	records=@@model_class.all
	wanted_columns=[:multimeter_id, :id, :created_at, :updated_at, :load_current_ma, :battery_id, :load_current_mA, :voltage, :status, :closed_circuit_current_ma]
	column_names=@@model_class.columns_present
	assert_equal([], column_names-wanted_columns, "Unwanted columns:")
end #Battery
end #BatteryTest

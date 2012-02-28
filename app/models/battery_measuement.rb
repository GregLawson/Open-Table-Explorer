###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class BatteryMeasurement
include NoDB
def self.all
	fixtures = YAML::load( File.open('test/data_sources/battery_measurements.yml' ) )
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

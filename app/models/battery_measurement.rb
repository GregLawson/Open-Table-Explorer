###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class BatteryMeasurement
include NoDB
extend NoDB::ClassMethods
def self.all
	fixtures = YAML::load( File.open('test/data_sources/battery_measurements.yml' ) )
	fixtures.values #map
end #all
def self.column_symbols
	column_names=sample.map do |r|
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
end #column_symbols
def self.column_remap
end #column_remap
end #BatteryMeasurement

###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class BatteryType
include NoDB
extend NoDB::ClassMethods
def self.all
	data_source_yaml.values #map
end #all
MAX_CONFIRMATIONS=10
def self.logical_primary_key
	matches=Array.new()
	data_source_yaml.each_pair do |composite_key, record|
		matches=matches&composite_key.split(',').map do |key|
			record.split(',').map {|field| feild==key}
		end #map
		
	end # each_pair
end #logical_primary_key
def self.column_remap
end #column_remap
end #BatteryType

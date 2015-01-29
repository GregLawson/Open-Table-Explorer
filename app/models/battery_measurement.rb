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
	data_source_yaml.values #map
end #all
def self.column_remap
end #column_remap
end #BatteryMeasurement

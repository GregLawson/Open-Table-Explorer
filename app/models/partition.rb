###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class Partition
include NoDB
extend NoDB::ClassMethods
def self.all
return `cat /proc/partitions`

end #all
def self.column_symbols
	[:major, :minor, :blocks, :device]
end #column_symbols
def self.column_remap
end #column_remap
end #BatteryMeasurement

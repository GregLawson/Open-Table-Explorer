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
	url=Url.find_by_name('partitions')
	stream_method=url.stream_method
	stream_method[:uri]=url.url
	stream_method.compile!
	stream_method.fire!
	acquisition=stream_method[:acquisition]
	line_parser=GenericType.find_by_name('bug'+',row')
	line_parser.match?(acquisition)
	
end #all
def self.column_symbols
	[:major, :minor, :blocks, :device]
end #column_symbols
def self.column_remap
end #column_remap
end #BatteryMeasurement

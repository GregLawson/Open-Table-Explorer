###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class AcquisitionInterface < ActiveRecord::Base
has_many :acquisition_stream_specs
def logical_primary_key
	return :acquisition_name
end #def
def scheme
	if self[:name].nil? then
		return ''
	else
		return self[:name].downcase
	end #if
end #def
def acquisition_class_name
	return "#{self[:name]}_Acquisition"
end # def
def urls_by_scheme
	@acquisition_stream_specs=AcquisitionStreamSpec.all
	@acquisition_stream_specs.select do |acquisition_stream_spec|
		acquisition_stream_spec.schemeFromInterface == scheme 
	end # select
end #def
end # class

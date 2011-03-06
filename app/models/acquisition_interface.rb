###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'global.rb'
class AcquisitionInterface < ActiveRecord::Base
has_many :acquisition_stream_specs, :class_name => "AcquisitionStreamSpec"
include Global
def scheme
	return self[:name].downcase
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

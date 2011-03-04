###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'global.rb'
class AcquisitionInterface < ActiveRecord::Base
has_many :acquisition_stream_specs, :class_name => "Acquisition_Stream_Spec"
include Global
def URI(component)
	self[:uri].select(component)
end #end
def acquire
	@previousAcq=self[:acquisition_data] # change detection
	@uri=URI.parse(URI.escape(self[:url]))	
#	puts "self[:url].inspect=#{self[:url].inspect}"
	self[:acquisition_data]=`#{schemelessUrl} 2>&1`
	if $?==0 then
		self[:error]=nil
	else
		self[:error]=self[:acquisition_data]
		self[:acquisition_data]=nil
	end
	return self
rescue Exception => e
 	self[:error]= "Exception: " + e.inspect + "couldn't acquire data from #{url}"
	return self
else
	self[:error]= "Not subclass of Exception: " + "couldn't acquire data from #{url}"
	return self
end #def
def parsedURI
	return URI.split(URI.escape(self[:url]))
end #def
def schemelessUrl
	return URI.unescape(URI.escape(self[:url]).split(':').last)
end #def
def acquisitionDuplicated?(acquisitionData=self[:acquisition_data])
	return @previousAcq==acquisitionData
end #def
def acquisitionUpdated?(acquisitionData=self[:acquisition_data])
	if	acquisitionData.nil?  || acquisitionData.empty? then
		acquisition_updated= false
	elsif @previousAcq.nil? || @previousAcq.empty? then
		acquisition_updated= true
	else
		acquisition_updated= @previousAcq!=acquisitionData
	end
	self[:acquisition_updated]=acquisition_updated
	return acquisition_updated
end #def
end # class

###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'generic.rb'
require 'webBox.rb'
require 'weather.rb'
class Monitor
include Acquisition

def self.csvParse
	s=StringScanner.new(data)
	s.scan(@ga.table_start)
	s.scan(@ga.row_start)
	@row_data=s.scan_until(@ga.row_end)
	s.scan(@ga.table_end)
end
def self.reportNull(variableHash)
	ret=Array.new
	variableHash.each_pair do |key,value|
		if value.nil? then
			puts "#{key} has nil value."
		end
	end
	return ret
end
def self.mon
genParams=Generic_Acquisitions.all(:conditions =>{:model_class=>'MULTIPLE_WEATHER'})  
puts "genParams.inspect=#{genParams.inspect}" if $VERBOSE
genParams.each do |g|
#	g.acquisition_class=eval(g.acquisition_class)
#	g.parse_class=eval(g.parse_class)
	classDef="class #{g.model_class} < ActiveRecord::Base
		include #{g.acquisition_interface}
		include #{g.parse_interface}
		#include Multi_Model
		self.constrainSleepInterval
		end # module
		"
	eval(classDef)
	puts "classDef=#{classDef}"
	classRef=eval(g.model_class)
	classRef.init
	acquisitionData=classRef.acquisitions
	puts "acquisitionData.inspect=#{acquisitionData.inspect}" #if $VERBOSE
	variableHashes=classRef.parses(acquisitionData)
	classRef.updates(variableHashes)
#	puts whoAmI(classRef)
	ad=classRef.acquire(g.url)
	variableHash=classRef.parse(ad,g.tree_walk)
	puts "variableHash['observation_time_rfc822']=#{variableHash['observation_time_rfc822']}"
	reportNull(variableHash)
	puts "variableHash.inspect=#{variableHash.inspect}" if $VERBOSE
	if !g.prefix.empty? then
		variableHash=addPrefix(variableHash,g.prefix.downcase)
	end
	puts "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}"
	reportNull(variableHash)
	variableHash=classRef.onlyInModel(variableHash)
	puts "after prefix variableHash.inspect=#{variableHash.inspect}" #if $VERBOSE
# 	if row.has_attribute?(attrName) then
# 	end
	puts "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}"
	reportNull(variableHash)
	if classRef.exists?(variableHash) then
		puts "record already exists"
	else
		row=classRef.new
		puts "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}"
		reportNull(variableHash)
		row.update_attributes(variableHash)
	
		now=Time.new
		if row.has_attribute?('created_at') then
			row.update_attribute("created_at",now)
		end
		if row.has_attribute?('updated_at') then
			row.update_attribute("updated_at",now)
		end
	#update_attribute("id","NULL") 
	end
	end # each
puts "genParams.inspect=#{genParams.inspect}" if $VERBOSE
end #def
end #class
Monitor.mon
#TEDWebBoxFull.log

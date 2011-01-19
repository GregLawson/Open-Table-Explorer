###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'generic.rb'
require 'global.rb'
require 'model.rb'
require 'ga.rb'
require 'acquire.rb'

def acquire_all
	loop do # forever
		model=Table_spec.nextAcquisition
		print "Scheduling #{model.model_class_name}"
		acquisitionData=model.acquire
		Global::log.debug("acquisitionData.inspect=#{acquisitionData.inspect}")
		urls=model.urls
		acquisitionData.each  do |ad|
			ad.save
			puts
			puts "ad.created_at=#{ad.created_at}"
			puts "ad.errors.inspect=#{ad.errors.inspect}"
		end
		puts " "+model.sleepRange
		model.initializeState
		model.updateSleepInterval
	end
end #def
acquire_all
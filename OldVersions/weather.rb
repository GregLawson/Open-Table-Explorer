#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
# 
#   You should have received a copy of the GNU Lesser General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
require 'generic.rb'
module WEATHER 
 mixin_class_methods { |klass|
 puts "Module WEATHER has been included by #{klass}" if $VERBOSE
 }
include HTTP_Acquisition
include XML_Parse
URL_Base='http://www.weather.gov/xml/current_obs'

define_class_methods {
def acquireSite(site='KLAX')
		puts "WEATHER.acquire called"
	acquisitionData=acquire("#{URL_Base}/#{site.upcase}.xml")
	names,values = xmlParse(acquisitionData,'*/*')
	#puts "names=#{names}"
	#puts "values=#{values}"
	names.collect! do |n|
		"#{site}_#{n}"
	end
	names.each_index do |i|
		update_attribute(names[i],values[i])
	end
end
def dontIgnore(column)
	if @@IGNORE_COLUMNS.include?(column) then
		return false
	else
		return true # default to report everything
	end
end
} #class methods

end

class MULTIPLE_WEATHER < ActiveRecord::Base
include WEATHER
@@IGNORE_COLUMNS=['klax_privacy_policy_url',
'khhr_credit',
'khhr_credit_URL',
'khhr_image',
'khhr_suggested_pickup',
'khhr_suggested_pickup_period',
'khhr_location',
'khhr_station_id',
'khhr_latitude',
'khhr_longitude',
'khhr_observation_time',
'khhr_icon_url_base',
'khhr_two_day_history_url',
'khhr_icon_url_name',
'khhr_ob_url',
'khhr_disclaimer_url',
'khhr_copyright_url',
'khhr_privacy_policy_url',
'klax_credit',
'klax_credit_URL',
'klax_image',
'klax_suggested_pickup',
'klax_suggested_pickup_period',
'klax_location',
'klax_station_id',
'klax_latitude',
'klax_longitude',
'klax_observation_time',
'klax_icon_url_base',
'klax_two_day_history_url',
'klax_icon_url_name',
'klax_ob_url',
'klax_disclaimer_url',
'klax_copyright_url',
'klax_credit_url',
'khhr_credit_url'
]
# def initialize
# 	super("weathers","khhr_observation_time_rfc822")
# end
end # class 

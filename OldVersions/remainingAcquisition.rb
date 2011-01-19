#!/usr/bin/ruby
#   Copyright (C) 2009  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
require 'net/http'
require 'uri'
require 'pg'
require 'rexml/document'
require 'table.rb'
#require 'weather.rb'
require 'sunnywebbox.rb'
#require 'network.rb'
#networks=Networks.new
db=DB.new
#weather=MULTIPLE_WEATHER.new

dailyDone=false

wbFTP=WebBoxHistory.new

#weather.pollWeather
#	wbFTP.WebBoxFTP2DB('/media/iomega1/Database/energy/WebBox History Download/2009-09-16.csv')
require 'net/ftp'
class FTP_Acquisition  <  Net::FTP
def initialize(ftpSite,user,password)
	super(ftpSite)
	login(user, password)
rescue SocketError => e
 	puts "SocketErrorr: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
	return ""
rescue Timeout::Error => e:
 	puts "Timeout::Error: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
	return ""
rescue Errno::EHOSTUNREACH => e
	puts "Errno::EHOSTUNREACH: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
	return ""
rescue Errno::ENETUNREACH => e
	puts "Errno::ENETUNREACH: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
	return ""
rescue Errno::ECONNREFUSED => e
	puts "Errno::ECONNREFUSED: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
	return ""
rescue Errno::ETIMEDOUT => e
	puts "Errno::ETIMEDOUT: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
rescue Errno::ECONNRESET => e
 	puts "Errno::ECONNRESET: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
rescue EOFError => e
 	puts "EOFError: " + e.to_s
	puts "couldn't get data from #{ftpSite}"
end
end

 while true do
	now=Time.new
	if now.hour > 20 then # kludge for solar sunset
		if not dailyDone then
			ftp = FTP_Acquisition.new('192.168.3.136','User', 'sma')
			ftp.chdir('DATA')
			years = ftp.list('*')
			now=Time.new
			year=now.year
			month=now.month
			day=now.day
			ftp.chdir(year.to_s)
			files = ftp.list('*')
			puts files  if $DEBUG
			todaysFile="#{year}-#{format("%02d",month)}-#{format("%02d",day)}.csv"
			puts todaysFile  if $VERBOSE
			ftp.getbinaryfile(todaysFile)
			ftp.close
			wbFTP.WebBoxFTP2DB(todaysFile)
			dailyDone=true
		else
			sleep 60
		end
	 else if now.hour>6 then # kludge for solar sunrise
		dailyDone=false
	end
	if now.min == 15 and now.sec <5 then # better if based on suggested_pickup field (which is currently ignored)
	#if true then
#		weather.pollWeather		
	end
#    networks.acquire
    sleep 1
  end

end # extraneous for debugging			


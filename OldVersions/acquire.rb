###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'ModTest.rb'
require "rubygems"
require 'net/http'
require 'uri'
require 'global.rb' #for logging
class Acquisition  < ActiveRecord::Base
validates_presence_of :acquisition_data, :if => "error.nil?"
validates_presence_of :url
include Global
def URI(component)
	self[:uri].select(component)
end #end
def acquire
	@previousAcq=self[:acquisition_data] # change detection
	self[:acquisition_data] =nil # reinitialize
	@uri=URI.parse(URI.escape(self[:url]))	
	Global::log.info("parsedURI.inspect=#{parsedURI.inspect}")
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

class Shell_Acquisition < Acquisition
def acquire
	super
#	puts "self[:url].inspect=#{self[:url].inspect}"
	Global::log.info("schemelessURI=#{schemelessUrl}")
	self[:acquisition_data]=`#{schemelessUrl} 2>&1`
	if $?==0 then
		self[:error]=nil
	else
		self[:error]=self[:acquisition_data]
		self[:acquisition_data]=nil
	end
	Global::log.info("self[:acquisition_data]=#{self[:acquisition_data]}")
	return self
end
end # class Shell_Acquisition
class Remote_Acquisition < Acquisition

  def streamEnd
	return false
end
end
class HTTP_Acquisition < Remote_Acquisition
def acquire
	super
	self[:acquisition_data]= Net::HTTP.get(@uri)
	Global::log.debug("self[:acquisition_data]=#{self[:acquisition_data]}")
	return self
rescue SocketError => e
 	self[:error]= "SocketError: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Timeout::Error => e:
 	self[:error]= "Timeout::Error: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Errno::EHOSTUNREACH => e
	self[:error]= "Errno::EHOSTUNREACH: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Errno::ENETUNREACH => e
	self[:error]= "Errno::ENETUNREACH: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Errno::ECONNREFUSED => e
	self[:error]= "Errno::ECONNREFUSED: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Errno::ETIMEDOUT => e
	self[:error]= "Errno::ETIMEDOUT: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue Errno::ECONNRESET => e
 	self[:error]= "Errno::ECONNRESET: " + e.inspect + "couldn't get data from #{url}"
	return self
rescue EOFError => e
 	self[:error]= "EOFError: " + e.inspect + "couldn't get data from #{url}"
	return self
end
end # class
class Wget_Acquisition < Remote_Acquisition
end
class File_Acquisition < Acquisition
 def acquire
	super
	open(schemelessUrl) do |f|
		self[:acquisition_data]=f.gets(nil)
   end
	Global::log.debug("self[:acquisition_data]=#{self[:acquisition_data]}")
	return self
end

end #class

class SunnyWebBox_Acquisition < Remote_Acquisition
ip='192.168.3.137'
User='User' # 'installer'
Password='sma'
Host_URL= "http://#{User}:#{Password}@#{ip}"

#URL= "http://#{User}:#{Password}@#{ip}/login"
UserAgent='Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.10 (like Gecko) (Debian)'
WgetHeaders="--user-agent='#{UserAgent}' --referer='http://#{ip}/home.htm' --header='Accept: text/html, image/jpeg, image/png, text/*, image/*, */*' --header='Accept-Encoding: x-gzip, x-deflate, gzip, deflate' --header='Accept-Charset: utf-8, utf-8;q=0.5, *;q=0.5' --header='Accept-Language: en'  --no-cache --header='Cache-control: no-cache'"
CookieControl='' #'--keep-session-cookies --save-cookies="cookies.txt"'
def acquire
	super
	url= "#{schemelessUrl}/login"
	ret=system("wget -q -r  #{WgetHeaders} --user=\"#{User}\" --password=\"#{Password}\" #{CookieControl} --post-data='Language=en&Password=#{Password}&ButtonLogin=Login'  \"#{url}\"")
	Global::log.info("login return=#{ret}")
	ret2=system("grep essage #{schemelessUrl}/login")
	if !ret then
		
		ret3=system("wget -r #{WgetHeaders} --user=\"#{User}\" --password=\"#{Password}\" #{CookieControl} --post-data='Language=en&Password=#{Password}&ButtonLogin=Login'  \"#{url}\"")
		self[:acquisition_data]="LOGIN_ERROR"		
		return self
	end
	ret=system("wget -q -O data/plant_current.htm \"http://User:sma@#{schemelessUrl}/plant_current.htm?DevKey=WR40U08E:2000673163&DevClass=Sunny%20Boy\"")
	Global::log.info("plant return=#{ret}")
	if !ret then
		self[:acquisition_data]="PLANT_ERROR"		
		return self
	end
	ret=system("wget -q -O data/current_values.ajax http://#{schemelessUrl}/current_values.ajax") 
	Global::log.info("current return=#{ret}")
	if !ret then
		raise RuntimeError ,"current error on #{schemelessUrl}"
	end
	@@file=File.open('data/current_values.ajax', "r")
#	@@file=File.open('../data/current_values.ajax', "r")
	self[:acquisition_data]= @@file.gets
	Global::log.info("self[:acquisition_data]=#{self[:acquisition_data]}")
	return self
end
def acquisitionUpdated?(acquisitionData=self[:acquisition_data])
	if acquisitionData =='NOT_MODIFIED' then
		return false
	elsif acquisitionData=='ABORT'
		return false
	elsif acquisitionData=='LOGIN_ERROR'
		return false
	elsif acquisitionData=='PLANT_ERROR'
		return false
	elsif acquisitionDuplicated?
		return false
	else
		return true
	end
end #def
end # class


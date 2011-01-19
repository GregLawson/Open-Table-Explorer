#!/usr/bin/ruby
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
require 'net/http'
require 'uri'
require 'pg'
require 'mathn.rb'
require 'table.rb'
require 'TED.rb'
require 'sunnywebbox.rb'
class TED_with_WebBox < TED
@@MIN_SOLAR_NOISE=9
def initialize
@production=Production.new
super # initialize TED
end

def acquire
	super # acquire from TED
	if Time.now.hour>6 and Time.now.hour < 20 then
    		update_attribute("production",@production.pollWebBox)
	else
    		update_attribute("production",0)
	end
	#puts "end of aquire in TED_with_WebBox"
rescue IOError => e
 	puts "IOError: " + e.to_s
rescue Timeout::Error => e
 	puts "Timeout::Error: " + e.to_s
end
def explainOutlier
	super
	@sum= @data["total_powernow"].to_i+ @data["production"].to_s.to_f
	@difference= -@data["total_powernow"].to_i + @data["production"].to_s.to_f
	#puts "@sum=#{@sum} @difference=#{@difference}"
	if plausible_values(@data) > 0 then
		#puts "@data['total_powernow'].to_s.to_f=#{@data['total_powernow'].to_s.to_f}"
		#puts "@sum=#{@sum} @difference=#{@difference}"
		#puts "@data['total_kva'].to_s.to_f=#{@data['total_kva'].to_s.to_f}"
		#puts "reactive power=#{@data['total_kva'].to_s.to_f-@data['total_powernow'].to_s.to_f}"
	end
end
def computeConsumption
	tedPower,reactivePower,noise=super
	#puts "before @sum,difference"
	# resolve net metering ambiguity
	#puts "@data['production'].to_s.to_f=#{@data['production'].to_s.to_f}"
	@sum= tedPower+ @data["production"].to_s.to_f
	@difference= -tedPower + @data["production"].to_s.to_f
	#puts "@sum=#{@sum} @difference=#{@difference}"
	if @difference < 0 then
		#puts "@difference < 0"
		@data["sign"]=true
	elsif @sum > @@MAX_TED then
		#puts "sum over max"
		@data["sign"]=false
	elsif @previous.empty? then
		if (@sum-1000.0).abs < (@difference-1000.0).abs then
			#puts "sign by prediction"
			@data["sign"]=true
		else
			#puts "else by prediction"
			@data["sign"]=false
		end	
	elsif (@sum-@previous["prediction"] ).abs < (@difference-@previous["prediction"] ).abs
		#puts "sign by prediction"
		@data["sign"]=true
	else
		#puts "else by prediction"
		@data["sign"]=false
	end
	#puts "sign defined"
	if @data["sign"] then
		@consumption=@sum
	else
		#puts "consumption=difference"
		@consumption=@difference
	end
	return [@consumption,reactivePower,noise]
end
def noiseFloored(noise)
	if noise.to_f<@@MIN_SOLAR_NOISE then # quantization noise doesn't average out
		return @@MIN_SOLAR_NOISE # guess minimum noise
	else
		return noise
	end
end
def compute
	super # compute TED only	

end
def printLog
	super # common fields
end


end

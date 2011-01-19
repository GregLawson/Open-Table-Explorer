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
require 'mathn.rb'
require 'table.rb'
require 'TED.rb'
#require 'sunnywebbox.rb'
#require 'TED_with_WebBox.rb'
class NetMetering

def initialize
@tedWithWebBox = TED.new
@retrieval = TED.new
end
def pollTED
	@tedWithWebBox.acquire
        #@tedWithWebBox.dumpAcquisitions
	#@tedWithWebBox.sqlValues=@tedWithWebBox.hash2values(@tedWithWebBox.data)
        #@tedWithWebBox.dump(@tedWithWebBox.sqlValues)
	@tedWithWebBox.data=@tedWithWebBox.values2hash(@tedWithWebBox.sqlValues) 
        #@tedWithWebBox.dumpAcquisitions
	#@tedWithWebBox.compute
#	@tedWithWebBox.printLog
#	print "%5.1f%"%(100*@powerFactor)
#	print "\n"
	@tedWithWebBox.sqlValues=@tedWithWebBox.hash2values(@tedWithWebBox.data)
        #@tedWithWebBox.dumpAcquisitions
	@tedWithWebBox.save
	#@retrieval.recalculate(@tedWithWebBox.flooredSleepInterval,"id>0")
end
end
trap("INT") do 
   puts "got signal INT from control-C, exiting" 
   exit
 end 
db=DB.new
netmetering = NetMetering.new
  while true do
    netmetering.pollTED
  end


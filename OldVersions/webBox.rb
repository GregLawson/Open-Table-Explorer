#!/usr/bin/ruby
#   Copyright (C) 2009,2010  Gregory Lawson
#  
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation; either version 2.1 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU Lesser General Public License
#   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
#require 'table.rb'
require 'generic.rb'
require 'net/http'
require 'json'
require 'columns.rb'
module SunnyWebBox_Acquisition
 mixin_class_methods { |klass|
 puts "Module SunnyWebBox_Acquisition has been included by #{klass}" if $VERBOSE
 }
include HTTP_Acquisition
include Wget_Acquisition
ip='192.168.3.137'
User='User' # 'installer'
Password='sma'
Host_URL= "http://#{User}:#{Password}@#{ip}"

#URL= "http://#{User}:#{Password}@#{ip}/login"
UserAgent='Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.10 (like Gecko) (Debian)'
WgetHeaders="--user-agent='#{UserAgent}' --referer='http://#{ip}/home.htm' --header='Accept: text/html, image/jpeg, image/png, text/*, image/*, */*' --header='Accept-Encoding: x-gzip, x-deflate, gzip, deflate' --header='Accept-Charset: utf-8, utf-8;q=0.5, *;q=0.5' --header='Accept-Language: en'  --no-cache --header='Cache-control: no-cache'"
CookieControl='' #'--keep-session-cookies --save-cookies="cookies.txt"'
define_class_methods {
def acquire(ip)
	url= "#{ip}/login"
	ret=system("wget -q -r  #{WgetHeaders} --user=\"#{User}\" --password=\"#{Password}\" #{CookieControl} --post-data='Language=en&Password=#{Password}&ButtonLogin=Login'  \"#{url}\"")
	puts "login return=#{ret}" if $VERBOSE
	ret2=system("grep essage #{ip}/login")
	if !ret then
		
		ret3=system("wget -r #{WgetHeaders} --user=\"#{User}\" --password=\"#{Password}\" #{CookieControl} --post-data='Language=en&Password=#{Password}&ButtonLogin=Login'  \"#{url}\"")
		@acquisitionData="LOGIN_ERROR"		
		return  @acquisitionData
	end
	ret=system("wget -q -O data/plant_current.htm \"http://User:sma@#{ip}/plant_current.htm?DevKey=WR40U08E:2000673163&DevClass=Sunny%20Boy\"")
	puts "plant return=#{ret}" if $VERBOSE
	if !ret then
		@acquisitionData="PLANT_ERROR"		
		return  @acquisitionData
	end
	ret=system("wget -q -O data/current_values.ajax http://#{ip}/current_values.ajax") 
	puts "current return=#{ret}" if $VERBOSE
	if !ret then
		raise RuntimeError ,"current error on #{ip}"
	end
	@@file=File.open('data/current_values.ajax', "r")
#	@@file=File.open('../data/current_values.ajax', "r")
	@acquisitionData= @@file.gets
	puts "@acquisitionData=#{@acquisitionData}" if $VERBOSE
	return @acquisitionData
end
def acquisitionUpdated?(acquisitionData)
	if acquisitionData =='NOT_MODIFIED' then
		return false
	elsif acquisitionData=='ABORT'
		return false
	elsif acquisitionData=='LOGIN_ERROR'
		return false
	elsif acquisitionData=='PLANT_ERROR'
		return false
	elsif dataInvalid?
		return false
	else
		return true
	end
end
}
end # module
module Structure_From_Data
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
define_class_methods {
def updateMaxTypeNum(maxTypeNums)
	adaptiveAcquisition
	values= getValues
	values.each_index do |i|
		maxTypeNums[i]=[Import_Column.firstMatch(values[i]),maxTypeNums.fetch(i,-1)].max
	end
	return   maxTypeNums
end
def sqlForm(s)
	s=Import_Column.unquote(s,'"')
	subs=s.strip.tr(",\s|\.|\n|\-",'_____')
	subs.sub!('_blank_','_')  # Sunny Web Box needs this
	subs.sub!(/_$/,'')  # Sunny Web Box needs this for missing units
	print "#{s}.sub=>#{subs}\n"  if $DEBUG
	return subs.downcase
end
def Column_Definitions
	adaptiveAcquisition
	names=getNames
	puts "names=#{names}" if $DEBUG
	typeNums=[] # make it array, so array functons can be used
        numSamples=0
        begin
        	typeNums=updateMaxTypeNum(typeNums)
        	numSamples = numSamples+1
        end until streamEnd or numSamples>10
	@sqlTypes=[]
	ret=[]
	names.each_index do |i| 
		@sqlTypes.push(Import_Column.row2ImportType(typeNums[i]))
		puts "#{names[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{typeNums[i]}"  if $DEBUG
		ret.push([names[i],@sqlTypes[i]])
		puts "ret=#{ret}" if $DEBUG
	end
	puts "ret=#{ret}" 
	return ret
end
}
end # module
module TED_Parse
 mixin_class_methods { |klass|
 puts "Module TED_Parse has been included by #{klass}" if $VERBOSE
 }
include HTTP_Acquisition
include XML_Parse
define_class_methods {
} # define_class_methods
end # module
module JSON_Parse
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
include Structure_From_Data
define_class_methods {
def alterColumns(defs=self.Column_Definitions)
	defs.each {|c| puts "alter table #{name} add column #{c[0]} #{c[1]}" }
end
def treeWalk(path,depth,subTree,&process)
	# tree nodes can have an array of key,value children
	# or  values 
	# keys or integer inices pick values from arrays
	puts "depth=#{depth}"
	if depth==0 then
		@ancestors=[]
	end
	puts "path.inspect=#{path.inspect}"
	puts "path.class=#{path.class}"
       	subTreeIndex=path.delete_at(0)
	puts "subTreeIndex.inspect=#{subTreeIndex.inspect}"
	puts "subTree.inspect=#{subTree.inspect}"
	if subTree.nil? then
		puts "subTree is nil!"
		return nil
	end
	if subTreeIndex.nil? then  # process all nodes
		subTree.each do |child|
			if path.empty? then
				return process.call(child)
			else
				return treeWalk(path.rest,depth+1,child,&process)
			end
		end
	else # one node
		@ancestors.push(subTree[0])
		return  treeWalk(path,depth+1,subTree[subTreeIndex],&process)
	end
end
def parse(path=[nil], &process)
	puts "path.inspect=#{path.inspect}"
	puts "path.class=#{path.class}"
	if path.nil? or path.empty? then
		path=[nil]
	elsif path.class.name=='String' then
		path=[path]		
	end
	puts "2 path.inspect=#{path.inspect}"
	puts "2 path.class=#{path.class}"
	if dataInvalid? then
		puts "dataInvalid error @acquisitionData=#{@acquisitionData}" #if $DEBUG
		ret=nil
	else
		wholeTree = JSON.parse(@acquisitionData)
		ret=treeWalk(path,0,wholeTree,&process)
        end
        return ret
end
} # define_class_methods
end # module

module SunnyWebBox_Parse
include JSON_Parse
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
define_class_methods {

def getNames
	#acquire
	if dataInvalid? then
		puts "error @acquisitionData=#{@acquisitionData}" #if $DEBUG
	else
		result = JSON.parse(@acquisitionData)
		names=[]
		result['CurrentValues'].each do |j|
			names.push("#{j['Name']}_#{j['Unit']}")
			end
        end
        return names
end

def getValues
	#acquire
	if @acquisitionData.nil? then
		puts "@acquisitionData is nil" #if $DEBUG
	elsif @acquisitionData=="" then
		puts "empty line." if $DEBUG
	else
		puts "in getValues else @acquisitionData=#{@acquisitionData}" if $DEBUG
	end
	if @acquisitionData == 'NOT_MODIFIED' then
		puts "@acquisitionData=#{@acquisitionData}"
	else
		puts "@acquisitionData=#{@acquisitionData}"  if $DEBUG
		result = JSON.parse(@acquisitionData)
		names=[]
		result['CurrentValues'].each do |j|
			names.push("#{j['Value']}")
			end
        end
        return names
end
def dataExamples
	puts "@acquisitionData=#{@acquisitionData}"
	result = JSON.parse(@acquisitionData)

   # if the hash has 'Error' as a key, we raise an error
   if result.has_key? 'Error' then
      raise "web service error"
   else
   	#puts "result=#{result}"
    	puts "result.keys.inspect=#{result.keys.inspect}"
#    	puts "result.keys[0]=#{result.keys[0]}"
#    	puts "result.keys[1]=#{result.keys[1]}"
#    	puts "result.keys[2]=#{result.keys[2]}"
#   	puts "result.values[0]=#{result.values[0]}"
#   	display 'result.keys.inspect'
	cv=result['CurrentValues']
   	puts "cv.collect{|e| e.keys}.uniq.inspect=#{cv.collect{|e| e.keys}.uniq.inspect}"
   	puts "cv.collect{|e| e['Name']}.inspect=#{cv.collect{|e| e['Name']}.inspect}"
   	puts "cv['vacl1_v']=#{cv['vacl1_v']}"
   	puts "cv['vacl1_v'].keys=#{cv['vacl1_v'].keys}"
   	puts "cv['vacl1_v'].values=#{cv['vacl1_v'].values}"
   	puts "cv[1]=#{cv[1]}"
   	puts "cv[1].keys=#{cv[1].keys}"
   	puts "cv[1].values=#{cv[1].values}"
   	puts "cv[1]['Name']=#{cv[1]['Name']}"
   	puts "cv[1]['Value']=#{cv[1]['Value']}"
   	puts "cv[1]['Unit']=#{cv[1]['Unit']}"
   end
end

} # define_class_methods
def parseRow(acquisitionData)
	puts "acquisitionData=#{acquisitionData}" if $DEBUG
	#puts "TEDWebBoxFull.acquisitionData=#{TEDWebBoxFull.acquisitionData}"

	result = JSON.parse(acquisitionData)
	cv=result['CurrentValues']
	#Class.whoAmI(row)
	#puts "row.inspect=#{row.inspect}"
  	
cv.each { |j| update_attribute(self.class.sqlForm("#{j['Name']}_#{j['Unit']}"), j['Value'])}
	return self
end
def printLog
	print "#{'%5.1f'%(vacl1_v-vacl2_v)}V"
	print " #{vacl1_v}V"
	print " + #{vacl2_v}V"
	print " =? #{vac_v}V"
	print " ( #{'%5.1f'%(vacl1_v+vacl2_v-vac_v)})"
	print " #{error}"
	print " #{pac_w}W"
	puts
rescue
	print "printLog error for: "
	puts self.inspect
end # printLog
end # module
module TEDWebBoxFull_Parse
 mixin_class_methods { |klass|
 puts "Module TEDWebBoxFull_Parse has been included by #{klass}" if $VERBOSE
 }
include SunnyWebBox_Parse
include TED_Parse
define_class_methods {

} # class methods
end # module

class TEDWebBoxFull < ActiveRecord::Base
cattr_reader :acquisitionData
include Generic_Table
include SunnyWebBox_Acquisition
include TEDWebBoxFull_Parse
#def self.generic
puts "TEDWebBoxFull class initialization" if $VERBOSE
self.constrainSleepInterval
def self.sqlForm(s)
	s=Import_Column.unquote(s,'"')
	subs=s.strip.tr(",\s|\.|\n|\-",'_____')
	subs.sub!('_blank_','_')  # Sunny Web Box needs this
	subs.sub!(/_$/,'')  # Sunny Web Box needs this for missing units
	print "#{s}.sub=>#{subs}\n"  if $DEBUG
	return subs.downcase
end # def sqlForm
end # module

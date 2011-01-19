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
require 'rexml/document'
require 'db.rb'
require 'columns.rb'

class Finite_Table < Table
def import
	puts "import called" if $DEBUG
	sql="TRUNCATE TABLE #{table_name}"
	errorMessage=DB.execute(sql)	
	startImport
	begin
		acquire
		save
	end until endOfImport?
end
end
class File_Acquisition < Finite_Table
def initialize(tableName,fileName,delimiter,headerLine,primaryKey)
	@fileName=fileName
	@delimiter=delimiter
	@headerLine=headerLine
	@primaryKey=primaryKey
 	puts "File open '#{@fileName}'" if $DEBUG
	@file=File.open(@fileName, "r")
	super(tableName.downcase,primaryKey)  # postgresql defaults to lower case names
	#puts "@sqlNames=#{@sqlNames}"
#	@sqlTyes=getNamesAndTypes
#rescue Errno::ENOENT => error
#	puts "error=#{error.to_s} @fileName=#{@fileName}"
#rescue TypeError => error
#	puts "error=#{error.to_s} @fileName=#{@fileName}"
end
def nextLine
	@line=@file.gets
    @parsed_cells = @line.split(@delimiter)
    puts "#{@parsed_cells.join(',')}" if $DEBUG
    @parsed_cells.each { |c| print c.delete("\177-\377"),","} if $DEBUG
    @parsed_cells = @parsed_cells.collect { |c| Import_Column.unquote(c.delete("\177-\377"),'"')}
    puts "Parsed #{ @parsed_cells.length } cells,delimited by #{"%3d"%@delimiter[0]}."  if $DEBUG
    puts "#{@parsed_cells.join(',')}" if $DEBUG
    return @parsed_cells
end
def getNames
	for i in 1..@headerLine
		@parsed_cells=sqlForm(nextLine)
		#print "header line @parsed_cells=#{@parsed_cells}\n"
	end
	puts "in get Header @parsed_cells=#{@parsed_cells}"  if $DEBUG
	@startData=@file.pos
	return @parsed_cells
end
def getNamesAndTypes
	@sqlNames=getNames
	@sqlTypeNum=[] # make it array, so array functons can be used
	@sqlTypeNum=@sqlTypeNum.fill(-1,@sqlNames.length)
	begin
	@sqlTypes=[]
		@sqlValues= nextLine
		@sqlValues.each_index do |i|
			@sqlTypeNum[i]=[Import_Column.firstMatch(@sqlValues[i]),@sqlTypeNum.fetch(i,-1)].max
		end
	end until @file.eof?
	@sqlNames.each_index {|i| puts "#{@sqlNames[i]} \"#{@sqlValues[i]}\" #{@sqlTypeNum[i]}" } if $DEBUG	
	@sqlNames.each_index do |i| 
		@sqlTypes.push(Import_Column.row2ImportType(@sqlTypeNum[i]))
		puts "#{@sqlNames[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{@sqlTypeNum[i]}"  if $DEBUG
		requireColumn(@sqlNames[i],@sqlTypes[i].class_name) 
		end
	puts "@sqlNames.length=#{@sqlNames.length} @sqlTypes.length=#{@sqlTypes.length} @sqlValues.length=#{@sqlValues.length}" if $DEBUG
end
def startImport
	@file.pos= @startData
end
def endOfImport?
	return @file.eof?
end

def acquire
	@data={}	
	@sqlValues=nextLine
	@sqlValues.collect! do |s| 
		s=s.sub(/\r\s+/,'')
		s=s.sub(/\'/,"''")
		s=s.strip
		#puts "s=#{s}"
		s
	end
	@sqlValues.each_index {|i| @sqlValues[i]= @sqlTypes[i].new(@sqlValues[i])}
	@sqlNames.each_index do |i|
 		#puts "#{@sqlNames[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{@sqlTypeNum[i]}"
		if columnExists(@sqlNames[i]) then
			if @sqlTypes[i]== "VARCHAR(255)" then 
				@sqlValues[i]="'#{@sqlValues[i]}'"
			else
				if @sqlValues[i]=='' then				
					@sqlValues[i]="NULL"
				end	
			end
		else
			puts "#{@sqlNames[i]} not stored because column does not exist."
		end		
 		#puts "#{@sqlNames[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{@sqlTypeNum[i]}"
	end

end
end
module Web_Acquisition
def getIP
res=DB.find_by_sql("select ip from #{table_name}_ip")
@IP=res[0]['ip']
end
def getPage(url)
  puts "url=#{url}" if $VERBOSE
  return Net::HTTP.get(URI.parse(url))
rescue SocketError => e
 	puts "SocketErrorr: " + e.to_s
	puts "couldn't get data from #{url}"
	return ""
rescue Timeout::Error => e:
 	puts "Timeout::Error: " + e.to_s
	puts "couldn't get data from #{url}"
	return ""
rescue Errno::EHOSTUNREACH => e
	puts "Errno::EHOSTUNREACH: " + e.to_s
	puts "couldn't get data from #{url}"
	return ""
rescue Errno::ENETUNREACH => e
	puts "Errno::ENETUNREACH: " + e.to_s
	puts "couldn't get data from #{url}"
	return ""
rescue Errno::ECONNREFUSED => e
	puts "Errno::ECONNREFUSED: " + e.to_s
	puts "couldn't get data from #{url}"
	return ""
rescue Errno::ETIMEDOUT => e
	puts "Errno::ETIMEDOUT: " + e.to_s
	puts "couldn't get data from #{url}"
rescue Errno::ECONNRESET => e
 	puts "Errno::ECONNRESET: " + e.to_s
	puts "couldn't get data from #{url}"
rescue EOFError => e
 	puts "EOFError: " + e.to_s
	puts "couldn't get data from #{url}"
end
end
module XML_Acquisition
include Web_Acquisition
def xmlParse(treePattern='*/*')
	names=[]
	values=[]
	@doc.elements.each(treePattern) do |s|
		#puts "s=#{s}"
		attrName=s.name.to_s
		names.push(attrName)
		values.push(s[0].to_s)
		puts "s[0].to_s=#{s[0].to_s} s[0].to_s.class=#{s[0].to_s.class}"  if $DEBUG
	end
	return [names,values]
end
def getXML(url)
	@page=getPage(url)
  @doc= REXML::Document.new(@page)
  return
end
end


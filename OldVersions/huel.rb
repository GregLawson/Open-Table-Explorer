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
require 'table.rb'
class Huel  < Table
include Web_Acquisition
# http://www.calgold.com/calgold/Default.asp?Series=3000&Show=428
def getIP
@IP= "http://www.calgold.com/"
end
def initialize
	super('huelshows','id')
	requireColumn('id','serial')
	requireColumn('name','VARCHAR(255)')
	requireColumn('shortName','VARCHAR(255)')
	getIP
	@series=HuelSeries.new
end
def acquire
	@page=getPage(@IP)
	@shows=@page.grep(/<li><a href=\"\/[a-z]+\//)
	@shows.each do | l |
		s=VerboseStringScanner.new(l)
		update_attribute('shortName',s.after(/\s+<li><a href="\//,/[a-z]+/))
		update_attribute('name',Import_Column.unquote(s.after(/\/\"\>/,/[a-zA-Z \\.']+/),"'"))
		#puts "shortName=#{shortName}, name=#{name}"
		save
		@series.acquire(getValue('shortName').to_s)
	end
	puts @shows  if $DEBUG
end
end
class HuelSeries < Table
include Web_Acquisition
def getIP
@IP= "http://www.calgold.com"
end
def initialize
	super('huelseries','id')
	requireColumn('id','serial')
	requireColumn('show','VARCHAR(255)')
	requireColumn('number','integer')
	requireColumn('name','VARCHAR(255)')
	getIP
end
def acquire(show)
	@page=getPage("#{@IP}/#{show}/")
	puts @page if $DEBUG
	@shows=@page.grep(/0 Series/)
	@shows.each do | l |
		puts l  if $VERBOSE
		s=VerboseStringScanner.new(l)
		update_attribute('show',show)
		update_attribute('number',s.after(/<li><a href="Default\.asp\?Series=/,/[0-9]+/))
		update_attribute('name',s.after(/">/,/[a-zA-Z0-9 \\.']+/))
		#puts "number=#{number}, name=#{name}"
		save
	end
	puts @shows  if $DEBUG
end
end
huel=Huel.new
huel.acquire

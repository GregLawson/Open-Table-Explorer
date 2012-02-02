###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
class Url < ActiveRecord::Base
include Generic_Table
has_many :stream_methods
after_initialize :init
def init
	if  self[:url].nil?
		@uri=nil
	else
		@uri=URI.parse(URI.escape(self[:url]))	
	end
end #init
def self.logical_primary_key
	return [:href]	# logically the link name is the part that is visible and should be the unique name
end #logical_primary_key
def Url.find_by_name(name)
	Url.find_by_href(name)
end #find_by_name
def parsedURI
	return URI.split(URI.escape(self[:url]))
end #def
def schemelessUrl
	return URI.unescape(URI.escape(self[:url]).split(':').last)
end #def
def uriComponent(componentName)
	ret=@uri.select(componentName)
	if ret.class==Array then
		return ret.class.name
	else
		return ret
	end
end #end
def uriArray
	return URI.split(URI.escape(self[:url]))
end #def
def uriHash
	componentNames=@uri.class::COMPONENT
	hash={}
	componentNames.each_index do |i| 
		componentName= componentNames[i] 
		component=uriComponent(componentName)
		if !component[0].nil? then
			hash.merge!({ componentName => component })
		end #if
	end # each_index
	return hash
end #def
def scheme
	return @uri.scheme
end #def
def schemelessUrl
	return URI.unescape(URI.escape(self[:url]).split(':').last)
end #def
end #Url

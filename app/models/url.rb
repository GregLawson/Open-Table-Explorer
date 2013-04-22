###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_table.rb' # in test_helper?
class Url < ActiveRecord::Base
#include Generic_Table # really needed?
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
end #schemelessUrl
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
end #scheme
def stream_method
	scheme_name=scheme
	scheme_name=scheme_name[0..0].upcase+scheme_name[1..-1]
	return StreamMethod.find_by_name(scheme_name)
end #stream_method
def implicit_stream_link
	return StreamLink.new
end #implicit_stream_link
require_relative '../../test/assertions/ruby_assertions.rb'
end #Url

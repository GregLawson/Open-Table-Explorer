###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_table.rb' # in test_helper?
require_relative '../../app/models/stream_method.rb'
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
require_relative '../../test/assertions/default_assertions.rb'
module Examples
Test_url_record=Url.find_by_name('nmap_local_network_0')
end #Examples
include Examples
module Assertions
include DefaultAssertions
module ClassMethods
include DefaultAssertions::ClassMethods
def assert_pre_conditions
	Url.all.map do |u|
		stream_methods= StreamMethod.find_all_by_name(u.scheme)
		assert_not_nil(stream_methods)
		assert_instance_of(Array, stream_methods)
	end #map
#	fail "end of class assert_pre_conditions "
end #assert_pre_conditions
end #ClassMethods
def assert_pre_conditions
	assert_instance_of(Url, self)
	stream_methods= StreamMethod.find_all_by_name(scheme)
	assert_not_nil(stream_methods)
	assert_instance_of(Array, stream_methods)
	assert_single_element_array(stream_methods)
#	fail "end of instance assert_pre_conditions"
end #assert_pre_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
end #Url

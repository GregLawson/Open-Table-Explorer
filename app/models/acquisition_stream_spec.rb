class AcquisitionStreamSpec < ActiveRecord::Base
belongs_to :acquisition_interface
belongs_to :table_spec
#belongs_to :table_specs, :class_name => "TableSpec"
has_many :acquisitions
attr_reader :uri
require 'global.rb'
include Generic_Table
#~ validates_format_of :name, :with => /\A[a-zA-Z0-9_]\z/,
    #~ :message => "Name should be alpha numeric plus underscores."
after_initialize :init
def init
	if  self[:url].nil?
		@uri=nil
	else
		@uri=URI.parse(URI.escape(self[:url]))	
	end
end
def logical_primary_key
	return :url
end #def
def parsedURI
	return URI.split(URI.escape(self[:url]))
end #def
def display_model_class_name
	associated_to_s(:table_spec,:model_class_name) 
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
def AcquisitionStreamSpec.urls(model_class_name)
	return AcquisitionStreamSpec.all(:order => "id",:conditions =>{:model_class_name=>model_class_name}).map { |m| m.url }
end #def
def nameFromInterface
	acquisition_interface.name
end #def
def schemeFromInterface
	nameFromInterface.downcase
end #def
def consistantSchemes
	return scheme==schemeFromInterface
end #def
def acquire
	acquisition=acquisition_interface.acquire(self)
	acquisition.acquisition_stream_spec_id=self.id # not clear why this is nil after being set in acquisition_interface
	acquisition
end #def
end

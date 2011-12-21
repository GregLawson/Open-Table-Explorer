###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'app/models/regexp_tree.rb' # make usable under rake
class Specification
include NoDB

# Initializes a spec from a hash
def initialize(hash)
	super(hash)
end #initialize
# Returns all specs
def Specification.all
# [name, specification, spec_kind, spec_id, parent, broader]
	patterns=StreamPattern.all.map{|s| {:name => s.name, :spec_kind => :StreamPattern}}
	methods=StreamMethod.all.map{|s| {:name => s.name, :spec_kind => :StreamMethod, :parent => s.stream_pattern.name.to_s}}
	regexps=ExampleType.all.map{|s| {:name => s.import_class, :spec_kind => :ExampleType, :parent => s.stream_pattern.name.to_s}}
	regexps=GenericType.all.map{|s| {:name => s.import_class, :spec_kind => :ExampleType, :parent => s.stream_pattern.name.to_s}}
	specifications=patterns+methods+regexps+[
		{:name => :Acquisitions, :spec_kind => :StreamPattern},
		{:name => :Shell, 	:spec_kind => :StreamMethod, 	:parent => :Acquisitions, :broader => :both},
		{:name => :Ifconfig,	:spec_kind => StreamMethodCall, :parent => :Shell, :specification => 'ifconfig'},
		{:name => :Nmap, 	:spec_kind =>  StreamMethodCall, :parent => :Shell, specification => "nmap -sP", },
		{:name => :Parsers, 	:spec_kind => :StreamPattern},
		{:name => :Regexp, 	:spec_kind => :StreamMethod, 	:parent => :Parsers, :broader => :both},
		{:name => :Hosts,	:spec_kind => StreamMethodCall, :parent => :Nmap, :specification => 'ifconfig'}
		]
	return specifications.map do |spec| 
		new_attributes={:spec_id =>  spec[:spec_kind].constantize.find_by_name(spec[:name])}
		
		hash=spec.merge(Specification.new(new_attributes))
	end #map
end #all
def []=(name, attribute)
	self[name]=attribute.class.new(attribute)
end #[]=
# like ActiveRecord method
def Specification.find_by_name(spec_name_symbol)
	index=Specification.all.index {|s| s[:name]==spec_name_symbol.to_sym}
	raise "spec_name_symbol=#{spec_name_symbol} not found" if index.nil?
	return Specification.all[index]
end #find_by_name
# for given spec return models
def assert_no_attributes(obj)
	assert_equal(0, obj.size)
end #
def assert_has_attributes(obj)
	assert_not_equal(0, obj.size)
end #assert_has_attributes
\
end #Specification
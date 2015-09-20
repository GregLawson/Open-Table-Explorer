###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
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
# [name, specification, spec_kind, spec_id, parent, broader]
# name = often logical key
# specification = string (regexp, url, html parse tree path)
# spec_kind = symbol of class name of polymorphic embedded class
# spec_id = foreign key for each polymorhic record
# parent = tree of specs
#       levels= Patterns, Methods, Specs (regexp, url, etc.)
# broader= probably GenericType.generalize
def Specification.all
	patterns=StreamPattern.all.map{|s| {:name => s.name, :spec_kind => :StreamPattern}}
	methods=StreamMethod.all.map do |s|
		spec={:name => s.name, :spec_kind => :StreamMethod}
		if !s.stream_pattern.nil? then
			spec[:parent]= s.stream_pattern.name.to_s
		end #if
		spec
	end #map
#	regexps=ExampleType.all.map{|s| {:name => s.generic_type.import_class, :spec_kind => :ExampleType}}
	regexps=GenericType.all.map{|s| {:name => s.import_class, :spec_kind => :GenericType}}
	urls=Url.all.map{|s| {:name => s.href, :spec_kind => :Url}}
	# 
	specifications=patterns+methods+regexps+urls+[
		{:name => :Acquisitions, :spec_kind => :StreamPattern},
		{:name => :Shell, 	:spec_kind => :StreamMethod, 	:parent => :Acquisitions, :broader => :both},
		{:name => :Ifconfig,	:spec_kind => :StreamMethodCall, :parent => :Shell, :specification => 'ifconfig'},
		{:name => :Nmap, 	:spec_kind =>  :StreamMethodCall, :parent => :Shell, :specification => "nmap -sP", },
		{:name => :Parsers, 	:spec_kind => :StreamPattern},
		{:name => :Regexp, 	:spec_kind => :StreamMethod, 	:parent => :Parsers, :broader => :both},
		{:name => :Hosts,	:spec_kind => :StreamMethodCall, :parent => :Nmap, :specification => 'ifconfig'}
		]
	return specifications.map do |spec| 
		klass=spec[:spec_kind].to_s.constantize
		if klass.respond_to?(:find_by_name) then
			new_attributes={:spec_id =>  klass.find_by_name(spec[:name])}
		else
			puts "No find_by_name, id in spec=#{spec.inspect}"
		end #if
		
		hash=Specification.new(spec.merge(new_attributes))
	end #map
end #all
def []=(name, attribute)
	self[name]=attribute.class.new(attribute)
end #[]=
# like ActiveRecord method
def Specification.find_by_name(spec_name_symbol)
	index=Specification.all.index {|s| s[:name].to_sym==spec_name_symbol.to_sym}
	raise "spec_name_symbol=#{spec_name_symbol} not found" if index.nil?
	return Specification.all[index]
end #find_by_name
# for given spec return models
def assert_no_attributes(obj)
	assert_equal(0, obj.size)
end #
def assert_has_attributes(obj)
	refute_equal(0, obj.size)
end #assert_has_attributes
end #Specification

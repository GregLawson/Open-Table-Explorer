###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_table.rb'
require_relative '../../test/assertions/default_assertions.rb'
class Chemistry < ActiveRecord
end #Chemistry
class FormFactor < ActiveRecord
end #FormFactor
class Brand < ActiveRecord
end #Brand
class BatteryType
include NoDB
extend NoDB::ClassMethods
# to_lowercase_symbols
def standardize_keys?
	ret={}
	each_pair do |key, value|
		name=key[0].upcase + key[1..-1] # upper case first letter (like constant)
		ret[name.to_sym] =value
	end #each_pair
	BatteryType.new(ret)
end #standardize_keys!
def self.all
	data_source_yaml('battery_types').values.map do |r| #map
		BatteryType.new(r).standardize_keys?	
	end #map
end #all
def self.chemistries
	all.map {|r| r[:Chemistry]}.uniq
end #chemistries
def self.brands
	all.map {|r| r[:Brand]}.uniq
end #brands
def self.form_factors
	all.map {|r| r[:Size]}.uniq
end #form_factors
MAX_CONFIRMATIONS=10
def self.logical_primary_key
	matches=Array.new()
	data_source_yaml('battery_types').each_pair do |composite_key, record|
		matches=matches&composite_key.split(',').map do |key|
			record.split(',').map {|field| feild==key}
		end #map
		
	end # each_pair
end #logical_primary_key
def self.column_remap
end #column_remap
module Assertions
end #Assertions
module Examples
end #Examples
include Examples
include Assertions
include DefaultAssertions
extend DefaultAssertions::ClassMethods
end #BatteryType

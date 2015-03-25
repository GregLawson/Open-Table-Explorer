###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/common_table.rb'
module NoDB # provide duck-typed ActiveRecord like functions.
attr_reader :attributes
#include ActiveModel # trying to fulfill Rails 3 promise that ActiveModel would allow non-ActiveRecord classes to share methods.
#include Generic_Table
#extend Generic_Table::ClassMethods
module ClassMethods
#include Generic_Table::ClassMethods
def column_symbols
	column_names=sample.flatten.map do |r|
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
end #column_symbols
def table_class
	return self
end #NoDB.table_class
def table_name
	return table_class.name.tableize
end #NoDB.table_name
def default_names(values_or_size, prefix='Col_')
	if values_or_size.instance_of?(Array) then
		size=values_or_size.size
	elsif values_or_size.instance_of?(Fixnum) then
		size=values_or_size
	else
		raise "values_or_size=#{values_or_size.inspect} is a #{values_or_size.class} not an Array or Fixnum."
	end #if
	Array.new(size) {|i| prefix+i.to_s}
end #default_names
def insert_sql(record)
	record.insert_sql
end #insert_sql
def dump
	all.map do |record|
		record.insert_sql
	end #map
end #dump
def data_source_yaml(yaml_table_name=table_name)
  unit = Unit.new(self.name)
  unit_data_source_directory = unit.data_sources_directory?
  data_source_file =  unit_data_source_directory + "/#{yaml_table_name}.yml"
	yaml = YAML::load( File.open(data_source_file) )
end #data_source_yaml
def get_field_names
	field_names=all.first.keys
end #field_names
end #ClassMethods
# NoDB.new(value_array, name_array, type_array) -specified values, names, and types
# NoDB.new(value_array, type_array) - values with default names and specified types (arrayish)
# NoDB.new(value_array) - values with default names and types
# NoDB.new(value_name_hash, type_array) -specified values (Hash.values), names (Hash.keys) and types
# NoDB.new(value_name_hash)-specified values (Hash.values), names (Hash.keys), and types
# NoDB.new - empty object no attributes, no values, no names, no types. All can be added.
DEFAULT_TYPE=String
def initialize(values=nil, names=nil, types=nil)
	if values.nil? then
		@attributes=ActiveSupport::HashWithIndifferentAccess.new
		@types={}
	elsif values.instance_of?(Array) then
		if names.instance_of?(Array) then
			if !names.all?{|n| n.instance_of?(String)|n.instance_of?(Symbol)} then
				names=self.class.default_names(values)
			end #if
		else #missing names
			names=self.class.default_names(values)
		end #if
		@attributes=Hash[[names, values].transpose]
		@types=types || names
	elsif values.instance_of?(Hash) then
		@attributes=values
		@types=types || names
	else
		message="values=#{values.inspect}, \nnames=#{names.inspect}, \ntypes=#{types.inspect}"
		message+="values.nil?=#{values.nil?.inspect}, \nvalues.instance_of?(Array)=#{values.instance_of?(Array).inspect}, \nvalues.instance_of?(Hash)=#{values.instance_of?(Hash).inspect}"
		raise "confused about arguments to NoDB.initialize.\n"+message
	end #if
end #NoDB initialize
def [](attribute_name)
	@attributes[attribute_name.to_sym]
end #[]
def []=(attribute_name, value)
	@attributes[attribute_name.to_sym]=value
end #[]=
def has_key?(key_name)
	return @attributes.has_key?(key_name.to_sym)
end #has_key?
def keys
	return @attributes.keys
end #keys
def table_class
	return self.class
end #table_class
def table_name
	return table_class.table_name
end #table_name
def clone
	return self.new(@attributes.clone, @types.clone)
end #clone
def each_pair(&block)
	@attributes.each_pair do |key, value|
		block.call(key, value)
	end #each_pair
end #each_pair
def insert_sql
	value_strings=@attributes.values.map do |value|
		if value.nil? then
			"NULL"
		elsif value.instance_of?(String) then
			value.inspect
		else
			value
		end #if
	end #map
	return "INSERT INTO #{self.table_name}(#{self.class.get_field_names.join(',')}) VALUES(#{value_strings.join(',')});\n"
end #insert_sql
end #NoDB


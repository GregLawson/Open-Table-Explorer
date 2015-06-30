###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
class GenericVariable
	include Virtus.value_object
	values do
		attribute :name, Symbol, :default => 'Col'
		attribute :ruby_type, Class, :default => String
		attribute :all_numbered, Symbol, :default => nil
	end # values
module Constants
Col = GenericVariable.new
end # module
include Constants
def ==(other)
	self.name == other.name || self.ruby_type.name == other.ruby_type.name # all_numbered is cosmetic?
end # ==
def header
	name[0..0].upcase + name[1..-1].sub('_', ' ')
end # header
module Examples
include Constants
Name = GenericVariable.new(name: 'name')
Var = GenericVariable.new(name: 'Var', all_numbered: true)
end # Examples
end # GenericVariable

class GenericColumn #< ActiveRecord::Base
#include Generic_Table
	include Virtus.value_object
	values do
		attribute :variable, GenericVariable, :default => GenericVariable::Col
		attribute :regexp_index, Fixnum, :default => 0
	end # values
module Constants
end #Constants
include Constants
module ClassMethods
# promote index to type GenericColumn
# uses defaults for unspecified fields (can this be smarter, more brain power needed here)
def promote(index)
case index.class.name
when 'GenericColumn' then index
when 'GenericVariable' then GenericColumn.new(variable: index)
when 'Symbol', 'String' then GenericColumn.new(variable: GenericVariable.new(name: index))
when 'Fixnum' then GenericColumn.new(name: index) # needs named_captures from Regexp
else
	fail 'index = ' + index.inspect
end # case
end # promote
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
def logical_primary_key
	return [:model_class, :column_name]
end #logical_primary_key
def name
	name_string = if @variable.name.nil? then
		'Col_' + @regexp_index.to_s
	elsif @all_numbered.nil? && @regexp_index==0 then
		@variable.name
	else
		@variable.name.to_s + '_' + @regexp_index.to_s
	end #if
	name_string.to_sym
end # name
def header
	name[0..0].upcase + name[1..-1].sub('_', ' ')
end # header
def to_hash(value)
	{self => value}
end # to_hash
module Constants
end # Constants
include Constants
# attr_reader
#def initialize
#end # initialize
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
#	asset_nested_and_included(:ClassMethods, self)
#	asset_nested_and_included(:Constants, self)
#	asset_nested_and_included(:Assertions, self)
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
include GenericVariable::Examples
Col_1 = GenericColumn.new(regexp_index: 1)
Name_0 = GenericColumn.new(regexp_index: 0, variable: Name)
Name3 = GenericColumn.new(regexp_index: 3, variable: Name)
Var_1 = GenericColumn.new(regexp_index: 1, variable: Var, all_numbered: true)
end # Examples
end # GenericColumn

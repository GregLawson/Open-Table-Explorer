###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
class GenericColumn #< ActiveRecord::Base
#include Generic_Table
  include Virtus.value_object
  values do
 	attribute :regexp_name, Symbol, :default => 'Col'
	attribute :regexp_index, Fixnum, :default => 0
	attribute :ruby_type, Class, :default => String
	attribute :all_numbered, Symbol, :default => nil
end # values
module Constants
end #Constants
include Constants
module ClassMethods
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
def logical_primary_key
	return [:model_class, :column_name]
end #logical_primary_key
def name
	name_string = if @regexp_name.nil? then
		'Col_' + @regexp_index.to_s
	elsif @all_numbered.nil? && @regexp_index==0 then
		@regexp_name
	else
		@regexp_name.to_s + '_' + @regexp_index.to_s
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
Col_1 = GenericColumn.new(regexp_index: 1)
Name = GenericColumn.new(regexp_index: 0, regexp_name: 'name')
Name3 = GenericColumn.new(regexp_index: 3, regexp_name: 'name')
Var_1 = GenericColumn.new(regexp_index: 1, regexp_name: 'Var', all_numbered: true)
end # Examples
end # GenericColumn

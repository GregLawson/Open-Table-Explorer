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
# 	attribute :branch, Symbol
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
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
module Constants
end # Constants
include Constants
# attr_reader
def initialize
end # initialize
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
end # Examples
end # GenericColumn

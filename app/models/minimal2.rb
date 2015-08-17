###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
class Minimal2
  include Virtus.value_object
  values do
# 	attribute :branch, Symbol
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
end # values
module Constants # constant parameters of the type
end #Constants
include Constants
module ClassMethods
include Constants
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
module Constants # constant objects of the type
end # Constants
include Constants
# attr_reader
#require_relative '../../test/assertions.rb'
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
end # Minimal2

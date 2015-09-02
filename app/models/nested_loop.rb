###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'virtus'
#require_relative '../../app/models/no_db.rb'
class NestedLoop
module Constants
Loops = [RubyVersion, Unit, Branch, TestRun] # Verbosity
end # Constants
include Constants
module ClassMethods
def next
	Loops.map do |dimension_class|
		if dimension.methods.includes?(:enumerator) then
			set_instance_variable(index_name, enumerator.next
		end # map
end # next
end # ClassMethods
extend ClassMethods
attr_reader :dimension, :enumerator, :next
def initialize(dimension)
	@dimension = dimension
end # initialize
def index_name
			@dimension.name.model_name?
end # index_name
def next
		if @dimension.methods.includes?(:enumerator) then
			@enumerator = @dimension.enumerator
			@next = @enumerator.next
		else
			@enumerator = nil
			@next = nil
		end # map
end # next
#require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
#	asset_nested_and_included(:ClassMethods, self)
#	asset_nested_and_included(:Constants, self)
#	asset_nested_and_included(:Assertions, self)
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
end # NestedLoop

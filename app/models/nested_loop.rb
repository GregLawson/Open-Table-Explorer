###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'rom' # how differs from rom-sql
require 'rom-sql' # conflicts with rom-csv and rom-rom
#require 'rom-relation' # conflicts with rom-csv and rom-rom
require 'rom-repository' # conflicts with rom-csv and rom-rom
require 'dry-types'
require_relative '../../app/models/ruby_interpreter.rb'
require_relative '../../app/models/branch.rb'
require_relative '../../app/models/test_executable.rb'

module Types
	include Dry::Types.module
end # Types

class NestedLoop
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
		Loops = [RubyVersion, Unit, Branch, TestExecutable] # Verbosity
end # DefinitionalConstants
include DefinitionalConstants
	
  module DefinitionalClassMethods
	def next
		Loops.map do |dimension_class|
			if dimension.methods.includes?(:enumerator) then
				set_instance_variable(index_name, enumerator.next)
			end # if
		end # map
end # next
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
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
		end # if
end # next
#require_relative '../../app/models/assertions.rb'
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
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
end # Examples
end # NestedLoop

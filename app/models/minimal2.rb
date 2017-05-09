###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
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
module Types
	include Dry::Types.module
end # Types

class Minimal2 < Dry::Types::Value
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

	module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
	end # DefinitionalConstants
	include DefinitionalConstants
	
  module DefinitionalClassMethods # if reference DefinitionalConstants
    include DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

#    attribute :name, Types::Strict::Symbol | Types::Strict::String
#		attribute :data_regexp, Types::Coercible::String
#		attribute :ruby_conversion, Types::Strict::String.optional

  module Constructors # such as alternative new methods
    include DefinitionalConstants
  end # Constructors
  extend Constructors
	
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
		Minimal_object = Minimal2.new
  end # ReferenceObjects
  include ReferenceObjects
	
require_relative '../../app/models/assertions.rb'

	module Assertions
    module ClassMethods

			def assert_nested_scope_submodule(module_symbol, context = self, message='')
				message+="\nIn assert_nested_scope_submodule for class #{context.name}, "
				message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
				message += " but not in #{context.nested_scope_module_names}"
				assert_includes(nested_scope_module_names, module_symbol)
			end # assert_included_submodule
			
			def assert_included_submodule(module_symbol, context = self, message='')
				message+="\nIn assert_included_submodule for class #{self.name}, "
				message += "make sure module Constants is nested in #{self.class.name.downcase} #{self.name}"
				message += " but not in #{self.nested_scope_module_names}"
				assert_includes(included_modules.map(&:module_name), module_symbol)
			end # assert_included_submodule
			
			def asset_nested_and_included(module_symbol, context = self, message='')
				assert_nested_scope_submodule(module_symbol)
				assert_included_submodule(module_symbol)
			end # asset_nested_and_included
			
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

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
				self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
				self # return for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
end # Minimal

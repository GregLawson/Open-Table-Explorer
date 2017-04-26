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

require_relative 'test_executable.rb'
require_relative 'repository.rb'
require_relative 'interactive_bottleneck.rb'

class Nomination < Dry::Types::Value
  module DefinitionalClassMethods # if reference by DefinitionalConstants or not referenced
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

	module DefinitionalConstants # constant parameters in definition of the type (suggest all CAPS)
	end # DefinitionalConstants
	include DefinitionalConstants
	
  module DefinitionalClassMethods # if reference DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods

    attribute :commit, Types::Strict::Symbol
		attribute :unit, Types::Strict::Symbol
		attribute :test_type, Types::Strict::Symbol
#		attribute :ruby_conversion, Types::Strict::String.optional

  module Constructors # such as alternative new methods
    include DefinitionalConstants
		def stash(test_executable)
				Nomination.new(commit: :stash, unit: test_executable.unit, test_type: test_executable.test_type)
		end # stash
		
		def pending
		end # pending
		
		def apply
			if test_executable.repository.something_to_commit?
				test_executable.repository.stash!
			else
				nil
			end # if
		end # apply
  end # Constructors
		
  extend Constructors
	
  module ReferenceObjects # example constant objects of the type (e.g. default_objects)
    include DefinitionalConstants
		Self = Nomination.new(commit: :stash, unit: TestExecutable::Examples::TestTestExecutable.unit.model_basename, test_type: TestExecutable::Examples::TestTestExecutable.test_type)
  end # ReferenceObjects
  include ReferenceObjects
	
		
		def apply
		end # apply
		
	require_relative '../../app/models/assertions.rb'

	module Assertions
    module ClassMethods
			def nested_scope_modules?
				nested_constants = self.class.constants
				message = ''
				assert_includes(included_modules.map{|m| m.name}, :Assertions, message)
				assert_equal([:Constants, :Assertions, :ClassMethods], Version.nested_scope_modules?)
			end # nested_scopes
			def assert_nested_scope_submodule(module_symbol, context = self, message='')
				message+="\nIn assert_nested_scope_submodule for class #{context.name}, "
				message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
				message += " but not in #{context.nested_scope_modules?.inspect}"
				assert_includes(constants, :Contants, message)
			end # assert_included_submodule
			def assert_included_submodule(module_symbol, context = self, message='')
				message+="\nIn assert_included_submodule for class #{self.name}, "
				message += "make sure module Constants is nested in #{self.class.name.downcase} #{self.name}"
				message += " but not in #{self.nested_scope_modules?.inspect}"
				assert_includes(included_modules, :Contants, message)
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
end # Nomination

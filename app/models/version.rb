###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
require_relative '../../app/models/no_db.rb'
require 'fileutils'
require_relative '../../app/models/parse.rb'
# see http://semver.org/
class Version
include Virtus.model
  attribute :major, String, :default => '0' # system version
  attribute :minor, String, :default => '0'
  attribute :patch, String, :default => '0'
  attribute :pre_release, String, :default => '0'
module Constants
# see http://semver.org/
Version_digits = /[1-9]?[0-9]{1,3}/
Version_pattern = [Version_digits.capture(:major), '.'] + 
	[Version_digits.capture(:minor)] + 
	[Version_digits.capture(:patch)] +
	[(/-/ * /[-.a-zA-Z0-9]*/.capture(:pre_release)) * Regexp::Optional] +
	[(/\+/ * /[-.a-zA-Z0-9]*/.capture(:build)) * Regexp::Optional]
end # Constants
include Constants
module ClassMethods
include Constants
def [](string)
	parse = string.parse(Version_pattern)
	Version.new(parse)
end # square_brackets
end # ClassMethods
extend ClassMethods
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def nested_scope_modules?(context = self)
	nested_constants = context.class.constants
	nested_constants.select do |constant|
		constant.class == Module
	end # select
end # nested_scopes
def assert_nested_scope_submodule(module_symbol, context = self, message='')
	message+="\nIn assert_nested_scope_submodule for class #{context.name}, "
	message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
	message += " but not in #{context.nested_scope_modules?.inspect}"
	assert_include(constants, :Contants, message)
end # assert_included_submodule
def assert_included_submodule(module_symbol, context = self, message='')
	message+="\nIn assert_included_submodule for class #{self.name}, "
	message += "make sure module Constants is nested in #{self.class.name.downcase} #{self.name}"
	message += " but not in #{self.nested_scope_modules?.inspect}"
	assert_include(included_modules, :Contants, message)
end # assert_included_submodule
def asset_nested_and_included(module_symbol, context = self, message='')
	assert_nested_scope_submodule(module_symbol)
	assert_included_submodule(module_symbol)
end # asset_nested_and_included
def assert_pre_conditions(message='')
	asset_nested_and_included(:ClassMethods, self)
	asset_nested_and_included(:Constants, self)
	asset_nested_and_included(:Assertions, self)
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Version::Constants
Sorted_version_names = ['1.9.0', '1.10.0', '1.11.0.']
First_example_version_name = Sorted_version_names[0]
#First_example_version = Version[First_example_version_name]
end # Examples
end # Version

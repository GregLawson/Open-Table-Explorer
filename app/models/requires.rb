###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/parse.rb'
class Require
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
Require_regexp = /require/ * /_relative/.capture(:relative) * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path) *  /['"]/
end # DefinitionalConstants
include DefinitionalConstants
module DefinitionalClassMethods # compute sub-objects such as default attribute values
include DefinitionalConstants
def scan(unit)
	ret = {}
	unit.edit_files.each do |file|
		code = IO.read(file)
		parse = code.capture?(Require_regexp)[:required_path]
		ret = ret.merge({FilePattern.find_from_path(file)[:name] => parse})
	end # each
	ret
end # scan
end # DefinitionalClassMethods
extend DefinitionalClassMethods
include Virtus.value_object
  values do
 	attribute :unit, Unit
	attribute :requires, Hash, :default => lambda {|require, attribute| Require.scan(require.unit) }
#	attribute :age, Fixnum, :default => 789
#	attribute :timestamp, Time, :default => Time.now
end # values
module ClassMethods
include DefinitionalConstants
def all
end # all
end # ClassMethods
extend ClassMethods
module Constants # constant objects of the type (e.g. default_objects)
end # Constants
include Constants
# attr_reader
require_relative '../../app/models/assertions.rb'
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
module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
include DefinitionalConstants
include Constants
Require_line = "require_relative '../../app/models/unit.rb'"
Executing_requires = Require.new(unit: Unit::Executable)
end # Examples
end # Require

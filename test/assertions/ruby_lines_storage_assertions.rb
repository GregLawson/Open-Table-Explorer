###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/assertions.rb'

module Assertions
  module ClassMethods
    def nested_scope_modules?
      nested_constants = self.class.constants
      message = ''
      assert_includes(included_modules.map(&:name), :Assertions, message)
      assert_equal([:Constants, :Assertions, :ClassMethods], Version.nested_scope_modules?)
    end # nested_scopes

    def assert_nested_scope_submodule(_module_symbol, context = self, message = '')
      message += "\nIn assert_nested_scope_submodule for class #{context.name}, "
      message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
      message += " but not in #{context.nested_scope_modules?.inspect}"
      assert_includes(constants, :Contants, message)
    end # assert_included_submodule

    def assert_included_submodule(_module_symbol, _context = self, message = '')
      message += "\nIn assert_included_submodule for class #{name}, "
      message += "make sure module Constants is nested in #{self.class.name.downcase} #{name}"
      message += " but not in #{nested_scope_modules?.inspect}"
      assert_includes(included_modules, :Contants, message)
    end # assert_included_submodule

    def asset_nested_and_included(module_symbol, _context = self, _message = '')
      assert_nested_scope_submodule(module_symbol)
      assert_included_submodule(module_symbol)
    end # asset_nested_and_included

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      #	asset_nested_and_included(:ClassMethods, self)
      #	asset_nested_and_included(:Constants, self)
      #	asset_nested_and_included(:Assertions, self)
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
  end # ClassMethods

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

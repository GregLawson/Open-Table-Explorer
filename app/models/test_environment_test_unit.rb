###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require 'test/unit'
AssertionsModule = Test::Unit::Assertions
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative 'method_model.rb'
# require_relative '../../app/models/unit.rb'
BaseTestCase = Test::Unit::TestCase
TestCase = BaseTestCase # allows subclassing BaseTestCase, sets default value
# AssertionFailedError = RuntimeError
AssertionFailedError = Test::Unit::AssertionFailedError
# assert_global_name(:AssertionFailedError)

include AssertionsModule
extend AssertionsModule
def assert_method(method_name, scope = self)
  assert_respond_to(scope, method_name, '')
  assert_kind_of(Module, scope)
  methods = scope.instance_methods(false)
  assert(methods.include?(method_name), methods)
end # method

def assert_included_modules(module_name, scope = self, message = '')
  message += 'In assert_included_modules, ' + module_name.to_s + ' is not included in ' + scope.inspect
  message += if scope.included_modules.empty?
               ' which does not include any modules.'
             else
               ' which includes ' + scope.included_modules.inspect
             end # if
  assert(scope.included_modules.include?(module_name), message)
end # assert_included_modules

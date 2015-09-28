###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
#require "minitest/autorun"
require "minitest/unit"
require 'active_support/all'
AssertionsModule = MiniTest::Assertions
#require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
BaseTestCase = MiniTest::Unit::TestCase 
TestCase = BaseTestCase # allows subclassing BaseTestCase, sets default value
AssertionFailedError = RuntimeError
#AssertionFailedError=Test::Unit::AssertionFailedError
#AssertionFailedError = MiniTest::Assertion
#assert_global_name(:AssertionFailedError)

include AssertionsModule
extend AssertionsModule
def assert_method(method_name, scope = self)
	assert_respond_to(scope, method_name, '')
	assert_kind_of(Module, scope)
	methods = scope.instance_methods(false)
	assert(methods.include?(method_name), methods)
end # method
def assert_included_modules(module_name, scope = self)
	assert(scope.included_modules.include?(module_name))
end # assert_included_modules

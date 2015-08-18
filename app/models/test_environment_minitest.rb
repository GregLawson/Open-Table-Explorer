###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
require "minitest/autorun"
require 'active_support/all'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
BaseTestCase = MiniTest::Unit::TestCase 
TestCase = BaseTestCase
AssertionsModule = MiniTest::Assertions
AssertionFailedError = RuntimeError
#AssertionFailedError=Test::Unit::AssertionFailedError
#AssertionFailedError = MiniTest::Assertion
#assert_global_name(:AssertionFailedError)
TestClassName = Unit::Executable.test_class_name
NewTestClass = Class.new(TestCase) do
	extend(RubyAssertions)
	include(RubyAssertions)
end # NewTestClass
TestClass = Object.const_set(TestClassName, NewTestClass)
class Object
def test_class_name
	self.class.name.to_s + 'Test'
end # test_class
end # Object
###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require "minitest/autorun"
require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
TestClassName = RailsishRubyUnit::Executable.test_class_name
NewTestClass = Class.new(TestCase) do
	extend(AssertionsModule)
	include(AssertionsModule)
	extend(RubyAssertions)
	include(RubyAssertions)
end # NewTestClass
include AssertionsModule
extend AssertionsModule
include RubyAssertions
extend RubyAssertions
raise Exception.new('') if NewTestClass.class != Class
TestClass = Object.const_set(TestClassName, NewTestClass)
class Object
def test_class_name
	self.class.name.to_s + 'Test'
end # test_class
end # Object
###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_minitest.rb'
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
###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_ruby.rb'
require_relative '../../app/models/default_test_case.rb'
class TestEnvironmentRubyTest < TestCase
include AssertionsModule
extend AssertionsModule
include RubyAssertions
extend RubyAssertions
assert_included_modules(:RubyAssertions, TestEnvironmentRubyTest)
assert_included_modules(:RubyAssertions, self)
def test_AssertionsModule
	message = 'AssertionsModule defined'
	assert_equal(MiniTest::Assertions, AssertionsModule, message)
	#puts "\nin test_environment_minitest.rb, Module.constants = " + Module.constants.inspect
	message = 'In instance assert_pre_conditions, '
	message += "\n AssertionsModule.methods = " + AssertionsModule.methods(false).inspect
	exception = Exception.new(message)
	raise exception if !AssertionsModule.instance_methods(false).include?(:assert_equal)
end # AssertionsModule
def test_requires
	assert_included_modules(:Fish, MiniTest::Assertions)
	assert_included_modules(:RubyAssertions, MiniTest::Assertions)
	assert(MiniTest::Assertions.included_modules.empty?, MiniTest::Assertions.included_modules)
	assert(MiniTest::Unit.included_modules.include?(:RubyAssertions), MiniTest::Unit.included_modules.inspect)
	assert_included_modules(MiniTest::Assertions, :RubyAssertions)
	assert(MiniTest::Assertions.instance_methods.include?(:assert_block), MiniTest::Assertions.instance_methods.inspect)
	assert(AssertionsModule.instance_methods.include?(:assert_block), AssertionsModule.instance_methods.inspect)
	assert(RubyAssertions.instance_methods.include?(:assert_block), RubyAssertions.instance_methods.inspect)
end # requires
def test_RubyAssertions
	message = "\n RubyAssertions.methods = " + RubyAssertions.methods(false).inspect
	exception = Exception.new(message)
	raise exception if !RubyAssertions.instance_methods(false).include?(:refute_empty)
	assert_method(:refute_empty, RubyAssertions)
	refute_empty([1])
end # RubyAssertions
def test_ruby_assertions
	assert_method(:refute_empty, RubyAssertions)
	explain_assert_respond_to(self, :refute_empty, '')
	refute_empty([1])
end # ruby_assertions
#include RubyAssertions
def test_constant_scope
	fail 'in test_environment_minitest.rb AssertionsModule not found in ' + Module.constants.inspect unless Module.constants.include?(:AssertionsModule)
	explain_assert_respond_to(self, :assert_global_name, '')
	assert_global_name(:AssertionsModule)
end # constant_scope
def test_RegexpError
	regexp_string = ')'
	Regexp.new(regexp_string) # test
rescue RegexpError => exception
	assert_instance_of(RegexpError, exception)
	assert_includes(exception.class.ancestors, Exception)
end # AssertionFailedError
def test_AssertionFailedError
	fail # test
rescue Exception => exception
	assert_kind_of(Exception, exception)
	assert_includes(exception.class.ancestors, Exception)
	assert_instance_of(AssertionFailedError, exception)
end # AssertionFailedError
end # TestEnvironmentRuby

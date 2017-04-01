###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'minitest/autorun'
require_relative '../../app/models/test_environment_minitest.rb'
class TestEnvironmentMinitestTest < TestCase
  include AssertionsModule
  extend AssertionsModule
  def test_requires
    #	assert_included_modules(:Fish, MiniTest::Assertions)
    assert(MiniTest::Assertions.included_modules.empty?, MiniTest::Assertions.included_modules)
    assert(MiniTest::Assertions.instance_methods.include?(:assert), MiniTest::Assertions.instance_methods.inspect)
    assert(AssertionsModule.instance_methods.include?(:assert), AssertionsModule.instance_methods.inspect)
    assert(RubyAssertions.instance_methods.include?(:assert), RubyAssertions.instance_methods.inspect)
    #	assert_included_modules(:RubyAssertions, MiniTest::Assertions)
    #	assert(MiniTest::Unit.included_modules.include?(:RubyAssertions), MiniTest::Unit.included_modules.inspect)
    #	assert_included_modules(MiniTest::Assertions, :RubyAssertions)
  end # requires

  def test_assert_method
    method_name = :assert
    scope = AssertionsModule
  end # method

  def test_assert_included_modules
    module_name = :assert
    scope = AssertionsModule
    message = ''
    message += 'In assert_included_modules, ' + module_name.to_s + ' is not included in ' + scope.inspect
    scope_defined = defined?(scope)
    assert_equal('constant', defined?(MiniTest::Assertions))
    assert_equal('self', defined?(self))
    assert_equal(nil, defined?(Fish))
  end # assert_included_modules

  def test_AssertionsModule
    message = 'AssertionsModule defined'
    assert_equal(MiniTest::Assertions, AssertionsModule, message)
    # puts "\nin test_environment_minitest.rb, Module.constants = " + Module.constants.inspect
    message = 'In instance assert_pre_conditions, '
    message += "\n AssertionsModule.methods = " + AssertionsModule.methods(false).inspect
    exception = Exception.new(message)
    raise exception unless AssertionsModule.instance_methods(false).include?(:assert_equal)
  end # AssertionsModule

  def test_constant_scope
    raise 'in test_environment_minitest.rb AssertionsModule not found in ' + Module.constants.inspect unless Module.constants.include?(:AssertionsModule)
    #	assert_global_name(:AssertionsModule)
  end # constant_scope

  def test_RegexpError
    regexp_string = ')'
    Regexp.new(regexp_string) # test
  rescue RegexpError => exception
    assert_instance_of(RegexpError, exception)
    assert(exception.class.ancestors.include?(Exception))
  end # AssertionFailedError

  def test_AssertionFailedError
    raise # test
  rescue Exception => exception
    assert_kind_of(Exception, exception)
    assert_includes(exception.class.ancestors, Exception)
    assert_instance_of(AssertionFailedError, exception)
  end # AssertionFailedError
end # MinitestTest

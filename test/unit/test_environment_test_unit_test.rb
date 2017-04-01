###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../assertions/ruby_assertions_test_unit.rb'
require_relative '../assertions/ruby_assertions_common.rb'
class TestEnvironmentTestUnitTest < TestCase
  include AssertionsModule
  extend AssertionsModule
  include RubyAssertions
  def test_requires
    #	assert_included_modules(:Fish, Test::Unit::Assertions)
    assert(Test::Unit::Assertions.included_modules.empty?, Test::Unit::Assertions.included_modules.inspect)
    assert(Test::Unit::Assertions.instance_methods.include?(:assert), Test::Unit::Assertions.instance_methods.inspect)
    assert(AssertionsModule.instance_methods.include?(:assert), AssertionsModule.instance_methods.inspect)
    #	assert(RubyAssertions.instance_methods.include?(:assert), RubyAssertions.instance_methods.inspect)
    #	assert_included_modules(:RubyAssertions, Test::Unit::Assertions)
    #	assert(Test::Unit::Unit.included_modules.include?(:RubyAssertions), Test::Unit::Unit.included_modules.inspect)
    #	assert_included_modules(Test::Unit::Assertions, :RubyAssertions)
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
    assert_equal('constant', defined?(Test::Unit::Assertions))
    assert_equal('self', defined?(self))
    assert_equal(nil, defined?(Fish))
  end # assert_included_modules

  def test_AssertionsModule
    message = 'AssertionsModule defined'
    assert_equal(Test::Unit::Assertions, AssertionsModule, message)
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
    assert(false) # test
  rescue Exception => exception
    assert_kind_of(Exception, exception)
    assert_includes(exception.class.ancestors, Exception)
    assert_instance_of(AssertionFailedError, exception)
  end # AssertionFailedError
end # TestUnit

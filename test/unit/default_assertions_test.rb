###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module DefaultAssertionTests
  include DefaultAssertions
  extend DefaultAssertions::ClassMethods
  # methods to extract model, class from TestCase subclass
  def name_of_test?
    self.class.name
  end # name_of_test?

  # Extract model name from test name if Rails-like naming convention is followed
  def model_name?
    name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '')
  end # model_name?

  def table_name?
    model_name?.tableize
  end # table_name?

  def model_class?
    eval(model_name?)
  end # model_class?

  def names_of_tests?
    methods(true).select do |m|
      m.match(/^test(_class)?_assert_(invariant|pre_conditions|post_conditions)/)
    end # map
  end # names_of_tests?

  # assert_includes(methods, :model_class?)
  # assert_includes(self.class.methods, :model_class?)
  # include "#{DefaultAssertionTests.model_class?}::Examples"
  def test_test_environment
    assert_equal(self.class.name[-4..-1], 'Test')
    assert_equal(6, names_of_tests?.size, names_of_tests?.sort.to_s)
    assert_equal([DefaultAssertionTests], Module.nesting)
    assert_includes(self.class.included_modules, Test::Unit::Assertions)
    assert_includes(self.class.included_modules, DefaultAssertionTests)
    assert_includes(methods(true), :explain_assert_respond_to)
    refute_includes(methods(false), :explain_assert_respond_to)
    refute_includes(self.class.methods(false), :explain_assert_respond_to)
    assert_equal([], self.class.methods(false))
    #	puts "model_class?::Examples.inspect=#{model_class?::Examples.inspect}"
    #	puts "model_class?::Examples.constants.inspect=#{model_class?::Examples.constants.inspect}"
    #	puts "model_class?::Examples.instance_methods.inspect=#{model_class?::Examples.instance_methods.inspect}"
    #	puts "model_class?::Examples.methods.inspect=#{model_class?::Examples.methods.inspect}"
    #	puts "model_class?::Assertions.inspect=#{model_class?::Assertions.inspect}"
    #	puts "model_class?::Assertions.constants.inspect=#{model_class?::Assertions.constants.inspect}"
    #	puts "model_class?::Assertions.instance_methods.inspect=#{model_class?::Assertions.instance_methods.inspect}"
    #	puts "model_class?::Assertions.methods.inspect=#{model_class?::Assertions.methods.inspect}"
    assert_includes(model_class?.included_modules, model_class?::Assertions)
    assert_includes(model_class?.included_modules, Test::Unit::Assertions)
    #	assert_equal('Test::Unit::Assertions', self.class.name)
    #	assert_equal([MiniTest::Assertions], self.class.included_modules)
    #	assert_equal([Module, Object, Test::Unit::Assertions, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
    #	fail "got to end of default test."
  end # test_test_case

  def test_assertion_inclusion
    assert_includes(model_class?.included_modules, model_class?::Assertions)
    assert_includes(model_class?.ancestors, Test::Unit::Assertions)
    assert_includes(model_class?.ancestors, model_class?::Examples, "module #{model_class?}::Examples  should exist in class #{model_class?}.\nPlace 'include Examples' within class #{model_class?} scope in assertions file.")
    assert_includes(model_class?.ancestors, DefaultAssertions, "module DefaultAssertions  should exist in class #{model_class?}.\nPlace 'include DefaultAssertions' within class #{model_class?} scope in assertions file.")
    assert_includes(model_class?.included_modules, model_class?::Examples, "module Examples  should be included in class #{model_class?}")
    assert_includes(model_class?.methods, :example_constant_names_by_class, "module DefaultAssertions::ClassMethods (including :example_constant_names_by_class) should exist in class #{model_class?}.\nPlace 'extend DefaultAssertions::ClassMethods' within class #{model_class?} scope in assertions file.")
    assert_respond_to(model_class?, :example_constant_names_by_class, "model_class?=#{model_class?}")
    #	assert_respond_to(model_class?, :example_constant_names_by_class)
    #	assert_includes(model_class?.methods, :example_constant_names_by_class, "model_class?=#{model_class?}")
  end # test_assertion_inclusion

  def test_class_assert_invariant
    # puts "self.class.methods(true)=#{self.class.methods(true)}"
    model_class?.assert_invariant
    #	fail "got to end of default test."
  end # class_assert_invariant

  def test_class_assert_pre_conditions
    model_class?.assert_pre_conditions
    #	fail "got to end of default test."
  end # class_assert_pre_conditions

  def test_class_assert_post_conditions
    model_class?.example_constant_names_by_class(model_class?).each(&:assert_pre_conditions) # each
    #	fail "got to end of default test."
  end # class_assert_post_conditions

  # ClassMethods
  def test_assert_pre_conditions
    model_class?.example_constant_names_by_class(model_class?).each(&:assert_pre_conditions) # each
    #	fail "got to end of default test."
  end # assert_pre_conditions

  def test_assert_invariant
    model_class?.example_constant_values_by_class(model_class?).each(&:assert_invariant) # each
    #	fail "got to end of default test."
  end # def assert_invariant

  def test_assert_post_conditions
    model_class?.example_constant_names_by_class(model_class?).each(&:assert_post_conditions) # each
    #	fail "got to end of default test."
  end # assert_post_conditions
end # DefaultAssertionTests

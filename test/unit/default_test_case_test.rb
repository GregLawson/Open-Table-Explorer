###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_default_test_case.rb'
class EmptyTest
end # EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end # EmptyDefaultTest
class EmptyIncludedTest
  include DefaultTests1
end # EmptyIncludedTest
# require_relative '../../test/assertions.rb'
class MinimalTest < BaseTestCase # DefaultTestCase0
end # MinimalTest
class ClassExists
  def self.assert_invariant
    assert_equal(:ClassExists, name.to_sym) # , caller_lines)
    assert_instance_of(Class, self)
  end # class_assert_invariant
end # ClassExists

class ClassExistsTest < DefaultTestCase1
  def test_examples_submodule
  end # example_submodule

  # klass filters example constants by type
  def test_example_constants
    #	assert_(, ExampleCall.example_constants?)
  end # example_submodule

  def test_each_example
    included_module_names = RailsishRubyUnit::Executable.model_class?.included_modules.map(&:name)
  end # each_example

  def test_existing_call
  end # existing_call

  def test_named_object?
    #	assert_equal('', ExampleCall.named_object?)
  end # named_object?

  def test_name_of_test
    assert_equal('Test', self.class.name[-4..-1], "2Naming convention is to end test class names with 'Test' not #{self.class.name}")
    #	assert_equal('ClassExistsTest', name_of_test?, "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_lines)
  end # name_of_test?

  def test_global_class_names
    constants = Module.constants
    assert_instance_of(Array, constants)
    constants.select { |n| eval(n.to_s).instance_of?(Class) }
    assert_includes(global_class_names, self.class.name.to_sym)
  end # global_classes

  def test_case_assert_invariant
    caller_message = " callers=#{caller.join("\n")}"
    assert_equal('Test', self.class.name[-4..-1], "Naming convention is to end test class names with 'Test' not #{self.class.name}" + caller_message)
  end # assert_invariant

  def test_assert_class_invariant
    assert_includes(Module.constants, :ClassExists)
  end # test_assert_class_invariant
  include DefaultTests1
end # DefaultTestCaseTest

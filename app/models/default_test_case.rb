###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require_relative 'test_environment_ruby.rb'
module ExampleCall
  def examples_submodule?
    RailsishRubyUnit::Executable.model_class?::Examples
  end # example_submodule

  # klass filters example constants by type
  def example_constants?(klass = nil)
    all = examples_submodule.constants
    unless klass.nil?
      all.select { |ec| ec.instance_of(klass) }
    end #
  end # example_submodule

  def each_example
    return if RailsishRubyUnit::Executable.model_class?.nil?
    assert_equal(examples_submodule?, RailsishRubyUnit::Executable.model_class?::Examples)
    assert(RailsishRubyUnit::Executable.model_class?.const_defined?(:Examples))
    if RailsishRubyUnit::Executable.model_class?.const_defined?(:Examples)
      #    info "RailsishRubyUnit::Executable.model_class?.constants=#{RailsishRubyUnit::Executable.model_class?.constants}"
      constant_objects = RailsishRubyUnit::Executable.model_class?.constants.map { |c| RailsishRubyUnit::Executable.model_class?.class_eval(c.to_s) }
      # verbose    info "constant_objects=#{constant_objects}"
      examples = constant_objects.select { |c| c.instance_of?(Regexp) }
      if examples.empty?
      # once      warn "There are no example constants of type #{RailsishRubyUnit::Executable.model_class?} in #{RailsishRubyUnit::Executable.model_class?}::Examples."
      else
        examples.each do |c|
          info "calling block on #{c.inspect}"
          yield(c)
        end # each
      end # if
    else
      warn "There is no module #{RailsishRubyUnit::Executable.model_class?}::Examples."
    end # if
  end # each_example

  # Call method symbol on object if method exists
  def existing_call(object, symbol)
    if object.respond_to?(symbol)
      info "method #{symbol.inspect} does  exist for object of type #{object.class.name}"
      assert_respond_to(object, symbol)
      object.method(symbol).call
    else
      message = "method #{symbol} does not exist for object "
      message += if object.respond_to?(:name)
                   "named #{object.name}"
                 else
                   "of type #{object.class.name}"
                 end # if
      warn message
    end # if
  end # existing_call

  def named_object?(object)
    if object.respond_to?(:name)
      "named #{object.name}"
    else
      "of type #{object.class.name}"
    end # if
  end # named_object?

  def assert_optional_method(object, symbol)
    if object.respond_to?(symbol)
      info "method #{symbol.inspect} does exist for object of type #{object.class.name}"
      assert_respond_to(object, symbol)
      object.method(symbol).call
    else
      message = "method #{symbol} does not exist for object " + named_object?(object)
      warn message
    end # if
  end #
end # ExampleCall
module DefaultTests0
  # require_relative '../../app/models/assertions.rb'

  # extend AssertionsModule
  def related_files?
    Unit.new(model_name?)
  end # related_files
end # DefaultTests0
module DefaultTests1
  include DefaultTests0
  def test_case_pre_conditions
    assert_equal([DefaultTests1], Module.nesting)
    caller_message = " callers=#{caller.join("\n")}"
    assert_equal('Test', self.class.name[-4..-1], "2Naming convention is to end test class names with 'Test' not #{self.class.name}" + caller_message)
    assert_operator(1, :<=, names_of_tests?.size, names_of_tests?.sort.to_s)
  end # test_case_pre_conditions

  def test_class_assert_invariant
    #	assert_includes(Module.constants, model_name?)
    #	refute_nil(RailsishRubyUnit::Executable.model_class?, "Define a class named #{RailsishRubyUnit::Executable.model_name?} or redefine model_name? to return correct class name.")
    RailsishRubyUnit::Executable.model_class?.assert_invariant
    #	fail "got to end of default test."
  end # class_assert_invariant
end # DefaultTests1
module DefaultTests2
  include DefaultTests1
  include ExampleCall
  def assert_environment
    warn { assert_equal(TestCase, self.class.superclass) }
    message = "self=#{inspect}"
    puts message
    message += "\nself.included_modules=#{included_modules.inspect}"
    assert_includes(included_modules, AssertionsModule, message)
    assert_includes(included_modules, DefaultTests0, message)
    assert_respond_to(RailsishRubyUnit::Executable, :model_class?, message)
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, AssertionsModule, message)
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, Regexp::Assertions, message)
    # ?  assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, Regexp::Assertions::ClassMethods, message)
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, Regexp::Examples, message)
  end # assert_environment

  def test_aaa_environment
    info "$VERBOSE=#{$VERBOSE.inspect}"
    return if RailsishRubyUnit::Executable.model_class?.nil?
    included_module_names = RailsishRubyUnit::Executable.model_class?.included_modules.map(&:name)
    info "included_module_names=#{included_module_names.inspect}"
    assert_includes(self.class.included_modules, AssertionsModule)
    #	assert_includes(RailsishRubyUnit::Executable.model_class?.methods(true), :explain_assert_respond_to, "Need to require ../../test/assertions/ruby_assertions.rb in #{RailsishRubyUnit::Executable.assertions_pathname?}")
    refute_includes(methods(false), :explain_assert_respond_to)
    refute_includes(self.class.methods(false), :explain_assert_respond_to)
    # startup allowed	assert_equal([], self.class.methods(false))
    #	puts "model_class?::Examples.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.inspect}"
    #	puts "model_class?::Examples.constants.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.constants.inspect}"
    #	puts "model_class?::Examples.instance_methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.instance_methods.inspect}"
    #	puts "model_class?::Examples.methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.methods.inspect}"
    #	puts "model_class?::Assertions.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.inspect}"
    #	puts "model_class?::Assertions.constants.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.constants.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Assertions.instance_methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.instance_methods.inspect}"
    #	puts "model_class?::Assertions.methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.methods.inspect}"
    message = "Define a class named #{RailsishRubyUnit::Executable.model_name?} or redefine model_name? to return correct class name."
    message += "\nself.class.name=#{self.class.name}"
    message += "\nmodel_name?=#{RailsishRubyUnit::Executable.model_name?}"
    message += "\nmodel_class?=#{RailsishRubyUnit::Executable.model_class?}"
    message += "\nor require '#{RailsishRubyUnit::Executable.model_pathname?}'"
    refute_nil(self.class.name, message)
    refute_nil(RailsishRubyUnit::Executable.model_name?, message)
    refute_nil(RailsishRubyUnit::Executable.model_class?, message)
    warn { assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, RailsishRubyUnit::Executable.model_class?::Assertions, "Need to include #{RailsishRubyUnit::Executable.model_class?::Assertions}") }
    warn { assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, AssertionsModule) }
    #	assert_equal('AssertionsModule', self.class.name)
    #	assert_equal([MiniTest::Assertions], self.class.included_modules)
    #	assert_equal([Module, Object, AssertionsModule, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
    #	fail "got to end of related_files ."
    constant_names = RailsishRubyUnit::Executable.model_class?::Examples.constants
    info "constant_names=#{constant_names}" if $VERBOSE
    constant_objects = constant_names.map do |c|
      assert_instance_of(Symbol, c)
      hiearchical_name = c.to_s.split('::')
      assert_equal(1, hiearchical_name.size)
      RailsishRubyUnit::Executable.model_class?::Examples.class_eval(c.to_s)
    end # map
    examples = constant_objects.select { |c| c.instance_of?(RailsishRubyUnit::Executable.model_class?) }
    info "examples=#{examples}" if $VERBOSE
    if examples.empty?
      message = "There are no example constants of type #{RailsishRubyUnit::Executable.model_class?} in #{RailsishRubyUnit::Executable.model_class?}::Examples."
      message += "\nconstant_objects=#{constant_objects.inspect}" if $VERBOSE
      warn message
    end # if
  end # test_aaa_environment

  def test_class_assert_pre_conditions
    existing_call(RailsishRubyUnit::Executable.model_class?, :assert_pre_conditions)
    #	fail "got to end of default test."
  end # class_assert_pre_conditions

  def test_class_assert_invariant
    #  existing_call(RailsishRubyUnit::Executable.model_class?, :assert_invariant)
    #	fail "got to end of default test."
  end # def assert_invariant

  def test_class_assert_post_conditions
    existing_call(RailsishRubyUnit::Executable.model_class?, :assert_post_conditions)
    #	fail "got to end of default test."
  end # class_assert_post_conditions

  # ClassMethods
  def test_assert_pre_conditions
    each_example { |e| existing_call(e, :assert_pre_conditions) }
  end # assert_pre_conditions

  def test_assert_invariant
    each_example { |e| assert_optional_method(e, :assert_invariant) }
  end # def assert_invariant

  def test_assert_post_conditions
    each_example { |e| existing_call(e, :assert_post_conditions) }
  end # assert_post_conditions
end # DefaultTests2
module DefaultTests3
  include DefaultTests2
  def test_assertion_inclusion
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, RailsishRubyUnit::Executable.model_class?::Assertions)
    assert_includes(RailsishRubyUnit::Executable.model_class?.ancestors, AssertionsModule)
  end # test_assertion_inclusion

  def test_related_files
    assert_includes(self.class.included_modules, AssertionsModule)
    #	assert_includes(self.class.included_modules, DefaultAssertionTests)
    assert_includes(methods(true), :explain_assert_respond_to, 'Need to require ../../test/assertions/ruby_assertions.rb in ?')
    refute_includes(methods(false), :explain_assert_respond_to)
    refute_includes(self.class.methods(false), :explain_assert_respond_to)
    assert_equal([], self.class.methods(false))
    #	puts "RailsishRubyUnit::Executable.model_class?::Examples.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Examples.constants.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.constants.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Examples.instance_methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.instance_methods.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Examples.methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Examples.methods.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Assertions.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Assertions.constants.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.constants.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Assertions.instance_methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.instance_methods.inspect}"
    #	puts "RailsishRubyUnit::Executable.model_class?::Assertions.methods.inspect=#{RailsishRubyUnit::Executable.model_class?::Assertions.methods.inspect}"
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, RailsishRubyUnit::Executable.model_class?::Assertions, "Need to include #{RailsishRubyUnit::Executable.model_class?::Assertions}")
    assert_includes(RailsishRubyUnit::Executable.model_class?.included_modules, AssertionsModule)
    #	assert_equal('AssertionsModule', self.class.name)
    #	assert_equal([MiniTest::Assertions], self.class.included_modules)
    #	assert_equal([Module, Object, AssertionsModule, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
    #	fail "got to end of default test."
  end # test_test_case
end # DefaultTests3
module DefaultTests4
  include DefaultTests3
end # DefaultTests4
class DefaultTestCase0 < BaseTestCase # doesn't follow any class filenaming conventions
  def name_of_test?
    self.class.name
  end # name_of_test?

  # Extract model name from test name if Rails-like naming convention is followed
  def model_name?
    name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '').to_sym
  end # model_name?

  def model_class?
    eval(model_name?.to_s)
  rescue
    nil
    # begin rescue
  end # model_class?

  def table_name?
    model_name?.to_s.tableize
  end # table_name?

  def names_of_tests?
    methods(true).select do |m|
      m.match(/^test(_class)?_assert_(invariant|pre_conditions|post_conditions)/)
    end # map
  end # names_of_tests

  def global_class_names
    Module.constants.select { |n| eval(n.to_s).instance_of?(Class) }
  end # global_class_names

  def default_message(&local_variables_block)
    # TMI	message = "\n self=#{self.inspect}\n"
    caller_binding = local_variables_block.binding
    "\nlocal_variables:" +
      local_variables_block.yield.map do |name|
        "\n  " + name.to_s + ' = ' +
          caller_binding.local_variable_get(name).inspect
      end.join # map
  end # default_message
end # DefaultTestCase0
class DefaultTestCase1 < DefaultTestCase0 # test file only
end # DefaultTestCase1

class DefaultTestCase2 < DefaultTestCase1 # test and model files
end # DefaultTestCase2

class DefaultTestCase3 < DefaultTestCase2 # test, model, and assertion files
end # DefaultTestCase3

class DefaultTestCase4 < DefaultTestCase3 # test, model, assertion, and assertion test files
  # require_relative '../../app/models/assertions.rb'

  extend AssertionsModule
  # assert_includes(methods, :model_class?)
  # assert_includes(self.class.methods, :model_class?)
  # include "#{DefaultAssertionTests.model_class?}::Examples"
end # DefaultTestCase4

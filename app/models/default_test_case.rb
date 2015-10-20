###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require_relative 'test_environment_ruby.rb'
module ExampleCall
def examples_submodule?
  model_class?::Examples
end # example_submodule
# klass filters example constants by type
def example_constants?(klass = nil)
  all = examples_submodule.constants
  unless klass.nil? then
	all.select {|ec| ec.instance_of(klass)}
  end #
end # example_submodule
def each_example(&block)
  return if model_class?.nil?
  assert_equal(examples_submodule?, model_class?::Examples)
  assert(model_class?.const_defined?(:Examples))
  if  model_class?.const_defined?(:Examples) then
#    info "model_class?.constants=#{model_class?.constants}"
    constant_objects=model_class?.constants.map{|c| model_class?.class_eval(c.to_s)}
#verbose    info "constant_objects=#{constant_objects}"
    examples=constant_objects.select{|c| c.instance_of?(Regexp)}
    if examples.empty? then
#once      warn "There are no example constants of type #{model_class?} in #{model_class?}::Examples."
    else
      examples.each do |c|
        info "calling block on #{c.inspect}"
        block.call(c)
      end #each
    end #if
  else
    warn "There is no module #{model_class?.to_s}::Examples."
  end #if
end #each_example
# Call method symbol on object if method exists
def existing_call(object, symbol)
 if object.respond_to?(symbol) then
   info "method #{symbol.inspect} does  exist for object of type #{object.class.name}"
   assert_respond_to(object, symbol)
   object.method(symbol).call
 else
	message="method #{symbol} does not exist for object "
	if object.respond_to?(:name) then
		message+="named #{object.name}"
	else
		message+="of type #{object.class.name}"
	end #if
   warn message
 end #if
end #existing_call
def named_object?(object)
	if object.respond_to?(:name) then
		"named #{object.name}"
	else
		"of type #{object.class.name}"
	end #if
end #named_object?
def assert_optional_method(object, symbol)
 if object.respond_to?(symbol) then
   info "method #{symbol.inspect} does exist for object of type #{object.class.name}"
   assert_respond_to(object, symbol)
   object.method(symbol).call
 else
	message="method #{symbol} does not exist for object "+named_object?(object)
   warn message
 end #if
end #
end #ExampleCall
module DefaultTests0
#require_relative '../../app/models/assertions.rb'

#extend AssertionsModule
def related_files?
	Unit.new(model_name?)
end #related_files
end #DefaultTests0
module DefaultTests1
include DefaultTests0
def test_case_pre_conditions
	assert_equal([DefaultTests1], Module.nesting)
	caller_message=" callers=#{caller.join("\n")}"
	assert_equal('Test', self.class.name[-4..-1], "2Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_message)
	assert_operator(1, :<=, names_of_tests?.size, "#{names_of_tests?.sort}")
end #test_case_pre_conditions
def test_class_assert_invariant
#	assert_includes(Module.constants, model_name?)
#	refute_nil(model_class?, "Define a class named #{TE.model_name?} or redefine model_name? to return correct class name.")
	model_class?.assert_invariant
#	fail "got to end of default test."
end # class_assert_invariant
end #DefaultTests1
module DefaultTests2
include DefaultTests1
include ExampleCall
def assert_environment
  warn {assert_equal(TestCase, self.class.superclass)}
  message= "self=#{self.inspect}"
  puts message
  message+= "\nself.included_modules=#{self.included_modules.inspect}"
  assert_includes(self.included_modules, AssertionsModule, message)
  assert_includes(self.included_modules, DefaultTests0, message)
  assert_respond_to(TE, :model_class?, message)
  assert_includes(TE.model_class?.included_modules, AssertionsModule, message)
  assert_includes(TE.model_class?.included_modules, Regexp::Assertions, message)
#?  assert_includes(TE.model_class?.included_modules, Regexp::Assertions::ClassMethods, message)
  assert_includes(TE.model_class?.included_modules, Regexp::Examples, message)
end #assert_environment
def test_aaa_environment
  info "$VERBOSE=#{$VERBOSE.inspect}"
  return if model_class?.nil?
  included_module_names=model_class?.included_modules.map{|m| m.name}
  info "included_module_names=#{included_module_names.inspect}"
  assert_includes(self.class.included_modules, AssertionsModule)
#	assert_includes(TE.model_class?.methods(true), :explain_assert_respond_to, "Need to require ../../test/assertions/ruby_assertions.rb in #{TE.assertions_pathname?}")
	refute_includes(self.methods(false), :explain_assert_respond_to)
	refute_includes(self.class.methods(false), :explain_assert_respond_to)
#startup allowed	assert_equal([], self.class.methods(false))
#	puts "model_class?::Examples.inspect=#{model_class?::Examples.inspect}"
#	puts "model_class?::Examples.constants.inspect=#{model_class?::Examples.constants.inspect}"
#	puts "model_class?::Examples.instance_methods.inspect=#{model_class?::Examples.instance_methods.inspect}"
#	puts "model_class?::Examples.methods.inspect=#{model_class?::Examples.methods.inspect}"
#	puts "model_class?::Assertions.inspect=#{model_class?::Assertions.inspect}"
#	puts "model_class?::Assertions.constants.inspect=#{model_class?::Assertions.constants.inspect}"
#	puts "model_class?::Assertions.instance_methods.inspect=#{model_class?::Assertions.instance_methods.inspect}"
#	puts "model_class?::Assertions.methods.inspect=#{model_class?::Assertions.methods.inspect}"
	message="Define a class named #{TE.model_name?} or redefine model_name? to return correct class name."
	message+="\nself.class.name=#{self.class.name}"
	message+="\nmodel_name?=#{TE.model_name?}"
	message+="\nmodel_class?=#{model_class?}"
	message+="\nor require '#{TE.model_pathname?}'"
	refute_nil(self.class.name, message)
	refute_nil(TE.model_name?, message)
	refute_nil(model_class?, message)
	warn{assert_includes(model_class?.included_modules, model_class?::Assertions, "Need to include #{model_class?::Assertions}")}
	warn{assert_includes(model_class?.included_modules, AssertionsModule)}
#	assert_equal('AssertionsModule', self.class.name)
#	assert_equal([MiniTest::Assertions], self.class.included_modules)
#	assert_equal([Module, Object, AssertionsModule, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
#	fail "got to end of related_files ."
    constant_names=model_class?::Examples.constants
    info "constant_names=#{constant_names}" if $VERBOSE
    constant_objects=constant_names.map do |c|
	assert_instance_of(Symbol, c)
	hiearchical_name = c.to_s.split('::')
	assert_equal(1, hiearchical_name.size)
	model_class?::Examples.class_eval(c.to_s)
    end # map
   examples=constant_objects.select{|c| c.instance_of?(model_class?)}
   info "examples=#{examples}"  if $VERBOSE
	if examples.empty? then
		message = "There are no example constants of type #{model_class?} in #{model_class?}::Examples."
		message += "\nconstant_objects=#{constant_objects.inspect}" if $VERBOSE
		warn message
	end #if
end #test_aaa_environment
def test_class_assert_pre_conditions
  existing_call(model_class?, :assert_pre_conditions)
#	fail "got to end of default test."
end #class_assert_pre_conditions
def test_class_assert_invariant
#  existing_call(model_class?, :assert_invariant)
#	fail "got to end of default test."
end #def assert_invariant
def test_class_assert_post_conditions
  existing_call(model_class?, :assert_post_conditions)
#	fail "got to end of default test."
end #class_assert_post_conditions
#ClassMethods
def test_assert_pre_conditions
  each_example {|e| existing_call(e, :assert_pre_conditions)}
end #assert_pre_conditions
def test_assert_invariant
  each_example {|e| assert_optional_method(e, :assert_invariant)}
end #def assert_invariant
def test_assert_post_conditions
  each_example {|e| existing_call(e, :assert_post_conditions)}
end #assert_post_conditions
end #DefaultTests2
module DefaultTests3
include DefaultTests2
def test_assertion_inclusion
	assert_includes(model_class?.included_modules, model_class?::Assertions)
	assert_includes(model_class?.ancestors, AssertionsModule)
end #test_assertion_inclusion
def test_related_files
	assert_includes(self.class.included_modules, AssertionsModule)
#	assert_includes(self.class.included_modules, DefaultAssertionTests)
	assert_includes(self.methods(true), :explain_assert_respond_to, "Need to require ../../test/assertions/ruby_assertions.rb in ?")
	refute_includes(self.methods(false), :explain_assert_respond_to)
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
	assert_includes(model_class?.included_modules, model_class?::Assertions, "Need to include #{model_class?::Assertions}")
	assert_includes(model_class?.included_modules, AssertionsModule)
#	assert_equal('AssertionsModule', self.class.name)
#	assert_equal([MiniTest::Assertions], self.class.included_modules)
#	assert_equal([Module, Object, AssertionsModule, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
#	fail "got to end of default test."
end #test_test_case
end #DefaultTests3
module DefaultTests4
include DefaultTests3
end #DefaultTests4
class DefaultTestCase0 < BaseTestCase # doesn't follow any class filenaming conventions
def name_of_test?
	self.class.name
end #name_of_test?
# Extract model name from test name if Rails-like naming convention is followed
def model_name?
	name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '').to_sym
end #model_name?
def model_class?
	begin
		eval(model_name?.to_s)
	rescue
		nil
	end #begin rescue
end #model_class?
def table_name?
	model_name?.to_s.tableize
end #table_name?
def names_of_tests?
	self.methods(true).select do |m|
		m.match(/^test(_class)?_assert_(invariant|pre_conditions|post_conditions)/) 
	end #map
end #names_of_tests
def global_class_names
	Module.constants.select {|n| eval(n.to_s).instance_of?(Class)}
end #global_class_names
def default_message(&local_variables_block)
#TMI	message = "\n self=#{self.inspect}\n"
	caller_binding = local_variables_block.binding
	"\nlocal_variables:" +
	local_variables_block.yield.map do |name|
		"\n  " + name.to_s + ' = ' +
		caller_binding.local_variable_get(name).inspect
	end.join # map
end # default_message
end #DefaultTestCase0
class DefaultTestCase1 < DefaultTestCase0 # test file only
end #DefaultTestCase1

class DefaultTestCase2 < DefaultTestCase1 # test and model files
end #DefaultTestCase2

class DefaultTestCase3 < DefaultTestCase2 # test, model, and assertion files
end #DefaultTestCase3

class DefaultTestCase4 < DefaultTestCase3# test, model, assertion, and assertion test files
#require_relative '../../app/models/assertions.rb'

extend AssertionsModule
#assert_includes(methods, :model_class?)
#assert_includes(self.class.methods, :model_class?)
#include "#{DefaultAssertionTests.model_class?}::Examples"
end #DefaultTestCase4

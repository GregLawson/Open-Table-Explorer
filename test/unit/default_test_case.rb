###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
#include TestIntrospection
BaseTestCase=ActiveSupport::TestCase
module DefaultTests0
require 'test/unit'
include Test::Unit::Assertions
def test_environment?
	NamingConvention.new(model_name?)
end #test_environment
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
#	assert_include(Module.constants, model_name?)
#	assert_not_nil(model_class?, "Define a class named #{TE.model_name?} or redefine model_name? to return correct class name.")
	model_class?.assert_invariant
#	fail "got to end of default test."
end # class_assert_invariant

def test_case_pre_conditions
end #test_case_pre_conditions
end #DefaultTests1
module DefaultTests2
include DefaultTests1
def test_class_assert_pre_conditions
	model_class?.assert_pre_conditions
#	fail "got to end of default test."
end #class_assert_pre_conditions
def test_class_assert_invariant
	model_class?.assert_invariant
#	fail "got to end of default test."
end #def assert_invariant
def test_class_assert_post_conditions
	model_class?.assert_post_conditions
#	fail "got to end of default test."
end #class_assert_post_conditions
#ClassMethods
def test_assert_pre_conditions
	model_class?.example_constant_values_by_class(model_class?).each do |c|
		assert_not_nil(c, "nil in test_assert_pre_conditions?")
#		assert_not_empty(c, "empty test_assert_pre_conditions")
		c.assert_pre_conditions
	end #each
#	fail "got to end of default test."
end #assert_pre_conditions
def test_assert_invariant
	model_class?.example_constant_values_by_class(model_class?).each do |c|
		c.assert_invariant
	end #each
#	fail "got to end of default test."
end #def assert_invariant
def test_assert_post_conditions
	model_class?.example_constant_values_by_class(model_class?).each do |c|
		c.assert_post_conditions
	end #each
#	fail "got to end of default test."
end #assert_post_conditions
def self.assert_invariant
	fail "got here=self.assert_invariant"
end # class_assert_invariant
def test_aaa_environment
	assert_include(self.class.included_modules, Test::Unit::Assertions)
#	assert_include(self.class.included_modules, DefaultAssertionTests)
#	assert_include(self.methods(true), :explain_assert_respond_to, "Need to require ../../test/assertions/ruby_assertions.rb in #{assertions_pathname?}")
	assert_not_include(self.methods(false), :explain_assert_respond_to)
	assert_not_include(self.class.methods(false), :explain_assert_respond_to)
	assert_equal([], self.class.methods(false))
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
	assert_not_nil(self.class.name, message)
	assert_not_nil(TE.model_name?, message)
	assert_not_nil(model_class?, message)
	assert_include(model_class?.included_modules, model_class?::Assertions, "Need to include #{model_class?::Assertions}")
	assert_include(model_class?.included_modules, Test::Unit::Assertions)
#	assert_equal('Test::Unit::Assertions', self.class.name)
#	assert_equal([MiniTest::Assertions], self.class.included_modules)
#	assert_equal([Module, Object, Test::Unit::Assertions, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
#	fail "got to end of test_environment ."
end #test_test_environment
end #DefaultTests2
module DefaultTests3
include DefaultTests2
def test_assertion_inclusion
	assert_include(model_class?.included_modules, model_class?::Assertions)
	assert_include(model_class?.ancestors, Test::Unit::Assertions)
	assert_include(model_class?.ancestors, model_class?::Examples, "module #{model_class?}::Examples  should exist in class #{model_class?}.\nPlace 'include Examples' within class #{model_class?} scope in assertions file.")
	assert_include(model_class?.ancestors, DefaultAssertions, "module DefaultAssertions  should exist in class #{model_class?}.\nPlace 'include DefaultAssertions' within class #{model_class?} scope in assertions file.")
	assert_include(model_class?.included_modules, model_class?::Examples, "module Examples  should be included in class #{model_class?}")
	assert_include(model_class?.methods, :example_constant_names_by_class, "module DefaultAssertions::ClassMethods (including :example_constant_names_by_class) should exist in class #{model_class?}.\nPlace 'extend DefaultAssertions::ClassMethods' within class #{model_class?} scope in assertions file.")
	assert_respond_to(model_class?, :example_constant_names_by_class, "model_class?=#{model_class?}")
#	assert_respond_to(model_class?, :example_constant_names_by_class)
#	assert_include(model_class?.methods, :example_constant_names_by_class, "model_class?=#{model_class?}")
end #test_assertion_inclusion
def test_test_environment
	assert_include(self.class.included_modules, Test::Unit::Assertions)
#	assert_include(self.class.included_modules, DefaultAssertionTests)
	assert_include(self.methods(true), :explain_assert_respond_to, "Need to require ../../test/assertions/ruby_assertions.rb in #{assertions_pathname?}")
	assert_not_include(self.methods(false), :explain_assert_respond_to)
	assert_not_include(self.class.methods(false), :explain_assert_respond_to)
	assert_equal([], self.class.methods(false))
#	puts "model_class?::Examples.inspect=#{model_class?::Examples.inspect}"
#	puts "model_class?::Examples.constants.inspect=#{model_class?::Examples.constants.inspect}"
#	puts "model_class?::Examples.instance_methods.inspect=#{model_class?::Examples.instance_methods.inspect}"
#	puts "model_class?::Examples.methods.inspect=#{model_class?::Examples.methods.inspect}"
#	puts "model_class?::Assertions.inspect=#{model_class?::Assertions.inspect}"
#	puts "model_class?::Assertions.constants.inspect=#{model_class?::Assertions.constants.inspect}"
#	puts "model_class?::Assertions.instance_methods.inspect=#{model_class?::Assertions.instance_methods.inspect}"
#	puts "model_class?::Assertions.methods.inspect=#{model_class?::Assertions.methods.inspect}"
	assert_include(model_class?.included_modules, model_class?::Assertions, "Need to include #{model_class?::Assertions}")
	assert_include(model_class?.included_modules, Test::Unit::Assertions)
#	assert_equal('Test::Unit::Assertions', self.class.name)
#	assert_equal([MiniTest::Assertions], self.class.included_modules)
#	assert_equal([Module, Object, Test::Unit::Assertions, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
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
end #DefaultTestCase0
class DefaultTestCase1 < DefaultTestCase0 # test file only
#include DefaultAssertions
#extend DefaultAssertions::ClassMethods
end #DefaultTestCase1

class DefaultTestCase2 < DefaultTestCase1 # test and model files
end #DefaultTestCase2

class DefaultTestCase3 < DefaultTestCase2 # test, model, and assertion files
def assertions_pathname?
	"../assertions/"+TE.model_name?+"_assertions.rb"
end #assertions_pathname?
end #DefaultTestCase3

class DefaultTestCase4 < DefaultTestCase3# test, model, assertion, and assertion test files
require 'test/unit'
include Test::Unit::Assertions
extend Test::Unit::Assertions
#assert_include(methods, :model_class?)
#assert_include(self.class.methods, :model_class?)
#include "#{DefaultAssertionTests.model_class?}::Examples"
end #DefaultTestCase4

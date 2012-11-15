###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module DefaultAssertionTests
include Test::Unit::Assertions
extend Test::Unit::Assertions
# methods to extract model, class from TestCase subclass
def name_of_test?
	self.class.name
end #name_of_test?
# Extract model name from test name if Rails-like naming convention is followed
def model_name?
	name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '')
end #model_name?
def table_name?
	model_name?.tableize
end #table_name?
def model_class?
	eval(model_name?)
end #model_class?
def names_of_tests?
	self.methods(true).select do |m|
		m.match(/^test(_class)?_assert_(invariant|pre_conditions|post_conditions)/) 
	end #map
end #names_of_tests?
#assert_include(methods, :model_class?)
#assert_include(self.class.methods, :model_class?)
#include "#{DefaultAssertionTests.model_class?}::TestCases"
def test_test_case
	assert_equal(self.class.name[-4..-1], 'Test')
	assert_equal(6, names_of_tests?.size, "#{names_of_tests?.sort}")
	assert_equal([DefaultAssertionTests], Module.nesting)
	assert_equal([DefaultAssertionTests, Test::Unit::Assertions, MiniTest::Assertions, PP::ObjectMixin, Kernel], self.class.included_modules)
	assert_include(self.methods(true), :explain_assert_respond_to)
	assert_not_include(self.methods(false), :explain_assert_respond_to)
	assert_not_include(self.class.methods(false), :explain_assert_respond_to)
	assert_equal([], self.class.methods(false))
	puts "model_class?::TestCases.inspect=#{model_class?::TestCases.inspect}"
	puts "model_class?::TestCases.constants.inspect=#{model_class?::TestCases.constants.inspect}"
	puts "model_class?::TestCases.instance_methods.inspect=#{model_class?::TestCases.instance_methods.inspect}"
	puts "model_class?::TestCases.methods.inspect=#{model_class?::TestCases.methods.inspect}"
	puts "model_class?::Assertions.inspect=#{model_class?::Assertions.inspect}"
	puts "model_class?::Assertions.constants.inspect=#{model_class?::Assertions.constants.inspect}"
	puts "model_class?::Assertions.instance_methods.inspect=#{model_class?::Assertions.instance_methods.inspect}"
	puts "model_class?::Assertions.methods.inspect=#{model_class?::Assertions.methods.inspect}"
	assert_include(model_class?.included_modules, model_class?::Assertions)
	assert_include(model_class?.included_modules, Test::Unit::Assertions)
#	assert_equal('Test::Unit::Assertions', self.class.name)
#	assert_equal([MiniTest::Assertions], self.class.included_modules)
#	assert_equal([Module, Object, Test::Unit::Assertions, MiniTest::Assertions, PP::ObjectMixin, Kernel, BasicObject], self.class.ancestors)
	assert_include(model_class?.methods, :example_constants_by_class, "model_class?=#{model_class?}")
	assert_respond_to(model_class?, :example_constants_by_class, "model_class?=#{model_class?}")
#	assert_respond_to(model_class?, :example_constants_by_class)
#	assert_include(model_class?.methods, :example_constants_by_class, "model_class?=#{model_class?}")
	fail "got to end of default test."
end #test_test_case
def test_class_assert_invariant
	#puts "self.class.methods(true)=#{self.class.methods(true)}"
	model_class?.assert_invariant
	fail "got to end of default test."
end # class_assert_invariant
def test_class_assert_pre_conditions
	model_class?.assert_pre_conditions
	fail "got to end of default test."
end #class_assert_pre_conditions
def test_class_assert_post_conditions
	model_class?.example_constants_by_class(model_class?).each do |c|
		c.assert_pre_conditions
	end #each
	fail "got to end of default test."
end #class_assert_post_conditions
def test_assert_pre_conditions
	model_class?.example_constants_by_class(model_class?).each do |c|
		c.assert_pre_conditions
	end #each
	fail "got to end of default test."
end #assert_pre_conditions
def test_assert_invariant
	model_class?.example_constants_by_class(model_class?).each do |c|
		c.assert_invariant
	end #each
	fail "got to end of default test."
end #def assert_invariant
def test_assert_post_conditions
	model_class?.example_constants_by_class(model_class?).each do |c|
		c.assert_post_conditions
	end #each
	fail "got to end of default test."
end #assert_post_conditions
end #DefaultAssertionTests

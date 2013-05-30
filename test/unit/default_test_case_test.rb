###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/unit/default_test_case.rb'
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest
require_relative '../../app/models/unbounded_fixnum.rb'
class TestEnvironmentTest < TestCase
include TestIntrospection::TestEnvironment::Examples
def test_model_basename
	assert_equal('test/unit/default_test_case_test.rb', $0)
	assert_equal('test/unit/default_test_case_test.rb', __FILE__)
	assert_equal('test/unit', File.dirname($0))
	assert_equal('default_test_case_test.rb', File.basename($0))
	assert_equal('.rb', File.extname($0))
	assert_equal('default_test_case_test', File.basename($0, '.rb'))
	assert_equal('default_test_case', File.basename($0, '.rb')[0..-6])
	assert_equal('default_test_case', model_basename?)
end #model_basename
def test_class_name
	assert_equal('DefaultTestCase', class_name?)
end #class_name
def test_initialize
#	model_name=
	assert_equal('test/unit/default_test_case_test.rb', __FILE__)
	assert_equal('test/unit', File.dirname(__FILE__))
	te=TestIntrospection::TestEnvironment.new(model_name?)
	
	assert_respond_to(UnboundedFixnumTestEnvironment, :model_basename)
	assert_equal(:unbounded_fixnum, UnboundedFixnumTestEnvironment.model_basename)	
	assert_equal(:unbounded_fixnum, TestIntrospection::TestEnvironment.new(:UnboundedFixnumTest).model_basename)
end #initialize
def test_inspect
	assert_match(/exist/, UnboundedFixnumTestEnvironment.inspect)
end #inspect
def test_model_pathname
	assert(File.exists?(UnboundedFixnumTestEnvironment.model_pathname?))
	assert_data_file(UnboundedFixnumTestEnvironment.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumTestEnvironment.model_test_pathname?))
	assert_data_file(UnboundedFixnumTestEnvironment.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumTestEnvironment.assertions_pathname?))
	assert_data_file(UnboundedFixnumTestEnvironment.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumTestEnvironment.inspect)
	assert_not_nil(UnboundedFixnumTestEnvironment.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumTestEnvironment)
	assert(File.exists?(UnboundedFixnumTestEnvironment.assertions_test_pathname?))
	assert_data_file(UnboundedFixnumTestEnvironment.assertions_test_pathname?)
end #assertions_test_pathname?
def test_default_test_class_id
	assert_equal(4, UnboundedFixnumTestEnvironment.default_test_class_id?)
	default_test_symbol=TestIntrospection::TestEnvironment.new(model_name?).default_test_class_id?
	assert_equal(0, default_test_symbol)
	assert_equal(0, TestIntrospection::TestEnvironment.new(model_name?).default_test_class_id?)
	tests=eval("DefaultTests"+default_test_symbol.to_s)
	assert_path_to_constant(:DefaultTestCase0)
	assert_path_to_constant(:DefaultTestCase1)
	assert_path_to_constant(:DefaultTestCase2)
	assert_path_to_constant(:DefaultTestCase3)
	assert_path_to_constant(:DefaultTestCase4)
	test_case=eval("DefaultTestCase"+default_test_symbol.to_s)
	assert_path_to_constant(:DefaultTests1)
	assert_path_to_constant(:DefaultTests2)
	assert_path_to_constant(:DefaultTests3)
	assert_path_to_constant(:DefaultTests4)
end #default_test_class_id
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumTestEnvironment.pathnames?)
	assert_equal(4, UnboundedFixnumTestEnvironment.pathnames?.size)
	assert_array_of(UnboundedFixnumTestEnvironment.pathnames?, String)
end #pathnames
def test_absolute_pathnames
	assert_instance_of(Array, UnboundedFixnumTestEnvironment.absolute_pathnames?)
	assert_equal(4, UnboundedFixnumTestEnvironment.absolute_pathnames?.size)
	assert_array_of(UnboundedFixnumTestEnvironment.absolute_pathnames?, String)
end #absolute_pathnames
def test_pathname_existance
	assert_instance_of(Array, UnboundedFixnumTestEnvironment.pathname_existance?)
	assert_equal(4, UnboundedFixnumTestEnvironment.pathname_existance?.size)
	assert_array_of(UnboundedFixnumTestEnvironment.pathname_existance?, Fixnum)
	UnboundedFixnumTestEnvironment.pathname_existance?.all? do |e|
		e
	end #all
end #pathname_existance
end #TestEnvironment


require_relative '../../test/assertions/default_assertions.rb'
class ClassExists
include DefaultAssertions
extend DefaultAssertions::ClassMethods
def self.assert_invariant
	assert_equal(:ClassExists, self.name.to_sym, caller_lines)
	assert_instance_of(Class, self)
end # class_assert_invariant
end #ClassExists

class ClassExistsTest < DefaultTestCase1
def test_name_of_test
	assert_equal('Test', self.class.name[-4..-1], "2Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_lines)
	assert_equal('ClassExistsTest', name_of_test?, "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_lines)
end #name_of_test?
def test_global_class_names
	constants=Module.constants
	assert_instance_of(Array, constants)
	constants.select {|n| eval(n.to_s).instance_of?(Class)}
	assert_include(global_class_names, self.class.name.to_sym)
end #global_classes
include Test::Unit::Assertions
extend Test::Unit::Assertions
def test_case_assert_invariant
	caller_message=" callers=#{caller.join("\n")}"
	assert_equal('Test', self.class.name[-4..-1], "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_message)
end #assert_invariant
def test_assert_class_invariant
	assert_include(Module.constants, :ClassExists)
end #test_assert_class_invariant
include DefaultTests1
end #ClassExistsTest

require_relative '../../test/assertions/minimal_assertions.rb'
class MinimalTest < TestCase
extend DefaultAssertions::ClassMethods
def test_example_constants_by_class
	assert_include(Minimal.constants, :Constant)
	assert_equal(Minimal::Constant, Minimal.value_of_example?(:Constant))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum, /on/))
end #example_constant_names_by_class
def test_TestIntrospection_TestEnvironment
	te=TestIntrospection::TestEnvironment.new(model_name?)
	default_test_symbol=te.default_test_class_id?
	default_tests=eval("DefaultTests"+default_test_symbol.to_s)
	default_test_case=eval("DefaultTestCase"+default_test_symbol.to_s)
end #test_TestIntrospection_TestEnvironment
end #MinimalTest

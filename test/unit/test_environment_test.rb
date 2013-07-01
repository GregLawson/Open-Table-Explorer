###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/unit/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest
require_relative '../../app/models/unbounded_fixnum.rb'
class TestEnvironmentTest < TestCase
#include DefaultTests2 # correct but should be computed
include DefaultTests    #less error messages
include TestEnvironment::Examples
include TestEnvironment::Assertions
include TestEnvironment::Assertions::KernelMethods
extend TestEnvironment::Assertions::ClassMethods
def test_initialize
	assert_respond_to(UnboundedFixnumTestEnvironment, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumTestEnvironment.model_basename)	
	assert_equal('unbounded_fixnum', TestEnvironment.new(:UnboundedFixnum).model_basename)
	model_class_name=path2model_name?
	assert_equal(:TestEnvironment, model_class_name)
	project_root_dir=project_root_dir?
	te=TestEnvironment.new(TE.model_name?)
	assert_equal(:TestEnvironment, te.model_class_name)
	assert_equal(:TestEnvironment, SELF.model_class_name)
	assert_equal('test_environment', TE.model_basename)
	assert_not_empty(TE.project_root_dir)
end #initialize
def test_inspect
#	assert_match(/exist/, UnboundedFixnumTestEnvironment.inspect)
end #inspect
def test_model_pathname
	assert(File.exists?(UnboundedFixnumTestEnvironment.model_pathname?), UnboundedFixnumTestEnvironment.model_pathname?)
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
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumTestEnvironment.inspect)
	assert(File.exists?(UnboundedFixnumTestEnvironment.assertions_test_pathname?), UnboundedFixnumTestEnvironment.inspect)
	assert_data_file(UnboundedFixnumTestEnvironment.assertions_test_pathname?)
end #assertions_test_pathname?
def test_data_sources_directory
	assert_pathname_exists(TE.data_sources_directory?)
end #data_sources_directory
def test_default_test_class_id
	assert_path_to_constant(:DefaultTestCase0)
	assert_path_to_constant(:DefaultTestCase1)
	assert_path_to_constant(:DefaultTestCase2)
	assert_path_to_constant(:DefaultTestCase3)
	assert_path_to_constant(:DefaultTestCase4)
	assert_path_to_constant(:DefaultTests0)
	assert_path_to_constant(:DefaultTests1)
	assert_path_to_constant(:DefaultTests2)
	assert_path_to_constant(:DefaultTests3)
	assert_path_to_constant(:DefaultTests4)
	assert_equal(4, UnboundedFixnumTestEnvironment.default_test_class_id?, UnboundedFixnumTestEnvironment.inspect)
	
	default_test_class_id=TestEnvironment.new(TE.model_name?).default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
	assert_equal(2, default_test_class_id, TE.inspect)
	assert_equal(2, TestEnvironment.new(TE.model_name?).default_test_class_id?, TE.inspect)
	assert_equal(1, TestEnvironment.new('DefaultTestCase').default_test_class_id?)
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
include TestEnvironment::Assertions
extend TestEnvironment::Assertions::ClassMethods
#def test_class_assert_invariant
#	TestEnvironment.assert_invariant
#end # class_assert_invariant
def test_class_assert_pre_conditions
	TestEnvironment.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
	TestEnvironment.assert_post_conditions
end #class_assert_post_conditions
def test_assert_default_test_class_id
#	assert_constant_path_respond_to(:TestIntrospection, :TestEnvironment, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(TestEnvironmentTest, :assert_default_test_class_id)
	explain_assert_respond_to(self, :assert_default_test_class_id)
	assert_default_test_class_id(4,'UnboundedFixnum')
	assert_default_test_class_id(2,'TestEnvironment')
	assert_default_test_class_id(1,'DefaultTestCase')
	assert_default_test_class_id(0,'EmptyDefaultTest')
	assert_default_test_class_id(3,'GenericType')
end #default_test_class_id
def tesst_assert_invariant
end #assert_invariant
def tesst_assert_pre_conditions
end #assert_pre_conditions
def tesst_assert_post_conditions
end #assert_post_conditions
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


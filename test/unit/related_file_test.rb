###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require_relative '../../test/unit/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/related_file.rb'
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest
require_relative '../../app/models/unbounded_fixnum.rb'
class RelatedFilesTest <  DefaultTestCase2
#include DefaultTests2 
#include DefaultTests0    #less error messages
def test_initialize
	assert_respond_to(UnboundedFixnumRelatedFiles, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumRelatedFiles.model_basename)	
	assert_equal('unbounded_fixnum', RelatedFiles.new(:UnboundedFixnum).model_basename)
	model_class_name=NamingConvention.path2model_name?
	assert_equal(:NamingConvention, model_class_name)
	project_root_dir=NamingConvention.project_root_dir?
	te=NamingConvention.new(SELF.model_name?)
	assert_equal(:NamingConvention, te.model_class_name)
	assert_equal(:NamingConvention, SELF.model_class_name)
	assert_equal('naming_convention', SELF.model_basename)
	assert_not_empty(SELF.project_root_dir)
end #initialize
def test_equals
	assert(NamingConvention.new==NamingConvention.new)
end #==
def test_model_pathname
	assert(File.exists?(UnboundedFixnumRelatedFiles.model_pathname?), UnboundedFixnumRelatedFiles.model_pathname?)
	assert_data_file(UnboundedFixnumRelatedFiles.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumRelatedFiles.model_test_pathname?))
	assert_data_file(UnboundedFixnumRelatedFiles.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumRelatedFiles.assertions_pathname?))
	assert_data_file(UnboundedFixnumRelatedFiles.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFiles.inspect)
	assert_not_nil(UnboundedFixnumRelatedFiles.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFiles.inspect)
	assert(File.exists?(UnboundedFixnumRelatedFiles.assertions_test_pathname?), UnboundedFixnumRelatedFiles.inspect)
	assert_data_file(UnboundedFixnumRelatedFiles.assertions_test_pathname?)
end #assertions_test_pathname?
def test_data_sources_directory
#	assert_pathname_exists(TE.data_sources_directory?)
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
	assert_equal(4, UnboundedFixnumRelatedFiles.default_test_class_id?, UnboundedFixnumRelatedFiles.inspect)
	te=RelatedFiles.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
	assert_equal(2, default_test_class_id, te.inspect)
	assert_equal(2, RelatedFiles.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, RelatedFiles.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumRelatedFiles.pathnames?)
	assert_equal(5, UnboundedFixnumRelatedFiles.pathnames?.size)
	assert_array_of(UnboundedFixnumRelatedFiles.pathnames?, String)
	pathnames=Patterns.map do |p|
		UnboundedFixnumRelatedFiles.pathname_pattern?(p[:name])
	end #
	assert_equal(UnboundedFixnumRelatedFiles.pathnames?, pathnames)
end #pathnames
def test_model_class
	assert_equal(RelatedFiles, SELF.model_class?)
end #model_class
def test_model_name
	assert_equal(:RelatedFiles, SELF.model_name?)
end #model_name?
include RelatedFiles::Assertions
extend RelatedFiles::Assertions::ClassMethods
#def test_class_assert_invariant
#	RelatedFiles.assert_invariant
#end # class_assert_invariant
def test_class_assert_pre_conditions
#	NamingConvention.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
#	NamingConvention.assert_post_conditions
end #class_assert_post_conditions
def test_assert_default_test_class_id
#	RelatedFilesassert_constant_path_respond_to(:TestIntrospection, :RelatedFiles, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(RelatedFilesTest, :assert_default_test_class_id)
#	explain_assert_respond_to(self, :assert_default_test_class_id)
#	assert_default_test_class_id(4,'UnboundedFixnum')
#	assert_default_test_class_id(2,'RelatedFiles')
#	assert_default_test_class_id(1,'DefaultTestCase')
#	assert_default_test_class_id(0,'EmptyDefaultTest')
#	assert_default_test_class_id(3,'GenericType')
end #default_test_class_id
def test_initialize
	assert_respond_to(UnboundedFixnumRelatedFiles, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumRelatedFiles.model_basename)	
	assert_equal('unbounded_fixnum', RelatedFiles.new(:UnboundedFixnum).model_basename)
	model_class_name=NamingConvention.path2model_name?
	assert_equal(:RelatedFiles, model_class_name)
	project_root_dir=NamingConvention.project_root_dir?
	te=RelatedFiles.new(SELF.model_name?)
	assert_equal(:RelatedFiles, te.model_class_name)
	assert_equal(:RelatedFiles, SELF.model_class_name)
	assert_equal('naming_convention', SELF.model_basename)
	assert_not_empty(SELF.project_root_dir)
end #initialize
def test_equals
	assert(RelatedFiles.new==RelatedFiles.new)
end #==
def test_model_pathname
	assert(File.exists?(UnboundedFixnumNamingConvention.model_pathname?), UnboundedFixnumRelatedFiles.model_pathname?)
	assert_data_file(UnboundedFixnumRelatedFiles.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumRelatedFiles.model_test_pathname?))
	assert_data_file(UnboundedFixnumRelatedFiles.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumRelatedFiles.assertions_pathname?))
	assert_data_file(UnboundedFixnumRelatedFiles.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFiles.inspect)
	assert_not_nil(UnboundedFixnumRelatedFiles.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFiles.inspect)
	assert(File.exists?(UnboundedFixnumRelatedFiles.assertions_test_pathname?), UnboundedFixnumRelatedFiles.inspect)
	assert_data_file(UnboundedFixnumRelatedFiles.assertions_test_pathname?)
end #assertions_test_pathname?
def test_data_sources_directory
#	assert_pathname_exists(TE.data_sources_directory?)
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
	assert_equal(4, UnboundedFixnumRelatedFiles.default_test_class_id?, UnboundedFixnumRelatedFiles.inspect)
	te=RelatedFiles.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
	assert_equal(2, default_test_class_id, te.inspect)
	assert_equal(2, RelatedFiles.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, RelatedFiles.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumNamingConvention.pathnames?)
	assert_equal(5, UnboundedFixnumNamingConvention.pathnames?.size)
	assert_array_of(UnboundedFixnumNamingConvention.pathnames?, String)
	pathnames=Patterns.map do |p|
		UnboundedFixnumNamingConvention.pathname_pattern?(p[:name])
	end #
	assert_equal(UnboundedFixnumNamingConvention.pathnames?, pathnames)
end #pathnames
def test_model_class
	assert_equal(RelatedFiles, SELF.model_class?)
end #model_class
def test_model_name
	assert_equal(:RelatedFiles, SELF.model_name?)
end #model_name?
end #RelatedFiles

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
#	assert_equal('ClassExistsTest', name_of_test?, "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_lines)
end #name_of_test?
def test_global_class_names
	constants=Module.constants
	assert_instance_of(Array, constants)
	constants.select {|n| eval(n.to_s).instance_of?(Class)}
	assert_include(global_class_names, self.class.name.to_sym)
end #global_classes
def test_case_assert_invariant
	caller_message=" callers=#{caller.join("\n")}"
	assert_equal('Test', self.class.name[-4..-1], "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_message)
end #assert_invariant
def test_assert_class_invariant
	assert_include(Module.constants, :ClassExists)
end #test_assert_class_invariant
def test_TestIntrospection_NamingConvention
	te=RelatedFiles.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	default_tests=eval("DefaultTests"+default_test_class_id.to_s)
	default_test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
end #test_TestIntrospection_NamingConvention
include DefaultTests1
end #ClassExistsTest


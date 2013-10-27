###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/related_file.rb'
require_relative '../../app/models/unbounded_fixnum.rb'
TE=RelatedFile.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
class RelatedFileTest <  DefaultTestCase2
include DefaultTests2 
#include DefaultTests0    #less error messages
include RelatedFile::Examples
def test_initialize
	assert_respond_to(UnboundedFixnumRelatedFile, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumRelatedFile.model_basename)	
	assert_equal('unbounded_fixnum', RelatedFile.new(:UnboundedFixnum).model_basename)
	model_class_name=FilePattern.path2model_name?
	assert_equal(:RelatedFile, model_class_name)
	project_root_dir=FilePattern.project_root_dir?
	assert_equal(:RelatedFile, SELF.model_class_name)
	assert_equal('related_file', SELF.model_basename)
	assert_not_empty(SELF.project_root_dir)
	SELF.assert_pre_conditions
	te=RelatedFile.new(SELF.model_name?)
	assert_equal(:RelatedFile, te.model_class_name)
	assert_equal(:RelatedFile, SELF.model_class_name)
end #initialize
def test_equals
	assert(RelatedFile.new==RelatedFile.new)
end #==
def test_model_pathname
	assert(File.exists?(UnboundedFixnumRelatedFile.model_pathname?), UnboundedFixnumRelatedFile.model_pathname?)
	assert_data_file(UnboundedFixnumRelatedFile.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumRelatedFile.model_test_pathname?))
	assert_data_file(UnboundedFixnumRelatedFile.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumRelatedFile.assertions_pathname?))
	assert_data_file(UnboundedFixnumRelatedFile.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFile.inspect)
	assert_not_nil(UnboundedFixnumRelatedFile.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumRelatedFile.inspect)
	assert(File.exists?(UnboundedFixnumRelatedFile.assertions_test_pathname?), UnboundedFixnumRelatedFile.inspect)
	assert_data_file(UnboundedFixnumRelatedFile.assertions_test_pathname?)
end #assertions_test_pathname?
def test_data_sources_directory
#	assert_pathname_exists(TE.data_sources_directory?)
end #data_sources_directory
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumRelatedFile.pathnames?)
	assert_operator(5, :<=, UnboundedFixnumRelatedFile.pathnames?.size)
	assert_array_of(UnboundedFixnumRelatedFile.pathnames?, String)
	pathnames=FilePattern::All.map do |p|
		UnboundedFixnumRelatedFile.		pathname_pattern?(p[:name])
	end #map
	assert_equal(UnboundedFixnumRelatedFile.pathnames?, pathnames)
	SELF.assert_pre_conditions
	SELF.assert_post_conditions
	assert_include(SELF.pathnames?, File.expand_path($0), SELF)
end #pathnames
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
	assert_equal(4, UnboundedFixnumRelatedFile.default_test_class_id?, UnboundedFixnumRelatedFile.inspect)
	te=RelatedFile.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
	assert_equal(2, default_test_class_id, te.inspect)
	assert_equal(2, RelatedFile.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, RelatedFile.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_tested_files
	executable=SELF.model_test_pathname?
	tested_files=SELF.tested_files(executable)
	assert_operator(SELF.default_test_class_id?, :<=, tested_files.size)
end #tested_files
def test_model_class
	assert_equal(RelatedFile, SELF.model_class?)
end #model_class
def test_model_name
	assert_equal(:RelatedFile, SELF.model_class_name)
	assert_equal(:RelatedFile, SELF.model_name?)
end #model_name?
include RelatedFile::Assertions
extend RelatedFile::Assertions::ClassMethods
def test_class_assert_pre_conditions
#	RelatedFile.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
#	RelatedFile.assert_post_conditions
end #class_assert_post_conditions
def test_assert_default_test_class_id
#	RelatedFile.assert_constant_path_respond_to(:TestIntrospection, :RelatedFile, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(RelatedFileTest, :assert_default_test_class_id)
#	explain_assert_respond_to(self, :assert_default_test_class_id)
	RelatedFile.new(:UnboundedFixnum).assert_default_test_class_id(4,'')
	RelatedFile.new(:RelatedFile).assert_default_test_class_id(2,'')
	RelatedFile.new(:DefaultTestCase).assert_default_test_class_id(1,'')
	RelatedFile.new(:EmptyDefaultTest).assert_default_test_class_id(0,'')
	RelatedFile.new(:GenericType).assert_default_test_class_id(3,'')
end #default_test_class_id
def test_Examples
	UnboundedFixnumRelatedFile.assert_pre_conditions
	UnboundedFixnumRelatedFile.assert_post_conditions
end #Examples
end #RelatedFile



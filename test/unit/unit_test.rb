###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/unbounded_fixnum.rb'
TE=Unit.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
class UnitTest <  DefaultTestCase2
include DefaultTests2 
#include DefaultTests0    #less error messages
def test_equals
	assert(Unit.new==Unit.new)
end #==
include Unit::Assertions
extend Unit::Assertions::ClassMethods
def test_class_assert_pre_conditions
#	Unit.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
#	Unit.assert_post_conditions
end #class_assert_post_conditions
end #Unit
class UnitTest < TestCase
include DefaultTests
include Unit::Examples
def test_initialize
	assert_respond_to(UnboundedFixnumUnit, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumUnit.model_basename)	
	assert_equal('unbounded_fixnum', Unit.new(:UnboundedFixnum).model_basename)
	model_class_name=FilePattern.path2model_name?
	assert_equal(:Unit, model_class_name)
	project_root_dir=FilePattern.project_root_dir?
	assert_equal(:Unit, SELF.model_class_name)
	assert_equal('unit', SELF.model_basename)
	assert_not_empty(SELF.project_root_dir)
	SELF.assert_pre_conditions
	te=Unit.new(SELF.model_name?)
	assert_equal(:Unit, te.model_class_name)
	assert_equal(:Unit, SELF.model_class_name)
end #initialize
def test_model_pathname
	assert(File.exists?(UnboundedFixnumUnit.model_pathname?), UnboundedFixnumUnit.model_pathname?)
	assert_data_file(UnboundedFixnumUnit.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumUnit.model_test_pathname?))
	assert_data_file(UnboundedFixnumUnit.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumUnit.assertions_pathname?))
	assert_data_file(UnboundedFixnumUnit.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumUnit.inspect)
	assert_not_nil(UnboundedFixnumUnit.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumUnit.inspect)
	assert(File.exists?(UnboundedFixnumUnit.assertions_test_pathname?), UnboundedFixnumUnit.inspect)
	assert_data_file(UnboundedFixnumUnit.assertions_test_pathname?)
end #assertions_test_pathname?
def test_data_sources_directory
	message='TE.data_sources_directory?='+TE.data_sources_directory?+"\n"
	message+='Dir[TE.data_sources_directory?]='+Dir[TE.data_sources_directory?].inspect+"\n"
	assert_not_empty(TE.data_sources_directory?, message)
	assert_empty(Dir[TE.data_sources_directory?], message)
	related_file=Unit.new_from_path?('test/unit/tax_form_test.rb')
	message='related_file='+related_file.inspect+"\n"
	message+='related_file.data_sources_directory?='+related_file.data_sources_directory?+"\n"
	message+='Dir[related_file.data_sources_directory?]='+Dir[related_file.data_sources_directory?].inspect+"\n"
	assert_not_empty(Dir[related_file.data_sources_directory?], message)
end #data_sources_directory
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumUnit.pathnames?)
	assert_operator(5, :<=, UnboundedFixnumUnit.pathnames?.size)
	assert_array_of(UnboundedFixnumUnit.pathnames?, String)
	pathnames=FilePattern::All.map do |p|
		UnboundedFixnumUnit.		pathname_pattern?(p[:name])
	end #map
	assert_equal(UnboundedFixnumUnit.pathnames?, pathnames)
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
	assert_equal(4, UnboundedFixnumUnit.default_test_class_id?, UnboundedFixnumUnit.inspect)
	te=Unit.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
#till split	assert_equal(2, default_test_class_id, te.inspect)
#till split	assert_equal(2, Unit.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, Unit.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_functional_parallelism
	edit_files=SELF.edit_files
	assert_operator(SELF.functional_parallelism(edit_files).size, :>=, 1)
	assert_operator(SELF.functional_parallelism.size, :<=, 4)
end #functional_parallelism
def test_tested_files
	executable=SELF.model_test_pathname?
	tested_files=SELF.tested_files(executable)
	assert_operator(SELF.default_test_class_id?, :<=, tested_files.size)
end #tested_files
def test_model_class
	assert_equal(Unit, SELF.model_class?)
end #model_class
def test_model_name
	assert_equal(:Unit, SELF.model_class_name)
	assert_equal(:Unit, SELF.model_name?)
end #model_name?
def test_assert_default_test_class_id
#	Unit.assert_constant_path_respond_to(:TestIntrospection, :Unit, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(UnitTest, :assert_default_test_class_id)
#	explain_assert_respond_to(self, :assert_default_test_class_id)
	Unit.new(:UnboundedFixnum).assert_default_test_class_id(4,'')
#til split	Unit.new(:Unit).assert_default_test_class_id(2,'')
	Unit.new(:DefaultTestCase).assert_default_test_class_id(2,'')
	Unit.new(:EmptyDefaultTest).assert_default_test_class_id(0,'')
	Unit.new(:GenericType).assert_default_test_class_id(3,'')
end #default_test_class_id
def test_Examples
	UnboundedFixnumUnit.assert_pre_conditions
	UnboundedFixnumUnit.assert_post_conditions
end #Examples
end # UnitTest
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
require_relative '../../app/models/naming_convention.rb'
require 'test/unit'
include Test::Unit::Assertions
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest
require_relative '../../app/models/unbounded_fixnum.rb'
class NamingConventionTest <  DefaultTestCase2
#include DefaultTests2 
#include DefaultTests0    #less error messages
include NamingConvention::Constants
include NamingConvention::Examples
include NamingConvention::Assertions
#include NamingConvention::Assertions::KernelMethods
extend NamingConvention::Assertions::ClassMethods
def test_extension_match
	s=Patterns[1]
	extension='.rb'
#	assert_equal(extension, File.extname(s[:suffix]))
	message="s=#{s}\nextension=#{extension}"
	message+="\nNamingConvention.extension_match(s, extension)=#{NamingConvention.extension_match(s, extension)}"
	assert(NamingConvention.extension_match(s, extension), message)
end #extension_match
def test_suffix_match
	s=Patterns[1]
	suffix='dct'
	extension='.rb'
	expected_suffix=File.basename(s[:suffix], extension)
	assert_equal(extension, File.basename(extension, extension))
#	assert_equal(suffix[-expected_suffix.size,expected_suffix.size], expected_suffix)
	message="s=#{s}\nsuffix=#{suffix}\nextension=#{extension}"
end #suffix_match
def test_sub_directory_match
	s=Patterns[1]
	path='script/dct.rb'
	sub_directory=File.dirname(path)
	expected_sub_directory=s[:sub_directory][0..-2] # drops trailing /
	message="expected_sub_directory=#{expected_sub_directory}\nsub_directory=#{sub_directory}"
	assert_not_nil(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], message)
	assert_equal(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], expected_sub_directory, message)
	message="s=#{s}\nsub_directory=#{sub_directory}\nexpected_sub_directory=#{expected_sub_directory}"
	message+="\nNamingConvention.sub_directory_match(s, path)=#{NamingConvention.sub_directory_match(s, path)}"
	assert(NamingConvention.sub_directory_match(s, path), message)
end #sub_directory_match
def test_path2model_name
	path=File.expand_path($0)
	extension=File.extname(path)
	assert_equal('.rb', extension)
	basename=File.basename(path, extension)
	assert_equal('naming_convention_test', basename)
	expected_match=2
	assert_include(NamingConvention.included_modules, NamingConvention::Assertions)
	assert_include(NamingConvention.methods, :assert_pre_conditions)
	assert_respond_to(	NamingConvention, :assert_pre_conditions)
	NamingConvention.assert_pre_conditions
	NamingConvention.assert_naming_convention_match(Patterns[expected_match], path)
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(17, name_length)
	matches=Patterns.reverse.map do |s| #reversed from rare to common
		if NamingConvention.naming_convention_extension(s, extension) && NamingConvention.naming_convention_basename(s, basename, extension) then
			name_length=basename.size+extension.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	assert_not_empty(matches)
	assert_not_empty(matches.compact)
	assert_equal(:NamingConvention, matches.compact.last)
	
	path=File.expand_path(DCT_filename)
	extension=File.extname(path)
	basename=File.basename(path, extension)
	assert_equal('dct', basename)
	assert_equal('.rb', extension)
	expected_match=1
	NamingConvention.assert_naming_convention_match(Patterns[expected_match], path)
	name_length=basename.size+extension.size-Patterns[expected_match][:suffix].size
	assert_equal(3, name_length)

	model_class_name=NamingConvention.path2model_name?
	assert_equal(:NamingConvention, model_class_name)
end #path2model_name
def test_project_root_dir
	path=File.expand_path($0)
end #project_root_dir
def test_lookup
	name=:assertions
	param_name=:suffix
	ret=Patterns.map do |s|
		s[:name]==name
	end #find
	assert_equal([false,false,false,true,false], ret)
	ret=Patterns.find do |s|
		s[:name]==name
	end #find
	assert_equal(name, ret[:name])
	param_name=:name # easy test, where I know the answer
	assert_equal(name, NamingConvention.lookup(name, param_name))
	assert_equal(:model, NamingConvention.lookup(:model, :name))
	assert_equal(:test, NamingConvention.lookup(:test, :name))
	assert_equal(:assertions, NamingConvention.lookup(:assertions, :name))
	assert_equal(:assertions_test, NamingConvention.lookup(:assertions_test, :name))
end #lookup
def test_initialize
	assert_respond_to(UnboundedFixnumNamingConvention, :model_basename)
	assert_equal('unbounded_fixnum', UnboundedFixnumNamingConvention.model_basename)	
	assert_equal('unbounded_fixnum', NamingConvention.new(:UnboundedFixnum).model_basename)
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
	assert(File.exists?(UnboundedFixnumNamingConvention.model_pathname?), UnboundedFixnumNamingConvention.model_pathname?)
	assert_data_file(UnboundedFixnumNamingConvention.model_pathname?)
end #model_pathname?
def test_model_test_pathname
	assert(File.exists?(UnboundedFixnumNamingConvention.model_test_pathname?))
	assert_data_file(UnboundedFixnumNamingConvention.model_test_pathname?)
end #model_test_pathname?
def test_assertions_pathname
#	assert(File.exists?(UnboundedFixnumNamingConvention.assertions_pathname?))
	assert_data_file(UnboundedFixnumNamingConvention.assertions_pathname?)
end #assertions_pathname?
def test_assertions_test_pathname
	assert_not_nil("UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumNamingConvention.inspect)
	assert_not_nil(UnboundedFixnumNamingConvention.assertions_test_pathname?)
	assert_not_equal('', "../../test/unit/"+"UnboundedFixnum"+"_assertions_test.rb", UnboundedFixnumNamingConvention.inspect)
	assert(File.exists?(UnboundedFixnumNamingConvention.assertions_test_pathname?), UnboundedFixnumNamingConvention.inspect)
	assert_data_file(UnboundedFixnumNamingConvention.assertions_test_pathname?)
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
	assert_equal(4, UnboundedFixnumNamingConvention.default_test_class_id?, UnboundedFixnumNamingConvention.inspect)
	te=NamingConvention.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
	tests=eval("DefaultTests"+default_test_class_id.to_s)
	assert_equal(2, default_test_class_id, te.inspect)
	assert_equal(2, NamingConvention.new(te.model_name?).default_test_class_id?, te.inspect)
#	assert_equal(1, NamingConvention.new('DefaultTestCase').default_test_class_id?)
end #default_test_class_id
def test_default_tests_module_name
end #default_tests_module?
def test_test_case_class_name
end #test_case_class?
def test_pathnames
	assert_instance_of(Array, UnboundedFixnumNamingConvention.pathnames?)
	assert_equal(4, UnboundedFixnumNamingConvention.pathnames?.size)
	assert_array_of(UnboundedFixnumNamingConvention.pathnames?, String)
end #pathnames
def test_model_class
	assert_equal(NamingConvention, SELF.model_class?)
end #model_class
def test_model_name
	assert_equal(:NamingConvention, SELF.model_name?)
end #model_name?
include NamingConvention::Assertions
extend NamingConvention::Assertions::ClassMethods
#def test_class_assert_invariant
#	NamingConvention.assert_invariant
#end # class_assert_invariant
def test_class_assert_pre_conditions
#	NamingConvention.assert_pre_conditions
end #class_assert_pre_conditions
def test_class_assert_post_conditions
#	NamingConvention.assert_post_conditions
end #class_assert_post_conditions
def test_assert_default_test_class_id
#	assert_constant_path_respond_to(:TestIntrospection, :NamingConvention, :KernelMethods, :assert_default_test_class_id)
#	assert_respond_to(NamingConventionTest, :assert_default_test_class_id)
#	explain_assert_respond_to(self, :assert_default_test_class_id)
#	assert_default_test_class_id(4,'UnboundedFixnum')
#	assert_default_test_class_id(2,'NamingConvention')
#	assert_default_test_class_id(1,'DefaultTestCase')
#	assert_default_test_class_id(0,'EmptyDefaultTest')
#	assert_default_test_class_id(3,'GenericType')
end #default_test_class_id
end #NamingConvention


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
include Test::Unit::Assertions
extend Test::Unit::Assertions
def test_case_assert_invariant
	caller_message=" callers=#{caller.join("\n")}"
	assert_equal('Test', self.class.name[-4..-1], "Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_message)
end #assert_invariant
def test_assert_class_invariant
	assert_include(Module.constants, :ClassExists)
end #test_assert_class_invariant
def test_TestIntrospection_NamingConvention
	te=NamingConvention.new(model_name?)
	default_test_class_id=te.default_test_class_id?
	default_tests=eval("DefaultTests"+default_test_class_id.to_s)
	default_test_case=eval("DefaultTestCase"+default_test_class_id.to_s)
end #test_TestIntrospection_NamingConvention
include DefaultTests1
end #ClassExistsTest


###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
#require_relative '../../test/unit/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/test_introspection.rb'
class TestIntrospectionTest < Test::Unit::TestCase
include TestIntrospection
#include TestIntrospection::Assertions::KernelMethods
#include DefaultTests2 # correct but should be computed
#include DefaultTests    #less error messages
def test_TestIntrospectionTest_test_environment
end #assert_test_environment
def test_path2model_name
	path=File.expand_path($0)
	extension=File.extname(path)
	assert_equal('.rb', extension)
	basename=File.basename(path, extension)
	assert_equal('test_introspection_test', basename)
	expected_match=1
	assert_include(TestIntrospection.included_modules, TestIntrospection::Assertions)
#	assert_include(TestIntrospection.methods, :assert_pre_conditions)
#	assert_respond_to(	TestIntrospection, :assert_pre_conditions)
#	TestIntrospection.assert_pre_conditions
#	TestIntrospection.assert_naming_convention_match(Suffixes[expected_match], basename, extension)
	name_length=basename.size+extension.size-Suffixes[expected_match][:suffix].size
	assert_equal(18, name_length)
	matches=Suffixes.reverse.map do |s| #reversed from rare to common
		if naming_convention_extension(s, extension) && naming_convention_basename(s, basename, extension) then
			name_length=basename.size+extension.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	assert_not_empty(matches)
	assert_not_empty(matches.compact)
	assert_equal(:TestIntrospection, matches.compact.last)
	model_class_name=path2model_name?
	assert_equal(:TestIntrospection, model_class_name)
end #path2model_name
def test_project_root_dir
	path=File.expand_path($0)
end #project_root_dir
def test_lookup
	name=:assertions
	param_name=:suffix
	ret=Suffixes.map do |s|
		s[:name]==name
	end #find
	assert_equal([false,false,true,false], ret)
	ret=Suffixes.find do |s|
		s[:name]==name
	end #find
	assert_equal(name, ret[:name])
	param_name=:name # easy test, where I know the answer
	assert_equal(name, lookup(name, param_name))
	assert_equal(:model, lookup(:model, :name))
	assert_equal(:test, lookup(:test, :name))
	assert_equal(:assertions, lookup(:assertions, :name))
	assert_equal(:assertions_test, lookup(:assertions_test, :name))
end #lookup
def test_model_basename
	assert_match(/test\/unit\/test_introspection_test.rb$/, File.expand_path($0))
	assert_match(/test\/unit\/test_introspection_test.rb$/, File.expand_path(__FILE__))
	assert_match(/test\/unit$/, File.dirname(File.expand_path($0)))
	assert_equal('test_introspection_test.rb', File.basename(File.expand_path($0)))
	assert_equal('.rb', File.extname(File.expand_path($0)))
	assert_equal('test_introspection_test', File.basename(File.expand_path($0), '.rb'))
	assert_equal('test_introspection', File.basename(File.expand_path($0), '.rb')[0..-6])
	assert_equal('test_introspection', model_basename?)
end #model_basename
def test_class_name
	assert_equal('TestIntrospection', class_name?)
end #class_name
def test_name_of_test
	assert_equal('Test', self.class.name[-4..-1], "2Naming convention is to end test class names with 'Test' not #{self.class.name}"+caller_lines)
	assert_equal('TestIntrospectionTest', name_of_test?)
end #name_of_test
module Assertions
end #Assertions
include Assertions


end #TestIntrospection

###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/unbounded_fixnum.rb'
class EmptyTest
end #EmptyTest
class EmptyDefaultTest < DefaultTestCase1
end #EmptyDefaultTest
class EmptyIncludedTest
include DefaultTests1
end #EmptyIncludedTest

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
module Examples
UnboundedFixnumTestEnvironment=TestEnvironment.new(:UnboundedFixnum)
end #Examples
include Examples
def test_initialize
	assert_respond_to(UnboundedFixnumTestEnvironment, :model_filename)
	assert_equal(:unbounded_fixnum, UnboundedFixnumTestEnvironment.model_filename)	
end #initialize
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
end #MinimalTest

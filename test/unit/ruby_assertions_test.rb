###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/ruby_assertions.rb'
class RubyAssertionsTest < TestCase
def test_caller_lines
	ignore_lines=19
	assert_equal("\ntest/unit/ruby_assertions_test.rb:13:in `test_caller_lines'\n", caller_lines(ignore_lines), caller_lines(ignore_lines))
end #caller_lines
class TestClass < Object
TestConstant=3.2
def test_instance_method
end #test_instance_method
def self.test_class_method
end #test_class_method
end #RubyAssertionsTest
def test_assert_call_result
	#~ explain_assert_respond_to(self,:testMethod)
	assert_call_result(self,:testMethod)
	assert_call(self,:testMethod)
	#~ assert_answer(self,:testMethod,'nice result')
	#~ assert_public_instance_method(table_specs(:ifconfig),:acquisition_stream_specs)
end #assert_call_result
def testMethod
	return 'nice result'
end #def
def test_assert_call
end #assert_call
def test_assert_answer
end #assert_answer
def test_explain_assert_equal
end #explain_assert_equal
def test_explain_assert_block
	message="assert_block failed." # :yields: 
end #explain_assert_block
def test_explain_assert_respond_to
	explain_assert_respond_to(TestClass,:test_class_method,"Local tet method.")
#	assert_raise(AssertionFailedError){explain_assert_respond_to(TestClass,:sequential_id?)}
#	explain_assert_respond_to(TestClass,:sequential_id?," probably does not include include Generic_Table statement.")

#	assert_respond_to(Acquisition,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")

end #explain_assert_respond_to
def test_assert_not_empty
	assert_not_empty('a')
	assert_not_empty(['a'])
	assert_not_empty(Set[nil])
end #assert_not_empty
def test_assert_empty
	assert_empty([])
	assert_empty('')
	assert_empty(Set[])
end #assert_empty
def test_assert_flat_set
	set=Set[1,2,3]
	assert(assert_flat_set(set))
	set=Set[1,Set[2],3]
	assert(set.to_a[1].instance_of?(Set))
	assert_raise(AssertionFailedError) {assert(assert_flat_set(set))}
	
end #assert_flat_set
def test_assert_subset
	subset_enumeration=[1,2]
#	superset_enumeration=[1,2,3]
	superset_enumeration=[1,2]
	assert_instance_of(Array, subset_enumeration)
	assert_instance_of(Array, superset_enumeration)
	subset_enumeration_array=subset_enumeration.to_a.map {|e| e.to_s}
	subset=subset_enumeration_array.to_set
	superset=Set.new(superset_enumeration.to_a.map {|e| e.to_s})
	assert_flat_set(subset)
	assert_flat_set(superset)
	subset_surplus=subset-superset
	assert_empty(subset_surplus, "subset_surplus=#{subset_surplus}, superset=#{superset}, subset=#{subset}")
	assert_subset([1,2],[1,2,3])
	assert_subset([1,2],[1,2])
end #assert_subset
def test_equal_sets
	expected_enumeration=[/a/,/b/]
	actual_enumeration=[/b/,/a/]
	assert_equal(Set.new(expected_enumeration),Set.new(actual_enumeration))
	assert(!expected_enumeration.instance_of?(Set))
		expected_set=Set.new(expected_enumeration.to_a.map {|e| e.to_s})
	assert(!actual_enumeration.instance_of?(Set))
		actual_set=Set.new(actual_enumeration.to_a.map {|e| e.to_s})
	assert_flat_set(expected_set)
	assert_flat_set(actual_set)
	assert_equal_sets(expected_enumeration,actual_enumeration)
	assert_module_included(Acquisition,Generic_Table)
end #assert_equal_sets
def test_assert_overlap
	enum1=[1,2,3]
	enum2=[3,4,5]
	assert_overlap(enum1,enum2)
	enum1=Set[1,2,3]
	enum2=Set[3,4,5]
	assert_overlap(enum1,enum2)
end #assert_overlap
def test_assert_include
	element=:b
	list=[:a,:b,:c]
	assert_include(list, element, "#{element.inspect} is not in list #{list.inspect}")
	assert_include('table_specs',fixture_names)
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	set=Set.new(list)
	assert(set.include?(element))
	assert_include(element,set)
end #assert_include
def test_assert_dir_include
	assert_dir_include('app','*')
	assert_not_empty(Dir['app/models/[a-zA-Z0-9_]*.rb'])
	assert_dir_include('app/models/global.rb','app/models/[a-zA-Z0-9_]*.rb')
	assert_dir_include('app/models/global.rb','app/models/[a-zA-Z0-9_]*[.]rb')
end #assert_dir_include
def test_assert_not_include
	element=1
	list=[1,2,3]
	assert(list.include?(element))
	assert_include(list, element)
	assert_not_include(list, 4)
	assert_raise(AssertionFailedError){assert_not_include(list, element)}
end #assert_not_include
def test_assert_public_instance_method
	obj=StreamPattern.new
	methodName=:stream_pattern_arguments
	assert_respond_to(obj,methodName)
	assert_raise(Test::Unit::AssertionFailedError){assert_respond_to(obj,methodName.to_s.singularize)}
	assert_respond_to(obj,methodName.to_s.pluralize) 
	assert_respond_to(obj,methodName.to_s.tableize)
	assert_raise(Test::Unit::AssertionFailedError){assert_respond_to(obj,methodName.to_s.tableize.singularize)}
	assert_public_instance_method(obj,methodName)
	assert_raise(Test::Unit::AssertionFailedError){assert_public_instance_method(obj,methodName.to_s.singularize)}
	assert_public_instance_method(obj,methodName.to_s.pluralize) 
	assert_public_instance_method(obj,methodName.to_s.tableize)
	assert_raise(Test::Unit::AssertionFailedError){assert_public_instance_method(obj,methodName.to_s.tableize.singularize)}


end #assert_public_instance_method
def test_assert_array_of
	assert_array_of(['',''], String)
	#assert_raise(Test::Unit::AssertionFailedError){assert_array_of(nil, String)}
	#assert_raise(Test::Unit::AssertionFailedError){assert_array_of([[]], String)}
	assert_array_of([], String)
end #array_of
def test_assert_no_duplicates
	array=[1,2,3]
	columns_to_ignore=[]
	assert_no_duplicates(array, columns_to_ignore)
	assert_no_duplicates(array)
	assert_no_duplicates([1,2,3,3])
	
end #assert_no_duplicates
def test_assert_single_element_array
	assert_single_element_array([3])	
end #assert_single_element_array
def test_assert_regexp
	assert_regexp('\(')
	assert_regexp('()')
	assert_raise(AssertionFailedError){assert_regexp('(')}
end #assert_regexp

def test_assert_module_included
	assert_module_included(RubyAssertionsTest, Test::Unit::Assertions)
end #assert_module_included
def test_global_name
	assert(global_name?(:String), Module.constants.inspect)
	assert(global_name?(:RubyAssertionsTest), Module.constants.inspect)
	assert(global_name?(:DefaultAssertions), Module.constants.inspect)
end #global_name
def test_assert_scope_path
	assert_scope_path(:RubyAssertionsTest, :TestClass)
	assert_scope_path(:TestClass)
end #assert_scope_path
def test_assert_path_to_constant
	assert_path_to_constant(:RubyAssertionsTest, :TestClass, :TestConstant) #global path
	assert_path_to_constant(:TestClass, :TestConstant) #relative path
end #assert_path_to_constant
def test_assert_constant_path_respond_to
	assert_constant_path_respond_to(:RubyAssertionsTest, :TestClass, :test_class_method)
	assert_constant_path_respond_to(:TestClass, :test_class_method)
	assert_constant_path_respond_to(:RubyAssertionsTest, :assert_path_to_method)
end #assert_constant_path_respond_to
def test_assert_constant_instance_respond_to
	assert_constant_path_respond_to(:RubyAssertionsTest, :TestClass, :test_class_method)
	assert_constant_path_respond_to(:TestClass, :test_class_method)
	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
end #assert_constant_instance_respond_to
end #RubyAssertionsTest


###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
class RubyAssertionsTest < ActiveSupport::TestCase
@@table_name='stream_patterns'
fixtures @@table_name.to_sym
fixtures :table_specs
require 'test/test_helper_test_tables.rb'

def test_testCallResult
	#~ explain_assert_respond_to(self,:testMethod)
	testCallResult(self,:testMethod)
	testCall(self,:testMethod)
	#~ testAnswer(self,:testMethod,'nice result')
	#~ assert_public_instance_method(table_specs(:ifconfig),:acquisition_stream_specs)
end #testCallResult
def testMethod
	return 'nice result'
end #def
def test_testCall
end #testCall
def test_testAnswer
end #testAnswer
def test_explain_assert_equal
end #explain_assert_equal
def test_explain_assert_respond_to
	assert_raise(Test::Unit::AssertionFailedError){explain_assert_respond_to(TestClass,:sequential_id?)}
#	explain_assert_respond_to(TestClass,:sequential_id?," probably does not include include Generic_Table statement.")

	explain_assert_respond_to(Acquisition,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")
	assert_respond_to(Acquisition,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")

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
	assert_raise(Test::Unit::AssertionFailedError) {assert(assert_flat_set(set))}
	
end #assert_flat_set
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
	assert_include(element,list,"#{element.inspect} is not in list #{list.inspect}")
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
	assert_include(element, list)
	assert_not_include(4, list)
	assert_raise(Test::Unit::AssertionFailedError){assert_not_include(element, list)}
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
	assert_raise(Test::Unit::AssertionFailedError){assert_array_of(nil, String)}
	assert_raise(Test::Unit::AssertionFailedError){assert_array_of([[]], String)}
	assert_array_of([], String)
end #array_of
def test_assert_single_element_array
	assert_single_element_array([3])	
end #assert_single_element_array

end #class


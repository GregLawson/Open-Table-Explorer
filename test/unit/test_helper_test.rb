require 'test/test_helper'
class TestHelperTest < ActiveSupport::TestCase
@@table_name='stream_patterns'
fixtures @@table_name.to_sym
fixtures :table_specs
require 'test/test_helper_test_tables.rb'
def test_fixtures
	table_name='table_specs'
	assert_not_nil fixtures(table_name)
	assert_fixture_name(table_name)
	assert_not_nil fixture_labels(table_name)
#	assert_not_nil model_class(table_specs(:ifconfig))
end #test
def test_fixture_names
	assert_include('stream_patterns',fixture_names)
	assert_include('table_specs',fixture_names)
end #test
def test_testCallResult
	#~ explain_assert_respond_to(self,:testMethod)
	testCallResult(self,:testMethod)
	testCall(self,:testMethod)
	#~ testAnswer(self,:testMethod,'nice result')
	#~ assert_public_instance_method(table_specs(:ifconfig),:acquisition_stream_specs)
end #test
def test_explain_assert_respond_to
	assert_raise(Test::Unit::AssertionFailedError){explain_assert_respond_to(TestClass,:sequential_id?)}
#	explain_assert_respond_to(TestClass,:sequential_id?," probably does not include include Generic_Table statement.")

	explain_assert_respond_to(Acquisition,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")
	assert_respond_to(Acquisition,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")

end #test
def test_assert_not_empty
	assert_not_empty('a')
	assert_not_empty(['a'])
	assert_not_empty(Set[nil])
end #test
def test_assert_empty
	assert_empty([])
	assert_empty('')
	assert_empty(Set[])
end #test
def test_assert_flat_set
	set=Set[1,2,3]
	assert(assert_flat_set(set))
	set=Set[1,Set[2],3]
	assert(set.to_a[1].instance_of?(Set))
	assert_raise(Test::Unit::AssertionFailedError) {assert(assert_flat_set(set))}
	
end #test
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
end #test
def test_assert_overlap
	enum1=[1,2,3]
	enum2=[3,4,5]
	assert_overlap(enum1,enum2)
	enum1=Set[1,2,3]
	enum2=Set[3,4,5]
	assert_overlap(enum1,enum2)
end #test
def test_assert_include
	element=:b
	list=[:a,:b,:c]
	assert_include(element,list,"#{element.inspect} is not in list #{list.inspect}")
	assert_include('table_specs',fixture_names)
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	set=Set.new(list)
	assert(set.include?(element))
	assert_include(element,set)
end #test
def test_assert_dir_include
	assert_dir_include('app','*')
	assert_not_empty(Dir['app/models/[a-zA-Z0-9_]*.rb'])
	assert_dir_include('app/models/global.rb','app/models/[a-zA-Z0-9_]*.rb')
	assert_dir_include('app/models/global.rb','app/models/[a-zA-Z0-9_]*[.]rb')
end #test
def test_assert_not_include
	element=1
	list=[1,2,3]
	assert(list.include?(element))
	assert_include(element, list)
	assert_not_include(4, list)
	assert_raise(Test::Unit::AssertionFailedError){assert_not_include(element, list)}
end #test
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


end #test
def test_assert_array_of
	assert_array_of(['',''], String)
	assert_raise(Test::Unit::AssertionFailedError){assert_array_of(nil, String)}
	assert_raise(Test::Unit::AssertionFailedError){assert_array_of([[]], String)}
	assert_array_of([], String)
end #array_of
def test_unknown
	class_reference=StreamMethodArgument
	association_reference=:stream_method
		klass=class_reference
	association_reference=association_reference.to_sym
	assert_not_empty(ActiveRecord::Base.instance_methods_from_class)
	assert_not_include(association_reference.to_s,ActiveRecord::Base.instance_methods_from_class)
	if (ActiveRecord::Base.instance_methods_from_class(true).include?(association_reference.to_s)) then
		raise "# Don’t create associations that have the same name (#{association_reference.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord::Base.instance_methods_from_class.inspect})."
	end #if
	assert_instance_of(Symbol,association_reference,"assert_association")
	if klass.module_included?(Generic_Table) then
		association_type=klass.association_to_type(association_reference)
		assert_not_nil(association_type)
		assert_include(association_type,[:to_one,:to_many])
	end #if
	#~ explain_assert_respond_to(klass.new,(association_reference.to_s+'=').to_sym)
	#~ assert_public_instance_method(klass.new,association_reference,"association_type=#{association_type}, ")
	assert(klass.is_association?(association_reference),"fail is_association?, klass.inspect=#{klass.inspect},association_reference=#{association_reference}")
	assert_association(class_reference,association_reference)
end #test
def test_assert_association_to_one
	class_reference=StreamMethodArgument
	association_reference=:stream_method
	assert_association(class_reference,association_reference)
	assert_association_to_one(class_reference,association_reference)
	
	assert_has_associations(TableSpec)
	assert_has_instance_methods(TableSpec)

end #test
def test_assert_association_to_many
	assert_not_nil(table_specs(:ifconfig).class.is_association_to_many?(:acquisition_stream_specs))
	assert_association_to_many(TableSpec,:acquisition_stream_specs)
	assert_association_one_to_many(table_specs(:ifconfig),:acquisition_stream_specs)
end #test
def test_assert_active_record_method
	assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
	method_name=:connection
	assert(ActiveRecord::Base.is_active_record_method?(method_name))
	assert_active_record_method(method_name)

	assert(ActiveRecord::Base.is_active_record_method?(:connection))
	assert(TestTable.is_active_record_method?(:connection))
	assert(TestTable.is_active_record_method?(method_name))
end #test
def test_assert_not_active_record_method
	association_reference=:parameter
	assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
	assert(!TestTable.is_active_record_method?(:parameter))
	method_name=:parameter
	assert(!ActiveRecord::Base.is_active_record_method?(method_name))
	assert_not_active_record_method(method_name)
end #test
#
# not single generic_table method
#
def test_assert_associations
	assert(@@CLASS_WITH_FOREIGN_KEY.belongs_to_association?(@@FOREIGN_KEY_ASSOCIATION_SYMBOL) ,"StreamPatternArgument belongs_to stream_pattern")
	assert(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s.classify.constantize.has_many_association?(@@TABLE_NAME_WITH_FOREIGN_KEY),"#{@@FOREIGN_KEY_ASSOCIATION_SYMBOL} does not has_many #{@@TABLE_NAME_WITH_FOREIGN_KEY}")
	assert_associations(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	assert_associations(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,@@CLASS_WITH_FOREIGN_KEY)
end #test
def test_assert_general_associations
	assert_general_associations(@@table_name)
end #test
def test_other_association
	model_class=TableSpec
	assert_equal(['frequency_id'],TableSpec.foreign_key_names)
	assert_equal(Set.new(['acquisition_interface_id','table_spec_id']),Set.new(AcquisitionStreamSpec.foreign_key_names))
	assert_equal([],AcquisitionInterface.foreign_key_names)
	ar_from_fixture=table_specs(:ifconfig)
	assName=:frequency
	assert_instance_of(Symbol,assName,"associated_foreign_key assName=#{assName.inspect}")
	
	assert_association(ar_from_fixture,assName)
	assert_not_nil(ar_from_fixture.class.associated_foreign_key_name(assName),"associated_foreign_key_name: ar_from_fixture=#{ar_from_fixture},assName=#{assName})")
	assert_equal('frequency_id',ar_from_fixture.class.associated_foreign_key_name(assName))
end #test
def test_assert_matching_association
#	assert_matching_association(TestTable,:full_associated_models)	
#	assert(TestTable.is_matching_association?(:full_associated_models))
	assert_matching_association("table_specs","frequency")
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_matching_association("acquisitions","frequency")
	end #assert_raised
end  #test
def test_handle_polymorphic
	association_type=StreamMethodArgument.association_to_type(:parameter)
	assert_not_nil(association_type)
#	assert_include(association_type,[:to_one,:to_many])
#	assert_association(StreamMethodArgument,:parameter)
#	assert_belongs_to_association(StreamMethodArgument,:parameter)
#	assert(StreamMethodArgument.belongs_to_association?(:parameter))
#	assert_include('parameter',StreamMethodArgument.foreign_key_association_names)
#	assert_equal(:to_one_belongs_to,StreamMethodArgument.association_type(:parameter))
end #test
def setup
#	define_association_names
end
def testMethod
	return 'nice result'
end #def
def test_various_assertions
	assert_not_empty([1])
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	ar_from_fixture=table_specs(:ifconfig)
	assert_not_nil ar_from_fixture.class.similar_methods(:acquisition_stream_spec)
end #test

end #class


###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../assertions/generic_table_examples.rb'
require 'app/models/generic_table_assertion.rb'
require 'test/assertions/ruby_assertions.rb'
class GenericTableTest < TestCase
include DefaultTests2
include Generic_Table
extend Generic_Table::ClassMethods
#include GenericTableAssertions
include GenericTableAssertion::KernelMethods
@@table_name='stream_patterns'
#	fixtures :table_specs
#	fixtures :acquisition_stream_specs
#	fixtures :acquisition_interfaces
TEST_SIZE=10
TEST_START=5
TEST_STEP=-1
TEST_ARRAY=(TEST_START..TEST_START+TEST_SIZE-1).map{|i| {:input => i, :output => TEST_STEP*i}}.to_a
class TestData < Array
include NoDB
extend NoDB::ClassMethods
def self.all
	return TEST_ARRAY
end #all
end #TestData
Example= TestData.new({:input => 2, :output => 4})

def test_nesting
	assert_equal([], TestData.modules)
end #nesting
def test_sample_burst
	assert_equal(TEST_ARRAY, TestData.all)
	assert_equal(TEST_ARRAY, TestData.sample_burst(:first, 0, 10, 10))
	assert_equal(TEST_ARRAY[0,1], TestData.sample_burst(:first, 0, 10, 1))
	assert_equal(TEST_ARRAY, TestData.sample_burst(:last, 0, 10, 10))
	assert_equal(TEST_ARRAY, TestData.sample_burst(:random, 0, 10, 10))
end #sample_burst
def test_sample
	samples_wanted=100
	sample_type=:first
	consecutive=1
	size=TestData.all.size
	samples_returned=[samples_wanted, size].min
	assert_equal(TEST_SIZE, samples_returned)
	bursts=(samples_returned/consecutive).ceil
	assert_equal(samples_returned, bursts)
	spacing=(size/bursts).ceil
	assert_equal(1, spacing)
	ret=(0..bursts-1).map do |burst|
		burst_start=burst*spacing
		TestData.sample_burst(sample_type, burst_start, spacing, consecutive)
	end #burst.times
	assert_equal(samples_returned, ret.size)
	assert_equal(TEST_ARRAY, TestData.all)
	assert_equal(TEST_ARRAY, ret.flatten)
	assert_equal(TEST_ARRAY, ret.flatten[0..samples_returned-1])
	assert_equal(TEST_ARRAY, TestData.sample(TEST_SIZE, :first, 1).flatten)
	assert_equal(TEST_ARRAY, TestData.sample(TEST_SIZE, :last, 1).flatten)
	assert_equal(TEST_ARRAY, TestData.sample(samples_wanted, sample_type, consecutive).flatten)
	assert_equal(TEST_ARRAY, TestData.sample.flatten)
	assert_equal(size, TestData.sample.size, "TestData.sample=#{TestData.sample}")
	many_random=(0..5).map do |i|
		TestData.sample(TEST_SIZE, :random, 1)
	end #map
	assert_equal(TEST_ARRAY, many_random.flatten.sort.uniq.reverse)
	BatteryMeasurement.all.each do |r|
		assert_instance_of(Hash, r)
	end #each
	BatteryMeasurement.sample.flatten.each do |r|
		assert_instance_of(Hash, r)
	end #each
end #sample
def test_model_file_name
end #model_file_name
def test_one_pass_statistics
	model_class=Bug
	column_name=:id
    	n = 0
    	min=nil; max=nil
	max_key, min_key = nil # declare scope outside loop!
	assert(model_class.column_names.include?('id'))
    	has_id=model_class.column_names.include?('id')
    	model_class.all.each do |row|
        x=row[column_name]
        n = n + 1
        if n==1 then
	    min=x # value for nil
	    max=x # value for nil
	    if has_id then
		    min_key=row.id
		    max_key=row.id
	    else
		    min_key=row.logical_primary_key_value_recursive
		    max_key=row.logical_primary_key_value_recursive
	    end #if
	    assert_not_nil(min)
	    assert_not_nil(max)
	    assert_not_nil(min_key)
	    assert_not_nil(max_key)
	else
	    assert_not_nil(min)
	    assert_not_nil(max)
	    assert_not_nil(max_key, "n=#{n}, has_id=#{has_id}, local_variables=#{local_variables.inspect}")
	    assert_not_nil(min_key, "n=#{n}, has_id=#{has_id}, local_variables=#{local_variables.inspect}")
	    if x<min then
	    	min=x
		if has_id then
		    min_key=row.id
	    	else
		    min_key=row.logical_primary_key_value_recursive
	    	end #if
	    end #if  # value for not nil
	    if x>max then
	    	max=x
		if has_id then
			max_key=row.id
		else
			max_key=row.logical_primary_key_value_recursive
		end #if
	    end #if  # value for not nil
	    assert_not_nil(min)
	    assert_not_nil(max)
	    assert_not_nil(min_key, "n=#{n}, has_id=#{has_id}, local_variables=#{local_variables.inspect}")
	    assert_not_nil(max_key)
	end #if
	    assert_not_nil(min)
	    assert_not_nil(max)
	    assert_not_nil(min_key)
	    assert_not_nil(max_key)
    end #each
	bug_statistics=Bug.one_pass_statistics(:id)
    	assert_not_nil(bug_statistics)
	assert_equal(1, bug_statistics[:min])
end #one_pass_statistics
def test_is_active_record_method
	association_reference=:inputs
	assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
	assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
	assert(!TestTable.is_active_record_method?(:parameter))
	assert(TestTable.is_active_record_method?(:connection))
end #active_record_method
def test_association_refs
	class_reference=StreamPattern
	association_reference=:stream_methods
	class_reference.association_refs(class_reference, association_reference) do |class_reference, association_reference|
	assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
	assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
#	assert_kind_of(ActiveRecord::Base,class_reference)
	assert_ActiveRecord_table(class_reference.name)
		assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
		assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
	#	assert_kind_of(ActiveRecord::Base,class_reference)
		assert_ActiveRecord_table(class_reference.name)
	end #association_refs
	assert_equal([StreamPattern, :stream_methods], ActiveRecord::Base.association_refs(StreamPattern, :stream_methods) { |class_reference, association_reference| [class_reference, association_reference]})
end #association_refs
#end #class Base
#end #module ActiveRecord
def test_grep
end #grep
def test_class_of_name
	assert_nil(Generic_Table.class_of_name('junk'))
	assert_equal(StreamPattern, Generic_Table.class_of_name('StreamPattern'))
end #class_of_name
def test_is_generic_table
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.is_generic_table?('EEG'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.is_generic_table?('MethodModel'))}
	assert(Generic_Table.is_generic_table?('StreamPattern'))
end #def
def test_table_exists
	assert(Generic_Table.rails_MVC_class?(StreamPattern))
end #table_exists
def test_rails_MVC_class
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('junk'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('TestHelper'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('EEG'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('MethodModel'))}
	assert(Generic_Table.rails_MVC_class?(StreamPattern))
end #rails_MVC_class
def test_is_generic_table_name
end #is_generic_table_name
def test_activeRecordTableNotCreatedYet
end #activeRecordTableNotCreatedYet
def test_aaa
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)

	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_spec,:acquisition_interface)

assert_equal(Fixtures::identify(:HTTP),acquisition_stream_spec.acquisition_interface_id)
	assert_equal(acquisition_stream_spec.acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_spec.scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_spec.scheme,acquisition_stream_spec.acquisition_interface.scheme)
	testCall(acquisition_stream_spec,:acquisition_interface)
	assert_association(acquisition_stream_spec,:acquisition_interface)
#	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
end
def test_Generic_Table
	assert(GenericTableAssociatedModel.module_included?(Generic_Table))
	assert_module_included(GenericTableAssociatedModel,Generic_Table)
	
	assert_kind_of(Class,Acquisition)
	assert_kind_of(Class,ActiveRecord::Base)
	assert_kind_of(ActiveRecord::Base,Acquisition.new)
	assert(Acquisition.new.kind_of?(ActiveRecord::Base))
	model_class=eval("Acquisition")
	assert(model_class.new.kind_of?(ActiveRecord::Base))
	assert(model_class.module_included?(Generic_Table))
	model_class=eval("acquisitions".classify)
	assert(model_class.module_included?(Generic_Table))

	
	assert(Generic_Table.table_exists?("acquisitions".tableize))
	assert(Generic_Table.table_exists?("acquisitions"))
	assert_table("acquisitions")
	assert_table_exists("acquisitions")
	assert(model_class.new.kind_of?(ActiveRecord::Base))
	assert(Generic_Table.is_ActiveRecord_table?("Acquisition"))
	assert_ActiveRecord_table("Acquisition")
	assert_generic_table("Acquisition")
	assert(Generic_Table.is_generic_table?("Acquisition"))
	assert(Generic_Table.is_generic_table?("acquisitions".classify))
	assert(Generic_Table.is_generic_table?("acquisitions"))
	assert(Generic_Table.is_generic_table?(Acquisition.name))
	assert(Generic_Table.is_generic_table?("frequency"))
	assert(Generic_Table.is_generic_table?("acquisition_stream_specs"))
	assert(!Generic_Table.is_generic_table?("fake_belongs_to"))
	assert(!Generic_Table.is_generic_table?("fake_has_and_belongs_to_many"))
	assert(!Generic_Table.is_generic_table?("fake_has_one"))
	assert(!Generic_Table.is_generic_table?("fake_has_many"))

	
	assert(Generic_Table.rails_MVC_class?(:stream_pattern))
	assert(Generic_Table.rails_MVC_class?(:stream_pattern))
	assert_include('StreamMethod',CodeBase.rails_MVC_classes.map {|c| c.name})
	assert(CodeBase.rails_MVC_classes.map {|c| c.name}.include?('StreamMethod'))
	assert(Generic_Table.rails_MVC_class?('StreamMethod'))
end #test
def setup
#	ActiveSupport::TestCase::fixtures :acquisition_stream_specs
end #setup
def test_attributes
	assert_instance_of(ActiveSupport::HashWithIndifferentAccess, Example.attributes)
end #attributes
def test_column_symbols
	assert_include('sample', BatteryMeasurement.methods(true)) # checks immediate class and included modules
	sample=BatteryMeasurement.sample
	column_symbols=sample.flatten.map do |r|
		assert_instance_of(Hash, r)
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
	column_symbols=model_class?.column_symbols
	wanted_columns=[:multimeter_id, :id, :created_at, :updated_at, :load_current_ma, :battery_id, :load_current_mA, :voltage, :status, :closed_circuit_current_ma]
	assert_equal([], column_symbols-wanted_columns, "Unwanted columns:")
end #column_symbols
def test_NoDB_table_class
	assert_equal(BatteryType, BatteryType)
	assert_equal(BatteryType, BatteryType.table_class)
end #NoDB.table_class
def test_NoDB_table_name
	assert_equal('battery_types', BatteryType.table_name)
end #NoDB.table_name
def test_default_names
	explain_assert_respond_to(Example.class,:default_names)
	explain_assert_respond_to(NoDB::ClassMethods,:default_names)
	assert_equal(['Col_0'], Example.class.default_names(1))
	assert_equal(['Var0'], Example.class.default_names(1, 'Var'))
	assert_equal(['Col_0', 'Col_1'], Example.class.default_names([1,2]))
end #default_names
def test_insert_sql
	assert_equal("INSERT INTO battery_types(Size,Chemistry,Brand,Rated_capacity_mAh) VALUES();\n", BatteryType.insert_sql({}))
end #insert_sql
def test_dump
	assert_not_nil(BatteryType.dump)
	assert_not_empty(BatteryType.dump)
	puts BatteryType.dump
end #dump
def test_data_source_yaml_values
	assert_equal('BatteryType', BatteryType.name)
end #data_source_yaml
def test_get_field_names
	assert_equal(TEST_ARRAY, TestData.all)
	assert_equal({:input => 5, :output => -5}, TestData.all.first)
	assert_equal([:input, :output], TestData.all.first.keys)
	assert_equal([:input, :output], TestData.get_field_names)
end #field_names
def test_initialize
	assert_not_nil(Example)
	assert_instance_of(TestData, Example)
	assert_not_nil(TestData.new.attributes)

	values=[1, 2, 3]
#?	default_names=NoDB::ClassMethods.default_names(3)
	default_names=TestData.default_names(3)
	names=[:a, :b, :c]
	name_value_hash=Hash[[names, values].transpose]
	assert_instance_of(Hash, name_value_hash)
	assert_instance_of(Symbol, name_value_hash.keys[0])
	assert_equal(1, name_value_hash[:a])
	assert_nil(name_value_hash['a'])
	assert_instance_of(String, ActiveSupport::HashWithIndifferentAccess.new(:a => 1).keys[0])
	assert_instance_of(Hash, Hash.new(:a => 1))
	assert_instance_of(Array, Hash.new(:a => 1).keys)
	assert_equal(1, {:a => 1}.keys.size, "Hash.new({:a => 1})=#{Hash.new({:a => 1}).inspect}")
	assert_instance_of(Symbol, {:a => 1}.keys[0])
	hash_with_default_names=Hash[[default_names, values].transpose]
	assert_instance_of(Array, values)
	assert_instance_of(Array, names)
	names.all? do |n|
		assert_instance_of(Symbol, n)
	end #each
	assert(names.all?{|n| n.instance_of?(String)|n.instance_of?(Symbol)})
	assert_equal(name_value_hash, TestData.new(values, names).attributes)
	assert_equal(name_value_hash, TestData.new(values, names).attributes)
	assert_not_empty(TestData.new([1]).attributes)
end #NoDB initialize
def test_at
	attribute_name=:input
	assert_equal(2, Example[:input])
end #[]
def test_assign_attribute
	example=Example.clone # so I can modify it.
	example[:new_attribute]= 3
	assert_equal(3, example[:new_attribute])
	assert_equal(['input', 'output'], Example.keys.sort)
end #[]
def test_has_key
	assert(Example.has_key?(:input))
end #has_key?
def test_keys
	assert_equal(['input', 'output'], Example.keys.sort)
end #keys
def test_table_class
	assert_equal(BatteryType, BatteryType.new.table_class)
end #table_class
def test_table_name
	assert_equal('battery_types', BatteryType.new.table_name)
end #table_name
def test_clone
	example=Example.clone # so I can modify it.
	example[:new_attribute]= 3
	assert_equal(3, example[:new_attribute])
	assert_equal(['input', 'output'], Example.keys.sort)

end #clone
end #class {Generic_table,NoDB}}Test


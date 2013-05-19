###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
#require_relative '../assertions/generic_table_examples.rb'
require_relative '../../app/models/generic_table_assertion.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
class GenericTableTest < TestCase
include Generic_Table
extend Generic_Table::ClassMethods
#include GenericTableAssertions
include GenericTableAssertion::KernelMethods
set_class_variables BatteryMeasurement
@@table_name='stream_patterns'
	fixtures :table_specs
	fixtures :acquisition_stream_specs
	fixtures :acquisition_interfaces
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
	column_symbols=@@model_class.column_symbols
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
end #[]=
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
def test_each_pair
	assert_instance_of(Enumerator, Example.each_pair)
	assert_equal(Example.each_pair)
end #each_pair
end #NoDB


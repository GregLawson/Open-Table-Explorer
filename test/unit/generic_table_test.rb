###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class GenericTableTest < ActiveSupport::TestCase
include Generic_Table
include GenericTableAssertions
@@table_name='stream_patterns'
	fixtures :table_specs
	fixtures :acquisition_stream_specs
	fixtures :acquisition_interfaces
TEST_SIZE=10
TEST_START=5
TEST_STEP=-1
TEST_ARRAY=(TEST_START..TEST_START+TEST_SIZE-1).map{|i| TEST_STEP*i}.to_a
class TestData < Array
	extend Common::ClassMethods
def self.all
	return TEST_ARRAY
end #all
end #TestData
def test_column_symbols
	assert_include('sample', BatteryMeasurement.methods)
	wanted_columns=[:multimeter_id, :id, :created_at, :updated_at, :load_current_ma, :battery_id, :load_current_mA, :voltage, :status, :closed_circuit_current_ma]
	column_names=@@model_class.column_symbols
	assert_equal([], column_names-wanted_columns, "Unwanted columns:")
end #column_symbols
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
	many_random=(0..4).map do |i|
		TestData.sample(TEST_SIZE, :random, 1)
	end #map
	assert_equal(TEST_ARRAY, many_random.flatten.sort.uniq.reverse)
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
	ActiveRecord::Base.association_refs(class_reference, association_reference) do |class_reference, association_reference|
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
def test_activeRecordTableNotCreatedYet?
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
def test_NoDB
end #NoDB

end #test class

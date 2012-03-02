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
def test_NoDB
end #NoDB
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
def test_model_file_name
end #model_file_name
def test_is_active_record_method
	association_reference=:inputs
	assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
	assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
	assert(!TestTable.is_active_record_method?(:parameter))
	assert(TestTable.is_active_record_method?(:connection))
end #active_record_method
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

end #test class

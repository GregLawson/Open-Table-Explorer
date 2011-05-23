require 'test_helper'
class Test_Table < TableSpec
include Generic_Table
has_many :acquisition_stream_specs
belongs_to :frequency
has_many :acquisitions
belongs_to :fake_belongs_to
has_many :fake_has_many
has_and_belongs_to_many :fake_has_and_belongs_to_many
has_one :fake_has_one
end #class
class GenericTableTest < ActiveSupport::TestCase
def test_aaa
	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:cabbage) }
	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).scheme,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).acquisition_interface.scheme)
	testCall(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_association(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name)
	assert_instance_of(String,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym).associated_to_s(:acquisition_interface,:name))
	assert_respond_to(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:associated_to_s)
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=nil
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=0
#	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
end
test "associated_to_s" do
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)
	assert_not_nil(acquisition_stream_spec)
	puts acquisition_stream_spec.matching_methods(/table_spec/).inspect
	puts acquisition_stream_spec.similar_methods(:table_spec).inspect
	assert_respond_to(acquisition_stream_spec,:table_spec)
	meth=acquisition_stream_spec.method(:table_spec)
#	assert_not_nil(meth.call)
#	ass=acquisition_stream_spec.send(:table_spec)
#	if ass.nil? then
#		return ''
#	else
#		return ass.send(:model_class_name,*args).to_s
#	end
#	puts "acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)=#{acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)}"
end #test
test "matching associations" do
	assert_equal(["frequency_id"],TableSpec.new.foreign_key_names)
	assert_equal([],Test_Table.new.matching_methods(/_id=$/))
	assert_equal([],Test_Table.new.matching_methods(/_id$/))
	assert_equal_sets(["fake_has_and_belongs_to_many_ids", "acquisition_ids", "acquisition_stream_spec_ids", "fake_has_many_ids"],Test_Table.new.matching_methods(/_ids$/))
	assert_equal_sets(["fake_has_and_belongs_to_many_ids=", "acquisition_ids=", "acquisition_stream_spec_ids=", "fake_has_many_ids="],Test_Table.new.matching_methods(/_ids=$/))
	assert_equal_sets(["fake_belongs_to=",
 "acquisition_stream_specs=",
 "fake_has_and_belongs_to_many_ids=",
 "fake_has_and_belongs_to_many=",
 "acquisitions=",
 "acquisition_ids=",
 "acquisition_stream_spec_ids=",
 "frequency=",
 "fake_has_many_ids=",
 "fake_has_one=",
 "fake_has_many="],Test_Table.new.matching_methods(/=$/))

	assert_equal_sets(["acquisition_stream_specs", "acquisition_stream_specs=", "acquisition_stream_spec_ids", "acquisition_stream_spec_ids="],Test_Table.new.matching_methods(/^acquisition_stream_spec/))
	assert_equal_sets(["acquisition_stream_specs",
 "acquisitions",
 "acquisition_stream_specs=",
 "acquisition_ids",
 "acquisition_stream_spec_ids",
 "acquisitions=",
 "acquisition_ids=",
 "acquisition_stream_spec_ids="],Test_Table.new.matching_methods(/^acquisition/))
	assert_equal_sets(["frequency", "frequency="],Test_Table.new.matching_methods(/^frequenc/))
	assert_equal_sets(["fake_has_many_ids", "fake_has_many", "fake_has_many_ids=", "fake_has_many="],Test_Table.new.matching_methods(/^fake_has_many/))
	assert_equal_sets(["fake_has_and_belongs_to_many_ids", "fake_has_and_belongs_to_many", "fake_has_and_belongs_to_many_ids=","fake_has_and_belongs_to_many="],Test_Table.new.matching_methods(/^fake_has_and_belongs_to_many/))
	assert_equal_sets(['fake_has_one','fake_has_one='],Test_Table.new.matching_methods(/^fake_has_one/))
	assert_equal_sets(["fake_belongs_to=", "fake_belongs_to"],Test_Table.new.matching_methods(/^fake_belongs_to/))

	assert_equal_sets([],Test_Table.new.Match_and_strip(/_id=$/))
	assert_equal_sets([],Test_Table.new.Match_and_strip(/_id$/))
	assert_equal_sets(["acquisition","fake_has_and_belongs_to_many", "fake_has_many","acquisition_stream_spec"],Test_Table.new.Match_and_strip(/_ids$/))
	assert_equal_sets(["acquisition","fake_has_and_belongs_to_many", "fake_has_many","acquisition_stream_spec"],Test_Table.new.Match_and_strip(/_ids=$/))
	assert_equal_sets(["fake_belongs_to",
 "acquisition_stream_specs",
 "fake_has_and_belongs_to_many_ids",
 "fake_has_and_belongs_to_many",
 "acquisitions",
 "acquisition_ids",
 "acquisition_stream_spec_ids",
 "frequency",
 "fake_has_many_ids",
 "fake_has_one",
 "fake_has_many"],Test_Table.new.Match_and_strip(/=$/))
	assert_equal_sets(["fake_belongs_to", "acquisition_stream_specs", "fake_has_and_belongs_to_many", "acquisitions", "frequency",  "fake_has_one", "fake_has_many"], Test_Table.new.Match_and_strip(/=$/).select {|a| Test_Table.new.is_association?(a)})

	#~ puts Test_Table.new.matching_methods(/table/,true).inspect
	#~ puts Test_Table.matching_methods(/table/,true).inspect
	#~ puts "Test_Table.context_names(22)=#{Test_Table.context_names(22).inspect}"
	#~ puts "Test_Table.new.context_names(22)=#{Test_Table.new.context_names(22).inspect}"
	#~ puts Test_Table.matching_methods_in_context(/table/,22).inspect
	#~ explain_assert_respond_to(Test_Table.new,:tables)
	#~ explain_assert_respond_to(TableSpec.new,:tables)
	assert_equal("Acquisition","acquisitions".classify)
	assert_equal("Acquisition",Acquisition.name)
	assert_equal("acquisitions",Acquisition.table_name)
	assert_equal("Acquisition".tableize,"acquisitions")
	assert(Generic_Table.table_exists?("acquisitions".tableize))
	
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
	assert_equal_sets(["acquisition_stream_specs",  "acquisitions", "frequency"], Test_Table.new.Match_and_strip(/=$/).select {|a| Generic_Table.is_generic_table?(a)})
	assert_not_empty(Test_Table.new.foreign_key_names)
	
	assert_equal(Test_Table.new.foreign_key_names.map {|fk| fk.sub(/_id$/,'')}-Test_Table.new.Match_and_strip(/=$/).select {|a| Generic_Table.is_generic_table?(a)},[])

	assert_respond_to(TableSpec.new,:frequency)
	assert_nil(TableSpec.new.frequency)
	assert_association(TableSpec.new,"frequency")
	assert(TableSpec.new.is_matching_association?("frequency"))
	assert_association(Frequency.new,"table_specs")
	assert_equal('frequencies',Frequency.table_name)
	assert(TableSpec.new.is_association?(Frequency.table_name.singularize))
	assert(Frequency.new.is_matching_association?("table_specs"))
	assert_matching_association("table_specs","frequency")
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_matching_association("acquisitions","frequency")
	end #assert_raised
end #test
test "has macros" do
#	assert_equal_sets(["has_one", "has_many", "has_and_belongs_to_many"],Frequency.matching_methods(/^has_/))
end #test
end #test class

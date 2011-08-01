require 'test_helper'
class TestHelperTest < ActiveSupport::TestCase
class TestClass
def self.classMethod
end #def
public
def publicInstanceMethod
end #def
protected
def protectedInstanceMethod
end #def
private
def privateInstanceMethod
end #def
end #class
def setup
#	define_association_names
end
def testMethod
	return 'nice result'
end #def
test "method call" do
	#~ explain_assert_respond_to(self,:testMethod)
	testCallResult(self,:testMethod)
	testCall(self,:testMethod)
	#~ testAnswer(self,:testMethod,'nice result')
	#~ assert_public_instance_method(table_specs(:ifconfig),:acquisition_stream_specs)
end #test
test "explain_assert_respond_to" do
#	assert_raise(Test::Unit::AssertionFailedError,explain_assert_respond_to(TestClass,:sequential_id?))
#	explain_assert_respond_to(TestClass,:sequential_id?," probably does not include include Generic_Table statement.")

	explain_assert_respond_to(Acquisition.new,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")
	assert_respond_to(Acquisition.new,:sequential_id?,"Acquisition.rb probably does not include include Generic_Table statement.")

end #test
test "assert_include" do
	assert_include('table_specs',fixture_names)
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))

end #test
test "various assertions" do
	assert_not_empty([1])
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	ar_from_fixture=table_specs(:ifconfig)
	assert_not_nil ar_from_fixture.class.similar_methods(:acquisition_stream_spec)
	assert_not_nil ar_from_fixture.matching_methods(/acquis*/)	
end #test
test "fixtures" do
	table_name='table_specs'
	assert_not_nil fixtures(table_name)
	assert_fixture_name(table_name)
	assert_not_nil fixture_labels(table_name)
#	assert_not_nil model_class(table_specs(:ifconfig))
	assert_include('table_specs',fixture_names)
end #test
test "assert_associations" do
	assert(@@CLASS_WITH_FOREIGN_KEY.belongs_to_association?(@@FOREIGN_KEY_ASSOCIATION_SYMBOL) ,"StreamPatternArgument belongs_to stream_pattern")
	assert(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s.classify.constantize.has_many_association?(@@TABLE_NAME_WITH_FOREIGN_KEY),"#{@@FOREIGN_KEY_ASSOCIATION_SYMBOL} does not has_many #{@@TABLE_NAME_WITH_FOREIGN_KEY}")
	assert_associations(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	assert_associations(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,@@CLASS_WITH_FOREIGN_KEY)
end #test
test "association to one" do
	ar_from_fixture=table_specs(:ifconfig)
	assName=:acquisition_stream_specs
	ASSNAME=ar_from_fixture.class.association_method_symbol(assName)
	assert_not_nil(ar_from_fixture.class.is_association?(ASSNAME))
	assName=ASSNAME.to_sym
	assert_instance_of(Symbol,ASSNAME,"assert_association")
	assert_public_instance_method(ar_from_fixture,ASSNAME)
	explain_assert_respond_to(ar_from_fixture,(ASSNAME.to_s+'=').to_sym)

	assName=:acquisition_stream_specs

	assert_association(ar_from_fixture,ASSNAME)
	assert_association(ar_from_fixture,:acquisition_stream_specs)
	assert_not_nil(ar_from_fixture.class.is_association_to_one?(ASSNAME))
	assert_association_to_one(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
	assert_association_many_to_one(fixtures(:acquisition_stream_specs).values.first,:table_spec)
	assert_association_one_to_one(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:acquisition_interface)
	assert_foreign_key_points_to_me(ar_from_fixture,ASSNAME)
	assert_has_associations(TableSpec)
	assert_has_instance_methods(TableSpec)

end #test
test "association to many" do
	assert_not_nil(table_specs(:ifconfig).class.is_association_to_many?(:acquisition_stream_specs))
	assert_association_to_many(fixtures(:table_specs).values.first,:acquisition_stream_specs)
	assert_association_one_to_many(table_specs(:ifconfig),:acquisition_stream_specs)
end #test
test "other association" do
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
test 'assert_matching_association' do
#	assert_matching_association(TestTable,:full_associated_models)	
#	assert(TestTable.is_matching_association?(:full_associated_models))
	assert_matching_association("table_specs","frequency")
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_matching_association("acquisitions","frequency")
	end #assert_raised
end  #test
test "empty" do
	assert_not_empty('a')
	assert_not_empty(['a'])
	assert_empty([])
	assert_empty('')
end #test
test "equal sets" do
	array1=['a']
	array2=['a']
	assert_equal_sets(array1,array2)
	assert_equal(Set.new(array1),Set.new(array2))
	assert_module_included(Acquisition,Generic_Table)
end #test
end #class


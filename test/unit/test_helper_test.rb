require 'test_helper'
class TestHelperTest < ActiveSupport::TestCase
def setup
#	define_association_names
end
def testMethod
	return 'nice result'
end #def
test "method call" do
	explain_assert_respond_to(self,:testMethod)
	testCallResult(self,:testMethod)
	testCall(self,:testMethod)
	testAnswer(self,:testMethod,'nice result')
	assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
end #test
test "various assertions" do
	assert_not_empty([1])
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	ar_from_fixture=table_specs(:MULTIPLE_WEATHER)
	assert_not_nil ar_from_fixture.similar_methods(:acquisition_stream_spec)
	assert_not_nil ar_from_fixture.matching_methods(/acquis*/)	
end #test
test "fixtures" do
	table_name='table_specs'
	assert_not_nil fixtures(table_name)
	assert_fixture_name(table_name)
	assert_not_nil fixture_labels(table_name)
#	assert_not_nil model_class(table_specs(:MULTIPLE_WEATHER))
	assert_include('table_specs',fixture_names)
end #test
test "association to one" do
	ar_from_fixture=table_specs(:MULTIPLE_WEATHER)
	assName=:acquisition_stream_specs
	assert_not_nil is_association?(ar_from_fixture,assName)
	assert_association(ar_from_fixture,assName)
	assert_not_nil is_association_to_one?(ar_from_fixture,assName)
	assert_association_to_one(acquisition_stream_specs(:one),:table_spec)
	assert_association_many_to_one(fixtures(:acquisition_stream_specs).values.first,:table_spec)
	assert_association_one_to_one(acquisition_stream_specs(:one),:acquisition_interface)
#	assert_foreign_key_points_to_me(ar_from_fixture,assName)

end #test
test "association to many" do
	assert_not_nil is_association_to_many?(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association_to_many(fixtures(:table_specs).values.first,:acquisition_stream_specs)
	assert_association_one_to_many(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
end #test
test "other association" do
	model_class=TableSpec
	assert_equal(['frequency_id'],foreign_key_names(TableSpec))
	assert_equal(Set.new(['acquisition_interface_id','table_spec_id']),Set.new(foreign_key_names(AcquisitionStreamSpec)))
	assert_equal([],foreign_key_names(AcquisitionInterface))
	ar_from_fixture=table_specs(:MULTIPLE_WEATHER)
	assName=:frequency
	assert_instance_of(Symbol,assName,"associated_foreign_key assName=#{assName.inspect}")
	
	assert_association(ar_from_fixture,assName)
	assert_not_nil(associated_foreign_key_name(ar_from_fixture,assName),"associated_foreign_key_name: ar_from_fixture=#{ar_from_fixture},assName=#{assName})")
	assert_equal('frequency_id',associated_foreign_key_name(ar_from_fixture,assName))
end #test
end #class


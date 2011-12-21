require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class TableSpecTest < ActiveSupport::TestCase
  #~ fixtures :acquisition_interfaces
  #~ fixtures :acquisition_stream_specs
  #~ fixtures :acquisitions
  #~ fixtures :table_specs
  #~ fixtures :frequencies
def setup
	define_model_of_test
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
	assert_equal('TableSpec',@model_name)
	assert_equal(TableSpec,@model_class)
	assert_equal('table_specs',@table_name)
	assert(TableSpec.instance_methods(false).include?('acquisition_stream_specs'),"TableSpec.instance_methods(false).include?('acquisition_stream_specs')")
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_include('acquisition_stream_specs_Not_a_method',TableSpec.instance_methods(false))
	end #assert_raise
	explain_assert_respond_to(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_respond_to(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert(table_specs(:MULTIPLE_WEATHER).class.is_association?(:acquisition_stream_specs),"is_association?(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)")
	assert_equal(Set.new(['acquisition_stream_specs',"frequency"]),Set.new(@possible_associations))
	assert_equal(['frequency_id'],@possible_foreign_keys)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:cabbage) }
	assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	testCall(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association(table_specs(:MULTIPLE_WEATHER),:frequency)
	assert_association_one_to_many(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association_many_to_one(table_specs(:MULTIPLE_WEATHER),:frequency)
	assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_specs) }
	assert_association(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
	assert_association_to_one(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
	assert_association_many_to_one(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
	@my_fixtures.each_value do |ar_from_fixture|
		assert_association_to_many(ar_from_fixture,:acquisition_stream_specs)
		assert_association_one_to_many(ar_from_fixture,:acquisition_stream_specs)
		assert_respond_to(ar_from_fixture,:acquisition_stream_specs)
		associated_records=testCallResult(ar_from_fixture,:acquisition_stream_specs)
		#~ associated_records.all? do |ar|
			#~ assert_equal(ar_from_fixture.id,associated_foreign_key_id(ar,:table_spec))
		#~ end #each
		assert_public_instance_method(acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym),:table_spec)
		assert_association_many_to_one(ar_from_fixture,:frequency)
		assert_equal(["frequency_id"],foreign_key_names(ar_from_fixture.class),"foreign_key_names(ar_from_fixture.class)=#{foreign_key_names(ar_from_fixture.class)}")
	end #each
end #test
def test_aaa_test_assertions # aaa to output first
	assert_equal(@my_fixtures,fixtures('table_specs'))
end #test
def test_associated_id_equal
	assert_instance_of(Hash,fixtures('table_specs'))
	assert_operator(fixtures('table_specs').length,:>,0,"fixtures('table_specs')=#{fixtures('table_specs')}")
	fixtures('table_specs').each_value do |ar_from_fixture|
		ar_from_fixture.acquisition_stream_specs.each do |ar|
			assert_equal(Fixtures::identify(ar_from_fixture.ar.logical_primary_key),ar.table_spec_id,"identify != acquisition_stream_specs.first.table_spec_id. logical_primary_key=#{logical_primary_key}")
		end #each
	end #each_value
end #def
def test_association_empty
#	assert_not_nil(acquisition_stream_specs,message)
	frequencies.each do |associated_record|
		puts "associated_record.inspect=#{associated_record.inspect}"
		assert_instance_of(Array,@my_fixtures)
		associated_record=@my_fixtures[rk.to_sym]
		puts "associated_record.frequency_id=#{associated_record.frequency_id}"
		message="#{associated_record.inspect} but frequency not associated with #{frequencies.inspect}"
		assert_equal(frequencies(rk.to_sym).id,associated_record.frequency_id)
		assert_operator(associated_record.frequency.count,:>,0,"count "+message)
		assert_operator(associated_record.frequency.length,:>,0,"length "+message)
		assert(!associated_record.frequency.empty?,"empty "+message)
	end #each
end #def
end #class

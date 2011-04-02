require 'test_helper'

class TableSpecTest < ActiveSupport::TestCase
  #~ fixtures :acquisition_interfaces
  #~ fixtures :acquisition_stream_specs
  #~ fixtures :acquisitions
  #~ fixtures :table_specs
  #~ fixtures :frequencies
def find_fixture
	#~ puts "name=#{Global.objectName(table_specs(:MULTIPLE_WEATHER))}"
	#~ puts "class=#{Global.objectClass(table_specs(:MULTIPLE_WEATHER))}"
	#~ puts Global.canonicalName(table_specs(:MULTIPLE_WEATHER),verbose=true)
	assert_equal(fixture_names,["weathers", "edisons", "breakers","acquisition_stream_specs", "measurements","transactions", "routers", "parse_specs", "loads", "urls", "stations", "schema_migrations","parameters","acquisition_interfaces", "tedprimaries","huelseries", "hosts","frequencies", "example_types","example_acquisitions", "postgresql2rails", "productions", "huelshows", "accounts", "ports","table_specs", "production_ftps","postgresql2import", "networks", "nodes","acquisitions", "transfers", "params", "generic_types", "bugs", "wired_locations"])
	assert_equal(record_keys('table_specs'),["huell_schedule","TEDWebBoxFull","nmap","Network","MULTIPLE_WEATHER"])

	#~ fixture=fixtures.send(:[],:MULTIPLE_WEATHER)
	#~ assert_equal(table_specs(:MULTIPLE_WEATHER),fixture)
	#~ fixtures=self.send(:table_specs)
	#~ assert_not_nil(fixtures)
	#~ assert_instance_of(Array,fixtures)
	#~ assert_equal(fixtures,@my_fixtures)
	#~ assert_respond_to(self,:table_specs)
		
#	assert_public_instance_method(self,:table_specs)
	#~ explain_assert_respond_to(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	#~ assert(TableSpec.instance_methods(false).include?('acquisition_stream_specs'),"TableSpec.instance_methods(false).include?('acquisition_stream_specs')")
	#~ assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))

#	puts " @loaded_fixtures.inspect=#{ @loaded_fixtures.inspect}"
#	puts " @loaded_fixtures['table_specs'].inspect=#{ @loaded_fixtures['table_specs'].inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).inspect=#{ @loaded_fixtures['table_specs'].at(0).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect}"
	@my_fixtures.each do |my_fixture|
		#~ puts "matching_methods(acquisition_stream_specs(:MULTIPLE_WEATHER),/^acquisition_stream_spec/)).inspect=#{matching_methods(my_fixture,/^acquisition_stream_spec/).inspect}"
		#~ puts "similar_methods(@my_fixture,:acquisition_stream_specs).inspect=#{similar_methods(my_fixture,:acquisition_stream_specs).inspect}"
		#~ puts "similar_methods(acquisition_stream_specs(:one),:table_spec)=#{similar_methods(acquisition_stream_specs(:one),:table_spec)}"
	end #each
	@my_fixtures.each do |my_fixture|
		assert_my_foreign_key_points_to_correct_id(my_fixture,:frequency)
		assert_foreign_key_points_to_me(my_fixture,:acquisition_stream_specs)
	end #each
	@fixture_names=@loaded_fixtures.keys
#	puts " @fixture_names.inspect=#{ @fixture_names.inspect}"
#	puts " @loaded_fixtures.inspect=#{ @loaded_fixtures.inspect}"
#	puts " @loaded_fixtures['table_specs'].inspect=#{ @loaded_fixtures['table_specs'].inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).inspect=#{ @loaded_fixtures['table_specs'].at(0).inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect}"
	puts "matching_methods(self,/.*_spec$/).inspect=#{matching_methods(self,/_spec/).inspect}"
	puts "instance_variables.inspect=#{instance_variables.inspect}"
	#~ @my_fixtures=@record_keys.collect do |rk|
		#~ table_specs(rk)
	#~ end #each
#	puts "@possible_foreign_keys=#{@possible_foreign_keys.inspect}"	
end #def
test "specific, stable and working" do
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
	assert(is_association?(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs),"is_association?(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)")
	assert_equal(Set.new(@possible_associations),Set.new(['acquisition_stream_specs',"frequency"]))
	assert_equal(@possible_foreign_keys,['frequency_id'])
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:cabbage) }
	assert_public_instance_method(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	testCall(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association(table_specs(:MULTIPLE_WEATHER),:frequency)
	assert_association_one_to_many(table_specs(:MULTIPLE_WEATHER),:acquisition_stream_specs)
	assert_association_many_to_one(table_specs(:MULTIPLE_WEATHER),:frequency)
	assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs(:one),:table_specs) }
	assert_association(acquisition_stream_specs(:one),:table_spec)
	assert_association_to_one(acquisition_stream_specs(:one),:table_spec)
	assert_association_many_to_one(acquisition_stream_specs(:one),:table_spec)
	@my_fixtures.each do |my_fixture|
		assert_association_to_many(my_fixture,:acquisition_stream_specs)
		assert_association_one_to_many(my_fixture,:acquisition_stream_specs)
		assert_respond_to(my_fixture,:acquisition_stream_specs)
		associated_records=testCallResult(my_fixture,:acquisition_stream_specs)
		#~ associated_records.all? do |ar|
			#~ assert_equal(my_fixture.id,associated_foreign_key_id(ar,:table_spec))
		#~ end #each
		assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
		assert_association_many_to_one(my_fixture,:frequency)
		assert_equal(["frequency_id"],foreign_key_names(my_fixture.class),"foreign_key_names(my_fixture.class)=#{foreign_key_names(my_fixture.class)}")
	end #each
end #def
def setup
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
def test_aaa_test_assertions # aaa to output first
	assert_equal(@my_fixtures,fixtures('table_specs'))
	find_fixture
#	puts "acquisition_stream_specs(:one).class.instance_method_names.inspect=#{acquisition_stream_specs(:one).class.instance_method_names.inspect}"
#~ assert_equal(@my_fixture.id,associated_foreign_key_id(acquisition_stream_specs(:one),:table_spec))

#	assert_equal([:frequency_id],associated_foreign_key_id(@my_fixture,:frequency),"associated_foreign_key_id(@my_fixture,:frequecy_id)=#{associated_foreign_key_id(@my_fixture,:frequecy_id)}")
#	assert_equal(Fixtures::identify(:one),associated_foreign_key_id(@my_fixture,:frequency),"associated_foreign_key_id(@my_fixture,:frequecy_id)=#{associated_foreign_key_id(@my_fixture,:frequecy_id)}")

#	assert_equal([],testCallResult(@my_fixture,:frequency))
#	assert_equal(associated_foreign_key_id(testCallResult(@my_fixture,:frequency).first,ass),Fixtures::identify(:one))

#	assert_foreign_key_points_to_me(@my_fixture,:acquisition_stream_specs)
	
#	Global.whoAmI(acquisition_stream_specs(:one))
#	assert_equal([:table_spec_id,:acquisition_stream_spec_id],@possible_foreign_keys)
#	http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
#	puts "self.class.instance_methods(false)=#{self.class.instance_methods(false).inspect}"

	
#	assert_association(AcquisitionStreamSpec,@model_class)
end
def test_id_equal
	@my_fixtures.each do |my_fixture|
		assert_equal(Fixtures::identify(my_fixture.model_class_name),my_fixture.id,"identify != id")
	end
end #def
def test_associated_id_equal
#	puts "@my_fixture.inspect=#{@my_fixture.inspect}"
#	puts "@my_fixture.acquisition_stream_specs.inspect=#{@my_fixture.acquisition_stream_specs.inspect}"
	assert_instance_of(Array,fixtures('table_specs'))
	assert_operator(fixtures('table_specs').length,:>,0,"fixtures('table_specs')=#{fixtures('table_specs')}")
	fixtures('table_specs').each do |my_fixture|
		my_fixture.acquisition_stream_specs.each do |ar|
			assert_equal(Fixtures::identify(my_fixture.model_class_name),ar.table_spec_id,"identify != acquisition_stream_specs.first.table_spec_id")
		end #each
	end #each
end #def
test "association empty" do
#	assert_not_nil(acquisition_stream_specs,message)
	frequencies.each do |my_fixture|
		puts "my_fixture.inspect=#{my_fixture.inspect}"
		assert_instance_of(Array,@my_fixtures)
		my_fixture=@my_fixtures[rk.to_sym]
		puts "my_fixture.frequency_id=#{my_fixture.frequency_id}"
		message="#{my_fixture.inspect} but frequency not associated with #{frequencies.inspect}"
		assert_equal(frequencies(rk.to_sym).id,my_fixture.frequency_id)
		assert_operator(my_fixture.frequency.count,:>,0,"count "+message)
		assert_operator(my_fixture.frequency.length,:>,0,"length "+message)
		assert(!my_fixture.frequency.empty?,"empty "+message)
	end #each
end #def
end #class

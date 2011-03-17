require 'test_helper'

class TableSpecTest < ActiveSupport::TestCase
def similar_methods(fixture,symbol)
	singular='^'+symbol.to_s.singularize
	plural='^'+symbol.to_s.pluralize
	table='^'+symbol.to_s.tableize
	return (matching_methods(fixture,singular) + matching_methods(fixture,plural) + matching_methods(table,plural)).uniq
end #def
def matching_methods(fixture,regexp)
	fixture.class.instance_methods(false).select {|m| m[Regexp.new(regexp),0] }
end #def
def is_association?(fixture,ass)
#	puts "is_association? is called with #{ass}"
	if fixture.respond_to?(ass) and fixture.respond_to?((ass.to_s+'=').to_sym)  then
		assert_respond_to(fixture,ass)
		assert_respond_to(fixture,(ass.to_s+'=').to_sym)
		return true
	else
		return false
	end
end #def
def is_association_to_one?(fixture,ass)
	if is_association?(fixture,ass)  and !fixture.respond_to?((ass.to_s.singularize+'_ids').to_sym) and !fixture.respond_to?((ass.to_s.singularize+'_ids=').to_sym) then
		assert_association(fixture,ass)
		return true
	else
		return false
	end
end #def
def is_association_to_many?(fixture,ass)
	if is_association?(fixture,ass)  and fixture.respond_to?((ass.to_s.singularize+'_ids').to_sym) and fixture.respond_to?((ass.to_s.singularize+'_ids=').to_sym) then
		assert_association(fixture,ass)
		assert_public_instance_method(fixture,(ass.to_s.singularize+'_ids').to_sym) 
		assert_public_instance_method(fixture,(ass.to_s.singularize+'_ids=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association(fixture,ass)
	assert_respond_to(fixture,ass)
	assert_respond_to(fixture,(ass.to_s+'=').to_sym)
	assert(is_association?(fixture,ass),"fail s_association?, fixture.inspect=#{fixture.inspect},ass=#{ass}")
end #def
def assert_association_to_many(fixture,ass)
	assert_association(fixture,ass)
	assert(is_association_to_many?(fixture,ass),"is_association_to_many?(#{fixture.inspect},#{ass.inspect}) returns false. #{similar_methods(fixture,ass).inspect}.respond_to?(#{(ass.to_s+'_ids').to_sym}) and fixture.respond_to?(#{(ass.to_s+'_ids=').to_sym})")
	assert(!is_association_to_one?(fixture,ass),"fail !is_association_to_one?, fixture.inspect=#{fixture.inspect},ass=#{ass}")
end #def
def assert_association_to_one(fixture,ass)
	assert_association(fixture,ass)
	assert(!is_association_to_many?(fixture,ass),"fail !is_association_to_many?, fixture.inspect=#{fixture.inspect},ass=#{ass}, similar_methods(fixture,ass).inspect=#{similar_methods(fixture,ass).inspect}")
end #def
def assert_association_one_to_one(fixture,ass)
	assert_association_to_one(fixture,ass)
end #def
def assert_association_one_to_many(fixture,ass)
	assert_association_to_many(fixture,ass)
end #def
def assert_association_many_to_one(fixture,ass)
	assert_association_to_one(fixture,ass)
end #def

def assert_include(element,list)
	assert(list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def define_association_names
	@model_name=self.class.name[0..-5]
	@model_class=eval(@model_name)
 	@table_name=@model_name.tableize
	@fixture_names=@loaded_fixtures.keys
#	puts " @fixture_names.inspect=#{ @fixture_names.inspect}"
	@my_fixture=eval(@table_name+'(:one)')
 	@possible_associations=@model_class.instance_methods(false).select { |m| m =~ /=$/ and !(m =~ /_ids=$/) and is_association?(@my_fixture,m[0..-2])}.collect {|m| m[0..-2] }
#	puts "@possible_associations.inspect=#{@possible_associations.inspect}"

#	puts "@model_class.column_names=#{@model_class.column_names.inspect}"
 	@possible_many_associations=@model_class.instance_methods(false).select { |m| (m =~ /_ids=$/) and is_association_to_many?(@my_fixture,m[0..-2])}.collect {|m| m[0..-2] }
#	puts "@possible_many_associations.inspect=#{@possible_many_associations.inspect}"
	#~ @content_column_names=@model_class.content_columns.collect {|m| m.name}
	#~ puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	#~ @special_columns=@model_class.column_names-@content_column_names
	#~ puts "@special_columns.inspect=#{@special_columns.inspect}"
	@possible_foreign_keys=foreign_key_names(@model_class)
#	puts "@possible_foreign_keys=#{@possible_foreign_keys.inspect}"
end
def foreign_key_names(model_class)
	@content_column_names=model_class.content_columns.collect {|m| m.name}
#	puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	@special_columns=model_class.column_names-@content_column_names
#	puts "@special_columns.inspect=#{@special_columns.inspect}"
	@possible_foreign_keys=@special_columns.select { |m| m =~ /_id$/ }
#	puts "@possible_foreign_keys=#{@possible_foreign_keys.inspect}"
	return @possible_foreign_keys
end #def
def associated_foreign_key_name(obj,assName)
	many_to_one_foreign_keys=foreign_key_names(obj.class)
	many_to_one_associations=many_to_one_foreign_keys.collect {|k| k[0..-4]}
	many_to_one_associations.each do |ass|
		assert_association_many_to_one(obj,ass)
	end
	return many_to_one_foreign_keys.first
end #def
def associated_foreign_key(obj,assName)
	return obj.method(associated_foreign_key_name(obj,assName))
end #def
def associated_foreign_key_id(obj,assName)
	return associated_foreign_key(obj,assName).call
end #def
def setup
	define_association_names
end
def assert_foreign_key_points_to_me?(fixture,ass)
	associated_records=testCallResult(fixture,ass)
	associated_records.all? do |ar|
		assert_equal(fixture.id,associated_foreign_key_id(ar,ass))
	end #each
end
test "general associations" do
	@possible_associations.each do |ass|
		if is_association_to_many?(@my_fixture,ass) then
			 assert_association_to_many(@my_fixture,ass)
#			assert_equal(@my_fixture.id,associated_foreign_key_id(testCallResult(@my_fixture,ass).first,ass),Fixtures::identify(:one))
		else
			assert_association_to_one(@my_fixture,ass)
#			assert_equal(associated_foreign_key_id(testCallResult(@my_fixture,ass).first,ass),Fixtures::identify(:one))
		end
	end
	assert_equal(Fixtures::identify(:one),@my_fixture.id,"identify != id")
end #test
test "specific, stable and working" do
	assert_equal(@model_name,'TableSpec')
	assert_equal(@model_class,TableSpec)
	assert_equal(@table_name,'table_specs')
	assert(TableSpec.instance_methods(false).include?('acquisition_stream_specs'),"TableSpec.instance_methods(false).include?('acquisition_stream_specs')")
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_include('acquisition_stream_specs_Not_a_method',TableSpec.instance_methods(false))
	end #assert_raise
	explain_assert_respond_to(table_specs(:one),:acquisition_stream_specs)
	assert_respond_to(table_specs(:one),:acquisition_stream_specs)
	assert_association(table_specs(:one),:acquisition_stream_specs)
	assert(is_association?(table_specs(:one),:acquisition_stream_specs),"is_association?(table_specs(:one),:acquisition_stream_specs)")
	assert_equal(Set.new(@possible_associations),Set.new(['acquisition_stream_specs',"frequency"]))
	assert_equal(@possible_foreign_keys,['frequency_id'])
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(table_specs(:one),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(table_specs(:one),:cabbage) }
	assert_public_instance_method(table_specs(:one),:acquisition_stream_specs)
	testCall(table_specs(:one),:acquisition_stream_specs)
	assert_association(table_specs(:one),:acquisition_stream_specs)
	assert_association(table_specs(:one),:frequency)
	assert_association_one_to_many(table_specs(:one),:acquisition_stream_specs)
	assert_association_many_to_one(table_specs(:one),:frequency)
	assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_specs(:one),:table_specs) }
	assert_association(acquisition_stream_specs(:one),:table_spec)
	assert_association_to_one(acquisition_stream_specs(:one),:table_spec)
	assert_association_many_to_one(acquisition_stream_specs(:one),:table_spec)
	assert_association_to_many(@my_fixture,:acquisition_stream_specs)
	assert_association_one_to_many(@my_fixture,:acquisition_stream_specs)
end #def
test "association empty" do
	message="table_specs(:one).inspect=#{table_specs(:one).inspect} but acquisition_stream_specs not associated with #{acquisition_stream_specs(:one).inspect}"
	assert_not_nil(acquisition_stream_specs,message)
#	assert_equal(@my_fixture.acquisition_stream_specs,[],message)
	assert_operator(@my_fixture.acquisition_stream_specs.count,:>,0,"count "+message)
	assert_operator(@my_fixture.acquisition_stream_specs.length,:>,0,"length "+message)
	assert(!@my_fixture.acquisition_stream_specs.empty?,"empty "+message)
end
def test_aaa_test_assertions # aaa to output first
	puts "acquisition_stream_specs(:one).class.instance_method_names.inspect=#{acquisition_stream_specs(:one).class.instance_method_names.inspect}"
	puts "name=#{Global.objectName(acquisition_stream_specs(:one))}"
	puts "class=#{Global.objectClass(acquisition_stream_specs(:one))}"
	puts Global.canonicalName(acquisition_stream_specs(:one),verbose=true)
	puts "matching_methods(acquisition_stream_specs(:one),/^acquisition_stream_spec/)).inspect=#{matching_methods(@my_fixture,/^acquisition_stream_spec/).inspect}"
	puts "similar_methods(@my_fixture,:acquisition_stream_specs).inspect=#{similar_methods(@my_fixture,:acquisition_stream_specs).inspect}"
	assert_respond_to(@my_fixture,:acquisition_stream_specs)
	associated_records=testCallResult(@my_fixture,:acquisition_stream_specs)
	assert_public_instance_method(acquisition_stream_specs(:one),:table_spec)
	puts "similar_methods(acquisition_stream_specs(:one),:table_spec)=#{similar_methods(acquisition_stream_specs(:one),:table_spec)}"
	assert_equal(@my_fixture.id,associated_foreign_key_id(acquisition_stream_specs(:one),:table_spec))
	associated_records.all? do |ar|
		assert_equal(@my_fixture.id,associated_foreign_key_id(acquisition_stream_specs(:one),:table_spec))
	end #each
#	assert_foreign_key_points_to_me?(@my_fixture,:acquisition_stream_specs)
#	Global.whoAmI(acquisition_stream_specs(:one))
#	assert_equal([:table_spec_id,:acquisition_stream_spec_id],@possible_foreign_keys)
#	http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
#	puts "self.class.instance_methods(false)=#{self.class.instance_methods(false).inspect}"

#	puts " @loaded_fixtures['table_specs'].inspect=#{ @loaded_fixtures['table_specs'].inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).inspect=#{ @loaded_fixtures['table_specs'].at(0).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).fixture.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect}"
	
#	assert_association(AcquisitionStreamSpec,@model_class)
end
def test_id_equal
		assert_equal(Fixtures::identify(:one),@my_fixture.id,"identify != id")
end #def
def test_associated_id_equal
#	puts "@my_fixture.inspect=#{@my_fixture.inspect}"
#	puts "@my_fixture.acquisition_stream_specs.inspect=#{@my_fixture.acquisition_stream_specs.inspect}"
	assert_equal(Fixtures::identify(:one),@my_fixture.acquisition_stream_specs.first.table_spec_id,"identify != acquisition_stream_specs.first.table_spec_id")
end #def
end

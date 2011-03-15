require 'test_helper'

class TableSpecTest < ActiveSupport::TestCase
def assert_fixture_name(obj,methodName=self.class.name,message='')
	if obj.respond_to?(methodName) then
		message='expect to pass'
	elsif obj.respond_to?(methodName.to_s.singularize) then
		message="but singular #{methodName.to_s.singularize} is a method"
	elsif obj.respond_to?(methodName.to_s.pluralize) then
		message="but plural #{methodName.to_s.pluralize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize) then
		message="but tableize #{methodName.to_s.tableize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize.singularize) then
		message="but singular tableize #{methodName.to_s.tableize.singularize} is a method"
	else
		message="but neither singular #{methodName.to_s.singularize} nor plural #{methodName.to_s.pluralize} nor tableize #{methodName.to_s.tableize} nor singular tableize #{methodName.to_s.tableize.singularize} is a method"
	end #if
	assert_respond_to( obj, methodName,message)
end #def
def is_association?(klass,ass)
#	puts "is_association? is called with #{ass}"
	if klass.respond_to?(ass) and klass.respond_to?((ass.to_s+'=').to_sym)  then
		assert_respond_to(klass,ass)
		assert_respond_to(klass,(ass.to_s+'=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association(klass,ass)
	assert_respond_to(klass,ass)
	assert_respond_to(klass,(ass.to_s+'=').to_sym)
	assert(is_association?(klass,ass))
end #def
def assert_association_to_many(klass,ass)
	assert_association(klass,ass)
	assert(is_association_to_many?(klass,ass))
end #def
def assert_association_to_one(klass,ass)
	assert_association(klass,ass)
	assert(!is_association_to_many?(klass,ass))
end #def
def assert_include(element,list)
	assert(list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def is_association_to_many?(klass,ass)
	if is_association?(klass,ass)  and klass.respond_to?((ass.to_s+'_ids').to_sym) and klass.respond_to?((ass.to_s+'_ids=').to_sym) then
	assert_association(klass,ass)
	assert_public_instance_method(klass,(ass.to_s+'_ids').to_sym) 
		assert_public_instance_method(klass,(ass.to_s+'_ids=').to_sym)
		return true
	else
		return false
	end
end #def
def define_association_names
	@model_name=self.class.name[0..-5]
	@model_class=eval(@model_name)
 	@table_name=@model_name.tableize
	@fixture_names=@loaded_fixtures.keys
	puts " @fixture_names.inspect=#{ @fixture_names.inspect}"
	@my_fixture=eval(@table_name+'(:one)')
 	@possible_associations=@model_class.instance_methods(false).select { |m| m =~ /=$/ and !(m =~ /_ids=$/) and is_association?(@my_fixture,m[0..-2])}.collect {|m| m[0..-2] }
	puts "@possible_associations.inspect=#{@possible_associations.inspect}"

	puts "@model_class.column_names=#{@model_class.column_names.inspect}"
 	@possible_many_associations=@model_class.instance_methods(false).select { |m| (m =~ /_ids=$/) and is_association_to_many?(@my_fixture,m[0..-2])}.collect {|m| m[0..-2] }
	puts "@possible_many_associations.inspect=#{@possible_many_associations.inspect}"
	@content_column_names=@model_class.content_columns.collect {|m| m.name}
	puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	@special_columns=@model_class.column_names-@content_column_names
	puts "@special_columns.inspect=#{@special_columns.inspect}"
	@possible_foreign_keys=@special_columns.select { |m| m =~ /_id$/ }
	puts "@possible_foreign_keys=#{@possible_foreign_keys.inspect}"
end
def setup
	define_association_names
end
test "general associations" do
	@possible_associations.each do |ass|
		if is_association_to_many?(@my_fixture,ass) then
			 assert_association_to_many(@my_fixture,ass)
		else
			assert_association_to_one(@my_fixture,ass)
		end
	end
end #test
test "specific, stable and working" do
	assert_equal(@model_name,'TableSpec')
	assert_equal(@model_class,TableSpec)
	assert_equal(@table_name,'table_specs')
	assert(TableSpec.instance_methods(false).include?('acquisition_stream_specs'))
	assert_include('acquisition_stream_specs',TableSpec.instance_methods(false))
	assert_raise(Test::Unit::AssertionFailedError) do
		assert_include('acquisition_stream_specs_Not_a_method',TableSpec.instance_methods(false))
	end #assert_raise
	explain_assert_respond_to(table_specs(:one),:acquisition_stream_specs)
	assert_respond_to(table_specs(:one),:acquisition_stream_specs)
	assert_association(table_specs(:one),:acquisition_stream_specs)
	assert(is_association?(table_specs(:one),:acquisition_stream_specs))
	assert_equal(@possible_associations,['acquisition_stream_specs'])
	assert_equal(@possible_foreign_keys,['frequency_id'])
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(table_specs(:one),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(table_specs(:one),:cabbage) }
	assert_public_instance_method(table_specs(:one),:acquisition_stream_specs)
	testCall(table_specs(:one),:acquisition_stream_specs)
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
	
#	assert_fixture_name(self,@model_name.to_sym)
#	assert_association(AcquisitionStreamSpec,@model_class)
end
def test_id_equal
		assert_equal(Fixtures::identify(:one),table_specs(:one).id,"identify != id")
end #def
def test_associated_id_equal
	puts "@my_fixture.inspect=#{@my_fixture.inspect}"
	puts "@my_fixture.acquisition_stream_specs.inspect=#{@my_fixture.acquisition_stream_specs.inspect}"
	assert_equal(Fixtures::identify(:one),@my_fixture.acquisition_stream_specs.first.table_spec_id,"identify != acquisition_stream_specs.first.table_spec_id")
end #def
end

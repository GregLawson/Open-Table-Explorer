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
	assert_public_instance_method(klass,ass)
	assert_public_instance_method(klass,ass+'=') 
	assert_public_instance_method(klass,ass+'_ids') 
	assert_public_instance_method(klass,ass+'_ids=')
	if klass.respond_to?(ass) and klass.respond_to?(ass+'=')  and klass.respond_to?(ass+'_ids') and klass.respond_to?(ass+'_ids=') then
		return true
	else
		return false
	end
end #def
def setup
	@model_name=self.class.name[0..-5]
	@model_class=eval(@model_name)
 	@table_name=@model_name.tableize
 	@possible_association_methods=@model_class.instance_methods(false).select { |m| m[-4,4]=='_ids' or m[-1,1]=='=' or m[-5,5]=='_ids='}
	puts "@possible_association_methods=#{@possible_association_methods.inspect}"
end
def test_aaa
#	puts self.fixtures
	assert_equal(@model_name,'TableSpec')
	assert_equal(@table_name,'table_specs')
	@possible_foreign_keys=@model_class.instance_methods(false).select { |m| m[-4..-1]='_id' and m[0,1]!='_' and m[0,9]!='validate_' and m[0,9]!='autosave_'}
	puts "@possible_foreign_keys=#{@possible_foreign_keys.inspect}"
#	assert_equal([:table_spec_id,:acquisition_stream_spec_id],@possible_foreign_keys)
	@other_models=@possible_foreign_keys.collect { |k| k[0..-5]}
	puts "@other_models=#{@other_models.inspect}"
#	http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
	@possible_associations=@model_class.instance_methods(false).select { |m| m[0..4]=='acqui' and  m[-4..-1]!='_id' and m[0,1]!='_' and m[0,9]!='validate_' and m[0,9]!='autosave_'}
	puts "@possible_associations=#{@possible_associations.inspect}"
	@confirmed_models=@other_models.select {|m| @model_class.instance_methods(false).include?(m)}
	puts "@confirmed_models=#{@confirmed_models.inspect}"
#	@assocation_names=@other_models.collect |m| {}
	assert(@model_class.instance_methods(false).include?('acquisition_stream_specs'))
	assert(TableSpec.instance_methods(false).include?('acquisition_stream_specs'))

	puts "self.class.instance_methods(false)=#{self.class.instance_methods(false).inspect}"

	puts " @loaded_fixtures.keys.inspect=#{ @loaded_fixtures.keys.inspect}"
	puts " @loaded_fixtures['table_specs'].inspect=#{ @loaded_fixtures['table_specs'].inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).inspect=#{ @loaded_fixtures['table_specs'].at(0).inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_methods.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).instance_variables.inspect}"
#	puts " @loaded_fixtures['table_specs'].at(0).at(1).class_variables.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).class_variables.inspect}"
	puts " @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect=#{ @loaded_fixtures['table_specs'].at(0).at(1).model_class.inspect}"
	
#	assert_fixture_name(self,@model_name.to_sym)
#	assert_public_instance_method(table_specs(:one),:acquisition_stream_specs)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(table_specs(:one),:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(table_specs(:one),:cabbage) }
#	table_specs(:one).acquisition_interface_id=1 # kludge
	assert_association(AcquisitionStreamSpec,@model_class)
#	assert_equal(table_specs(:one).acquisition_interface_id,acquisition_interfaces(:one).id)
#	assert_equal(table_specs(:one).scheme,acquisition_interfaces(:one).scheme)
#	assert_equal(table_specs(:one).scheme,acquisition_stream_specs(:one).acquisition_interface.scheme)
#	testCall(table_specs(:one),:acquisition_stream_interfaces)
end
def test_id_equal
#	assert_raise(Test::Unit::AssertionFailedError) do
		assert_equal(Fixtures::identify(:one),table_specs(:one).id,"identify != id")
#	end #assert_raise
end #def
end

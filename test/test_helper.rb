ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
require 'test_helper_assert_generic_table.rb'
# flexible access to all fixtures
def fixtures(table_name)
	table_name=table_name.to_s
	assert_fixture_name(table_name)
	assert_not_nil(fixture_labels(table_name))
	assert_not_nil(@loaded_fixtures[table_name])
	assert_instance_of(Array,fixture_labels(table_name))
	fixture_hash={}
	@loaded_fixtures[table_name].each do |f|
		fixture_label=f.at(0)
		assert_not_nil(fixture_label)
		if fixture_label.instance_of?(String) then
			fixture_label=fixture_label.to_sym
		end
		assert_not_nil(fixture_label)
		fixture_data=f.at(1)
		ar_from_fixture=fixture_data.model_class.new(fixture_data.to_hash)
		if ar_from_fixture.id.nil? and !fixture_data.to_hash['id'].nil? then # id not set in new
			assert_nil(ar_from_fixture['id'])
			assert_nil(ar_from_fixture[:id])
			assert_nil(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_not_nil(fixture_data.to_hash['id'] )
			assert_not_equal(fixture_data.to_hash['id'] ,fixture_data.to_hash[:id] )
			
			ar_from_fixture[:id]=fixture_data.to_hash['id'] # lost by new
			assert_not_nil(ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])

			ar_from_fixture.id=fixture_data.to_hash['id'] # lost by new
			assert_not_nil(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
		else
			assert_not_nil(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
		end
		assert_not_nil(ar_from_fixture['id'])
		assert_not_nil(ar_from_fixture[:id])
		assert_not_nil(ar_from_fixture.id)
		assert_instance_of(fixture_data.model_class,ar_from_fixture)
	#	puts " ar_from_fixture.inspect=#{ ar_from_fixture.inspect}"
	#	puts " ar_from_fixture.instance_variables.inspect=#{ ar_from_fixture.instance_variables.instance_variables.inspect}"
		#~ puts " ar_from_fixture.model_class.inspect=#{ ar_from_fixture.model_class.inspect}"
		#~ puts " ar_from_fixture.to_hash.inspect=#{ ar_from_fixture.to_hash.inspect}"
		#~ puts " ar_from_fixture.key_list.inspect=#{ ar_from_fixture.key_list.inspect}"
		#~ puts " ar_from_fixture.value_list.inspect=#{ ar_from_fixture.value_list.inspect}"
	#	puts " ar_from_fixture.ar_from_fixture.inspect=#{ ar_from_fixture.ar_from_fixture.inspect}"
		assert_respond_to(ar_from_fixture,:sequential_id?,"sequential_id? ar_from_fixture.inspect=#{ar_from_fixture.inspect}")
	#	puts " ar_from_fixture.class.table_name.inspect=#{ ar_from_fixture.class.table_name.inspect}"
	#	puts " ar_from_fixture.class.name.inspect=#{ ar_from_fixture.class.name.inspect}"
		assert_not_nil(ar_from_fixture['id'],"ar_from_fixture.id is nil. From hash=#{fixture_data.to_hash.inspect} into in ar_from_fixture.inspect=#{ar_from_fixture.inspect}")
		if ar_from_fixture.sequential_id? then
		else
			assert_equal(Fixtures::identify(fixture_label),ar_from_fixture.id,"#{table_name}.yml probably defines id rather than letting Fixtures define it as a hash.")
		end #if
		fixture_hash[fixture_label]=ar_from_fixture
	end #each
	return fixture_hash
end #def

# http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
def fixture_names
	@loaded_fixtures.keys
end #def
def assert_fixture_name(table_name)
	assert_include(table_name.to_s,fixture_names)
	assert_not_nil(@loaded_fixtures[table_name.to_s],"table_name=#{table_name.inspect}, fixture_names=#{fixture_names.inspect}")
end #def
def fixture_labels(table_name)
	@fixture_labels=@loaded_fixtures[table_name.to_s].collect do |fix|
#		puts "fix.at(0)=#{fix.at(0).inspect}"
		fix.at(0)
	end #collect
end #def
def testCallResult(obj,methodName,*arguments)
	assert_instance_of(Symbol,methodName,"testCallResult caller=#{caller.inspect}")
	explain_assert_respond_to(obj,methodName)
	m=obj.method(methodName)
	return m.call(*arguments)
end #def
def testCall(obj,methodName,*arguments)
	result=testCallResult(obj,methodName,*arguments)
	assert_not_nil(result)
	message="\n#{obj.canonicalName}.#{methodName}(#{arguments.collect {|arg|arg.inspect}.join(',')}) returned no data. result.inspect=#{result.inspect}; obj.inspect=#{obj.inspect}"
	if result.instance_of?(Array) then
		assert_operator(result.size,:>,0,message)
	elsif result.instance_of?(String) then
		assert_operator(result.length,:>,0,message)
	elsif result.kind_of?(Acquisition) then
		assert(!result.acquisition_data.empty? || !result.error.empty?) 
	end
	return result
end #def
def testAnswer(obj,methodName,answer,*arguments)
	result=testCallResult(obj,methodName,*arguments)	
	assert_equal(answer,result)
	return result
end #def

def explain_assert_respond_to(obj,methodName,message='')
	assert_not_nil(obj,"explain_assert_respond_to can\'t do much with a nil object.")
	assert_respond_to(methodName,:to_s,"methodName must be of a type that supports a to_s method.")
	assert(methodName.to_s.length>0,"methodName=\"#{methodName}\" must not be a empty string")
	message1=message+"Object #{obj.canonicalName(false)} of class='#{obj.class}' does not respond to method :#{methodName}"
	if obj.instance_of?(Class) then
		if obj.instance_methods(true).include?(methodName.to_s) then
			message= "It's an instance, not a class method."
		else
			if obj.instance_methods(false).empty? then
				message="#{message1}; has no noninherited class methods."
			else
				message="#{message1}; noninherited class methods= #{obj.instance_methods(false).inspect}"
			end #if
		end #if
		assert_respond_to(obj,methodName,message)
	else # not class
		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
#		assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
		if obj.respond_to?(methodName.to_s) then
			return # OK not ActiveRecord
		#~ elsif obj.activeRecordTableNotCreatedYet?(obj) then
			#~ message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj).inspect}"
		else
			message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods.inspect}"
			assert_respond_to(obj,methodName,message)
		end
	end
end
def assert_include(element,list,message=nil)
	message=build_message(message, "? is not in list ?", element,list)   
	assert(list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def assert_not_include(element,list,message=nil)
	message=build_message(message, "? is in list ?", element,list)   
	assert(!list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def assert_public_instance_method(obj,methodName,message='')
	#noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
	if obj.respond_to?(methodName) then
		message+='expect to pass'
	elsif obj.respond_to?(methodName.to_s.singularize) then
		message+="but singular #{methodName.to_s.singularize} is a method"
	elsif obj.respond_to?(methodName.to_s.pluralize) then
		message+="but plural #{methodName.to_s.pluralize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize) then
		message+="but tableize #{methodName.to_s.tableize} is a method"
	elsif obj.respond_to?(methodName.to_s.tableize.singularize) then
		message+="but singular tableize #{methodName.to_s.tableize.singularize} is a method"
	else
		message+="but neither singular #{methodName.to_s.singularize} nor plural #{methodName.to_s.pluralize} nor tableize #{methodName.to_s.tableize} nor singular tableize #{methodName.to_s.tableize.singularize} is a method"
	end #if
	assert_respond_to( obj, methodName,message)
end #def
def assert_has_instance_methods(model_class,message=nil)
	message=build_message(message, "? has no public instance methods.", model_class.canonicalName)   
	assert_block(message){!model_class.instance_methods(false).empty?}
end #def
def assert_not_empty(object,message=nil)
	  message=build_message(message, "? is empty with value ?.", object.canonicalName,object.inspect)   
	assert_block(message){!object.empty?}
end #def
def assert_empty(object,message=nil)
	  message=build_message(message, "? is not empty but contains ?.", object.canonicalName,object.inspect)   
	assert_block(message){object.empty?}
end #def
def assert_equal_sets(array1,array2)
	assert_equal(Set.new(array1),Set.new(array2))
end #def

def assert_model_class(model_name)
	a_fixture_record=fixtures(model_name.tableize).values.first
	assert_kind_of(ActiveRecord::Base,a_fixture_record)
	theClass=a_fixture_record.class
	assert_equal(theClass,Generic_Table.eval_constant(model_name))
end #def

# does not require any fixtures
def define_model_of_test 
	@model_name=self.class.name.sub(/Test$/, '').sub(/Controller$/, '')
 	@table_name=@model_name.tableize
	@model_class=eval(@model_name)
	assert_instance_of(Class,@model_class)
	assert_kind_of(ActiveRecord::Base,@model_class.new)
end #def
MESSAGE_CONTEXT="In define_association_names of test_helper.rb, "
def define_association_names
	define_model_of_test
	assert_model_class(@model_name)
	assert_fixture_name(@table_name)
	assert_not_nil(@loaded_fixtures)
	@my_fixtures=fixtures(@table_name)
	@fixture_labels=fixture_labels(@table_name)
	@assignable_ids=@model_class.instance_methods(false).grep(/_ids=$/ )
	@assignable=(@model_class.instance_methods(false).grep(/=$/ )-@assignable_ids).collect {|m| m[0..-2] }
	@assignable_ids_to_many=@model_class.instance_methods(false).grep(/_ids=$/ ).collect {|m| m[0..-6] }
	@ids_to_many=@model_class.instance_methods(false).grep(/_ids$/ ).collect {|m| m[0..-5] }
	assert_has_instance_methods(@model_class,MESSAGE_CONTEXT)
	assert_has_associations(@model_class,MESSAGE_CONTEXT)
#	puts "@model_class.instance_methods(false)=#{@model_class.instance_methods(false).inspect}"
	assert_not_empty(@model_class.instance_methods(false).grep(/=$/ ))
	#~ puts "@model_class.instance_methods(false).grep(/=$/ )=#{@model_class.instance_methods(false).grep(/=$/ ).inspect}"
	#~ puts "@assignable=#{@assignable.inspect}"
	#~ puts "@assignable_ids_to_many=#{@assignable_ids_to_many.inspect}"
	assert_not_empty(@model_class.instance_methods(false).grep(/=$/ )-@model_class.column_names.grep(/_ids=$/))
	@possible_associations=(@assignable&@model_class.instance_methods(false))
	assert_not_empty(@possible_associations)
#	puts "@possible_associations.inspect=#{@possible_associations.inspect}"
 	@possible_many_associations=@assignable_ids_to_many&@ids_to_many&@model_class.instance_methods(false)&@assignable
#	puts "@possible_many_associations.inspect=#{@possible_many_associations.inspect}"
	#~ @content_column_names=@model_class.content_columns.collect {|m| m.name}
	#~ puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	#~ @special_columns=@model_class.column_names-@content_column_names
	#~ puts "@special_columns.inspect=#{@special_columns.inspect}"
	@possible_foreign_keys=@model_class.foreign_key_names
end


end #class

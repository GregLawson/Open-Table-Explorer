class Object
def matching_methods(regexp)
	self.class.instance_methods(false).select {|m| m[Regexp.new(regexp),0] }
end #def
module Generic_Table
end #def
def similar_methods(symbol)
	singular='^'+symbol.to_s.singularize
	plural='^'+symbol.to_s.pluralize
	table='^'+symbol.to_s.tableize
	return (matching_methods(singular) + matching_methods(plural) + matching_methods(table)).uniq
end #def
end #class

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
def explain_assert_respond_to(obj,methodName)
	assert_not_nil(obj,"explain_assert_respond_to can\'t do much with a nil object.")
	assert_respond_to(methodName,:to_s,"methodName must be of a type that supports a to_s method.")
	assert(methodName.to_s.length>0,"methodName=\"#{methodName}\" must not be a empty string")
	message1="Object #{obj.canonicalName(false)} of class='#{obj.class}' does not respond to method :#{methodName}"
	if obj.instance_of?(Class) then
		message="#{message1}; noninherited class methods= #{obj.noninherited_public_class_methods(obj)}"
		assert_respond_to(obj,methodName,message)
	else
		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
#			assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
		if noninherited.include?(methodName.to_s) then
			return # OK not ActiveRecord
		#~ elsif obj.activeRecordTableNotCreatedYet?(obj) then
			#~ message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj).inspect}"
		#~ else
			message="#{message1}; noninherited instance methods= #{obj.noninherited_public_instance_methods(obj)}"
			assert_respond_to(obj,methodName,message)
		end
	end
end
def assert_public_instance_method(obj,methodName,message='')
	#noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
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
def assert_not_empty(object)
	assert(!object.empty?)
end #def
def is_association?(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"is_association? is called with #{assName} caller=#{caller}")
#	puts "is_association? is called with #{assName}"
	if assName.to_s[-3..-1]=='_id' then 
		fail "assName=#{assName} should not end in '_id' as it will be confused wth a foreign key."
	end # if
	if ar_from_fixture.respond_to?(assName) and ar_from_fixture.respond_to?((assName.to_s+'=').to_sym)  then
		assert_respond_to(ar_from_fixture,assName)
		assert_respond_to(ar_from_fixture,(assName.to_s+'=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association")
	assert_respond_to(ar_from_fixture,assName)
	assert_respond_to(ar_from_fixture,(assName.to_s+'=').to_sym)
	assert(is_association?(ar_from_fixture,assName),"fail is_association?, ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName}")
end #def
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

def model_class(fixtures)
	a_fixture_record=fixtures.values.first
	assert_kind_of(ActiveRecord::Base,a_fixture_record)
	ret=a_fixture_record.class
	return ret
end #def
def is_association_to_one?(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"is_association_to_one")
	if is_association?(ar_from_fixture,assName)  and !ar_from_fixture.respond_to?((assName.to_s.singularize+'_ids').to_sym) and !ar_from_fixture.respond_to?((assName.to_s.singularize+'_ids=').to_sym) then
		assert_association(ar_from_fixture,assName)
		return true
	else
		return false
	end
end #def
def is_association_to_many?(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"is_association_to_many  caller=#{caller.inspect}")
	if is_association?(ar_from_fixture,assName)  and ar_from_fixture.respond_to?((assName.to_s.singularize+'_ids').to_sym) and ar_from_fixture.respond_to?((assName.to_s.singularize+'_ids=').to_sym) then
		assert_association(ar_from_fixture,assName)
		assert_public_instance_method(ar_from_fixture,(assName.to_s.singularize+'_ids').to_sym) 
		assert_public_instance_method(ar_from_fixture,(assName.to_s.singularize+'_ids=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association_to_many(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_to_many")
	assert_association(ar_from_fixture,assName)
	assert(is_association_to_many?(ar_from_fixture,assName),"is_association_to_many?(#{ar_from_fixture.inspect},#{assName.inspect}) returns false. #{ar_from_fixture.similar_methods(assName).inspect}.respond_to?(#{(assName.to_s+'_ids').to_sym}) and ar_from_fixture.respond_to?(#{(assName.to_s+'_ids=').to_sym})")
	assert(!is_association_to_one?(ar_from_fixture,assName),"fail !is_association_to_one?, ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName}")
end #def
def assert_association_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_to_one")
	assert_association(ar_from_fixture,assName)
	assert(!is_association_to_many?(ar_from_fixture,assName),"fail !is_association_to_many?, ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName}, ar_from_fixture.similar_methods(assName).inspect=#{ar_from_fixture.similar_methods(assName).inspect}")
end #def
def assert_association_one_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #def
def assert_association_one_to_many(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_many")
	assert_association_to_many(ar_from_fixture,assName)
end #def
def assert_association_many_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_many_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #def

def assert_include(element,list)
	assert(list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def define_association_names
	@model_name=self.class.name.sub(/Test$/, '').sub(/Controller$/, '')
 	@table_name=@model_name.tableize
	assert_not_nil(@loaded_fixtures)
	assert_fixture_name(@table_name)
	@fixture_labels=fixture_labels(@table_name)
	@my_fixtures=fixtures(@table_name)
	@model_class=model_class(@my_fixtures)
	@assignable_ids=@model_class.instance_methods(false).grep(/_ids=$/ )
	@assignable=(@model_class.instance_methods(false).grep(/=$/ )-@assignable_ids).collect {|m| m[0..-2] }
	@assignable_ids_to_many=@model_class.instance_methods(false).grep(/_ids=$/ ).collect {|m| m[0..-6] }
	@ids_to_many=@model_class.instance_methods(false).grep(/_ids$/ ).collect {|m| m[0..-5] }
	assert_not_empty(@model_class.instance_methods(false))
	assert_not_empty(@assignable)
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
	@possible_foreign_keys=foreign_key_names(@model_class)
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
# 
def associated_foreign_key_name(obj,assName)
	assert_instance_of(Symbol,assName,"associated_foreign_key_name assName=#{assName.inspect}")
	many_to_one_foreign_keys=foreign_key_names(obj.class)
#	many_to_one_associations=many_to_one_foreign_keys.collect {|k| k[0..-4]}
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		assert_instance_of(String,fk)
		ass=fk[0..-4].to_sym
		assert_association_many_to_one(obj,ass)
#not all		assert_equal(ass,assName,"associated_foreign_key_name ass,assName=#{ass},#{assName}")
		ass==assName
	end #end
	assert_equal(matchingAssNames,[matchingAssNames.first].compact,"assName=#{assName.inspect},matchingAssNames=#{matchingAssNames.inspect},many_to_one_foreign_keys=#{many_to_one_foreign_keys.inspect}")
	return matchingAssNames.first
end #def
# find 
def associated_foreign_key(obj,assName)
	assert_instance_of(Symbol,assName,"associated_foreign_key assName=#{assName.inspect}")
	assert_association(obj,assName)
	assert_not_nil(associated_foreign_key_name(obj,assName),"associated_foreign_key_name: obj=#{obj},assName=#{assName})")
	return obj.method(associated_foreign_key_name(obj,assName).to_sym)
end #def
def associated_foreign_key_id(obj,assName)
	assert_instance_of(Symbol,assName,"associated_foreign_key_id assName=#{assName.inspect}")
	return associated_foreign_key(obj,assName).call
end #def
def assert_foreign_key_points_to_me(ar_from_fixture,assName)
	assert_association(ar_from_fixture,assName)
	associated_records=testCallResult(ar_from_fixture,assName)
	assert_not_nil(associated_records,"assert_foreign_key_points_to_me ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName} Check if id is specified in #{assName.to_sym}.yml file.")
	if associated_records.instance_of?(Array) then
		associated_records.each do |ar|
			fkAssName=ar_from_fixture.class.name.tableize.singularize
			fk=associated_foreign_key_name(ar,(fkAssName.to_s).to_sym)
			assert_not_nil(fk,"assert_foreign_key_points_to_me ar.inspect=#{ar.inspect},ar_from_fixture.class.name=#{ar_from_fixture.class.name} Check if id is specified in #{assName.to_sym}.yml file,ar_from_fixture.class.name.tableize.singularize.to_s+'_id'=#{ar_from_fixture.class.name.tableize.singularize.to_s+'_id'}.")
			@associated_foreign_key_id=
			assert_equal(ar_from_fixture.id,associated_foreign_key_id(ar,fkAssName.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},ar_from_fixture=#{ar_from_fixture.inspect}")
		end #each
	else # single record
			associated_foreign_key_name(associated_records,assName).each do |fk|
				assert_equal(ar_from_fixture.id,associated_foreign_key_id(associated_records,fk.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},ar_from_fixture=#{ar_from_fixture.inspect},assName=#{assName}")
			end #each
	end #if
end #def
def assert_general_associations(table_name)
	fixtures(table_name).each_value do |my_fixture|
	@possible_associations.each do |association_name|
		assName=association_name.to_sym
		if is_association_to_many?(my_fixture,assName) then
			 assert_association_to_many(my_fixture,assName)
			assert_foreign_key_points_to_me(my_fixture,assName)
		else
			assert_association_to_one(my_fixture,assName)
		end #if
	end #each
#	assert_equal(Fixtures::identify(my_fixture.logical_prmary_key),my_fixture.id,"identify != id")
	end #each
end #def
end #class

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
	message="\n#{Global.canonicalName(obj)}.#{methodName}(#{arguments.collect {|arg|arg.inspect}.join(',')}) returned no data. result.inspect=#{result.inspect}; obj.inspect=#{obj.inspect}"
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
def assert_model(model_class_name)
	assert_block("#{model_class_name} not defined in Generic_Acquisitions table."){Generic_Acquisitions.typeRecords(model_class_name).size>0}
end #def
def explain_assert_respond_to(obj,methodName)
	assert_not_nil(obj,"explain_assert_respond_to can\'t do much with a nil object.")
	assert_respond_to(methodName,:to_s,"methodName must be of a type that supports a to_s method.")
	assert(methodName.to_s.length>0,"methodName=\"#{methodName}\" must not be a empty string")
	message1="Object #{Global.canonicalName(obj,false)} of class='#{obj.class}' does not respond to method :#{methodName}"
	if obj.instance_of?(Class) then
		message="#{message1}; noninherited class methods= #{Global.noninherited_public_class_methods(obj)}"
		assert_respond_to(obj,methodName,message)
	else
		noninherited=obj.class.public_instance_methods-obj.class.superclass.public_instance_methods
#			assert_equal(obj.class.public_instance_methods,obj.public_class_methods)
		if noninherited.include?(methodName.to_s) then
			return # OK not ActiveRecord
		elsif Global.activeRecordTableNotCreatedYet?(obj) then
			message="#{message1}; noninherited instance methods= #{Global.noninherited_public_instance_methods(obj).inspect}"
		else
			message="#{message1}; noninherited instance methods= #{Global.noninherited_public_instance_methods(obj)}"
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
def is_association?(fixture,ass)
	assert_instance_of(Symbol,ass,"is_association? is called with #{ass} caller=#{caller}")
#	puts "is_association? is called with #{ass}"
	if ass.to_s[-3..-1]=='_id' then 
		fail "ass=#{ass} should not end in '_id' as it will be confused wth a foreign key."
	end # if
	if fixture.respond_to?(ass) and fixture.respond_to?((ass.to_s+'=').to_sym)  then
		assert_respond_to(fixture,ass)
		assert_respond_to(fixture,(ass.to_s+'=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association")
	assert_respond_to(fixture,ass)
	assert_respond_to(fixture,(ass.to_s+'=').to_sym)
	assert(is_association?(fixture,ass),"fail s_association?, fixture.inspect=#{fixture.inspect},ass=#{ass}")
end #def

# http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
def fixture_names
	@loaded_fixtures.keys
end #def
def assert_table_name(table_name)
	assert_include(table_name.to_s,fixture_names)
	assert_not_nil(@loaded_fixtures[table_name.to_s],"table_name=#{table_name.inspect}, fixture_names=#{fixture_names.inspect}")
end #def
def record_keys(table_name)
	@record_keys=@loaded_fixtures[table_name.to_s].collect do |fix|
#		puts "fix.at(0)=#{fix.at(0).inspect}"
		fix.at(0)
	end #collect
end #def
def fixtures(table_name)
	assert_table_name(table_name)
	
	record_keys(table_name).collect do |rk|
		assert_not_nil(rk)
		rk=rk.to_sym
		assert_not_nil(rk)
		case table_name.to_sym
		when :table_specs then
			assert_equal(table_specs(rk).id,Fixtures::identify(rk))
			table_specs(rk)
		when :acquisition_stream_specs then
			assert_equal(acquisition_stream_specs(rk).id,Fixtures::identify(rk))
			acquisition_stream_specs(rk)
		when :acquisition_interfaces then
			assert_equal(acquisition_interfaces(rk).id,Fixtures::identify(rk))
			acquisition_interfaces(rk)
		when :frequencies then
			assert_equal(frequencies(rk).id,Fixtures::identify(rk))
			frequencies(rk)
		when :acquisitions then
			assert_equal(acquisitions(rk).id,Fixtures::identify(rk))
			acquisitions(rk)
		when :accounts then
			assert_equal(accounts(rk).id,Fixtures::identify(rk))
			accounts(rk)
		when :transfers then
			assert_equal(transfers(rk).id,Fixtures::identify(rk))
			transfers(rk)
		else
			"else #{rk.inspect}"
		end #case
	end #each
end #def
#~ def fixture(table_name,record_key)
	#~ return fixtures(table_name)(record_key)
#~ end #def
def model_class(fixtures)
	return fixtures.first.class
end #def
def similar_methods(fixture,symbol)
	singular='^'+symbol.to_s.singularize
	plural='^'+symbol.to_s.pluralize
	table='^'+symbol.to_s.tableize
	return (matching_methods(fixture,singular) + matching_methods(fixture,plural) + matching_methods(table,plural)).uniq
end #def
def matching_methods(fixture,regexp)
	fixture.class.instance_methods(false).select {|m| m[Regexp.new(regexp),0] }
end #def
def is_association_to_one?(fixture,ass)
	assert_instance_of(Symbol,ass,"is_association_to_one")
	if is_association?(fixture,ass)  and !fixture.respond_to?((ass.to_s.singularize+'_ids').to_sym) and !fixture.respond_to?((ass.to_s.singularize+'_ids=').to_sym) then
		assert_association(fixture,ass)
		return true
	else
		return false
	end
end #def
def is_association_to_many?(fixture,ass)
	assert_instance_of(Symbol,ass,"is_association_to_many  caller=#{caller.inspect}")
	if is_association?(fixture,ass)  and fixture.respond_to?((ass.to_s.singularize+'_ids').to_sym) and fixture.respond_to?((ass.to_s.singularize+'_ids=').to_sym) then
		assert_association(fixture,ass)
		assert_public_instance_method(fixture,(ass.to_s.singularize+'_ids').to_sym) 
		assert_public_instance_method(fixture,(ass.to_s.singularize+'_ids=').to_sym)
		return true
	else
		return false
	end
end #def
def assert_association_to_many(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association_to_many")
	assert_association(fixture,ass)
	assert(is_association_to_many?(fixture,ass),"is_association_to_many?(#{fixture.inspect},#{ass.inspect}) returns false. #{similar_methods(fixture,ass).inspect}.respond_to?(#{(ass.to_s+'_ids').to_sym}) and fixture.respond_to?(#{(ass.to_s+'_ids=').to_sym})")
	assert(!is_association_to_one?(fixture,ass),"fail !is_association_to_one?, fixture.inspect=#{fixture.inspect},ass=#{ass}")
end #def
def assert_association_to_one(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association_to_one")
	assert_association(fixture,ass)
	assert(!is_association_to_many?(fixture,ass),"fail !is_association_to_many?, fixture.inspect=#{fixture.inspect},ass=#{ass}, similar_methods(fixture,ass).inspect=#{similar_methods(fixture,ass).inspect}")
end #def
def assert_association_one_to_one(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association_one_to_one")
	assert_association_to_one(fixture,ass)
end #def
def assert_association_one_to_many(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association_one_to_many")
	assert_association_to_many(fixture,ass)
end #def
def assert_association_many_to_one(fixture,ass)
	assert_instance_of(Symbol,ass,"assert_association_many_to_one")
	assert_association_to_one(fixture,ass)
end #def

def assert_include(element,list)
	assert(list.include?(element),"#{element.inspect} is not in list #{list.inspect}")
end #def
def define_association_names
	@model_name=self.class.name.sub(/Test$/, '').sub(/Controller$/, '')
 	@table_name=@model_name.tableize
	assert_not_nil(@loaded_fixtures)
	assert_table_name(@table_name)
	@record_keys=record_keys(@table_name)
	@my_fixtures=fixtures(@table_name)
	@model_class=model_class(@my_fixtures)
	@possible_associations=@model_class.instance_methods(false).select { |m| m =~ /=$/ and !(m =~ /_ids=$/) and is_association?(@my_fixtures.first,m[0..-2].to_sym)}.collect {|m| m[0..-2] }
#	puts "@possible_associations.inspect=#{@possible_associations.inspect}"
 	@possible_many_associations=@model_class.instance_methods(false).select { |m| (m =~ /_ids=$/) and is_association_to_many?(@my_fixtures.first,m[0..-2].to_sym)}.collect {|m| m[0..-2] }
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
def assert_foreign_key_points_to_me(fixture,ass)
	assert_association(fixture,ass)
	associated_records=testCallResult(fixture,ass)
	assert_not_nil(associated_records,"assert_foreign_key_points_to_me fixture.inspect=#{fixture.inspect},ass=#{ass} Check if id is specified in #{ass.to_sym}.yml file.")
	if associated_records.instance_of?(Array) then
		associated_records.each do |ar|
			fkAssName=fixture.class.name.tableize.singularize
			fk=associated_foreign_key_name(ar,(fkAssName.to_s).to_sym)
			assert_not_nil(fk,"assert_foreign_key_points_to_me ar.inspect=#{ar.inspect},fixture.class.name=#{fixture.class.name} Check if id is specified in #{ass.to_sym}.yml file,fixture.class.name.tableize.singularize.to_s+'_id'=#{fixture.class.name.tableize.singularize.to_s+'_id'}.")
			@associated_foreign_key_id=
			assert_equal(fixture.id,associated_foreign_key_id(ar,fkAssName.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},fixture=#{fixture.inspect}")
		end #each
	else # single record
			associated_foreign_key_name(associated_records,ass).each do |fk|
				assert_equal(fixture.id,associated_foreign_key_id(associated_records,fk.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},fixture=#{fixture.inspect},ass=#{ass}")
			end #each
	end #if
end #def
def assert_my_foreign_key_points_to_correct_id(fixture,ass)
	assert_association(fixture,ass)
	myForeignKeyName=associated_foreign_key_name(fixture,ass)
	assert_not_nil(myForeignKeyName,"assert_my_foreign_key_points_to_correct_id fixture.inspect=#{fixture.inspect},ass=#{ass}")
	record_keys('table_specs').each do |rk|
	end #each rk
	@my_fixtures.each do |my_fixture|
		assert_respond_to(my_fixture,ass,"assert_my_foreign_key_points_to_correct_id my_fixture.inspect=#{my_fixture.inspect},ass=#{ass}")
		foreignKey_id=testCallResult(my_fixture,myForeignKeyName.to_sym)
		associated_table_name=ass.to_s.pluralize.to_sym
		assert_table_name(associated_table_name)
		associated_fixtures=fixtures(associated_table_name)
		fixtures('table_specs').each do |f|
			
		end
		possible_ids=""
		available_ids=fixtures(associated_table_name).collect do |f|
			possible_ids= possible_ids+", Fixtures::identify(#{f.logical_primary_key})=#{Fixtures::identify(f.logical_primary_key)}=#{f.id}"
			f.id
		end #collect
		association=my_fixture.send(ass)
		associated_records=testCallResult(my_fixture,ass)
		assert_equal(association,associated_records)
		assert_not_nil(association,"No records associated. #{my_fixture.inspect}: Foreign key #{myForeignKeyName}=#{foreignKey_id}, #{associated_table_name}=#{possible_ids}")
		assert_not_nil(testCallResult(my_fixture,ass),"assert_my_foreign_key_points_to_correct_id my_fixture.inspect=#{my_fixture.inspect},ass=#{ass}")
		assert_equal(testCallResult(my_fixture,myForeignKeyName.to_sym),testCallResult(my_fixture,ass).id)
	end
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

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :acquisition_interfaces
  fixtures :acquisition_stream_specs
  fixtures :acquisitions
  fixtures :table_specs

  # Add more helper methods to be used by all tests here...
def testCallResult(obj,methodName,*arguments)
	m=obj.method(methodName)
	return m.call(*arguments)
end #def
def testCall(obj,methodName,*arguments)
	explain_assert_respond_to(obj,methodName)
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
# http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
def assert_association(ass1,ass2)
# assume ass1 contains foreign key so we don't need to check both 
	singularAssociatonName=ass2.class.name.tableize.singularize.to_sym
	pluralAssociatonName=ass2.class.name.tableize.to_sym
	if ass1.respond_to?(singularAssociatonName) then
		message="but singularAssociatonName #{singularAssociatonName} is a method"
		if ass1.send(singularAssociatonName).respond_to?(:exists?) then
			fail "singular association could have multiple records."
		end
		assert_public_instance_method(ass1,singularAssociatonName,message)
	elsif ass1.respond_to?(pluralAssociatonName) then
		message="but pluralAssociatonName #{pluralAssociatonName} is a method"
		if ass1.send(pluralAssociatonName).respond_to?(:exists?) then
		else
			fail "plural association cannot have multiple records."
		end
		assert_public_instance_method(ass1,pluralAssociatonName,message)
	else
		fail "No association exists between #ass1 and #ass2"
	end
	conventionalForeignKey1=ass2.class.name.foreign_key # assume
	singularForeignKey="#{singularAssociatonName}_id"
	pluralForeignKey="#{pluralAssociatonName}_id"
	if ass1.respond_to?(conventionalForeignKey1)  then
		assert_respond_to(ass1,conventionalForeignKey1)
		assert_equal(1,ass1.send(conventionalForeignKey1))
	elsif ass1.respond_to?(singularForeignKey) then
		fail "singularForeignKey=#{singularForeignKey}"
	elsif ass1.respond_to?(pluralForeignKey) then
		fail "pluralForeignKey=#{pluralForeignKey}"
	end
	conventionalForeignKey2=ass1.class.name.foreign_key # assume not                                                                                
	if ass2.respond_to?(conventionalForeignKey2)  then
		fail "conventionalForeignKey2=#{conventionalForeignKey2} should not be a foreign key in ass2=#{ass2.inspect}. Try assert_association(#{ass2.class.name},#{ass1.class.name})"
	end
end #def
end #class
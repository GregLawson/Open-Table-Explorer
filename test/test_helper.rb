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
  fixtures :frequencies

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
end #class
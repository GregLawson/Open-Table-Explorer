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
			Global::log.debug(message)
		else
			message="#{message1}; noninherited instance methods= #{Global.noninherited_public_instance_methods(obj)}"
			assert_respond_to(obj,methodName,message)
		end
	end
end
end #class
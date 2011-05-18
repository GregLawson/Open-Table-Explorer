class Nil_Class
def canonicalName
	return 'nil'
end #def
end #class
require 'test_helper'
class GlobalTest < ActiveSupport::TestCase
class TestClass
def self.classMethod
end #def
public
def publicInstanceMethod
end #def
protected
def protectedInstanceMethod
end #def
private
def privateInstanceMethod
end #def
end #class

def test_aaa
	assert_equal('Symbol',:cat.objectClass)
	assert_equal('cat',:cat.objectName)

	assert_equal('Symbol :cat',:cat.whoAmI)
	assert_nil(TestClass.relationship(:cat))
end #test
test "canonical name" do
	assert_equal('Symbol :cat',:cat.canonicalName)
	assert_equal('nil',nil.canonicalName)
end #test
test 'instance methods' do
	assert_equal(['publicInstanceMethod'],TestClass.public_instance_methods(false))
	assert_equal(Set.new(['publicInstanceMethod','protectedInstanceMethod']),Set.new(TestClass.instance_methods(false)))
	assert_equal(['publicInstanceMethod'],TestClass.new.noninherited_public_instance_methods)
end #test
test 'class methods' do
	assert_equal(Class,TestClass.class)
	assert_equal(Object,TestClass.superclass)
	assert_equal(['classMethod'],TestClass.methods-TestClass.superclass.methods)
#	assert_equal(['classMethod'],TestClass.class.public_instance_methods)
	assert_equal(['classMethod'],TestClass.new.noninherited_public_class_methods)
end #test
test 'matching methods' do
	testClass=Acquisition
#	puts "testClass.canonicalName=#{testClass.canonicalName}"
#	puts "testClass.superclass.canonicalName=#{testClass.superclass.canonicalName}"
#	puts "testClass.matching_methods(//).inspect=#{testClass.matching_methods(//).inspect}"
	assert_instance_of(Array,testClass.matching_methods(//))
end #def
test 'matching methods in context' do
	testClass=Acquisition
	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
	assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
	assert_equal([Generic_Table],testClass.ancestors-[testClass]-testClass.superclass.ancestors)
end #def
test "Acquisition Stream Spec modules" do
	assert(Generic_Table.module?)
	assert_equal([Generic_Table],Account.noninherited_modules)
	assert(AcquisitionStreamSpec.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_include('Generic_Table',AcquisitionStreamSpec.ancestors.map{|a| a.name})
	assert(AcquisitionStreamSpec.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionStreamSpec,:Generic_Table)
end #test
test "Acquisition Interface modules" do
	assert(Generic_Table.module?)
	assert_equal([Generic_Table],AcquisitionInterface.noninherited_modules)
	assert(AcquisitionInterface.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_include('Generic_Table',AcquisitionInterface.ancestors.map{|a| a.name})
	assert(AcquisitionInterface.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionInterface,:Generic_Table)
end #test
end #test class

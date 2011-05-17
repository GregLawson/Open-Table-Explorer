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
	assert_equal([testClass.canonicalName,testClass.instance_methods(false)],testClass.matching_methods(//)[0])
	assert_instance_of(Array,testClass.matching_methods(//))
	assert_instance_of(Class,testClass.ancestors[0])
	assert_equal(testClass,testClass.ancestors[0])
	assert_equal([Generic_Table],testClass.ancestors-[testClass]-testClass.superclass.ancestors)
end #def
test "modules" do
	assert_equal([General_Table],Account.noninherited_modules)
	assert(General_Table.module?)
end #test
end #test class

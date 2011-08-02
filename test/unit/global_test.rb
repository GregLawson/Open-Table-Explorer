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
test 'matching_instance_methods' do
	testClass=TestClass
	assert_instance_of(Array,testClass.matching_instance_methods(//))
	assert_equal(['classMethod'],testClass.public_methods(false).select {|m| m[Regexp.new('M'),0] })
	assert_equal(['publicInstanceMethod'],testClass.matching_instance_methods(/publicInstanceMethod/),false)
	assert_equal(['publicInstanceMethod'],testClass.matching_instance_methods(/publicInstanceMethod/),true)
	assert_equal(['publicInstanceMethod'],testClass.matching_instance_methods(/publicInstanceMethod/))
end #test
test 'matching_class_methods' do
	testClass=TestClass
	assert_instance_of(Array,testClass.matching_class_methods(//))
	assert_equal(['classMethod'],testClass.public_methods(false).select {|m| m[Regexp.new('M'),0] })
	assert_equal(['classMethod'],testClass.matching_class_methods(/classMethod/),false)
	assert_equal(['classMethod'],testClass.matching_class_methods(/classMethod/),false)
	assert_equal(['classMethod'],testClass.matching_class_methods(/classMethod/),true)
	assert_equal(['classMethod'],testClass.matching_class_methods(/classMethod/))
end #test

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
test '' do
#~ def noninherited_modules
	#~ if module? then
		#~ return ancestors-[self]
	#~ else
		#~ return ancestors-[self]-superclass.ancestors
	#~ end #if
#~ end #def
	assert(Generic_Table.module?)
	assert(!AcquisitionStreamSpec.module?)
	assert_include('Generic_Table',AcquisitionStreamSpec.ancestors.map{|a| a.name})
	assert_equal([Generic_Table],Account.noninherited_modules)
	assert_equal([Generic_Table],AcquisitionStreamSpec.noninherited_modules)
	assert(AcquisitionStreamSpec.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert(AcquisitionInterface.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	testClass=Acquisition
	assert_equal([Generic_Table],testClass.ancestors-[testClass]-testClass.superclass.ancestors)
	assert_include(Generic_Table,AcquisitionInterface.ancestors-[AcquisitionInterface])
	assert_equal([Generic_Table],AcquisitionInterface.ancestors-[AcquisitionInterface,RubyInterface]-AcquisitionInterface.superclass.superclass.ancestors)
	assert_equal([],AcquisitionInterface.noninherited_modules) # stI at work
end #test
test 'matching methods in context' do
	testClass=Acquisition
#error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
#error message too long		assert_equal([testClass.canonicalName,testClass.matching_instance_methods(//)],testClass.matching_methods_in_context(//)[0])
#error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
end #def
test "Acquisition Stream Spec modules" do
	assert(Generic_Table.module?)
	assert(!AcquisitionStreamSpec.module?)
	assert_equal([Generic_Table],AcquisitionStreamSpec.noninherited_modules)
	assert(AcquisitionStreamSpec.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_include('Generic_Table',AcquisitionStreamSpec.ancestors.map{|a| a.name})
	assert(AcquisitionStreamSpec.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionStreamSpec,:Generic_Table)
end #test
test "Acquisition Interface modules" do
	assert(Generic_Table.module?)
	assert(AcquisitionInterface.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_equal([],AcquisitionInterface.noninherited_modules) # because of STI Generic_Table is not directly included
	assert_include('Generic_Table',AcquisitionInterface.ancestors.map{|a| a.name})
	assert(AcquisitionInterface.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionInterface,:Generic_Table)
end #test
end #test class

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
	
	acquisition_stream_spec=AcquisitionStreamSpec.new
	assert_include('acquisition_interface',acquisition_stream_spec.matching_methods(//))
	assert_respond_to(acquisition_stream_spec,:associated_to_s) 
	assert_include('acquisition_interface',acquisition_stream_spec.matching_methods(/acquisition_interface/))
	assert_respond_to(acquisition_stream_spec.class,:instance_methods)
	assert_public_instance_method(acquisition_stream_spec.class,:instance_methods)
	
	#~ assert_include('instance_methods',acquisition_stream_spec.class.instance_methods)
	#~ assert_equal('',acquisition_stream_spec.method_context(:instance_methods))
	#~ assert_include('instance_methods',acquisition_stream_spec.class.matching_methods(/instance_method/)) 
	#~ assert_include('instance_methods',acquisition_stream_spec.class.matching_methods_in_context(//,20)) 
	#~ assert_include('instance_methods',acquisition_stream_spec.matching_methods(/instance_method/)) 
	#~ assert_respond_to(acquisition_stream_spec,:instance_methods) 
	assert_equal('',acquisition_stream_spec.associated_to_s(:acquisition_interface,:name) )
	
end #def
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
#error message too long		assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
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
test "method model" do
	puts "Generic_Table.method_model=#{Generic_Table.method_model}"
end #test class

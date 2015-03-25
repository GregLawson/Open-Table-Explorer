###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/ruby_assertions.rb'
#require_relative '../test_helper_test_tables.rb'
# contains mostly functions created for testing / debugging but not dependant on ActiveRecord
class Nil_Class
def canonicalName
	return 'nil'
end #def
end #class
class GlobalTest < TestCase
class TestClass < Object
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
def test_set_inspect
	assert_equal('#<Set: {1, 2, 3}>',Set[1,2,3].inspect)
	set=Set[/1/,/1/,/3/]
	assert_match(/,\/3\/>/,set.set_inspect)
	assert_match(/\(\?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/\(\?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/\(?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/\{4408\},\(\?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/\{4408\},\(\?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/ #[0-9-]+\{4408\},\(\?-mix:3\),\/3\/>/,set.set_inspect)
	assert_match(/\{[0-9]+\},\(\?-mix:1\),\/1\/>, <Regexp #[0-9-]+\{4408\},\(\?-mix:3\),\/3\/>/,set.set_inspect)
#	assert_match(/#<Set: \{\/1\/, \/3\/\}>; /<Regexp #[0-9-]+\{[0-9]+\},/,set.set_inspect)
#	assert_match(/#<Set: \{\/1\/, \/3\/\}>; /<Regexp #[0-9-]+\{[0-9]+\},(?-mix:1),\/1\/>, <Regexp #[0-9-]+\{4408\},(?-mix:3),\/3\/>/,set.set_inspect)
#	assert_match(/#<Set: \{\/1\/, \/3\/\}>; /<Regexp #[0-9-]+\{[0-9]+\},(?-mix:1),\/1\/>, <Regexp #[0-9-]+\{4408\},(?-mix:3),\/3\/>/,set.set_inspect)
end #set_inspect
def test_instance_methods_from_class
	assert_include('full_associated_models',['full_associated_models'])
	assert_include('full_associated_models',TestTable.instance_methods_from_class)
end #instance_methods_from_class
def test_instance_respond_to
	assert(TestClass.respond_to?(:instance_respond_to?))
	assert(TestClass.instance_respond_to?(:instance_respond_to?), "TestClass.instance_methods_from_class=#{TestClass.instance_methods_from_class}")
end #instance_respond_to
def test_similar_methods
#?	assert_not_empty(TestTable.similar_methods(:assert_fixture_name))
end #similar_methods
def test_matching_instance_methods
	testClass=TestClass
	assert_instance_of(Array,testClass.matching_instance_methods(//))
	assert_equal([:classMethod],testClass.public_methods(false).select {|m| m[Regexp.new('M'),0] })
	assert_equal([:publicInstanceMethod],testClass.matching_instance_methods(/publicInstanceMethod/),false)
	assert_equal([:publicInstanceMethod],testClass.matching_instance_methods(/publicInstanceMethod/),true)
	assert_equal([:publicInstanceMethod],testClass.matching_instance_methods(/publicInstanceMethod/))
end #matching_instance_methods
def test_matching_class_methods
	testClass=TestClass
	assert_instance_of(Array,testClass.matching_class_methods(//))
	assert_equal([:classMethod],testClass.public_methods(false).select {|m| m[Regexp.new('M'),0] })
	assert_equal([:classMethod],testClass.matching_class_methods(/classMethod/),false)
	assert_equal([:classMethod],testClass.matching_class_methods(/classMethod/),false)
	assert_equal([:classMethod],testClass.matching_class_methods(/classMethod/),true)
	assert_equal([:classMethod],testClass.matching_class_methods(/classMethod/))
end #matching_class_methods
def test_data_source_directory?
	assert_equal('test/data_source/Class', Class.data_source_directory?)
end #data_source_directory?
def test_object_identities
	assert_match('<StreamPattern',StreamPattern.new.object_identities)
	assert_match(/StreamPattern/,StreamPattern.new.object_identities)
	assert_match(/StreamPattern id: nil, name: nil, created_at: nil, updated_at: nil>>/,StreamPattern.new.object_identities)
	assert_match(/StreamPattern:0x[a-f0-9]+>,#<StreamPattern id: nil, name: nil, created_at: nil, updated_at: nil>>/,StreamPattern.new.object_identities)
	assert_match(/[0-9-]+\{4\},#<StreamPattern:0x[a-f0-9]+>,#<StreamPattern id: nil, name: nil, created_at: nil, updated_at: nil>>/,StreamPattern.new.object_identities)
	assert_match(/[0-9-]+\{4\},#<StreamPattern:0x[a-f0-9]+>,#<StreamPattern id: nil, name: nil, created_at: nil, updated_at: nil>>/,StreamPattern.new.object_identities)
	assert_match(/<StreamPattern #[0-9-]+\{4\},#<StreamPattern:0x[a-f0-9]+>,#<StreamPattern id: nil, name: nil, created_at: nil, updated_at: nil>>/,StreamPattern.new.object_identities)
end #object_identities
def test_objectKind
	assert_equal('nil',nil.objectKind)
	assert_equal("Class Fixnum has no superclass.",3.objectKind)
end #objectKind
def test_objectClass
	assert_equal('Symbol',:cat.objectClass)
	assert_equal('NilClass',nil.objectClass)
	assert_equal('Module Generic_Table',Generic_Table.objectClass)
	assert_equal("Fixnum",3.objectClass)
	assert_equal("Regexp",/3/.objectClass)
end #objectClass
def test_objectName
	assert_equal(':cat',:cat.objectName)
end #test
def test_canonical_name
	assert_equal('Symbol :cat',:cat.canonicalName)
	assert_equal('nil',nil.canonicalName)
end #test
def test_noninherited_public_instance_methods
	assert_equal([:publicInstanceMethod],TestClass.public_instance_methods(false))
	assert_equal(Set.new(['publicInstanceMethod','protectedInstanceMethod']),Set.new(TestClass.instance_methods(false)))
	assert_equal([:publicInstanceMethod],TestClass.new.noninherited_public_instance_methods)
end #noninherited_public_instance_methods
def test_noninherited_public_class_methods
	assert_equal(Class,TestClass.class)
	assert_equal(Object,TestClass.superclass)
	assert_equal([:classMethod],TestClass.methods-TestClass.superclass.methods)
#	assert_equal([:classMethod],TestClass.class.public_instance_methods)
	assert_equal([:classMethod],TestClass.new.noninherited_public_class_methods)
end #noninherited_public_class_methods
def test_whoAmI
	assert_equal('Symbol :cat',:cat.whoAmI)
end #whoAmI
def test_relationship

	assert_nil(TestClass.relationship(:cat))
end #relationship
def test_module
	assert(!StreamPattern.module?)
	assert(Generic_Table.module?)
end #module
def test_noninherited_modules
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
end #noninherited_modules
def test_module_included
	assert(StreamPattern.module_included?(:Generic_Table))
end #test
def test_matching_methods_in_context
	testClass=Acquisition
#error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
#error message too long		assert_equal([testClass.canonicalName,testClass.matching_instance_methods(//)],testClass.matching_methods_in_context(//)[0])
#error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
end #def
def test_Acquisition_Stream_Spec_modules
	assert(Generic_Table.module?)
	assert(!AcquisitionStreamSpec.module?)
	assert_equal([Generic_Table],AcquisitionStreamSpec.noninherited_modules)
	assert(AcquisitionStreamSpec.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_include('Generic_Table',AcquisitionStreamSpec.ancestors.map{|a| a.name})
	assert(AcquisitionStreamSpec.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionStreamSpec,:Generic_Table)
end #test
def test_Acquisition_Interface_modules
	assert(Generic_Table.module?)
	assert(AcquisitionInterface.ancestors.map{|a| a.name}.include?('Generic_Table'),"Module not included in #{canonicalName} context.")
	assert_equal([],AcquisitionInterface.noninherited_modules) # because of STI Generic_Table is not directly included
	assert_include('Generic_Table',AcquisitionInterface.ancestors.map{|a| a.name})
	assert(AcquisitionInterface.module_included?(:Generic_Table),"Module not included in #{canonicalName} context.")
	assert_module_included(AcquisitionInterface,:Generic_Table)
end #test
end #test class

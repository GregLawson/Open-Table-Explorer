require 'test_helper'
class GlobalTest < ActiveSupport::TestCase
test 'matching methods' do
	testClass=Acquisition
	assert_instance_of(Array,testClass.matching_methods(//))
	
	
end #test
test '' do
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
	assert_equal(['String'],Module.constants.map { |c| c.objectKind}.uniq)
	assert_include('String',MethodModel.constantized.map { |c| c.objectKind}.uniq)
	assert_operator(1000,:>,Module.constants.size)
	ObjectSpace.each_object(Class) do |c| 
		if c.name.match(/ExclusionValidator/) then
			p c.inspect
		end #if
	end #each_object
	#~ puts "ExclusionValidator.inspect=#{ExclusionValidator.inspect}"
	#~ puts " 'ExclusionValidator'.constantized.inspect=#{'ExclusionValidator'.constantized.inspect}"
	assert_operator(MethodModel.constantized.size,:<,MethodModel.classes_and_modules.size)
	assert_operator(100,:<,MethodModel.constantized.size)
#	puts "Module.constants=#{Module.constants.inspect}"
	METHODS=Module.constants.map do |c|
		if c.objectKind=='Class' || c.objectKind=='Module' then
			method_record(c)
		end #if
	end #map
	assert_operator(METHODS.size,:<,1000)
	assert_operator(100,:<,METHODS.size)
	assert_include( "Class",MethodModel.constantized.map { |c| c.objectKind}.uniq)
	puts "pretty print"
	#~ pp MethodModel.all
	#~ assert_not_nil(method_record('object_id',Object,:methods))
	assert_equal(Set.new([4,6,10]),Set.new(MethodModel.all.map { |m| m.keys.size}.uniq))
	assert_equal(Set.new([Set.new([:exception,:scope, :owner, :name]),
 Set.new([:exception,:scope, :method, :arity, :owner, :name]),
 Set.new([:exception,:scope,
  :instance_variable_defined,
  :method,
  :singleton,
  :protected,
  :private,
  :arity,
  :owner,
  :name])]),Set.new(MethodModel.all.map { |m| Set.new(m.keys)}.uniq))
	puts MethodModel.all.map { |m| m.keys}.uniq.inspect
	assert_equal(Set.new([:instance, :class, :singleton]),Set.new(MethodModel.all.map { |m| m[:scope]}.uniq))
end #test
end #test class

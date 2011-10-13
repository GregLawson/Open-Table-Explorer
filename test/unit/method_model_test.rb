require 'test_helper'
class GlobalTest < ActiveSupport::TestCase
def test_initialize
	owner=ActiveRecord::ConnectionAdapters::ColumnDefinition
	scope=:instance
	m=:to_sql
	explain_assert_respond_to(owner.new,m)
	assert_respond_to(owner.new,m)
	assert_instance_of(Method,owner.new.method(m.to_sym))
	assert_instance_of(Method,owner.new.method(m.to_sym))
	mr=MethodModel.new(m,owner,scope)
	assert_instance_of(MethodModel,mr)
	assert_not_nil(mr)
	assert_equal(MethodModel, mr.class)
#	assert_nil(mr[:exception])

	assert_equal(mr[:name], :to_sql)
	assert_equal(mr[:scope], :instance)
#	assert_equal(mr[:protected], false)
	assert_equal(mr[:instance_variable_defined], false)
	assert_equal(mr[:private], false)
	assert_equal(mr[:singleton], false)
	assert_not_nil(mr[:owner],"owner is nil for m=#{m}")

	owner=MethodModel
	scope=:class
	m=:inspect
	assert_equal([],owner.instance_methods(false))
	assert_equal_sets(["inspect", "instantiate_observers", "joins", "instance_method_already_implemented?"],owner.matching_class_methods(/ins/,false))
#new	assert_instance_of(Method,owner.new.method(m.to_sym))
#new	assert_instance_of(Method,owner.new.method(m.to_sym))
	assert_nil(MethodModel.new(m,owner,scope)[:exception])

end #new
def test_constantized
	assert_equal(['String'],Module.constants.map { |c| c.objectKind}.uniq)
	assert_include('String',MethodModel.constantized.map { |c| c.objectKind}.uniq)
	assert_operator(1000,:>,Module.constants.size)
	assert_operator(MethodModel.constantized.size,:<,MethodModel.classes_and_modules.size)
	assert_operator(100,:<,MethodModel.constantized.size)
#	puts "Module.constants=#{Module.constants.inspect}"
	method_list=Module.constants.map do |c|
		if c.objectKind==:class || c.objectKind==:module then
			new(c)
		end #if
	end #map
	assert_operator(method_list.size,:<,1000)
	assert_operator(100,:<,method_list.size)
	assert_include( "Class",MethodModel.constantized.map { |c| c.objectKind}.uniq)
	puts "pretty print"
	#~ pp MethodModel.all
	#~ assert_not_nil(new('object_id',Object,:methods))
end #constantized
test "size" do
end #test
def test_classes
	assert_kind_of(Enumerable::Enumerator,ObjectSpace.each_object(Module))
	assert_instance_of(Array,MethodModel.classes)
	MethodModel.classes.each do |m|
		assert_instance_of(Class,m)
	end #each
	assert_not_equal('',MethodModel.classes[0])
	assert_equal(MethodModel.classes.size,MethodModel.classes.uniq.size)
#	puts MethodModel.classes.inspect
	assert_empty(MethodModel.classes.map { |c| c.name}.sort-MethodModel.classes.map { |c| c.name}.sort.uniq)
	classNames=MethodModel.classes.map { |c| c.name}
	uniqClasses=classNames.sort.uniq
	duplicates=0 # found so far
	classNames.each_index do |i|
		if classNames[i].nil? then
			puts "class name[#{i}] is nil, class=#{MethodModel.classes[i].inspect}"
		end #if
		if classNames[i].empty?
			puts "class name[#{i}] is empty, class=#{MethodModel.classes[i].inspect}"
		end #if
		if classNames[i+duplicates]!=uniqClasses[i] then
			puts "Duplicate class name[#{i}] = #{classNames[i+duplicates]}"
			duplicates+=1
		end # if
	end #each
	assert_include(String,MethodModel.classes)
	assert_include(ActiveRecord::Base,MethodModel.classes)
	
end #classes
def test_modules
	assert_kind_of(Enumerable::Enumerator,ObjectSpace.each_object(Module))
	assert_instance_of(Array,MethodModel.modules)
	MethodModel.modules.each do |m|
		if !m.instance_of?(Module) then
			if MethodModel.classes.include?(m) then
				puts "#{m} should be Module but is #{m.class}, included in classes."
			else
				puts "#{m} should be Module but is #{m.class}"
			end #if
		end #if
#hope		assert_instance_of(Module,m)
	end #each
	MethodModel.modules.any? {|m| m.instance_of?(Module)}
	assert_not_equal('',MethodModel.modules[0])
	assert_equal(MethodModel.modules.size,MethodModel.modules.uniq.size)
	assert_include(Generic_Table,MethodModel.modules)
	assert_not_include(ActiveRecord::Base,MethodModel.modules)

end #modules
def test_classes_and_modules
	assert_operator(MethodModel.classes.size, :>, MethodModel.modules.size)
	assert_empty((MethodModel.modules-MethodModel.classes)&MethodModel.classes)
	assert_not_empty(MethodModel.classes_and_modules)
	assert_not_empty(MethodModel.classes_and_modules.find_all{|i| i.to_s=='ActiveRecord::ConnectionAdapters::ColumnDefinition'})
#	assert_equal([],MethodModel.classes_and_modules.find_all{|i| i.to_s=='ActiveRecord::ConnectionAdapters::ColumnDefinition'})

end #classes_and_modules
def test_all_instance_methods
	assert(MethodModel.classes.all? {|mr| mr.instance_of?(Class)})
	assert(MethodModel.modules.all? {|mr| mr.instance_of?(Module)})
	assert(MethodModel.all_instance_methods.any? {|mr| mr.instance_of?(MethodModel)})
	MethodModel.all_instance_methods.each do |mr| 
		assert_instance_of(MethodModel, mr)
	end #each
end #all_instance_methods
def test_all_class_methods
	assert(MethodModel.classes.all? {|mr| mr.instance_of?(Class)})
	assert(MethodModel.modules.all? {|mr| mr.instance_of?(Module)})
#	assert(MethodModel.classes.map { |c| c.methods(false).map { |m| new(m,c,:class) } }
	assert(MethodModel.all_class_methods.any? {|mr| mr.instance_of?(MethodModel)})
	MethodModel.all_class_methods.each do |mr| 
		assert_instance_of(MethodModel, mr)
	end #each
end #all_class_methods
def test_all_singleton_methods
	assert(MethodModel.classes.all? {|mr| mr.instance_of?(Class)})
	assert(MethodModel.modules.all? {|mr| mr.instance_of?(Module)})
	assert(MethodModel.all_singleton_methods.any? {|mr| mr.instance_of?(MethodModel)})
	MethodModel.all_singleton_methods.each do |mr| 
		assert_instance_of(MethodModel, mr)
	end #each
end #all_singleton_methods
def test_all
	all_records=MethodModel.all
	assert_instance_of(Array,all_records)
	assert_operator(100,:<,all_records.size)
	all_records.each do |mr| 
		assert_instance_of(MethodModel, mr)
		assert_include(mr[:scope].to_sym, [:instance, :class, :singleton])
	end #each
	assert(all_records.all? {|mr| mr[:name]})
	assert(all_records.all? {|mr| mr[:owner]})
	assert(all_records.all? {|mr| mr[:scope]})
	assert(all_records.all? {|mr| mr.has_key?(:singleton)})
	assert(all_records.all? {|mr| mr.has_key?(:protected)})
	assert(all_records.all? {|mr| mr.has_key?(:private)})
	assert(all_records.any? {|mr| mr[:method]})
	assert(all_records.any? {|mr| mr[:singleton]})
	assert(all_records.any? {|mr| mr[:protected]})
	assert(all_records.any? {|mr| mr[:private]})
	assert(all_records.any? {|mr| mr[:arity]})
	assert(all_records.any? {|mr| mr.has_key?(:instance_variable_defined)})
	assert(!all_records.any? {|mr| mr.has_key?(:exception)})
	assert(!all_records.any? {|mr| mr[:instance_variable_defined]})
	assert(!all_records.any? {|mr| mr[:source_location]})
	assert(!all_records.any? {|mr| mr[:parameters]})
	puts all_records.map { |m| m.keys}.uniq.inspect
#why?	assert_equal(Set.new([4,6,10]),Set.new(all_records.map { |m| m.keys.size}.uniq))
	assert_not_empty(Set.new(all_records.map { |m| m.keys}.uniq))
end #all
def test_first
	all_records=MethodModel.all
	assert_instance_of(Hash,all_records[0])
	assert_equal(all_records.first,all_records[0])
	assert_not_nil(MethodModel.first)
	assert_not_nil(all_records[0])
	assert_equal(MethodModel.first,all_records[0])
	assert_equal([],all_records[0])
	assert_instance_of(Hash,MethodModel.first)
	assert_equal([:scope, :class],all_records.first)
	assert_equal([:scope, :class],all_records.first)
	assert_equal([:scope, :class],MethodModel.first)
	assert_instance_of(String,MethodModel.first[:owner].name)
	assert_instance_of(String,MethodModel.first[:owner].name)
end #first
def test_find_by_name
	to_sqls=MethodModel.all.select {|m|m[:name].to_sym==:to_sql}
	assert_equal(to_sqls,MethodModel.find_by_name(:to_sql))
	assert_equal(to_sqls,MethodModel.all.find_all{|i| i[:name].to_sym==:to_sql})
	MethodModel.find_by_name(:to_sql).each do |mr|
		assert_equal(mr[:name], :to_sql)
		assert_equal(mr[:scope], :class)
		assert_equal(mr[:protected], false)
		assert_equal(mr[:instance_variable_defined], false)
		assert_equal(mr[:private], false)
		assert_equal(mr[:singleton], false)
		assert_not_nil(mr[:owner])
		puts "#{mr[:owner]}:#{mr[:owner].object_id}"
	end #each
	to_sql_owners=to_sqls.map {|t|t[:owner]}
	assert_equal(to_sql_owners.uniq,to_sql_owners,"No duplicates, please.")
end #find_by_name
def test_ExclusionValidator
	ObjectSpace.each_object(Class) do |c| 
		if c.name.match(/ExclusionValidator/) then
			p c.inspect
		end #if
	end #each_object
	#~ puts "ExclusionValidator.inspect=#{ExclusionValidator.inspect}"
	#~ puts " 'ExclusionValidator'.constantized.inspect=#{'ExclusionValidator'.constantized.inspect}"
end #ExclusionValidator
test 'matching methods' do
	testClass=Acquisition
	assert_instance_of(Array,testClass.matching_class_methods(//))
	assert_instance_of(Array,testClass.matching_instance_methods(//))
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
def test_owners_of
	assert_not_empty(MethodModel.owners_of(:to_sql))
end #owners_of
def test_matching_methods_in_context
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

end #test class

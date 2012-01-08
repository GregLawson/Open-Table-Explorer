require 'test/test_helper'

class GenericTypeTest < ActiveSupport::TestCase
def test_example_types
    assert_not_nil(GenericType.all)
    assert_not_nil(GenericType.all[0])
    
    GenericType.all.each do |t| 
    	assert_not_nil(t.example_types)
	t.example_types.each do |e|
		assert_match(Regexp.new(t.data_regexp), e.example_string)
	end #each
#	assert_equal([], t.example_types.map{|t| t.attributes})
    end #each
end #example_types
def test_ancestors
	assert(GenericType.all.any? {|t| !t.ancestors.empty?})
	assert_include("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').ancestors.map{|a| a.import_class})
	assert_include("Text_Column", GenericType.find_by_import_class('Integer_Column').ancestors.map{|a| a.import_class})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		assert_instance_of(Array, t.ancestors)
		if !t.ancestors.empty? then
			assert_instance_of(GenericType, t.ancestors[0])
		end #if
	end #each
	assert_equal(["VARCHAR_Column", "Text_Column"], GenericType.find_by_import_class('Integer_Column').ancestors.map{|a| a.import_class})
end #ancestors
def test_generalize
	GenericType.all.each do |t|
		assert_not_equal(t[:generalize_id], 0, "t=#{t.inspect}")
	end #each
	
	assert(GenericType.all.any? {|t| !t.generalize.nil?})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		if !t.generalize.nil? then
			assert_instance_of(GenericType, t.generalize)
		end #if
	end #each
	assert_equal("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').generalize.import_class)
end #generalize
def test_descendants
	assert(GenericType.all.any? {|t| !t.descendants.empty?})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		assert_instance_of(Array, t.descendants)
		if !t.descendants.empty? then
			assert_instance_of(GenericType, t.descendants[0])
		end #if
	end #each
	assert_include('Integer_Column', GenericType.find_by_import_class("VARCHAR_Column").descendants.map{|a| a.import_class})
	assert_include('Integer_Column', GenericType.find_by_import_class("Text_Column").descendants.map{|a| a.import_class})
end #descendants
end #GenericType

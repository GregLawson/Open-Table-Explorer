###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

require 'test/assertions/generic_type_assertions.rb'
class GenericTypeTest < ActiveSupport::TestCase
set_class_variables
def test_logical_primary_key
#	first=GenericType.first
	assert_equal(:import_class, GenericType.logical_primary_key)
end #logical_primary_key
def test_find_by_name
	macro_name='lower'
	macro_generic_type=GenericType.find_by_name(macro_name)
	assert_not_nil(macro_generic_type, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{GenericType.all.map{|t| t.import_class}.inspect}")
end #find_by_name
def test_generalizations
	assert_instance_of(GenericType, GenericType.find_by_import_class('digit'))
	assert_equal(["Text_Column", "VARCHAR_Column", "ascii", "print", "graph", "word", "alnum", "xdigit"], GenericType.find_by_import_class('digit').generalizations.map{|g| g.import_class})
	assert(GenericType.all.any? {|g| !g.generalizations.empty?})
	assert_include("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.import_class})
	assert_include("Text_Column", GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.import_class})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		assert_instance_of(Array, t.generalizations)
		if !t.generalizations.empty? then
			assert_instance_of(GenericType, t.generalizations[0])
		end #if
	end #each
	assert_equal_sets(["VARCHAR_Column", "Text_Column"], GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.import_class})
end #generalizations
def test_most_general
	most_general=GenericType.find_by_import_class('Text_Column')
	assert(most_general.most_general?)
	
end #most_general
def test_unspecialized
	digit=GenericType.find_by_import_class('digit')
	assert_empty(digit.specialize)
	assert(digit.unspecialized?)
	most_general=GenericType.find_by_import_class('Text_Column')
	assert_not_empty(most_general.specialize)
	assert(!most_general.unspecialized?)
end #unspecialized
def test_one_level_specializations
	assert(GenericType.all.any? {|t| !t.one_level_specializations.empty?})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		assert_instance_of(Array, t.one_level_specializations)
		if !t.one_level_specializations.empty? then
			assert_instance_of(GenericType, t.one_level_specializations[0])
		end #if
	end #each
	assert_include('Integer_Column', GenericType.find_by_import_class("VARCHAR_Column").one_level_specializations.map{|a| a.import_class})
	assert_not_include('Integer_Column', GenericType.find_by_import_class("Text_Column").one_level_specializations.map{|a| a.import_class})
	assert_equal(["cntrl", "print", "space"], GenericType.find_by_import_class('ascii').one_level_specializations.map{|g| g.import_class})
end #one_level_specializations
def test_specializations
	assert_equal(["tab", "lower", "upper", "digit", "alpha", "xdigit", 'underscore', "alnum", "word", "punct", "graph", "blank", "cntrl", "print", "space"], GenericType.find_by_import_class('ascii').specializations.map{|g| g.import_class})
	most_general=GenericType.find_by_import_class('Text_Column')
#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_import_class('Text_Column').specializations.map{|g| g.import_class})

#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_import_class('Text_Column').specializations.map{|g| g.import_class})
	GenericType.all.each do |g|
		assert_instance_of(Array, g.specializations)
	end #each
end #specializations
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
def test_assert_specialized_examples
	regexp=GenericType.find_by_import_class('word')[:data_regexp]
	assert_equal(2, regexp.size)
	assert_equal('\w', regexp)
	assert_equal(/\w/, Regexp.new(regexp))
#	assert_equal('\w', RegexpTree.string_of_matching_chars(/\w/))
	assert_match(Regexp.new(regexp), 'd')
	GenericType.all.each do |g|
		g.assert_specialized_examples
	end #each
end #assert_specialized_examples
def test_expansion_termination
	xdigit_type=GenericType.find_by_name('xdigit')
	regexp=xdigit_type[:data_regexp]
	assert_regexp(regexp)
	parse=RegexpTree.new(regexp)[0]
	macro_name=RegexpTree.macro_call?(parse)
	assert_instance_of(String, macro_name)
	assert_equal(xdigit_type[:import_class], macro_name)
	assert_block("xdigit_type=#{xdigit_type.inspect}.\n regexp=#{regexp}, parse=#{parse.inspect}\n macro_name=#{macro_name}"){xdigit_type.expansion_termination?}
end #expansion_termination
def test_expand
	parent=GenericType.find_by_name('Macaddr_Column')
	regexp=parent[:data_regexp]
	assert_regexp(regexp)
	parse=RegexpTree.new(regexp)
	macro_name=RegexpTree.macro_call?(parse)
	assert_not_equal(macro_name, parent[:import_class])
	expansion=parse.map_branches do |branch|
		macro_name=RegexpTree.macro_call?(branch)
		if macro_name then
			assert_not_empty(macro_name, "macro_name=#{macro_name} should be in #{GenericType.all.map{|t| t.import_class}.inspect}")
			all_macro_names= GenericType.all.map{|t| t.import_class}
			assert_include(macro_name, all_macro_names)
			macro_generic_type=GenericType.find_by_name(macro_name)
			assert_not_nil(macro_generic_type, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{all_macro_names.inspect}")
			macro_call=macro_generic_type[:data_regexp]
			assert_not_nil(macro_call, "")
			assert_not_equal(macro_call, regexp)
			assert_equal(macro_name, macro_generic_type[:import_class])
			assert_equal(branch, macro_generic_type.expand, "macro_name=#{macro_name},\n")
			macro_generic_type.expand
		else
			branch
		end #if
	end #map_branches
	assert_equal(expansion, parse.map_branches{|branch|branch})
end #expand
def test_most_specialized
	start=GenericType.find_by_name('text')
	assert_regexp(start[:data_regexp])
	string_to_match='123'
	if start.match(string_to_match) then
		one_level_specializations.map do |specialization|
			specialization.most_specialized(string_to_match, specialization)
		end #map
	end #if
	assert_equal('Integer_Column', GenericType::most_specialized('123'))
	assert_equal('Macaddr_Column', GenericType::most_specialized('12:34:56:78'))
end #most_specialized
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #id_equal
end #GenericType

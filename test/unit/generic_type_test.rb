###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

require 'test/assertions/generic_type_assertions.rb'
class GenericTypeTest < ActiveSupport::TestCase
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
	assert_equal(["cntl", "print", "space"], GenericType.find_by_import_class('ascii').one_level_specializations.map{|g| g.import_class})
end #one_level_specializations
def test_specializations
	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", 'underscore', "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_import_class('ascii').specializations.map{|g| g.import_class})
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
end #GenericType

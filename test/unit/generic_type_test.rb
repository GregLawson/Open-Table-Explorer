###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class GenericType < ActiveRecord::Base
include GenericTypeAssertions
extend GenericTypeAssertions::ClassMethods
end #class GenericType < ActiveRecord::Base

class GenericTypeTest < ActiveSupport::TestCase
set_class_variables
Text=GenericType.find_by_name('Text_Column')
Ascii=GenericType.find_by_name('ascii')
Alpha=GenericType.find_by_name('alpha')
Alnum=GenericType.find_by_name('alnum')
Digit=GenericType.find_by_name('digit')
Lower=GenericType.find_by_name('lower')
Xdigit=GenericType.find_by_name('xdigit')
Macaddr=GenericType.find_by_name('Macaddr_Column')
Integer=GenericType.find_by_name('Integer_Column')
VARCHAR_Column=GenericType.find_by_name('VARCHAR_Column')
def test_logical_primary_key
#	first=GenericType.first
	assert_equal([:import_class], GenericType.logical_primary_key)
end #logical_primary_key
def test_find_by_name
	macro_name='lower'
	macro_generic_type=GenericType.find_by_name(macro_name)
	assert_not_nil(macro_generic_type, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{GenericType.all.map{|t| t.name}.inspect}")
	assert_equal(macro_name, macro_generic_type.name, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{GenericType.all.map{|t| t.name}.inspect}")
end #find_by_name
def test_generalizations
	assert_instance_of(GenericType, GenericType.find_by_import_class('digit'))
	assert_equal(["Text_Column", "VARCHAR_Column", "ascii", "print", "graph", "word", "alnum", "xdigit"], GenericType.find_by_import_class('digit').generalizations.map{|g| g.name})
	assert(GenericType.all.any? {|g| !g.generalizations.empty?})
	assert_include("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.name})
	assert_include("Text_Column", GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.name})
	GenericType.all.each do |t|
		assert_instance_of(GenericType, t)
		assert_instance_of(Array, t.generalizations)
		if !t.generalizations.empty? then
			assert_instance_of(GenericType, t.generalizations[0])
		end #if
	end #each
	assert_equal_sets(["VARCHAR_Column", "Text_Column"], GenericType.find_by_import_class('Integer_Column').generalizations.map{|a| a.name})
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
	assert_include('Integer_Column', GenericType.find_by_import_class("VARCHAR_Column").one_level_specializations.map{|a| a.name})
	assert_not_include('Integer_Column', GenericType.find_by_import_class("Text_Column").one_level_specializations.map{|a| a.name})
	assert_equal(["cntrl", "print", "space"], GenericType.find_by_import_class('ascii').one_level_specializations.map{|g| g.name})
end #one_level_specializations
def test_specializations
	assert_equal(["tab", "lower", "upper", "digit", "alpha", "xdigit", 'underscore', "alnum", "word", "punct", "graph", "blank", "cntrl", "print", "space"], GenericType.find_by_import_class('ascii').specializations.map{|g| g.name})
	most_general=GenericType.find_by_import_class('Text_Column')
#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_import_class('Text_Column').specializations.map{|g| g.name})

#	assert_equal(["lower", "upper", "digit", "alpha", "xdigit", "alnum", "word", "punct", "graph", "blank", "cntl", "print", "space"], GenericType.find_by_import_class('Text_Column').specializations.map{|g| g.name})
	GenericType.all.each do |g|
		assert_instance_of(Array, g.specializations)
	end #each
end #specializations
def test_expansion_termination
	regexp=Xdigit[:data_regexp]
	assert_regexp(regexp)
	parse=RegexpTree.new(regexp)[0]
	macro_name=RegexpTree.macro_call?(parse)
	assert_instance_of(String, macro_name)
	assert_equal(Xdigit.name, macro_name)
	assert_block("Xdigit=#{Xdigit.inspect}.\n regexp=#{regexp}, parse=#{parse.inspect}\n macro_name=#{macro_name}"){Xdigit.expansion_termination?}
end #expansion_termination
def test_expand
	regexp=Macaddr[:data_regexp]
	assert_regexp(regexp)
	parse=RegexpTree.new(regexp)
	macro_name=RegexpTree.macro_call?(parse)
	assert_not_equal(macro_name, Macaddr.name)
	expansion=parse.map_branches do |branch|
		macro_name=RegexpTree.macro_call?(branch)
		if macro_name then
			assert_not_empty(macro_name, "macro_name=#{macro_name} should be in #{GenericType.all.map{|t| t.name}.inspect}")
			all_macro_names= GenericType.all.map{|t| t.name}
			assert_include(macro_name, all_macro_names)
			macro_generic_type=GenericType.find_by_name(macro_name)
			assert_not_nil(macro_generic_type, "GenericType.find_by_name('#{macro_name}')=#{GenericType.find_by_name(macro_name)} should be in #{all_macro_names.inspect}")
			macro_call=macro_generic_type[:data_regexp]
			assert_not_nil(macro_call, "")
			assert_not_equal(macro_call, regexp)
			assert_equal(macro_name, macro_generic_type.name)
			assert_equal(branch, macro_generic_type.expand, "macro_name=#{macro_name},\n")
			macro_generic_type.expand
		else
			branch
		end #if
	end #map_branches
	assert_equal(expansion, parse.map_branches{|branch|branch})
end #expand

def test_match
	regexp=Regexp.new(Text.expand.join)
	assert_regexp(regexp)
	string_to_match='123'
	assert_match(regexp, string_to_match)
	assert_not_nil(Text.match_exact?(string_to_match))
end #match
def test_match_Start
	regexp=Regexp.new(Text.expand.join)
	assert_regexp(regexp)
	string_to_match='123'
	assert_match(regexp, string_to_match)
	assert_not_nil(Text.match_start?(string_to_match))
end #match_start
def test_match_end
	regexp=Regexp.new(Text.expand.join)
	assert_regexp(regexp)
	string_to_match='123'
	assert_match(regexp, string_to_match)
	assert_not_nil(Text.match_end?(string_to_match))
end #match_end
def test_match_any
	regexp=Regexp.new(Text.expand.join)
	assert_regexp(regexp)
	string_to_match='123'
	assert_match(regexp, string_to_match)
	assert_not_nil(Text.match_any?(string_to_match))
end #match_any
def test_specializations_that_match

	regexp=Regexp.new(Text[:data_regexp])
	assert_regexp(regexp)
	string_to_match='123'
	message="Text=#{Text}, Text.match_exact?(string_to_match)=#{Text.match_exact?(string_to_match)}"
	assert_block(message){Text.match_exact?(string_to_match)}
	ret=Text.one_level_specializations.map do |specialization|
		assert(specialization.match_exact?(string_to_match))
		if specialization.match_exact?(string_to_match) then
			[specialization, specialization.specializations_that_match?(string_to_match)]
		else
			nil
		end #if
	end.compact.uniq #map
	assert_equal(ret, ret.compact)
	assert_equal([[VARCHAR_Column, [Integer]]], ret, NestedArray.new(ret).map_recursive{|s| s.name}.inspect)
	assert_instance_of(NestedArray, Text.specializations_that_match?(string_to_match))
	assert(Lower.unspecialized?)
	assert(!Alpha.unspecialized?)
	assert(!Xdigit.unspecialized?)
#	Ascii.assert_specializations_that_match([[:alpha, [:lower, :xdigit]]], 'c')
	Alnum.assert_specializations_that_match([:alpha, [:lower], :xdigit], 'c')
	Alnum.assert_specializations_that_match([:alpha, [:lower], :xdigit], 'c')
	assert_equal([:alpha, [:lower], :xdigit], Alnum.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}, Alnum.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}.inspect)
	assert_equal([:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]], Ascii.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}, Ascii.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}.inspect)
	assert_equal([:VARCHAR_Column, [:Integer_Column]], Text.specializations_that_match?(string_to_match).map_recursive{|s| s.name.to_sym}, Text.specializations_that_match?(string_to_match).map_recursive{|s| s.name.to_sym}.inspect)
end #specializations_that_match
def test_possibilities
	common_matches=Ascii.common_matches?('c')
	assert_kind_of(Array, common_matches)
	assert_kind_of(Array, common_matches[1])
	message="common_matches=#{common_matches.inspect}"
	alternatives=NestedArray.new([Lower, Xdigit])
	assert_equal(alternatives, Ascii.possibilities?(alternatives))
	tail=NestedArray.new([Alpha, [Lower]])
	assert_equal([:lower], Ascii.possibilities?(tail).map{|s| s.name.to_sym})
	fork=NestedArray.new([Alpha, [Lower], Xdigit])
	assert_equal([:lower, :xdigit], Ascii.possibilities?(fork).map{|s| s.name.to_sym})
	ambiguity=NestedArray.new([Alnum, [Alpha, [Lower], Xdigit]])
	assert_equal([:lower, :xdigit], Ascii.possibilities?(ambiguity).map{|s| s.name.to_sym})
	assert_equal([:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]], Ascii.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}, Ascii.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}.inspect)
	assert_equal([:alpha, [:lower], :xdigit], Alnum.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}, Alnum.specializations_that_match?('c').map_recursive{|s| s.name.to_sym}.inspect)
	assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map{|p|p.name.to_sym}, message)
	assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches[1]).map{|p|p.name.to_sym}, message)
	assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map{|p|p.name.to_sym}, message)
	Ascii.assert_possibilities([:lower, :xdigit], 'c')
	Lower.assert_possibilities([:lower], 'c')
	Ascii.assert_possibilities([:digit], '9')
	Lower.assert_possibilities([:digit], '9')
	Digit.assert_possibilities([:xdigit], 'c')
end #possibilities
def test_most_specialized
	Lower.assert_common_matches([:lower], 'l')
	Lower.assert_most_specialized([:lower], 'l')
	Digit.assert_common_matches([:xdigit], 'c')
	Digit.assert_most_specialized([:xdigit], 'c')
	Ascii.assert_common_matches([:ascii, [:print, [:graph, [:word, [:alnum, [:alpha, [:lower], :xdigit]]]]]], 'c')
	common_matches=Ascii.common_matches?('c')
	assert_kind_of(Array, common_matches)
	assert_kind_of(Array, common_matches[1])
	assert_equal([:lower, :xdigit], Ascii.possibilities?(common_matches).map{|p|p.name.to_sym})
	most_specialized=Ascii.most_specialized?('c', common_matches[1])
	assert_kind_of(Array, most_specialized)
	assert_equal([:lower, :xdigit], most_specialized.map{|p|p.name.to_sym})
	assert_equal([:lower, :xdigit], Ascii.possibilities?(most_specialized).map{|p|p.name.to_sym})
	Ascii.assert_most_specialized([:lower, :xdigit], 'c')
	Lower.assert_common_matches([:alnum, [:xdigit, [:digit]]], '9')
	Lower.assert_most_specialized([:digit], '9')
	assert_equal([Digit], Lower.most_specialized?('9'))
	assert_equal([Lower, Xdigit], Text.most_specialized?('c'), Text.most_specialized?('c').map{|m|m.name}.inspect) # ambiguous
	assert_not_empty(Digit.most_specialized?('c'))
	assert_equal([Xdigit], Digit.most_specialized?('c'))
	Digit.assert_most_specialized([:xdigit], 'c')
end #most_specialized
def test_common_matches
	regexp=Regexp.new(Text[:data_regexp])
	assert_regexp(regexp)
	string_to_match='123'
	assert_match(regexp, string_to_match)
	common_matches=if Text.match_exact?(string_to_match) then
		Text.specializations_that_match?(string_to_match)
	else
		Text.generalize.common_matches?(string_to_match)
	end #if
	assert_instance_of(NestedArray, common_matches)
	Digit.assert_common_matches([:xdigit], 'c')
	assert_equal([VARCHAR_Column, [Integer]], common_matches)
	assert_instance_of(NestedArray, Text.common_matches?('123'))
	assert_equal([Text, [VARCHAR_Column, [Integer]]], Text.common_matches?('123'))
	mac_example='12:34:56:78'
	regexp=Macaddr[:data_regexp]
	mac_match=RegexpMatch.new(regexp, mac_example)
	assert_equal([Text, [VARCHAR_Column, [Macaddr]]], Text.common_matches?(mac_example))
end #common_matches
def test_generalize
	assert_equal("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').generalize.name)
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
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #id_equal
end #GenericType

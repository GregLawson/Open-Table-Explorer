###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/regexp_parse_assertions.rb'
class RegexpParseAssertionsTest < TestCase
include RegexpParse::Examples
extend RegexpParse::Examples::ClassMethods
#include DefaultAssertionTests
#include DefaultAssertionTests::ClassMethods
def test_class_assert_invariant
	regexp_string='K.*C'
	test_tree=RegexpParse.new(regexp_string)
	refute_nil(test_tree.parse_tree)
	refute_nil(RegexpParse.new(''))
	assert_equal('', RegexpParse.new(test_tree.rest).to_s)
	assert_equal(["K", [".", "*"], "C"], test_tree.parse_tree)
	refute_nil(RegexpParse.new(["K", [".", "*"], "C"].to_s))
	refute_nil(RegexpParse.new(test_tree.parse_tree.to_s))
	refute_nil(test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest+test_tree.parse_tree.to_s)
	test_tree.assert_invariant
end #assert_class_invariant_conditions
def test_assert_pre_conditions
	parser=RegexpParse::Examples::Sequence_parse
	parser.restartParse!
	parser.assert_pre_conditions
end #assert_pre_conditions
def test_assert_repetition_range
	RegexpParse.new(RegexpParse::Examples::Empty_language_string).assert_repetition_range(UnboundedRange.new(0,0))
	assert_equal(UnboundedRange::Once, RegexpParse.new('a').repetition_length)
end #assert_repetition_range
def test_assert_round_trip
	RegexpParse.assert_round_trip(RegexpParse::Examples::Dot_star_array)
	RegexpParse.assert_round_trip(RegexpParse::Examples::Parenthesized_array)
end #assert_round_trip
def test_value_of
	name=:Parenthesized
	suffix=:_string
	assert_nil(RegexpParse.full_name?(:Parenthesized))
	full_name=RegexpParse.full_name?(name, suffix)
	refute_nil(RegexpParse::Examples.const_get(name.to_sym))
	assert_nil(RegexpParse::Examples.const_get(full_name.to_sym))
	assert_equal(RegexpParse::Examples::Parenthesized_string, RegexpParse.value_of?(name, suffix))
end #value_of
def test_path_array
	name=:Parenthesized
	suffix=:_string
	assert_equal([:RegexpParse, :Examples, (name.to_s+suffix.to_s).to_sym], RegexpParse.path_array?(name, suffix))
end #path_array
def test_full_name
	name=:Parenthesized
	suffix=:_string
	full_name='RegexpParse::Examples::'+name.to_s+suffix.to_s
	assert_equal('RegexpParse::Examples::Parenthesized_string', RegexpParse.full_name?(name, suffix))
	ret=begin
		eval(full_name.to_s)
		full_name
	rescue 
		nil
	end #begin
	assert_equal(ret, RegexpParse.full_name?(name, suffix))
	suffix=''
	full_name='RegexpParse::Examples::'+name.to_s+suffix.to_s
	ret=begin
		eval(full_name.to_s)
		full_name
	rescue 
		nil
	end #begin
	assert_nil(ret)
	assert_equal(ret, RegexpParse.full_name?(name, ''))
	assert_nil(RegexpParse.full_name?(:Parenthesized))
end #full_name
def test_parse_of
	string=RegexpParse::Examples::Parenthesized_string
	assert_equal(RegexpParse::Examples::Parenthesized_parse, RegexpParse.parse_of?('Parenthesized'))
end #parse_of
def test_string_of
	name=:Parenthesized
	suffix=:_string
	array=RegexpParse::Examples::Parenthesized_array
	assert_equal(RegexpParse::Examples::Parenthesized_parse, RegexpParse.string_of?('Parenthesized'))
end #string_of
def test_array_of
	string=RegexpParse::Examples::Parenthesized_string
end #array_of
def test_name_of
	constant='Parenthesized_parse'
	match=/([A-Z][a-z_]*)_(array|string|parse)/.match(constant)
	refute_nil(match)
	assert_equal(3, match.size, "match=#{match.inspect}")
end #name_of
def test_constants_by_class
	klass=RegexpParse
	rps=RegexpParse::Examples.constants.select do |c|
		RegexpParse.value_of?(c).instance_of?(klass)
	end #select
	refute_empty(rps)
	assert_equal(rps, RegexpParse.example_constant_names_by_class(klass))
end #example_constant_names_by_class
def test_names
	constants=RegexpParse::Examples.constants
	refute_empty(constants)
	assert_instance_of(Symbol, constants[0])
	constants.map do |name|
		constant=RegexpParse::Examples.const_get(name)
		refute_nil(name, "name=#{name.inspect}, constants=#{constants.inspect}")
		assert_instance_of(Symbol, name)
		match=RegexpParse.name_of?(name)
		if !match.nil? && (constant.class==String || constant.class==Array || constant.class==RegexpParse) then
			refute_nil(match, "name.class=#{name.class.inspect}, name=#{name.inspect}, constants=#{constants.inspect}")
			match[1]
		else
			nil
		end #if
	end.compact.uniq #map
	assert_include(RegexpParse.names, 'Sequence')

end #names
def test_strings
	refute_nil(RegexpParse::Examples.constants)
	assert_include(RegexpParse::Examples.constants, :Dot_star_string)

#	assert_include(RegexpParse::Examples.methods(false), :strings)

	assert_include(RegexpParse.strings, :Dot_star_string)

end #strings
def test_arrays
	assert_include(RegexpParse.arrays, :Dot_star_array)

end #arrays
def test_parses
	num_RegexpParse=0
	ret=RegexpParse::Examples.constants.select do |c|
# http://www.postal-code.com/mrhappy/blog/2007/02/01/ruby-comparing-an-objects-class-in-a-case-statement/
		case c
		when RegexpParse 
			assert_instance_of(RegexpParse, c)
			num_RegexpParse+=1
		when Symbol 
			assert(!(Symbol=== c.class), "Unexpected RegexpParse::Examples constant=#{c.inspect} of type #{c.class}")
			assert(Symbol=== c, "Unexpected RegexpParse::Examples constant=#{c.inspect} of type #{c.class}")
			assert_instance_of(Symbol, c)
		else
			assert(Symbol=== c.class, "Unexpected RegexpParse::Examples constant=#{c.inspect} of type #{c.class}")
			refute_equal(Symbol, c.class)
			fail "Unexpected RegexpParse::Examples constant=#{c.inspect} of type #{c.class}"
		end #case
		c.instance_of?(RegexpParse)
	end #select
#message	refute_empty(ret, "num_RegexpParse=#{num_RegexpParse}")
	assert_subset(RegexpParse::Examples.constants.select {|c| /.*_parse/.match(c)}, RegexpParse.parses, "num_RegexpParse=#{num_RegexpParse}")

end #parses
RegexpParse.assert_pre_conditions
end #RegexpParseAssertionsTest

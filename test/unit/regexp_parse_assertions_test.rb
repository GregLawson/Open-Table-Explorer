###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/regexp_parse_assertions.rb'
require_relative 'default_assertions_test.rb'
class RegexpParseAssertionsTest < TestCase
#set_class_variables
include RegexpParse::TestCases
include DefaultAssertionTests
def test_Class_assert_pre_conditions
	RegexpParse.assert_pre_conditions
end #self.assert_pre_conditions
def test_Class_assert_invariant
	RegexpParse.assert_invariant
end #assert_RegexpParse_invariant_conditions
def test_Class_assert_post_conditions
	RegexpParse.assert_post_conditions
end #assert_RegexpParse_post_conditions
Asymmetrical_Tree=RegexpParse.new(NestedArray::TestCases::Asymmetrical_Tree_Array)
def test_assert_invariant
	regexp_string='K.*C'
	test_tree=RegexpParse.new(regexp_string)
	assert_not_nil(test_tree.parse_tree)
	assert_not_nil(RegexpParse.new(''))
	assert_equal('', RegexpParse.new(test_tree.rest).to_s)
	assert_equal(["K", [".", "*"], "C"], test_tree.parse_tree)
	assert_not_nil(RegexpParse.new(["K", [".", "*"], "C"].to_s))
	assert_not_nil(RegexpParse.new(test_tree.parse_tree.to_s))
	assert_not_nil(test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest+test_tree.parse_tree.to_s)
	test_tree.assert_invariant
end #assert_invariant
def test_assert_pre_conditions
	parser=RegexpParse::TestCases::Sequence_parse
	parser.restartParse!
	parser.assert_pre_conditions
end #assert_pre_conditions
def test_assert_post_conditions
	parser=RegexpParse::TestCases::Sequence_parse
	parser.assert_post_conditions
end #assert_post_conditions
def test_assert_repetition_range
	RegexpParse.new(RegexpParse::TestCases::Empty_language_string).assert_repetition_range(UnboundedRange.new(0,0))
	assert_equal(UnboundedRange::Once, RegexpParse.new('a').repetition_length)
end #assert_repetition_range
def test_assert_round_trip
	RegexpParse.assert_round_trip(RegexpParse::TestCases::Dot_star_array)
	RegexpParse.assert_round_trip(RegexpParse::TestCases::Parenthesized_array)
end #assert_round_trip
def test_value_of
	name=:Parenthesized
	form=:string
	assert_equal(RegexpParse::TestCases::Parenthesized_string, RegexpParse::TestCases.value_of?(name, form))
end #value_of
def test_constant_name
	name=:Parenthesized
	form=:string
	assert_equal('RegexpParse::TestCases::Parenthesized_string', RegexpParse::TestCases.constant_reference?(name, form))
end #constant_name
def test_parse_of
	string=RegexpParse::TestCases::Parenthesized_string
end #parse_of
def test_string_of
	name=:Parenthesized
	form=:string
	array=RegexpParse::TestCases::Parenthesized_array
end #string_of
def test_array_of
	string=RegexpParse::TestCases::Parenthesized_string
end #array_of
def test_name_of
	constant='Parenthesized_parse'
	match=/([A-Z][a-z_]*)_(array|string|parse)/.match(constant)
	assert_not_nil(match)
	assert_equal(3, match.size, "match=#{match.inspect}")
end #name_of
def test_names
	constants=RegexpParse::TestCases.constants
	assert_not_empty(constants)
	assert_instance_of(Symbol, constants[0])
	constants.map do |name|
		constant=RegexpParse::TestCases.const_get(name)
		assert_not_nil(name, "name=#{name.inspect}, constants=#{constants.inspect}")
		assert_instance_of(Symbol, name)
		match=RegexpParse::TestCases.name_of?(name)
		if !match.nil? && (constant.class==String || constant.class==Array || constant.class==RegexpParse) then
			assert_not_nil(match, "name.class=#{name.class.inspect}, name=#{name.inspect}, constants=#{constants.inspect}")
			match[1]
		else
			nil
		end #if
	end.compact.uniq #map
	assert_include(RegexpParse::TestCases.names, 'Sequence')

end #names
def test_strings
	assert_not_nil(RegexpParse::TestCases.constants)
	assert_include(RegexpParse::TestCases.constants, :Dot_star_string)

	assert_include(RegexpParse::TestCases.methods(false), :strings)

	assert_include(RegexpParse::TestCases::strings, :Dot_star_string)

end #strings
def test_arrays
	assert_include(RegexpParse::TestCases::arrays, :Dot_star_array)

end #arrays
def test_parses
	assert_include(RegexpParse::TestCases::parses, :Dot_star_parse)

end #parses
RegexpParse.assert_pre_conditions
end #RegexpParseAssertionsTest

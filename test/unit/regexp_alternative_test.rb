###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class RegexpAlternative < RegexpTree # reopen class to add assertions
include RegexpTreeAssertions
extend RegexpTreeAssertions::ClassMethods
end #RegexpAlternative
class RegexpAlternativeTest < TestCase
set_class_variables
Alternative_ab_of_abc_10=RegexpAlternative.new('a|b', '[abc]{1,10}')
Tree123=RegexpParse.new('[1-3]')
def test_probability_space_regexp
	assert_equal(RegexpTree.new('[abc]{1,10}'), Alternative_ab_of_abc_10.probability_space_regexp)
end #probability_space_regexp

def test_probability_of_alternatives
	assert_equal(3, [1,2].reduce {|sum, e| sum + e })
	summation=['a','b'].reduce(0) do |sum, e| 
		assert_instance_of(String, e)
		assert_instance_of(Fixnum, sum)
		sum + e.size 
	end #reduce
	assert_equal(2, summation)
	assert_equal(2, ['a','b'].reduce(0) {|sum, e| sum + e.size })
	branch=Alternative_ab_of_abc_10
	assert_equal(2.0/3, branch.probability_of_alternatives)
end #probability_of_alternatives
def test_initialize
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp_string)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp_string)

	assert_equal(['K'], RegexpAlternative.new('K').to_a)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal(Asymmetrical_Tree_Array.flatten, Asymmetrical_Tree.to_a.flatten)
	assert_equal(Sequence, Asymmetrical_Tree_Array.flatten)
	assert_not_nil(RegexpAlternative.new(['.']))
	assert_not_nil(RegexpAlternative.new('.'))
	assert_not_nil(RegexpAlternative.new(/./))
end #initialize
def test_compare_character_class
	assert_equal(Asymmetrical_Tree, Asymmetrical_Tree)
	assert_operator(RegexpAlternative.new('a'), :==, RegexpAlternative.new('a'))
	my_cc=RegexpAlternative.new('[ab]').character_class?
	other_cc=RegexpAlternative.new('[a]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, my_cc.compare_character_class?(other_cc))
	my_cc.assert_specialized_by(other_cc)

	
	my_cc=RegexpAlternative.new('[[:print:]]').character_class?
	assert_equal(95, my_cc.to_s.length)
	other_cc=RegexpAlternative.new('[[:xdigit:]]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, RegexpAlternative.new('[[:print:]]').compare_character_class?(RegexpAlternative.new('[[:xdigit:]]')))
end #compare_character_class
def test_case
	assert_equal(Anchoring, Both_anchor.case?)
	assert_equal(RepetitionLength, RegexpRepetition::Any.case?)
end #case
def test_alternatives_intersect
	rhs=RegexpRepetition::Many.repeated_pattern
	lhs=RegexpRepetition::Any.repeated_pattern
	assert_equal('.', rhs.to_s)
	assert_equal(RegexpParse::TestCases::Any_binary_char_string, lhs.to_s)
	lhs_alternatives=lhs.alternatives?
	rhs_alternatives=rhs.alternatives?
	assert_instance_of(Array, lhs_alternatives)
	assert_instance_of(Array, rhs_alternatives)
	alternatives=lhs_alternatives & rhs_alternatives
	assert_instance_of(Array, alternatives)
	assert_equal(RegexpTree::Binary_bytes, lhs.alternatives_intersect(rhs))
end #alternatives_intersect
def test_RegexpTree_intersection
	assert_equal(RegexpRepetition::Many, RegexpRepetition::Any & RegexpRepetition::Many)
end #intersection
Alternatives_4=RegexpTree.new('a|b|c|d')
Nested_alternatives=RegexpTree.new('(a|b)(c|d)')
def test_alternatives
	# Pre-conditions
	assert_equal([["a", "|"], ["b", "|"], ["c", "|"], "d"], Alternatives_4)
	assert_equal([["(", ["a", "|"], "b", ")"], ["(", ["c", "|"], "d", ")"]], Nested_alternatives)
	#line by line known test case (particular invariant conditions)
	# character class test
	branch=RegexpTree.new('[0-2]')
	assert_kind_of(Array, branch)
	
	cc_comparison=branch.character_class?
	assert_not_nil(cc_comparison)
	assert_equal(['0','1','2'], cc_comparison)
	assert_equal(['0', '1', '2'], cc_comparison)
	# Unroll recursion
	# 
	branch=RegexpTree.new('a|b|c')
	assert_equal([["a", "|"], ["b", "|"], "c"], branch)
	assert_kind_of(Array, branch)
	assert_equal(branch[0].size, 2)
	assert_equal(branch[0][-1], '|')
	lhs=branch[0][0]
	assert_equal('a', lhs)
	assert_equal([["b", "|"], 'c'], branch[1..-1])
	# terminal recursion
	branch2=branch[1..-1]
	assert_equal([["b", "|"], "c"], branch2)
	assert_kind_of(Array, branch2)
	assert_equal(branch2[0].size, 2)
	assert_equal(branch2[0][-1], '|')
	lhs=branch2[0][0]
	assert_equal('b', lhs)
	assert_equal(['c'], branch2[1..-1])
	rhs=branch.alternatives?(branch2[1..-1])
	assert_not_nil(rhs)
	assert_equal(['c'], rhs)
	assert_equal(['b', 'c'], ([lhs] + rhs).sort)
	
	lhs=branch[0][0]
	assert_equal('a', lhs)
	assert_equal([["b", "|"], 'c'], branch[1..-1])
	rhs=branch.alternatives?(branch[1..-1])
	assert_not_nil(rhs)
	assert_equal(['b', 'c'], rhs)
	assert_equal(['a', 'b', 'c'], ([lhs] + rhs).sort)
	#test known cases of method (post conditions)
	assert_equal(['a', 'b'], RegexpTree.new('a|b').alternatives?)
	assert_equal(['a', 'b', 'c'], RegexpTree.new('a|b|c').alternatives?)
	assert_equal(['a', 'b', 'c', 'd'], Alternatives_4.alternatives?)
	assert_nil(Nested_alternatives.alternatives?)
	assert_equal(['a'], RegexpTree.new('a').alternatives?('a'))
	assert_equal(['.'], RegexpRepetition::Any.repeated_pattern)
	assert_instance_of(Array, RegexpTree.new('.').character_class?)
	assert_instance_of(Array, RegexpTree.new('.').alternatives?)
	assert_instance_of(Array, RegexpRepetition::Any.repeated_pattern.alternatives?)
end #alternatives
def test_character_class
	character_class=RegexpTree.new('[a]')
	assert_instance_of(RegexpTree, character_class)
	assert_instance_of(Array, character_class.character_class?)
	assert_equal('a', character_class.character_class?.to_s)
	promoted_character_class=RegexpTree.new('a')
	assert_kind_of(RegexpTree, promoted_character_class)
	assert_equal(0, character_class <=> promoted_character_class)
	assert_equal(character_class, promoted_character_class)
	assert_equal(['a'], promoted_character_class)
	assert_instance_of(RegexpTree, promoted_character_class)
	assert_equal(1, promoted_character_class.length)
	assert_equal(character_class.character_class?, promoted_character_class.character_class?)
	assert_instance_of(Array, promoted_character_class.character_class?)
	assert_equal(256, RegexpRepetition::Any.string_of_matching_chars.length)
	assert_instance_of(Array, RegexpRepetition::Any.repeated_pattern.string_of_matching_chars)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], RegexpRepetition::Any.repeated_pattern)
	assert_equal(256, RegexpRepetition::Any.repeated_pattern.character_class?.size)
	assert_instance_of(Array, RegexpRepetition::Any.repeated_pattern.character_class?)
	assert_instance_of(Array, RegexpRepetition::Any.repeated_pattern.alternatives?)
end #character_class
Test_Pattern_Array=["t", "e", "s", "t", "/",
	  	[["[", "a", "-", "z", "A", "-", "Z", "0", "-", "9", "_", "]"], "*"],
	 	["[", ".", "]"],
	 	"r",
		[["[", "a", "-", "z", "]"], "*"]]
Test_Pattern=RegexpTree.new(Test_Pattern_Array)
def test_to_s


	assert_equal(Asymmetrical_Tree_Array,Asymmetrical_Tree.to_a)
	assert_equal('123',Asymmetrical_Tree.to_s)
#recurse	assert_equal('.*',RegexpTree.new('.*').to_s)
	assert_equal('K.*C',RegexpTree.new('K.*C').to_s)
end #to_s
def test_to_regexp
	assert_equal(/.*/mx,RegexpTree.new('.*').to_regexp)
end #to_regexp
Quantified_repetition=RegexpTree.new([".", ["{", "3", ",", "4", "}"]])
Tree123=RegexpTree.new('[1-3]')
def test_string_of_matching_chars
	regexp=Regexp.new('\d')
	char='9'
	assert_match(regexp, char)
	ascii_characters=(0..255).to_a.map { |i| i.chr}
	assert_equal(256, ascii_characters.size)
	assert_equal(['1','2','3'], ("\x31".."\x33").to_a)
	assert_equal(['A','B','C'], ("\x41".."\x43").to_a)
	assert_equal(['Q','R','S'], ("\x51".."\x53").to_a)
	assert_equal(['a','b','c'], ("\x61".."\x63").to_a)
	matches=(("\x31".."\x33").to_a.select do |char|
		if regexp.match(char) then
			char
		else
			nil
		end #if
	end) #select
	assert_equal('123', matches.join)
	assert_match(/[a-z]/, 'a')
	assert_instance_of(Array, Tree123.string_of_matching_chars)
	assert_instance_of(String, Tree123.string_of_matching_chars[0])
	assert_equal(['[', '1', '-', '3', ']'], Tree123)
	assert_equal(['[', '1', '-', '3', ']'], Tree123.to_a)
	assert_equal(['1', '2', '3'], Tree123.string_of_matching_chars)
	assert_equal('123', Tree123.string_of_matching_chars.join)
	assert_equal('0123456789', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('0123456789', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz'.upcase, Tree123.string_of_matching_chars(/[A-Z]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz', Tree123.string_of_matching_chars(/[a-z]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz', Tree123.string_of_matching_chars(Regexp.new('[a-z]')).join)
	assert_match(/[[:print:]]/, 'a')
	assert_equal(95, RegexpTree.new('[[:print:]]').string_of_matching_chars.length)
	assert_equal(194, RegexpTree.new('.').string_of_matching_chars.length)
	assert_equal(256, RegexpTree.new("#{RegexpParse::TestCases::Any_binary_char_string}").string_of_matching_chars.length)
	assert_equal(256, RegexpRepetition::Any.string_of_matching_chars.length)
	assert_instance_of(Array, RegexpRepetition::Any.repeated_pattern.string_of_matching_chars)
end #string_of_matching_chars
end #RegexpTreeTest

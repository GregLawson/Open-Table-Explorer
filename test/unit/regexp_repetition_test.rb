###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class RegexpTree < NestedArray # reopen class to add assertions
include RegexpTreeAssertions
extend RegexpTreeAssertions::ClassMethods
end #RegexpTree
class RepetitionLengthTest < ActiveSupport::TestCase
set_class_variables
One_to_ten=RepetitionLength.new('.', 1, 10)
One_a=RepetitionLength.new('a', UnboundedRange::Once)
Any_repetition=RepetitionLength.new('.', 0, nil)
def test_RepetitionLength_initialize
	assert_equal(One_to_ten.repetition_length, 1..10)
	assert_instance_of(UnboundedRange, One_a.repetition_length)
	assert_instance_of(UnboundedRange, RepetitionLength.new('b+').repetition_length)
	assert_instance_of(UnboundedRange, Any_repetition.repetition_length)
	assert_equal(UnboundedRange::Once, One_a.repetition_length)
	assert_equal(One_a.repetition_length, 1..1)
end #initialize
def test_RepetitionLength_compare
	assert(nil == nil)
	assert_equal(RepetitionLength.new('.', 1, nil), RepetitionLength.new('.', 1, nil))
	assert_equal(RepetitionLength.new('.', 1, 3), RepetitionLength.new('.', 1, 3))
	assert_operator(RepetitionLength.new('.', 1, 4), :>, RepetitionLength.new('.', 1, 3))
	assert_operator(RepetitionLength.new('.', 0, 3), :>, RepetitionLength.new('.', 1, 3))
	assert_operator(RepetitionLength.new('.', 0, nil), :>, RepetitionLength.new('.', 1, nil))
	assert_operator(RepetitionLength.new('.', 1, nil), :>, RepetitionLength.new('.', 1, 3))
end #compare
def test_plus
	rep=RepetitionLength.new('.', 1, 2)
	other=RepetitionLength.new('.', 1, 2)
	assert_equal({"max"=>4, "min"=>2}, rep+other)
	assert_equal({"max"=>nil, "min"=>2}, rep+RepetitionLength.new('.', 1, nil))
	assert_equal({"max"=>nil, "min"=>2}, RepetitionLength.new('.', 1, nil)+rep)
end #plus
Any_length=RegexpTree::Any.repetition_length
Many_length=RegexpTree::Many.repetition_length
def test_intersect
	assert_include('&', RepetitionLength.instance_methods(false))
	assert_equal({"max"=>nil, "min"=>1}, Any_length.&(Many_length))
	assert_equal({"max"=>nil, "min"=>1}, Any_length & Many_length)
end #intersect
def test_union
	assert_equal({"max"=>nil, "min"=>0}, Any_length | Many_length)
end #union / generalization
Repetition_1_2=RegexpTree.new(["{", ["1", ",", "2"], "}"])
def test_canonical_repetition_tree
	assert_equal(Repetition_1_2, RepetitionLength.new('.', 1,2).canonical_repetition_tree)
end #canonical_repetition_tree
One_to_ten=RepetitionLength.new('.', 1, 10)
Any_repetition=RepetitionLength.new('.', 0, nil)
Repetition_1_2=RegexpTree.new(["{", ["1", ",", "2"], "}"])
def test_canonical_repetition_tree
	assert_equal(Repetition_1_2, RepetitionLength.new('.', 1,2).canonical_repetition_tree)
end #canonical_repetition_tree
def test_concise_repetition_node
	assert_equal('', RepetitionLength.new('.', 1, 1).concise_repetition_node)
	assert_equal("+", RepetitionLength.new('.', 1, nil).concise_repetition_node)
	assert_equal("?", RepetitionLength.new('.', 0, 1).concise_repetition_node)
	assert_equal("*", RepetitionLength.new('.', 0, nil).concise_repetition_node)
	assert_equal(Repetition_1_2, RepetitionLength.new('.', 1,2).concise_repetition_node)
	assert_equal(['{',['2'], '}'], RepetitionLength.new('.', 2, 2).concise_repetition_node)
end #concise_repetition_node
def test_concise_repetition_node
	assert_equal('', RepetitionLength.new('.', 1, 1).concise_repetition_node)
	assert_equal("+", RepetitionLength.new('.', 1, nil).concise_repetition_node)
	assert_equal("?", RepetitionLength.new('.', 0, 1).concise_repetition_node)
	assert_equal("*", RepetitionLength.new('.', 0, nil).concise_repetition_node)
	assert_equal(Repetition_1_2, RepetitionLength.new('.', 1,2).concise_repetition_node)
	assert_equal(['{',['2'], '}'], RepetitionLength.new('.', 2, 2).concise_repetition_node)
end #concise_repetition_node
def test_repeated_pattern

	assert_equal(['.','*'], RegexpTree.new('.*'))
	assert(RegexpTree.new('.*').postfix_expression?)
	assert_equal(['.'], RegexpTree.new('.*').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.+').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.?').repeated_pattern)
	assert_equal(['a'], RegexpTree.new('a'))
	assert_equal(['a'], RegexpTree.new('a').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.').repeated_pattern)
	assert_equal(Quantified_repetition, RegexpTree.new('.{3,4}'))
	assert_equal(['.'], RegexpTree.new('.{3,4}').repeated_pattern)
	assert_equal('*', Any.postfix_expression?)
	assert_instance_of(RegexpTree, Any.repeated_pattern('a'))
	assert_instance_of(RegexpTree, Any.repeated_pattern)
	assert_instance_of(RegexpTree, Quantified_repetition.repeated_pattern)
	assert_instance_of(RegexpTree, RegexpTreeTest::Sequence.repeated_pattern)
	assert_equal(Binary_range, Any.repeated_pattern.to_s)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], Any.repeated_pattern)
end #repeated_pattern
def test_merge_to_repetition
	# first line by line test case
	side=['a']
	branch=RegexpTree.new([side, side])
	first=branch[0]
	second=branch[1]
	assert_equal(first, second)
	first_repetition=first.repetition_length
	second_repetition=second.repetition_length
	merged_repetition=(first_repetition+second_repetition).concise_repetition_node
	assert_equal(["{", ["2"], "}"], merged_repetition)
	assert_equal(['a'], first.repeated_pattern)
	assert_equal([2, 2], [first_repetition.begin+second_repetition.begin, first_repetition.end+second_repetition.end])
	assert_instance_of(RegexpTree, first.repeated_pattern)
	branch.merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1])
	assert_equal(['a',['{',['2'], '}']], branch.merge_to_repetition)
	# second line by line test case
	branch=RegexpTree.new('a?a')
	assert_instance_of(RegexpTree, branch)
	assert_equal([["a", "?"], "a"], branch)
	first=branch[0]
	second=branch[1]
	assert_instance_of(RegexpTree, first)
	assert_instance_of(String, second)
	assert_equal(['a'], branch.repeated_pattern(first))
	assert_equal(['a'], branch.repeated_pattern(second))
	first_repetition=first.repetition_length
	second_repetition=branch.repetition_length(second)
	assert_equal([1, 2], [first_repetition.begin+second_repetition.begin, first_repetition.end+second_repetition.end])
	assert_equal(['a'], branch.repeated_pattern(first))
	assert_equal(['a'], branch.repeated_pattern(second))
	merged_repetition=(first_repetition+second_repetition).concise_repetition_node
	assert_equal(["{", ["1", ",", "2"], "}"], merged_repetition)
	assert_equal([], branch[2..-1])
	merged_pattern=['a',['{',['1',',','2'], '}']]
	assert_equal(merged_pattern, first.repeated_pattern << merged_repetition)
	assert_equal(merged_pattern, branch.merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1]))
	assert_equal(merged_pattern, branch.merge_to_repetition)
end #merge_to_repetition
end #RegexpTreeTest

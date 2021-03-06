###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# require_relative '../assertions/generic_table_examples.rb'
class RegexpTree < NestedArray # reopen class to add assertions
  include RegexpTreeAssertions
  extend RegexpTreeAssertions::ClassMethods
end # RegexpTree
class RegexpRepetitionTest < TestCase
  def test_RegexpRepetition_initialize
    assert_equal(One_to_ten.repetition_length, 1..10)
    assert_instance_of(UnboundedRange, One_a.repetition_length)
    assert_instance_of(UnboundedRange, RegexpRepetition.new('b+').repetition_length)
    assert_instance_of(UnboundedRange, RegexpRepetition::TestCases::Any.repetition_length)
    assert_equal(UnboundedRange::Once, One_a.repetition_length)
    assert_equal(One_a.repetition_length, 1..1)
    refute_nil(RegexpRepetition.new('.', 1, nil).repeated_pattern)
  end # initialize

  def test_RegexpRepetition_compare
    assert(nil.nil?)
    lhs = RegexpRepetition::TestCases::Dot_star
    rhs = RegexpRepetition::TestCases::Many
    refute_nil(RegexpRepetition.new('.', 1, nil).repeated_pattern)
    refute_nil(lhs.repeated_pattern)
    assert_instance_of(RegexpRepetition, lhs)
    assert_instance_of(RegexpRepetition, rhs)
    assert_kind_of(RegexpTree, lhs.repeated_pattern)
    assert_kind_of(RegexpTree, rhs.repeated_pattern)
    lhs_length = lhs.repetition_length
    rhs_length = rhs.repetition_length
    assert_equal(UnboundedFixnum::Inf, lhs_length.last)
    assert_equal(UnboundedFixnum::Inf, rhs_length.last)
    assert_equal(lhs_length.first, 0)
    assert_equal(rhs_length.first, 1, "rhs_length.first=#{rhs_length.first.inspect}")
    base_compare = lhs.repeated_pattern <=> rhs.repeated_pattern
    assert_operator(lhs.repetition_length.first, :<=, rhs.repetition_length.first, "lhs.repetition_length=#{lhs.repetition_length.inspect} rhs.repetition_length=#{rhs.repetition_length.inspect}")
    assert_operator(lhs.repetition_length.last, :>=, rhs.repetition_length.last, "lhs.repetition_length=#{lhs.repetition_length.inspect} rhs.repetition_length=#{rhs.repetition_length.inspect}")
    assert_operator(lhs.repetition_length, :>=, rhs.repetition_length, "lhs.repetition_length=#{lhs.repetition_length.inspect} rhs.repetition_length=#{rhs.repetition_length.inspect}")
    length_compare = lhs.repetition_length <=> rhs.repetition_length
    assert(base_compare.nonzero? || length_compare)
    assert_operator(lhs, :>, rhs)
    assert_equal(RegexpRepetition.new('.', 1, 3), RegexpRepetition.new('.', 1, 3))
    assert_operator(RegexpRepetition.new('.', 1, 4), :>, RegexpRepetition.new('.', 1, 3))
    assert_operator(RegexpRepetition.new('.', 0, 3), :>, RegexpRepetition.new('.', 1, 3))
    assert_operator(RegexpRepetition.new('.', 0, nil), :>, RegexpRepetition.new('.', 1, nil))
    assert_operator(RegexpRepetition.new('.', 1, nil), :>, RegexpRepetition.new('.', 1, 3))
    assert_operator(RegexpRepetition::TestCases::Any, :>, RegexpRepetition::TestCases::Many)
    assert_operator(RegexpRepetition::TestCases::Any, :>, RegexpRepetition::TestCases::Dot_star)
    assert_operator(RegexpRepetition::TestCases::Dot_star, :>, RegexpRepetition::TestCases::Many)
  end # compare

  def test_intersect
    assert_includes('&', RegexpRepetition.instance_methods(false))
    lhs = RegexpRepetition::TestCases::Any
    rhs = RegexpRepetition::TestCases::Many
    rhs = RegexpRepetition.promote(rhs)
    assert_equal(RegexpParse::TestCases::Any_binary_char_string, lhs.repeated_pattern.to_s)
    assert_equal(RegexpRepetition.new('.'), RegexpRepetition.new('.') & RegexpParse::TestCases::Any_binary_char_string)
    assert_equal(RegexpTree.new('.'), RegexpTree.new('.') & rhs.repeated_pattern)
    base = lhs.repeated_pattern & rhs.repeated_pattern
    length = lhs.repetition_length & rhs.repetition_length
    assert_equal(RegexpRepetition::TestCases::Many, RegexpRepetition.new(base, length))
    assert_equal(RegexpRepetition::TestCases::Many, RegexpRepetition::TestCases::Any.&(RegexpRepetition::TestCases::Many))
    assert_equal(UnboundedRange::Once, UnboundedRange::Once & RegexpRepetition::TestCases::Any)
  end # intersect

  def test_union
    assert_equal(UnboundedRange::Any_range, UnboundedRange::Any_range | UnboundedRange::Many_range)
  end # union / generalization
  One_to_ten = RegexpRepetition.new('.', 1, 10)
  def test_canonical_repetition_tree
    assert_equal(UnboundedRange::Repetition_1_2, RegexpRepetition.new('.', 1, 2).canonical_repetition_tree)
  end # canonical_repetition_tree

  def test_concise_repetition_node
    assert_equal('', RegexpRepetition.new('.', 1, 1).concise_repetition_node)
    assert_equal('+', RegexpRepetition.new('.', 1, nil).concise_repetition_node)
    assert_equal('?', RegexpRepetition.new('.', 0, 1).concise_repetition_node)
    assert_equal('*', RegexpRepetition.new('.', 0, nil).concise_repetition_node)
    assert_equal(UnboundedRange::Repetition_1_2, RegexpRepetition.new('.', 1, 2).concise_repetition_node)
    assert_equal(['{', ['1', ',', '2'], '}'], RegexpRepetition.new('.', 1, 2).concise_repetition_node)
    assert_equal(['{', ['2'], '}'], RegexpRepetition.new('.', 2, 2).concise_repetition_node)
  end # concise_repetition_node

  def test_probability_range
    assert_equal(1.0, RegexpRepetition::TestCases::Any.probability_of_repetition(1))
    refute_nil(RegexpRepetition::TestCases::Any.probability_of_repetition(1))
    assert_equal(1.0..1.0, Many.probability_range)
    assert_equal(0..1.0, RegexpRepetition::TestCases::Dot_star.probability_range)
    assert_equal(1.0 / 95..1.0 / 95, Asymmetrical_Tree.probability_range)

    assert_equal(1.0 / 95..1.0 / 95, No_anchor.probability_range)
    assert_equal(1.0 / 95..1.0 / 95, Start_anchor.probability_range)
    assert_equal(1.0 / 95..1.0 / 95, End_anchor.probability_range)
    assert_equal(1.0 / 95..1.0 / 95, Both_anchor.probability_range)
  end # probability_range

  def test_probability_of_repetition
    rhs = RegexpRepetition::TestCases::Any
    alternative_list = rhs.repeated_pattern.alternatives? # kludge for now
    refute_nil(alternative_list)
    alternatives = alternative_list.size
    assert_equal(256, alternatives)
    character_probability = alternatives / rhs.probability_space_size
    assert_equal(1.0, character_probability)
    length = 0
    assert_equal(0, length)
    assert_equal(1.0, rhs.probability_of_repetition(0))
    assert_equal(1.0, rhs.probability_of_repetition(1))
    assert_equal(1.0, rhs.probability_of_repetition(nil))
    # 0 repetitions always match
    assert_equal(1.0, No_anchor.probability_of_repetition(1))
    assert_equal(1.0, Start_anchor.probability_of_repetition(1))
    assert_equal(1.0, End_anchor.probability_of_repetition(1))
    assert_equal(1.0, Both_anchor.probability_of_repetition(1))
    # 1
    assert_equal(1.0 / 95, No_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, Start_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, End_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, Both_anchor.probability_of_repetition(1))
    # 2
    assert_equal(1.0 / 95, No_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, Start_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, End_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, Both_anchor.probability_of_repetition(1))
    # nil , unanchored always matches
    assert_equal(1.0, No_anchor.probability_of_repetition(1))
    assert_equal(1.0, Start_anchor.probability_of_repetition(1))
    assert_equal(1.0, End_anchor.probability_of_repetition(1))
    assert_equal(1.0 / 95, Both_anchor.probability_of_repetition(1))
  end # probability_of_repetition

  def test_merge_to_repetition
    # first line by line test case
    side = ['a']
    branch = RegexpTree.new([side, side])
    first = branch[0]
    second = branch[1]
    assert_equal(first, second)
    first_repetition = first.repetition_length
    second_repetition = second.repetition_length
    merged_repetition = (first_repetition + second_repetition).concise_repetition_node
    assert_equal(['{', ['2'], '}'], merged_repetition)
    assert_equal(['a'], first.repeated_pattern)
    assert_equal([2, 2], [first_repetition.begin + second_repetition.begin, first_repetition.end + second_repetition.end])
    assert_instance_of(RegexpTree, first.repeated_pattern)
    branch.merge_to_repetition(first.repeated_pattern << merged_repetition + branch[2..-1])
    assert_equal(['a', ['{', ['2'], '}']], branch.merge_to_repetition)
    # second line by line test case
    branch = RegexpTree.new('a?a')
    assert_instance_of(RegexpTree, branch)
    assert_equal([['a', '?'], 'a'], branch)
    first = branch[0]
    second = branch[1]
    assert_instance_of(RegexpTree, first)
    assert_instance_of(String, second)
    assert_equal(['a'], branch.repeated_pattern(first))
    assert_equal(['a'], branch.repeated_pattern(second))
    first_repetition = first.repetition_length
    second_repetition = branch.repetition_length(second)
    assert_equal([1, 2], [first_repetition.begin + second_repetition.begin, first_repetition.end + second_repetition.end])
    assert_equal(['a'], branch.repeated_pattern(first))
    assert_equal(['a'], branch.repeated_pattern(second))
    merged_repetition = (first_repetition + second_repetition).concise_repetition_node
    assert_equal(['{', ['1', ',', '2'], '}'], merged_repetition)
    assert_equal([], branch[2..-1])
    merged_pattern = ['a', ['{', ['1', ',', '2'], '}']]
    assert_equal(merged_pattern, first.repeated_pattern << merged_repetition)
    assert_equal(merged_pattern, branch.merge_to_repetition(first.repeated_pattern << merged_repetition + branch[2..-1]))
    assert_equal(merged_pattern, branch.merge_to_repetition)
  end # merge_to_repetition
end # RegexpTreeTest

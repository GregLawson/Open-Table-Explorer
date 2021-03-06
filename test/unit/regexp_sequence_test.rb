###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# require_relative '../assertions/generic_table_examples.rb'
require_relative '../../app/models/regexp_sequence.rb'
class RegexpTree < NestedArray # reopen class to add assertions
  # include RegexpTreeAssertions
  # extend RegexpTreeAssertions::ClassMethods
end # RegexpTree
class RegexpSequenceTest < TestCase
  def test_Anchoring_initialize
    No_anchor.assert_anchoring
    Start_anchor.assert_anchoring
    End_anchor.assert_anchoring
    Both_anchor.assert_anchoring
    #	assert_equal(Anchor_root_test_case, Anchoring.new(No_anchor))
    assert_equal(No_anchor, Anchoring.new(No_anchor)[:base_regexp])
    assert_equal(No_anchor, Anchoring.new(Start_anchor)[:base_regexp])
    assert_equal(No_anchor, Anchoring.new(End_anchor)[:base_regexp])
    assert_equal(No_anchor, Anchoring.new(Both_anchor)[:base_regexp])
    assert_equal(Anchoring::Start_anchor_regexp, Anchoring.new(Start_anchor)[:start_anchor])
    assert_nil(Anchoring.new(No_anchor)[:start_anchor])
    assert_nil(Anchoring.new(Start_anchor)[:end_anchor])
    assert_equal(Anchoring::End_anchor_regexp, Anchoring.new(End_anchor)[:end_anchor])
  end # initialize

  def test_compare_anchor
    assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
    assert_operator(Anchoring.new(Start_anchor), :>, Anchoring.new(Both_anchor))
    assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(End_anchor))
    assert_operator(Anchoring.new(End_anchor), :>, Anchoring.new(Both_anchor))
    assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Both_anchor))
    assert_nil(Anchoring.new(Start_anchor) <=> Anchoring.new(End_anchor))
  end # compare_anchor

  def test_probability_of_sequence
    branch = No_anchor
    assert_equal(0, 1 / 95)
    refute_equal(0, 1.0 / 95)

    assert_equal(1.0 / 95, No_anchor.probability_of_sequence)
    assert_equal((1.0 / 95)**3, Asymmetrical_Tree.probability_of_sequence)
    refute_equal((1.0 / 95), Asymmetrical_Tree.probability_of_sequence)
    assert_equal(1.0 / 95, Start_anchor.probability_of_sequence)
    assert_equal(1.0 / 95, End_anchor.probability_of_sequence)
    assert_equal(1.0 / 95, Both_anchor.probability_of_sequence)
  end # probability_of_sequence

  def test_initialize
    refute_nil(@@CONSTANT_PARSE_TREE.regexp_string)
    assert_equal(['K'], @@CONSTANT_PARSE_TREE.to_a)
    assert_equal('K', @@CONSTANT_PARSE_TREE.regexp_string)

    assert_equal(['K'], RegexpSequence.new('K').to_a)
    assert_equal([%w(1 2), '3'], Asymmetrical_Tree.to_a)
    assert_equal(Sequence, Asymmetrical_Tree_Array.flatten)
    refute_nil(RegexpSequence.new(['.']))
    refute_nil(RegexpSequence.new('.'))
    refute_nil(RegexpSequence.new(/./))
  end # initialize

  def test_compare_anchors
    assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
    No_anchor.assert_anchors_specialized_by(Start_anchor)
    RegexpSequence.new('a').assert_anchors_specialized_by('^a')
    assert_equal(1, No_anchor.compare_anchors?(Start_anchor))
  end # compare_anchors

  def test_sequence_comparison
    assert_equal(1, RegexpSequence.new('ab').compare_sequence?(RegexpSequence.new('abc')))
    RegexpSequence.new('ab').assert_sequence_specialized_by(RegexpSequence.new('abc'))
    RegexpSequence.new('ab').assert_sequence_specialized_by(RegexpSequence.new('abc'))
  end # sequence_comparison

  def test_sequence_intersect
    #	alternatives=Ab.alternatives?
    lhs = Ab
    rhs = A
    assert_nil(lhs.alternatives?)
    assert_empty(lhs.alternatives?)
    refute_nil(rhs.alternatives?)
    refute_empty(rhs.alternatives?)
    assert_instance_of(String, rhs[0])
    assert_nil(lhs.alternatives?)
    #	assert_includes(rhs[0], lhs.alternatives?)
    assert_equal(rhs, lhs.sequence_intersect(A))
    assert_equal(B, Ab.sequence_intersect(B))
  end # sequence_intersect

  def test_RegexpTree_to_a
    assert_equal(Asymmetrical_Tree_Array, Asymmetrical_Tree.to_a)
  end # to_a
end # RegexpTreeTest

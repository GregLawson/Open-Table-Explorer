###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
#require 'test/test_helper_test_tables.rb'
require_relative '../../app/models/regexp_sequence.rb'
class RegexpTree < NestedArray # reopen class to add assertions
#include RegexpTreeAssertions
#extend RegexpTreeAssertions::ClassMethods
end #RegexpTree
class RegexpSequenceTest < TestCase
include RegexpSequence::Examples
include RegexpSequence::Assertions
# How about anchoring as special Regexp Constants at start and end of sequence
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
end #initialize
def test_compare_anchor
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
	assert_operator(Anchoring.new(Start_anchor), :>, Anchoring.new(Both_anchor))
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(End_anchor))
	assert_operator(Anchoring.new(End_anchor), :>, Anchoring.new(Both_anchor))
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Both_anchor))
	assert_nil(Anchoring.new(Start_anchor) <=> Anchoring.new(End_anchor))
end #compare_anchor

def test_probability_of_sequence
	branch=No_anchor
	assert_equal(0, 1/95)
	assert_not_equal(0, 1.0/95)
	
	assert_equal(1.0/95, No_anchor.probability_of_sequence)
	assert_equal((1.0/95)**3, Asymmetrical_Tree.probability_of_sequence)
	assert_not_equal((1.0/95), Asymmetrical_Tree.probability_of_sequence)
	assert_equal(1.0/95, Start_anchor.probability_of_sequence)
	assert_equal(1.0/95, End_anchor.probability_of_sequence)
	assert_equal(1.0/95, Both_anchor.probability_of_sequence)
end #probability_of_sequence
def test_initialize
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp_string)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp_string)

	assert_equal(['K'], RegexpSequence.new('K').to_a)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal(Sequence, Asymmetrical_Tree_Array.flatten)
	assert_not_nil(RegexpSequence.new(['.']))
	assert_not_nil(RegexpSequence.new('.'))
	assert_not_nil(RegexpSequence.new(/./))
end #initialize
def test_compare_anchors
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
	No_anchor.assert_anchors_specialized_by(Start_anchor)
	RegexpSequence.new('a').assert_anchors_specialized_by('^a')
	assert_equal(1, No_anchor.compare_anchors?(Start_anchor))
end #compare_anchors
def test_sequence_comparison
	assert_equal(1, RegexpSequence.new('ab').compare_sequence?(RegexpSequence.new('abc')))
	RegexpSequence.new('ab').assert_sequence_specialized_by(RegexpSequence.new('abc'))	
	RegexpSequence.new('ab').assert_sequence_specialized_by(RegexpSequence.new('abc'))	
end #sequence_comparison
A=RegexpTree.new('a')
B=RegexpTree.new('b')
Ab=RegexpTree.new('ab')
def test_sequence_intersect
#	alternatives=Ab.alternatives?
	lhs=Ab
	rhs=A
	assert_nil(lhs.alternatives?)
	assert_empty(lhs.alternatives?)
	assert_not_nil(rhs.alternatives?)
	assert_not_empty(rhs.alternatives?)
	assert_instance_of(String, rhs[0])
	assert_nil(lhs.alternatives?)
#	assert_include(rhs[0], lhs.alternatives?)
	assert_equal(rhs, lhs.sequence_intersect(A))
	assert_equal(B, Ab.sequence_intersect(B))
end #sequence_intersect
def test_RegexpTree_to_a
	assert_equal(Asymmetrical_Tree_Array, Asymmetrical_Tree.to_a)

end #to_a
end #RegexpTreeTest

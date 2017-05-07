###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

require_relative '../../app/models/regexp_tree.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
class RegexpTree
  # require_relative '../assertions/default_assertions.rb'
  module Assertions
    # Assertions (validations)
    include Test::Unit::Assertions
    # require 'rails/test_help'
    module ClassMethods
      def assert_pre_conditions
        assert_equal(Object, superclass)
      end # assert_pre_conditions

      def def(_assert_post_conditions)
        assert_includes(instance_methods, :[])
        assert_includes(instance_methods, :+)
        assert_includes(instance_methods, :|)
        assert_includes(instance_methods, :*)
      end # assert_post_conditions
    end # ClassMethods
    def assert_anchoring
      anchoring = Anchoring.new(self)
      #	explain_assert_respond_to(anchoring, :default_message)
      #	explain_assert_respond_to(Test::Unit::Assertions, :default_message)
      #	message=anchoring.default_message
      message = ''
      assert_includes(anchoring.start_base, [0, 1])
      assert_includes(anchoring.end_base, [-1, -2])
      refute_empty(self[0..-1])
      refute_empty(self[anchoring.start_base..anchoring.end_base])
      refute_empty(anchoring[:base_regexp], message)
      assert_equal([anchoring[:start_anchor], anchoring[:base_regexp], anchoring[:end_anchor]].compact.to_s, to_s, message)
    end # anchor

    def assert_specialized_repetitions(other)
      unless other.is_a?(RegexpTree)
        other = RegexpTree.new(other)
      end # if
      assert_kind_of(RegexpTree, self)
      assert_kind_of(RegexpTree, other)
      message = "In assert_specialized_repetitions, self=#{inspect} is not more specialized than (other=#{other.inspect})"
      my_repeated_pattern = repeated_pattern
      other_repeated_pattern = other.repeated_pattern
      assert_equal(my_repeated_pattern, other_repeated_pattern)
      my_repetition_length = repetition_length
      other_repetition_length = other.repetition_length
      refute_nil(my_repetition_length)
      refute_nil(other_repetition_length)
      refute_nil(my_repetition_length[:min])
      refute_nil(other_repetition_length[:min])
      refute_equal(my_repetition_length, other_repetition_length)
      assert_operator(my_repetition_length[:min], :<=, other_repetition_length[:max])
      unless my_repetition_length[:max].nil?
        if other_repetition_length[:max].nil?
          raise message
        else
          assert(my_repetition_length[:max] >= other_repetition_length[:max])
        end # if
      end # if
    end # compare_repetitions

    def assert_specialized_character_class(specialized)
      unless specialized.is_a?(RegexpTree)
        specialized = RegexpTree.new(specialized)
      end # if
      assert_kind_of(RegexpTree, self)
      assert_kind_of(RegexpTree, specialized)
      message = "In self=#{inspect}assert_specialized_by(specialized=#{specialized.inspect})"
      my_cc = character_class?
      refute_nil(my_cc)
      my_chars = my_cc[1..-2]
      specialized_cc = specialized.character_class?
      refute_nil(specialized_cc)
      specialized_chars = specialized_cc[1..-2]
      intersection = my_chars & specialized_chars
      assert_equal(intersection, specialized_chars)
    end # compare_character_class

    def assert_anchors_specialized_by(other)
      other = RegexpTree.canonical_regexp_tree(other)
      assert_operator(Anchoring.new(self), :>, Anchoring.new(other))
    end # compare_anchors

    def assert_sequence_specialized_by(other)
      assert_kind_of(Array, self)
      assert_kind_of(Array, other)
      each_with_index do |node, i|
        next unless i - 1 <= other.length
        comparison = node <=> other[i]
        refute_nil(comparison, "comparison of #{node.inspect} to #{other[i]} should not be nil.")
        assert_operator(comparison, :>=, 0)
        # if
      end # each
      assert_equal(1, compare_sequence?(other))
    end # sequence_comparison

    def assert_specialized_by(specialized)
      unless specialized.is_a?(RegexpTree)
        specialized = RegexpTree.new(specialized)
      end # if
      assert_kind_of(RegexpTree, self)
      assert_kind_of(RegexpTree, specialized)
      message = "In self=#{inspect}assert_specialized_by(specialized=#{specialized.inspect})"
      my_cc = character_class?
      specialized_cc = specialized.character_class?
      if !my_cc.nil? && !specialized_cc.nil?
        assert_specialized_character_class(specialized_cc)
      end # if
      message = "In self=#{inspect}assert_specialized_by(specialized=#{specialized.inspect})"
      my_cc = character_class?
      specialized_cc = specialized.character_class?
      if !my_cc.nil? && !specialized_cc.nil?
        assert_specialized_character_class(specialized_cc)
      end # if
      my_repeated_pattern = repeated_pattern
      specialized_repeated_pattern = specialized.repeated_pattern
      if my_repeated_pattern == specialized_repeated_pattern
        assert_specialized_repetitions(other)
      end # if
      comparison = self <=> specialized
      assert_equal(1, comparison)
      assert_operator(self, :>, specialized, message)
    end # <=>
  end # Assertions
end # RegexpTree

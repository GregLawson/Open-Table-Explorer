###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
require_relative 'nested_array.rb'
require_relative 'regexp_parse.rb'
# require_relative 'regexp_alternative.rb'
# require_relative 'regexp_sequence.rb'
class RegexpTree < NestedArray
  include Comparable
  # raise "" unless self.constants.include?('Default_options')
  # Parse regexp_string into parse tree for editing
  module ClassMethods
    def promote(node)
      if node.is_a?(RegexpTree) # nested Arrays
        node
      elsif node.is_a?(Array) # nested Arrays
        RegexpTree.new(node)

      elsif node.instance_of?(String)
        RegexpTree.new(RegexpParse.new(node).to_a)
      elsif node.instance_of?(RegexpParse)
        RegexpTree.new(node.to_a)
      elsif node.instance_of?(Regexp)
        RegexpTree.new(RegexpParse.new(node.source).to_a)
      else
        raise "unexpected node=#{node.inspect}"
      end # if
    end # promote
  end # ClassMethods
  extend ClassMethods
  def initialize(regexp = [], probability_space_regexp = '[[:print:]]+', options = RegexpParse::Default_options)
    if regexp.is_a?(Array) # nested Arrays
      super(regexp)

    elsif regexp.instance_of?(String)
      super(RegexpParse.new(regexp).to_a)
    elsif regexp.instance_of?(RegexpParse)
      super(regexp.to_a)
    elsif regexp.instance_of?(Regexp)
      super()
      super(RegexpParse.new(regexp.source).to_a)
    else
      raise "unexpected regexp=#{regexp.inspect}"
    end # if
    @probability_space_regexp = probability_space_regexp
    @errors = [RegexpParse.regexp_error(regexp.to_s, options)]
    #	@anchor=Anchoring.new(self) infinite recursion
  end # initialize

  def self.canonical_regexp(regexp)
    if regexp.instance_of?(String)
      regexp = Regexp.regexp_rescued(regexp)
    elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch)
      regexp = RegexpParse.regexp_rescued(regexp.to_s)
    elsif regexp.nil?
      return //
    elsif !regexp.instance_of?(Regexp)
      raise "Unexpected regexp.class=#{regexp.class}."
    end # if
    regexp
  end # canonical_regexp

  def self.canonical_regexp_tree(regexp)
    if regexp.instance_of?(String)
      regexp = RegexpTree.new(regexp)
    elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch)
      regexp = RegexpTree.new(regexp.to_s)
    elsif regexp.nil?
      return //
    elsif !regexp.instance_of?(Regexp)
      raise "Unexpected regexp.class=#{regexp.class.inspect}."
    end # if
    regexp
  end # canonical_regexp_tree

  # include Inline_Assertions
  def probability_space_regexp
    RegexpTree.new(@probability_space_regexp)
  end # probability_space_regexp

  def probability_space_size
    probability_space_regexp.repeated_pattern.string_of_matching_chars.size
  end # probability_space_size

  def compare_repetitions?(other)
    return nil if other.instance_of?(String)
    my_repeated_pattern = repeated_pattern
    other_repeated_pattern = other.repeated_pattern
    if my_repeated_pattern != other_repeated_pattern
      return nil #
    else
      my_repetition_length = repetition_length
      other_repetition_length = other.repetition_length
      if my_repetition_length == other_repetition_length
        return 0
      elsif my_repetition_length.begin <= other_repetition_length.begin
        if my_repetition_length.end.nil?
        elsif my_repetition_length.end >= other_repetition_length.end
          return 1
        end # if
      elsif my_repetition_length.end <= other_repetition_length.end && my_repetition_length.begin >= other_repetition_length.begin
        return -1
      else
        return nil
      end # if
    end # if
  end # compare_repetitions

  # intersetion should be interpreted as
  # the intersection of the Languages (sets of possible matches)
  # that can be matched by each regexp
  # I == L & R
  # then L >= I && R >= I
  # if no intersetion: I==[]
  # then L >= [] and R >= []
  def &(rhs)
    repetition_length = self.repetition_length & rhs.repetition_length
    repetition_node = repetition_length.concise_repetition_node(repetition_length.begin, repetition_length.end)
    RegexpTree.new([repeated_pattern.sequence_intersect(rhs.repeated_pattern), repetition_node])
  end # intersection

  def <=>(other)
    anchor_comparison = compare_anchors?(other)
    if to_s == other.to_s # avoid recursion
      return 0
    else
      cc_comparison = compare_character_class?(other)
      if !cc_comparison.nil?
        return cc_comparison
      else
        repetition_comparison = compare_repetitions?(other)
        unless repetition_comparison.nil?
          return repetition_comparison
        end # if
        sequence_comparison = compare_sequence?(other)
        if !sequence_comparison.nil?
          return sequence_comparison
        else
          return nil
        end # if
      end # if
    end # if
  end # <=>

  def +(other)
    RegexpTree.new(to_a + other.to_a)
  end #+

  def to_a
    NestedArray.new(self)
  end # to_a

  # file name glob (suitible for Dir[]) most like regexp.
  # often matches more filenames than regexp (see pathnames)
  def to_s
    to_a.join
  end # to_s

  def to_regexp(options = RegexpParse::Default_options)
    regexp_string = to_s
    regexp = RegexpParse.regexp_rescued(regexp_string, options)

    regexp
  end # to_regexp
  Ascii_characters = (0..127).to_a.map(&:chr)
  Binary_bytes = (0..255).to_a.map(&:chr)
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    def assert_pre_conditions
      assert_kind_of(NestedArray, self)
    end # assert_pre_conditions
  end # Assertions
  require_relative '../../test/assertions/default_assertions.rb'
  include DefaultAssertions
  extend DefaultAssertions::ClassMethods
end # RegexpTree

###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
class RegexpTree < NestedArray # declare class
end # RegexpTree reopen later
class RegexpAlternative < RegexpTree
  include Comparable
  # Parse regexp_string into parse tree for editing
  def initialize(regexp = [], probability_space_regexp = '[[:print:]]+', _options = Default_options)
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
    #	@anchor=Anchoring.new(self) infinite recursion
  end # initialize

  def self.promote(node)
    if node.is_a?(RegexpTree) # nested Arrays
      node
    elsif node.is_a?(Array) # nested Arrays
      RegexpAlternative.new(node)

    elsif node.instance_of?(String)
      RegexpAlternative.new(RegexpParse.new(node).to_a)
    elsif node.instance_of?(RegexpParse)
      RegexpAlternative.new(node.to_a)
    elsif node.instance_of?(Regexp)
      RegexpAlternative.new(RegexpParse.new(node.source).to_a)
    else
      raise "unexpected node=#{node.inspect}"
    end # if
  end # RegexpAlternative.promote

  def self.canonical_regexp(regexp)
    if regexp.instance_of?(String)
      regexp = RegexpAlternative.regexp_rescued(regexp)
    elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpTree) || regexp.instance_of?(RegexpMatch)
      regexp = RegexpTree.regexp_rescued(regexp.to_s)
    elsif regexp.nil?
      return //
    elsif !regexp.instance_of?(Regexp)
      raise "Unexpected regexp.class=#{regexp.class}."
    end # if
    regexp
  end # canonical_regexp

  def self.canonical_regexp_tree(regexp)
    if regexp.instance_of?(String)
      regexp = RegexpAlternative.new(regexp)
    elsif regexp.instance_of?(Array) || regexp.instance_of?(RegexpAlternative) || regexp.instance_of?(RegexpMatch)
      regexp = RegexpAlternative.new(regexp.to_s)
    elsif regexp.nil?
      return //
    elsif !regexp.instance_of?(Regexp)
      raise "Unexpected regexp.class=#{regexp.class.inspect}."
    end # if
    regexp
  end # canonical_regexp_tree

  def probability_of_alternatives(branch = self)
    if branch.instance_of?(String)
      return 1.0 / probability_space_size
    end # if
    bulk_length = branch.reduce(0) { |sum, e| sum + e.size }
    if bulk_length == branch.size # character class
      branch.size / probability_space_size
    elsif branch.size == 2 # recursion termination
      intersection = branch[0] & branch[1]
      (branch[0].size + branch[1].size - intersection.size) / probability_space_size
    elsif branch.size == 1 # recursion termination
      branch[0].size / probability_space_size

      # alternatives

    end # if
  end # probability_of_alternatives

  def compare_character_class?(other)
    return nil if other.instance_of?(String)
    my_cc = character_class?
    return nil if my_cc.nil?
    my_chars = my_cc
    other_cc = other.character_class?
    return nil if other_cc.nil?
    other_chars = other_cc
    intersection = my_chars & other_chars
    if my_chars.to_s == other_chars.to_s
      return 0
    elsif intersection == my_chars
      return -1
    elsif intersection == other_chars
      return 1
    else
      return nil
    end # if
  end # compare_character_class

  # inputs are RegexpTree
  # pass only alternatives not sequences or repetitions
  # return alternative Array not RegexpTree
  def alternatives_intersect(rhs)
    lhs_alternatives = alternatives?
    rhs_alternatives = rhs.alternatives?
    alternatives = lhs_alternatives & rhs_alternatives
    alternatives
  end # alternatives_intersect

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

  # Returns flattened(?) Array of alternatives
  # flattening removes the tree structure of the | operator
  # since | (choice like addition) is associative and transitive
  # Does not change distribution of sequence over choice
  # as that could lead to combinoric explosion
  # Or nil if no alternatives
  # If passed a non-array recursion terminates and branch is returned.
  # Converts character classes to alternatives
  def alternatives?(branch = self)
    if branch.is_a?(String)
      [branch]
    elsif !branch.is_a?(Array)
      nil # no alternatives possible
    else
      cc_comparison = branch.character_class?
      if cc_comparison
        cc_comparison
      elsif branch[0].size == 2 && branch[0][-1] == '|'
        lhs = branch[0][0]
        rhs = alternatives?(branch[1..-1])
        if rhs.nil?
          [lhs]
        else
          ([lhs] + rhs).sort
        end # if
      else
        if branch.instance_of?(String) && branch.length == 1
          branch # # terminate recursion with last alternative
        end # if
      end # if
    end # if
  end # alternatives

  # is RegexpTree a character class?
  # compatible with alternatives? and string_of_matching_chars
  def character_class?(branch = self)
    if branch.is_a?(Array) && branch[0] == '[' && branch[-1] == ']'
      return branch.string_of_matching_chars
    elsif branch.is_a?(Array)  && branch.size == 1 && branch[0].instance_of?(String) && branch[0].size == 1
      return branch.string_of_matching_chars(branch) # single character
    elsif branch.is_a?(String) && branch.length == 1
      return branch.string_of_matching_chars(branch) # single character
    else
      return nil
    end # if
  end # character_class

  def to_s
    to_a.join
  end # to_s
  Ascii_characters = (0..127).to_a.map(&:chr)
  Binary_bytes = (0..255).to_a.map(&:chr)
  # y caller
  #
  def string_of_matching_chars(regexp = self)
    char_array = Binary_bytes.select do |char|
      if RegexpMatch.match_data?(regexp, char)
        char
      end # if
    end # select

    char_array
  end # string_of_matching_chars
end # RegexpTree

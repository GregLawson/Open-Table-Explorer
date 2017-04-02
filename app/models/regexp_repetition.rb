###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class RegexpRepetition < RegexpTree
  include Comparable
  attr_reader :repeated_pattern, :repetition_length
  # RegexpRepetition.new(RegexpTree)
  # RegexpRepetition.new(RegexpTree, UnboundedRange)
  # RegexpRepetition.new(RegexpTree, min, max)
  # Ambiguity of nil for third prameter: missing or infinity?
  # Resolved by checking second parameter for numric or Range to resolve ambiguity
  def initialize(branch, min = nil, max = nil, _probability_space_regexp = '[[:print:]]+', _options = Default_options)
    if branch.instance_of?(RegexpParse)
      @repeated_pattern = branch.repeated_pattern
      @repetition_length = branch.repetition_length
    else
      branch = RegexpRepetition.promote(branch)
    end # if
    if !max.nil? # all arguments provided
      @repetition_length = UnboundedRange.new(min, max)
      raise 'min must not be nil.' if min.nil?
    elsif !min.nil? # only one length argument
      if min.is_a?(Range)
        @repetition_length = min
      else # third parameter specified as nil/infinity
        @repetition_length = UnboundedRange.new(min, max)
        raise 'min must not be nil.' if min.nil?
      end # if
    else # implicit length
      @repetition_length = branch.repetition_length
    end # if
  end # initialize
  class TestCases
    Any = RegexpRepetition.new(RegexpParse::TestCases::Any_binary_char, 0, UnboundedFixnum::Inf, RegexpParse::TestCases::Any_binary_string)
    Many = RegexpRepetition.new(RegexpParse::TestCases::Any_binary_char, 1, UnboundedFixnum::Inf, '.+')
    Dot_star = RegexpRepetition.new(['.'], 0, UnboundedFixnum::Inf, RegexpParse::TestCases::Any_binary_string)
    One_to_ten = RegexpRepetition.new('.', 1, 10)
    One_a = RegexpRepetition.new('a', UnboundedRange::Once)
    Any_length = Any.repetition_length
    Many_length = Many.repetition_length
    Quantified_repetition = RegexpTree.new(['.', ['{', '3', ',', '4', '}']])
  end # TestCases

  def <=>(rhs)
    lhs = self
    base_compare = lhs.repeated_pattern <=> rhs.repeated_pattern
    length_compare = lhs.repetition_length <=> rhs.repetition_length
    base_compare.nonzero? || length_compare
  end # compare

  # intersection. If neither is a subset of the rhs return nil
  def &(rhs)
    lhs = self
    rhs = RegexpRepetition.promote(rhs)
    base = lhs.repeated_pattern & rhs.repeated_pattern
    length = lhs.repetition_length & rhs.repetition_length
    RegexpRepetition.new(base, length)
  end # intersect

  # Union. Unlike set union disjoint sets return a spanning set.
  def |(rhs)
    lhs = self
    base = lhs.repeated_pattern | rhs.repeated_pattern
    length = lhs.repetition_length | rhs.repetition_length
    RegexpRepetition.new(base, length)
  end # union / generalization

  # the useful inverse function of new. String to regexp
  def canonical_repetition_tree(min = repetition_length.begin, max = repetition_length.end)
    RegexpTree.new(['{', [min.to_s, ',', max.to_s], '}'])
  end # canonical_repetition_tree

  # Return a RegexpTree node for self
  # Concise means to use abbreviations like '*', '+', ''
  # rather than the canonical {n,m}
  # If no repetition returns '' equivalent to {1,1}
  def concise_repetition_node(min = repetition_length.begin, max = repetition_length.end)
    if min.to_i == 0
      if max.to_i == 1
        return '?'
      elsif max == UnboundedFixnum::Inf
        return '*'
      else
        return canonical_repetition_tree(min, max)
      end # if
    elsif min.to_i == 1
      if max == 1
        return ''
      elsif max == UnboundedFixnum::Inf
        return '+'
      else
        return canonical_repetition_tree(min, max)
      end # if
    elsif min == max
      return RegexpTree.new(['{', [min.to_i.to_s], '}'])
    else
      return canonical_repetition_tree(min, max)
    end # if
    RegexpTree.new(['{', [min.to_s, max.to_s], '}'])
  end # concise_repetition_node

  # Probability range depending on matched length
  def probability_range(node = self)
    range = if node.instance_of?(String)
              node.size..node.size
            else
              node.repetition_length
            end # if
    probability_of_repetition(range.begin)..probability_of_repetition(range.end)
  end # probability_range

  # Probability for a single matched repetitions of an alternative (single character)
  # Here the probability distribution is
  # assumed uniform across the probability space
  # ranges from zero for an impossible match (usually avoided)
  # to 1 for certain match like /.*/ (actually RegexpRepetition::TestCases::Any is more accurate)
  # returns nil if indeterminate (e.g. nested repetitions)
  # (call probability_range or RegexpMatch#probability instead)
  # match_length (of random characters) is useful in unanchored cases
  # match_length.nil?
  # probability (.p) of length n
  # I == L & R
  # then L >= I && R >= I
  # and L.p(n) >= I.p(n) && R.p(n) >= I.p(n)
  def probability_of_repetition(repetition, _match_length = nil, branch = self)
    if branch.instance_of?(String)
      alternatives = 1
      base = branch
      repetition_length = branch.repetition_length
      anchoring = Anchoring.new(branch)
    else
      repetition_length = branch.repetition_length
      base = branch.repeated_pattern
      anchoring = Anchoring.new(branch)
      alternative_list = alternatives?(branch.repeated_pattern) # kludge for now
      if alternative_list.nil?
        return nil
      else
        alternatives = alternative_list.size
      end # if
    end # if
    character_probability = alternatives.to_f / probability_space_size
    if repetition == 0
      probability = 1.0
    elsif repetition.nil? # infinit repetition
      probability = if character_probability == 1.0
                      1.0
                    else
                      0.0
                    end # if
    else
      probability = character_probability**repetition
    end # if
    raise "probability_space_regexp=#{probability_space_regexp} is probably too restrictive for branch=#{branch.inspect}" if probability > 1.0
    probability
  end # probability_of_repetition

  # recursive merging of consecutive identical pairs
  def merge_to_repetition(branch = self)
    if branch.instance_of?(Array)
      branch = RegexpTree.new(branch)
    end # if
    if branch.size < 2 # terminate recursion
      return branch
    else
      # puts "branch=#{branch}"
      first = branch[0]
      second = branch[1]
      if branch.repeated_pattern(first) == branch.repeated_pattern(second)
        first_repetition = first.repetition_length
        second_repetition = branch.repetition_length(second)
        merged_repetition = (first_repetition + second_repetition).concise_repetition_node
        merge_to_repetition(first.repeated_pattern << merged_repetition + branch[2..-1])
      else # couldn't merge first element
        [first] + merge_to_repetition(branch[1..-1])	# shorten string to ensure recursion termination
      end # if
    end # if
  end # merge_to_repetition
end # RegexpRepetition

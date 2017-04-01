###########################################################################
#    Copyright (C) 2010-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/regexp_parse_assertions.rb'
class RegexpParseTypeAssertionsTest < TestCase
  include RegexpParseType::Examples
  extend RegexpParseType::Examples::ClassMethods
  # include DefaultAssertionTests
  # include DefaultAssertionTests::ClassMethods
  def test_class_assert_invariant
    regexp_string = 'K.*C'
    test_tree = RegexpParseType.new(regexp_string)
    refute_nil(test_tree.parse_tree)
    refute_nil(RegexpParseType.new(''))
    assert_equal('', RegexpParseType.new(test_tree.rest).to_s)
    assert_equal(['K', ['.', '*'], 'C'], test_tree.parse_tree)
    refute_nil(RegexpParseType.new(['K', ['.', '*'], 'C'].to_s))
    refute_nil(RegexpParseType.new(test_tree.parse_tree.to_s))
    refute_nil(test_tree.rest.to_s + test_tree.parse_tree.to_s)
    assert_equal(test_tree.regexp_string, test_tree.rest.to_s + test_tree.parse_tree.to_s)
    assert_equal(test_tree.regexp_string, test_tree.rest + test_tree.parse_tree.to_s)
    test_tree.assert_invariant
  end # assert_class_invariant_conditions

  def test_assert_pre_conditions
    parser = RegexpParseType::Examples::Sequence_parse
    parser.restartParse!
    parser.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_repetition_range
    RegexpParseType.new(RegexpParseType::Examples::Empty_language_string).assert_repetition_range(UnboundedRange.new(0, 0))
    assert_equal(UnboundedRange::Once, RegexpParseType.new('a').repetition_length)
  end # assert_repetition_range

  def test_assert_round_trip
    RegexpParseType.assert_round_trip(RegexpParseType::Examples::Dot_star_array)
    RegexpParseType.assert_round_trip(RegexpParseType::Examples::Parenthesized_array)
  end # assert_round_trip

  def test_value_of
    name = :Parenthesized
    suffix = :_string
    assert_nil(RegexpParseType.full_name?(:Parenthesized))
    full_name = RegexpParseType.full_name?(name, suffix)
    refute_nil(RegexpParseType::Examples.const_get(name.to_sym))
    assert_nil(RegexpParseType::Examples.const_get(full_name.to_sym))
    assert_equal(RegexpParseType::Examples::Parenthesized_string, RegexpParseType.value_of?(name, suffix))
  end # value_of

  def test_path_array
    name = :Parenthesized
    suffix = :_string
    assert_equal([:RegexpParseType, :Examples, (name.to_s + suffix.to_s).to_sym], RegexpParseType.path_array?(name, suffix))
  end # path_array

  def test_full_name
    name = :Parenthesized
    suffix = :_string
    full_name = 'RegexpParseType::Examples::' + name.to_s + suffix.to_s
    assert_equal('RegexpParseType::Examples::Parenthesized_string', RegexpParseType.full_name?(name, suffix))
    ret = begin
      eval(full_name.to_s)
      full_name
    rescue
      nil
    end # begin
    assert_equal(ret, RegexpParseType.full_name?(name, suffix))
    suffix = ''
    full_name = 'RegexpParseType::Examples::' + name.to_s + suffix.to_s
    ret = begin
      eval(full_name.to_s)
      full_name
    rescue
      nil
    end # begin
    assert_nil(ret)
    assert_equal(ret, RegexpParseType.full_name?(name, ''))
    assert_nil(RegexpParseType.full_name?(:Parenthesized))
  end # full_name

  def test_parse_of
    string = RegexpParseType::Examples::Parenthesized_string
    assert_equal(RegexpParseType::Examples::Parenthesized_parse, RegexpParseType.parse_of?('Parenthesized'))
  end # parse_of

  def test_string_of
    name = :Parenthesized
    suffix = :_string
    array = RegexpParseType::Examples::Parenthesized_array
    assert_equal(RegexpParseType::Examples::Parenthesized_parse, RegexpParseType.string_of?('Parenthesized'))
  end # string_of

  def test_array_of
    string = RegexpParseType::Examples::Parenthesized_string
  end # array_of

  def test_name_of
    constant = 'Parenthesized_parse'
    match = /([A-Z][a-z_]*)_(array|string|parse)/.match(constant)
    refute_nil(match)
    assert_equal(3, match.size, "match=#{match.inspect}")
  end # name_of

  def test_constants_by_class
    klass = RegexpParseType
    rps = RegexpParseType::Examples.constants.select do |c|
      RegexpParseType.value_of?(c).instance_of?(klass)
    end # select
    refute_empty(rps)
    assert_equal(rps, RegexpParseType.example_constant_names_by_class(klass))
  end # example_constant_names_by_class

  def test_names
    constants = RegexpParseType::Examples.constants
    refute_empty(constants)
    assert_instance_of(Symbol, constants[0])
    constants.map do |name|
      constant = RegexpParseType::Examples.const_get(name)
      refute_nil(name, "name=#{name.inspect}, constants=#{constants.inspect}")
      assert_instance_of(Symbol, name)
      match = RegexpParseType.name_of?(name)
      if !match.nil? && (constant.class == String || constant.class == Array || constant.class == RegexpParseType)
        refute_nil(match, "name.class=#{name.class.inspect}, name=#{name.inspect}, constants=#{constants.inspect}")
        match[1]
      end # if
    end.compact.uniq # map
    assert_includes(RegexpParseType.names, 'Sequence')
  end # names

  def test_strings
    refute_nil(RegexpParseType::Examples.constants)
    assert_includes(RegexpParseType::Examples.constants, :Dot_star_string)

    #	assert_includes(RegexpParseType::Examples.methods(false), :strings)

    assert_includes(RegexpParseType.strings, :Dot_star_string)
  end # strings

  def test_arrays
    assert_includes(RegexpParseType.arrays, :Dot_star_array)
  end # arrays

  def test_parses
    num_RegexpParseType = 0
    ret = RegexpParseType::Examples.constants.select do |c|
      # http://www.postal-code.com/mrhappy/blog/2007/02/01/ruby-comparing-an-objects-class-in-a-case-statement/
      case c
      when RegexpParseType
        assert_instance_of(RegexpParseType, c)
        num_RegexpParseType += 1
      when Symbol
        assert(!(Symbol === c.class), "Unexpected RegexpParseType::Examples constant=#{c.inspect} of type #{c.class}")
        assert(Symbol === c, "Unexpected RegexpParseType::Examples constant=#{c.inspect} of type #{c.class}")
        assert_instance_of(Symbol, c)
      else
        assert(Symbol === c.class, "Unexpected RegexpParseType::Examples constant=#{c.inspect} of type #{c.class}")
        refute_equal(Symbol, c.class)
        raise "Unexpected RegexpParseType::Examples constant=#{c.inspect} of type #{c.class}"
      end # case
      c.instance_of?(RegexpParseType)
    end # select
    # message	refute_empty(ret, "num_RegexpParseType=#{num_RegexpParseType}")
    assert_subset(RegexpParseType::Examples.constants.select { |c| /.*_parse/.match(c) }, RegexpParseType.parses, "num_RegexpParseType=#{num_RegexpParseType}")
  end # parses
  RegexpParseType.assert_pre_conditions
end # RegexpParseTypeAssertionsTest

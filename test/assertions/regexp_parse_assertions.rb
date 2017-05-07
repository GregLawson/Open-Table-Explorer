###########################################################################
#    Copyright (C) 2010-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp_parse.rb'
require_relative '../../test/assertions.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/unbounded_range_assertions.rb'
# parse tree internal format is nested Arrays.
# Postfix operators and brackets end embeddded arrays
module RegexpParseType
  # require_relative '../assertions/default_assertions.rb'
  require 'test/unit'
  module Assertions
    include Test::Unit::Assertions
    extend Test::Unit::Assertions
    module ClassMethods
      include Test::Unit::Assertions
      def assert_invariant
        assert_equal(RegexpParseType, self)
        assert_includes(instance_methods(false), :parseOneTerm!)
        assert_includes(instance_methods(true), :assert_post_conditions)
        assert_includes(instance_methods(true), :assert_repetition_range)
        #	moduleName='RegexpParseType::Examples'
        moduleName = 'RegexpParseType'
        klass = RegexpParseType
        message = "Module #{moduleName} not included in #{RegexpParseType.inspect} context.Modules actually included=#{klass.ancestors.inspect}."
        assert(RegexpParseType.module_included?(moduleName), message)
        assert_module_included(RegexpParseType, RegexpParseType)
        message2 = "klass.module_included?(moduleName)=#{klass.module_included?(moduleName)}"
        #	Restartable_parse.restartParse!
        #	assert_equal(Restartable_parse.regexpTree!,['K'])
        #	KC_parse.restartParse!
        #	assert_equal(['K','C'],KC_parse.regexpTree!)
        #	assert_equal(["(", "<", "t", "r", [".", "*"], "<", "/", "t", "r", ">"],Rows_parse.regexpTree!('('))
      end # assert_class_invariant_conditions

      # conditions true after initialization of class constants.
      # pre-conditions of constants should now be true
      def assert_post_conditions
        #	assert_invariant
        assert_operator(Examples.parses.size, :>, 0)
        Examples.parses.each(&:assert_pre_conditions) # each
      end # assert_class_post_conditions

      # assert conversions to arrays and strings are correct and reversable (?).
      def assert_round_trip(array)
        message = 'In assert_round_trip: array=' + array.inspect
        assert_equal(array, ::RegexpParseType.new(array).parse_tree, message)
        assert_equal(array.to_s, RegexpParseType.new(array.to_s).to_s, message)
        assert_equal(Regexp.new(array.to_s).source, RegexpParseType.new(Regexp.new(array.to_s)).to_s, message)
      end # assert_round_trip
    end # ClassMethods
    # invariant assertions that can be called during parsing for debugging parsing functions.
    def assert_invariant
      message = "assert_invariant: regexp_string=#{@regexp_string},rest=#{rest},parse_tree.inspect=#{@parse_tree.inspect}."
      assert_equal(NestedArray, @parse_tree.class)
      refute_nil(regexp_string, message)
      refute_nil(parse_tree, message)
      refute_nil(tokenIndex, message)
      assert_instance_of(String, rest)
      assert_instance_of(String, @regexp_string)
      assert_instance_of(NestedArray, @parse_tree)
      assert_equal(@regexp_string, rest + @parse_tree.to_s, message)
      #	self.class.assert_pre_conditions
    end # assert_invariant

    # assertions during object initialization (RegexpParseType.new) or after restart parse!
    def assert_pre_conditions(parser = self)
      #	assert_invariant
      message = "parser=#{parser.inspect}"
      assert_equal(@regexp_string.length - 1, parser.tokenIndex, message)
      assert(!parser.beyondString?)
      assert(!parser.rest.empty?)
      assert(parser.rest == parser.regexp_string)
    end # assert_pre_conditions

    # Post conditions are true after an operation
    # assert that an initialized RegexpParseType instance is valid and fully parse
    def assert_post_conditions(parser = self)
      #	assert_invariant
      message = "parser=#{parser.inspect}"
      if parser.tokenIndex == -1
        assert_equal(-1, parser.tokenIndex, message)
        assert(parser.rest == '')
        assert(parser.beyondString?)
      else # not fully parse
        message = 'Not fully parse. In internal tests call only if you are sure parsing is complete. Another test may have restarted the parsing.'
        assert_equal(-1, parser.tokenIndex, message)

      end # if
    end # assert_post_conditions

    # should this be an assertion or merged with above?
    def regexpParserTest(parser)
      #	Now test after full parse.
      parser.restartParse!
      parser.assert_pre_conditions
      #	Test after a little parsing.
      refute_nil(parser.nextToken!)
      assert(parser.rest != parser.regexp_string)

      parser.restartParse!
      refute_nil(parser.parseOneTerm!)

      parser.restartParse!
      assert(!parser.parseOneTerm!.empty?)

      #	Now test after full parse.
      parser.restartParse!
      refute_nil(parser.regexpTree!)

      parser.restartParse!
      parser.assert_invariant
      parser.restartParse!
      assert(!parser.regexpTree!.empty?)
    end # regexpParserTest

    def assert_repetition_range(range)
      assert_post_conditions
      range.assert_unbounded_range_equal(repetition_length)
      assert_operator(range.first, :>=, 0)
      assert_operator(repetition_length.first, :>=, 0)
    end # assert_repetition_range

    def assert_postfix_expression
      post_op = postfix_expression?
      refute_nil(post_op, "self=#{inspect}")
    end # postfix_expression
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
#  include DefaultAssertions
#  extend DefaultAssertions::ClassMethods
  module Examples #  Namespace
    assert_equal(RegexpParseType::Examples, self)
    assert_includes(RegexpParseType.constants, :Examples)
    # Asymmetrical_Tree_Parse=RegexpParseType.new(NestedArray::Examples::Asymmetrical_Tree_Array)
    Quantified_operator_array = ['{', '3', ',', '4', '}'].freeze
    Quantified_operator_string = Quantified_operator_array.join
    Quantified_repetition_array = ['.', ['{', '3', ',', '4', '}']].freeze
    Quantified_repetition_string = Quantified_repetition_array.join
    Quantified_repetition_parse = RegexpParseType.new(Quantified_repetition_string)
    Composite_regexp_array = ['t', 'e', 's', 't', '/',
                              [['[', 'a', '-', 'z', 'A', '-', 'Z', '0', '-', '9', '_', ']'], '*'],
                              ['[', '.', ']'],
                              'r',
                              [['[', 'a', '-', 'z', ']'], '*']].freeze
    Composite_regexp_string = Composite_regexp_array.join
    Composite_regexp_parse = RegexpParseType.new(Composite_regexp_string)
    Parenthesized_array = ['a', ['(', '.', ')']].freeze
    Parenthesized_string = Parenthesized_array.join
    Parenthesized_parse = RegexpParseType.new(Parenthesized_string)
    Sequence_array = %w(1 2 3).freeze
    Sequence_string = Sequence_array.join
    Sequence_parse = RegexpParseType.new(Sequence_string)
    module Parameters
      Start_anchor_string = '^'.freeze # should be \S or start of String
      End_anchor_string = '$'.freeze # should be \s or end of String
      Anchor_root_test_case = 'a'.freeze
    end # module Parameters
    No_anchor = RegexpParseType.new(Parameters::Anchor_root_test_case)
    Start_anchor = RegexpParseType.new(Parameters::Start_anchor_string + Parameters::Anchor_root_test_case)
    End_anchor = RegexpParseType.new(Parameters::Anchor_root_test_case + Parameters::End_anchor_string)
    Both_anchor = RegexpParseType.new(Parameters::Start_anchor_string + Parameters::Anchor_root_test_case + Parameters::End_anchor_string)
    CONSTANT_PARSE_TREE = RegexpParseType.new('K')
    Restartable_parse = CONSTANT_PARSE_TREE.clone
    # CONSTANT_PARSE_TREE.freeze

    KC_parse = RegexpParseType.new('KC')
    RowsRegexp = '(<tr.*</tr>)'.freeze
    Rows_parse = RegexpParseType.new(RowsRegexp)
    RowsEdtor2 = RegexpParseType.new('\s*(<tr.*</tr>)')
    KCET_parse = RegexpParseType.new('KCET[^
    ]*</tr>\s*(<tr.*</tr>).*KVIE')
    module ClassMethods
      def value_of?(name, suffix = '')
        path_array = path_array?(name, suffix)
        eval(path_array[0..-2].join).const_get(path_array[-1].to_sym)
      end # value_of

      def path_array?(name, suffix = '')
        path_array = [:RegexpParseType, :Examples, (name.to_s + suffix.to_s).to_sym]
      end # path_array

      def full_name?(name, suffix = '')
        full_name = 'RegexpParseType::Examples::' + name.to_s + suffix.to_s
        ret = begin
          eval(full_name.to_s)
          full_name
        rescue
          nil
        end # begin
      end # full_name

      def parse_of?(name)
        if full_name = full_name?(name)
          return RegexpParseType.new(value_of?(full_name))
        elsif full_name = full_name?(name, :_parse)
          return RegexpParseType.new(value_of?(full_name))
        elsif full_name = full_name?(name, :_array)
          return RegexpParseType.new(value_of?(full_name))
        elsif full_name = full_name?(name, :_string)
          return RegexpParseType.new(value_of?(full_name))
        else
          return nil
        end
        RegexpParseType.new(name.to_s)
      end # parse_of

      def string_of?(_name)
        array.to_a.join
      end # string_of

      def array_of?(string)
        parse_of?(string.to_s).to_a
      end # array_of

      # removes suffix if present else nil
      def name_of?(constant)
        match = /([A-Z][a-z_]*)_(array|string|parse)$/.match(constant)
        match
      end # name_of

      def names
        constants = RegexpParseType::Examples.constants
        constants.map do |name|
          constant = RegexpParseType::Examples.const_get(name)
          match = RegexpParseType.name_of?(name)
          if !match.nil? && (constant.class == String || constant.class == Array || constant.class == RegexpParseType)
            match[1]
          end # if
        end.compact.uniq # map
      end # names

      def strings
        example_constant_names_by_class(String)
      end # strings

      def arrays
        example_constant_names_by_class(Array)
      end # arrays

      def parses
        example_constant_names_by_class(RegexpParseType)
      end # parses
    end # ClassMethods
  end # Examples
  include Examples
  extend Examples::ClassMethods
end # RegexpParseType

###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
# require_relative '../../app/models/stream_tree.rb'
require_relative '../../app/models/regexp_parse.rb'
require_relative '../../app/models/generic_column.rb'
# encapsulates the difference between parsing from MatchData and from Array#split
# regexp are Regexp not Arrays or Strings (see String#parse)
class Capture
  module ClassMethods
    def symbolize_keys(tree)
      if tree.instance_of?(Array)
        tree.map do |element|
          symbolize_keys(element)
        end # map
      elsif tree.instance_of?(Hash)
        symbolize_keys = {}
        tree.each_pair do |key, value|
          if value.instance_of?(Hash)
            value = symbolize_keys(value) # value is a recursive hash
          elsif value.instance_of?(Hash)
            value = value.map do |element|
              symbolize_keys(element) # value is a recursive Array
            end # map
          end # if
          unless key.instance_of?(Symbol)
            key = key.name
          end # if
          symbolize_keys = symbolize_keys.merge(key => value)
        end # each
        symbolize_keys
      end # if
    end # symbolize_keys
  end # ClassMethods
  extend ClassMethods
  attr_reader :string, :regexp # arguments
  attr_reader :captures
  attr_reader :raw_captures
  def initialize(string, regexp)
    @string = string
    @regexp = Regexp.promote(regexp)
    #     named_captures for captures.size > names.size
  end # initialize

  def num_captures
    @regexp.named_captures.values.flatten.size
  end # num_captures

  def [](index, _hash_offset = 0)
    to_a(_hash_offset)[index]
  end # []

  def to_hash(_hash_offset = 0)
    named_hash = {}
    @regexp.named_captures.each_pair do |named_capture, _indices| # return named subexpressions
      if _indices.size == 1
        named_hash = named_hash.merge(named_capture.to_sym =>
           to_a(_hash_offset)[_indices[0] - 1]) # one and only capture
      else
        named_hash = named_hash.merge(named_capture.to_sym =>
          _indices.map { |i| to_a(_hash_offset)[i - 1] }) # fix index to skip $0 == whole string
      end # if
    end # each_pair
    # with the current ruby Regexp implementation, the following is impossible
    # If there is a named capture in match or split, all unnamed captures are ignored
    #	possible_unnamed_capture_indices.each do |capture_index|
    #		name=Capture.default_name(capture_index).to_sym
    #		named_hash[name]= to_a[capture_index]
    #	end #each
    named_hash
  end # to_hash

  # Unlike MatchData, Capture#[0] is first capture not the entire matched string (which is accessed via Capture#matched_characters)
  # both named and positional indices should work
  def named_hash_variable(variable, _hash_offset = 0)
    named_capture = variable.name
    indices = @regexp.named_captures[named_capture.to_s]
    named_hash = {}
    indices.each_index do |_capture_index, _i|
      column = GenericColumn.new(regexp_index: 0, variable: variable)
      named_hash = named_hash.merge(named_hash_column(column))
    end # each_index
    named_hash
  end # named_hash_variable

  def named_hash_column(column, hash_offset = 0)
    indices = @regexp.named_captures[column.variable.name.to_s]
    column.to_hash(self[indices[column.regexp_index], hash_offset])
  end # named_hash_column

  # returns hash of all column names and values captured
  def named_hash(hash_offset = 0)
    named_hash = {}
    @regexp.named_captures.each_pair do |named_capture, _indices| # return named subexpressions
      variable = GenericVariable.new(name: named_capture)

      named_hash = named_hash.merge(named_hash_variable(variable, hash_offset))
    end # each_pair
    # with the current ruby Regexp implementation, the following is impossible
    # If there is a named capture in match or split, all unnamed captures are ignored
    #	possible_unnamed_capture_indices.each do |capture_index|
    #		name=Capture.default_name(capture_index).to_sym
    #		named_hash[name]= to_a[capture_index]
    #	end #each
    named_hash
  end # named_hash

  def ==(other)
    instance_variables.all? do |iv_name|
      if ![:@raw_captures].include?(iv_name)
        instance_variable_get(iv_name) == other.instance_variable_get(iv_name)
      else
        true # pass all? for cetain instance variables
      end # if
    end # All?
  end # equal

  # return a capture object for two Capture instances (assumed consecutive)
  def +(other_capture)
    raise 'Only Capture instances can be added.' unless other_capture.instance_of?(Capture)
    Capture.new(string + other_capture.string, [regexp, other_capture.regexp])
  end # +
  #     named_captures for captures.size > names.size

  # Capture::Assertions
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
      end # assert_pre_conditions

      def assert_method(match_capture, limit_capture, argumentless_method_name = :output, message = '')
        message += "match_capture = #{match_capture.inspect}\limit_capture = #{limit_capture.inspect}"
        match_method_object = match_capture.method(argumentless_method_name)
        limit_method_object = limit_capture.method(argumentless_method_name)
        assert_equal(match_method_object.call, limit_method_object.call, message)
      end # assert_method
    end # ClassMethods
    # Any match at all
    def assert_pre_conditions(_message = '')
      refute_nil(to_a(0), 'no match at all.')
      if output == {}

      #		assert_equal({}. to_a, 'MatchData but no captures.')
      elsif output == []
        refute_empty(to_a, 'split but no captures.')
      end # if
      assert(success?)
    end # assert_pre_conditions

    def assert_success
      if @raw_captures.nil?
        assert(false, inspect)
      elsif @raw_captures.instance_of?(MatchData)
        true
      else # :split
        if num_captures == 0 # no captures
          match_capture = MatchCapture.new(string, regexp)
          match_capture.assert_success
        else # captures
          if @raw_captures.size < 2 # split failed
            assert(false, inspect)
          else # split succeeded
            true
          end # if
        end # if
      end # if
      assert(success?, inspect)
    end # assert_success

    def assert_left_match(message = '')
      #	message = add_default_message(message)
      assert(success?, message)
      message += "\nregexp = " + regexp.inspect
      message += "\nstring... = " + string[0..50].inspect
      refute_match(regexp, pre_match)
      assert_empty(pre_match, message + "\nA left match requires pre_match = #{pre_match.inspect} to be empty.")
      assert_empty((delimiters - [pre_match] - [post_match]).join("\n")[0..100], message + "\nDelimiters were found in a split match = " + delimiters.inspect)
      assert_success
    end # assert_left_match

    # exact match, no left-overs
    def assert_post_conditions(message = '')
      #	assert_left_match(add_default_message(message))
      #	assert_empty(post_match, 'Only a left match.' + add_default_message(message))
    end # assert_post_conditions

    def repetition_options?
      if @regexp.respond_to?(:repetition_options)
        @regexp.repetition_options
      end # if
    end # repetition_options?

    def add_parse_message(string, pattern, message = '')
      message = add_default_message(message)
      newline_if_not_empty(message) + "\n#{string.inspect}.match(#{pattern.inspect})=#{string.match(pattern).inspect}"
    end # add_parse_message
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  module Examples
    Newline_Delimited_String = "* 1\n  2".freeze
    Newline_Terminated_String = Newline_Delimited_String + "\n"
    Branch_current_regexp = /[* ]/.capture(:current) * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
    Branch_regexp = /[* ]/ * / / * /[-a-z0-9A-Z_]+/.capture(:branch)
    Branch_line_regexp = Branch_regexp * "\n"
    Current_variable = GenericVariable .new(name: 'current')
    Branch_variable = GenericVariable .new(name: 'branch')
    Current_column = GenericColumn.new(regexp_index: 0, variable: Current_variable)
    Branch_column = GenericColumn.new(regexp_index: 0, variable: Branch_variable)
    Branch_column_value = { Branch_column => '1' }.freeze
    Branch_column_answer = { Branch_column => '1' }.freeze
    Branch_answer = { branch: '1' }.freeze
    LINE = /[^\n]*/.capture(:line)
    Line_terminator = /\n/.capture(:terminator)
    Terminated_line = (LINE * Line_terminator).group
    Hash_answer = { line: '* 1', terminator: "\n" }.freeze
    Array_answer = [{ line: '* 1', terminator: "\n" }, { line: '  2', terminator: "\n" }].freeze
    Branch_hashes = [{ current: '*', branch: '1' }, { current: ' ', branch: '2' }].freeze

    WORD = /([^\s]*)/.capture(:word)
  end # Examples
end # Capture

# encapsulates the difference between parsing from MatchData and from Array#split
class RawCapture < Capture
  def initialize(string, regexp)
    super(string, regexp)
    @raw_captures = raw_captures
    #     named_captures for captures.size > names.size
  end # initialize
end # RawCapture

class MatchCapture < RawCapture
  attr_reader :string, :regexp # arguments
  attr_reader :captures
  attr_reader :raw_captures
  def initialize(string, regexp)
    super(string, regexp)
  end # initialize

  def raw_captures
    @string.match(@regexp)
  end # raw_captures

  def success?
    if @raw_captures.nil?
      nil
    else
      true
    end # if
  end # success?

  def repetitions?
    if @raw_captures.nil?
      0
    else
      1
    end # if
  end # repetitions?

  # Tranform split and MatchData captures into single (split) form
  def to_a(_repetition = 0)
    raise @raw_captures.inspect unless @raw_captures.nil? || @raw_captures.instance_of?(MatchData)
    @raw_captures[1..-1] # discard $0 = whole string
  end # to_a

  def to_tree
    raise @raw_captures.inspect unless @raw_captures.nil? || @raw_captures.instance_of?(MatchData)
    { pre_match: pre_match,
      named_captures: to_hash,
      post_match: post_match }
  end # to_tree

  def output
    to_hash(0)
  end # output

  def post_match
    @raw_captures.post_match
  end # post_match

  def pre_match
    if !success?
      ''
    else
      @raw_captures.pre_match

    end # if
  end # pre_match

  def matched_characters
    if @raw_captures.nil?
      ''
    else
      @raw_captures[0]
    end # if
  end # matched_characters

  def number_matched_characters
    matched_characters.length
  end # number_matched_characters

  def column_output
    if !success?
      {}
    elsif @raw_captures.instance_of?(MatchData)
      if @raw_captures.names == []
        @raw_captures[1..-1] # return unnamed subexpressions
      else
        named_hash(0)
      end # if
    end # if
  end # column_output

  def delimiters
    []
  end # delimiters
  module Examples
    include Capture::Examples
    Branch_capture = MatchCapture.new(Newline_Delimited_String, Branch_regexp)
    Parse_string = MatchCapture.new(Newline_Delimited_String, Branch_regexp)
    Branch_line_capture = MatchCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Branch_current_capture = MatchCapture.new(Newline_Delimited_String, Branch_current_regexp)
  end # Examples
end # MatchCapture

class SplitCapture < RawCapture
  attr_reader :string, :regexp # arguments
  attr_reader :captures
  attr_reader :raw_captures
  def initialize(string, regexp)
    super(string, regexp)
  end # initialize

  def raw_captures
    @string.split(@regexp)
  end # raw_captures

  def success?
    if num_captures == 0 # no captures
      match_capture = MatchCapture.new(string, regexp)
      match_capture.success?
    else # captures
      if @raw_captures.size < 2 # split failed
        false
      else # split succeeded
        true
      end # if
    end # if
  end # success?

  def repetitions?
    if @raw_captures.nil?
      0
    else
      (@raw_captures.size / (num_captures + 1)).ceil
    end # if
  end # repetitions?

  # Tranform split and MatchData captures into single (split) form
  def to_a(repetition)
    raise @raw_captures.inspect unless @raw_captures.nil? || @raw_captures.instance_of?(Array)
    @raw_captures[1 + repetition * (num_captures + 1), num_captures] # does not include delimiters
  end # to_a

  def to_tree
    raise @raw_captures.inspect unless @raw_captures.nil? || @raw_captures.instance_of?(Array)
    match_tree =
      if repetitions? == 1
        to_hash(0)
      else
        (0..repetitions? - 1).map { |i| to_hash(i) }
      end # if
    { pre_match: pre_match,
      named_captures: match_tree,
      delimiters: delimiters,
      post_match: post_match }
  end # to_tree

  def output
    (0..(repetitions? - 1)).map do |i|
      to_hash(i)
    end # map
  end # output

  def post_match
    if @raw_captures.size.odd?
      @raw_captures[-1]
    else
      ''
    end # if
  end # post_match

  def pre_match
    @raw_captures[0]
  end # pre_match

  def matched_characters
    @string[0, number_matched_characters]
  end # matched_characters

  def number_matched_characters
    @string.length - pre_match.length - post_match.length
  end # number_matched_characters

  def column_output
    (0..repetitions? - 1).map do |i|
      named_hash(i * (num_captures + 1))
    end # map
  end # column_output

  # includes pre_match and post_match
  def delimiters
    delimiters = []
    @raw_captures.each_with_index do |raw_capture, _i|
      if (_i % (num_captures + 1)) == 0
        delimiters << raw_capture
      end # if
    end # each_index
    delimiters
  end # delimiters

  # within match excluding pre_match and post_match
  def internal_delimiters
    delimiters[1..-2]
  end # internal_delimiters
  module Examples
    include Capture::Examples
    Split_capture = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Parse_array = SplitCapture.new(Newline_Terminated_String, Branch_regexp)
    Branch_line_capture = SplitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Branch_regexp_capture = SplitCapture.new(Newline_Delimited_String, Branch_regexp)
    Failed_capture = SplitCapture.new('cat', /fish/)
    Syntax_failed_capture = SplitCapture.new('cat', 'f)i]s}h')
    Parse_delimited_array = SplitCapture.new(Newline_Delimited_String, Branch_regexp)
  end # Examples
end # SplitCapture

# class ParsedCapture
class ParsedCapture < MatchCapture
	module ClassMethods
		def remove_matches(unmatches, regexp_array)
			regexp_array.map do |regexp|    
				unmatches = unmatches.map do |unmatched|
					capture = unmatched.capture?(regexp, SplitCapture)
					capture.delimiters
				end.flatten.select {|um| um != ''}# map
			end.flatten # map regexp
		end # remove_matches

		def priority_match(unmatched, regexp_array) # first match deletes string
			regexp_array.map do |regexp|    
				if unmatched.instance_of?(String)
					capture = unmatched.capture?(regexp, SplitCapture)
					if capture.success?
						delimiters = capture.delimiters.select {|delimiter| delimiter != ''}.uniq
						if delimiters == []
							[{ regexp => capture.output}]
						else
							if regexp_array.size == 1
								[{ regexp => capture.output} ] + delimiters # out of regexps to try
							else
								recurse_on_delimiters = delimiters.map do |delimiter|
									ParsedCapture.priority_match(delimiter, regexp_array[1..-1]) # one try in priority order
								end.flatten # map
								[{ regexp => capture.output} ] + recurse_on_delimiters
							end # if
						end # if
					else
							nil
					end # if
				else
					nil
				end # if
			end.flatten.uniq.compact.select {|um| um != ''}# map
		end # priority_match
		
		def show_matches(unmatches, regexp_array)
			unmatches.map do |unmatched|
				priority_match(unmatched, regexp_array)
			end.flatten # map regexp
		end # show_matches
	end # ClassMethods
	extend ClassMethods
	
  attr_reader :string, :regexp # arguments
  attr_reader :parsed_regexp
  attr_reader :raw_captures
  def initialize(string, regexp)
    super(string, regexp)
    @parsed_regexp = Regexp::Parser.parse(regexp.to_s, 'ruby/1.8')
  end # ParsedCapture_initialize

  def raw_captures
    raise Exception.new('@string is not String but ' + @string.class.name) unless @string.instance_of?(String)
#    match_extent = @string.match(@regexp)
    match_extent = MatchCapture.new(@string, @regexp)
		if match_extent.success?
			if @parsed_regexp.instance_variables.include?(:@quantifier) # quantifier
  # limit match to :match length of string
					string = match_extent[0] # regexp matched string
#					string.split(@regexp) # after string shortened
					SplitCapture.new(string, @regexp) # after string shortened
			else
				match_extent # not yet recursing into embeded quantifiers
			end # if
		else
			match_extent
		end # if
  end # raw_captures

  def column_output
    @raw_captures.reduce({}, :merge) { |c| c[:raw_capture].output }
  end # column_output

  def delimiters
    @raw_captures.reduce('', :+) { |c| c[:raw_capture].delimiters }
  end # delimiters
  module Examples
    include Capture::Examples
    # Branch_line_capture = ParsedCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Parsed_a_capture = ParsedCapture.new('a,a,', /a{2}/.capture(:label))
    Parsed_aa_capture = ParsedCapture.new('a,a,', (/a,/.capture(:label)) * 2)
		Match_a = {/(?<alpha>a)/=>[{:alpha=>"a"}]}
		Match_b = {/(?<beta>b)/=>[{:beta=>"b"}]}
		Unmatched_c = 'c'
		Ordered_matches = [Match_a, Match_b, Unmatched_c]
  end # Examples
end # ParsedCapture

class LimitCapture < ParsedCapture
  # limit match to :match length of string
  def raw_captures
    raise Exception.new('@string is not String but ' + @string.class.name) unless @string.instance_of?(String)
    method = @string.method(:match)
    match = method.call(@regexp)
    if match.nil?
      match
    else
      string = match[0] # regexp matched string
      string.method(:split).call(@regexp) # after string shortened
    end # if
  end # raw_captures
  module Examples
    include Capture::Examples
    Branch_line_capture = LimitCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Limit_capture = LimitCapture.new(Newline_Delimited_String, Branch_line_regexp)
  end # Examples
  def post_match
    @raw_captures[0][:raw_capture].post_match
  end # post_match

  def pre_match
    @raw_captures[0][:raw_capture].pre_match
  end # pre_match

  def matched_characters
    @raw_captures.reduce('', :+) { |c| c[:raw_capture].matched_characters }
  end # matched_characters

  def delimiters
    []
  end # delimiters
end # LimitCapture

class String
  def map_captures?(regexp_array)
    ret = []
    capture = capture?(regexp_array[0])
    remaining_string = if capture.success?
                         capture.post_match
                       else
                         string # no advance in string yet
                       end # if
    if remaining_string.empty? || regexp_array.size == 1
      return ret # return array of exact captures including failures
    else
      ret += [capture]
      ret += remaining_string.map_captures?(regexp_array[1..-1])
    end # if
  end # map_capture?

  # Try to unify match and split (with Regexp delimiter)
  # What is the difference between an Object and an Array of size 1?
  # Should difference be derived from recursive analysis of RegexpParse?
  # Where repetitions produce Array, others produe Hash
  # complicated by fact regular expressions simulate repetitions with recursive alternatives
  # capture? returns a tree of Capture objects while parse returns only the output Hash
  # capture_class default should be best parse capture; currently LimitCapture
  def capture?(pattern, capture_class = MatchCapture)
    if pattern.instance_of?(Array)
      pos = 0
      pattern.map do |p|
        ret = self[pos..-1].capture?(p) # recurse returning Capture
        pos += if ret.instance_of?(Array)
                 ret.reduce(0) { |sum, c| sum + c.number_matched_characters }
               else
                 ret.number_matched_characters
               end # if
        ret
      end # map
    elsif pattern.instance_of?(String)
      # see http://stackoverflow.com/questions/3518161/another-way-instead-of-escaping-regex-patterns
      capture?(Regexp.new(Regexp.quote(pattern)), capture_class)
    else
      capture = capture_class.new(self, pattern)
    end # if
  end # capture?

  def capture_in(pattern, capture_class = MatchCapture)
    capture?(pattern, capture_class)
  end # capture_in

  def capture_exact(pattern, capture_class = MatchCapture)
    capture?(Regexp::Start_string * pattern * Regexp::End_string, capture_class)
  end # capture_in

  def capture_start(pattern, capture_class = MatchCapture)
    capture?(Regexp::Start_string * pattern, capture_class)
  end # capture_in

  def capture_end(pattern, capture_class = MatchCapture)
    capture?(pattern * Regexp::End_string, capture_class)
  end # capture_in

  def capture_many(pattern)
    capture?(pattern, SplitCapture)
  end # capture_many

  def parse(regexp)
    regexp.enumerate(:map) do |reg|
      capture?(reg).enumerate(:map, &:output)
    end # enumerate
  end # parse
  module Constants
  end # Constants
  include Constants
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_parse_sequence(answer, string, pattern1, pattern2, message = '')
        match1 = parse_string(string, pattern1)
        refute_nil(match1)
        refute_nil(answer[0, match1.size])
        assert_equal(answer[0, match1.size], match1, add_parse_message(string, pattern1, message))
        match2 = parse_string(string, pattern2)
        assert_empty(match2 - answer, add_parse_message(string, pattern2, message))
        match12 = parse_string(pattern1.match(string).post_match, pattern2)
        assert_equal(match12, answer[-match12.size..-1], add_parse_message(pattern1.match(string).post_match, pattern2, message))
        match = parse_string(string, pattern1 * pattern2)
        if match == [] || match == {}
          message += "match1=#{match1.inspect}\n"
          message += "match2=#{match2.inspect}\n"
          message += "match12=#{match12.inspect}\n"
          message += "string.match(#{pattern1 * pattern2})=#{string.match(pattern1 * pattern2).inspect}"
          assert_equal(answer, parse_string(string, pattern1 * pattern2), message)
        end # if
      end # parse_sequence

      def assert_parse_repetition(answer, string, pattern, repetition_range, message = '')
        assert_parse_string(answer, string, pattern * repetition_range, message)
        match1 = parse_string(string, pattern)
        assert_equal(match1, answer[0, match1.size], add_parse_message(string, pattern, message))
        match_any = parse_string(string, pattern * Regexp::Any)
        assert_equal(answer, match_any[-answer.size..-1], add_parse_message(string, pattern * Regexp::Any, message))
        match = parse_string(string, pattern * repetition_range)
        if match == [] || match == {}
          message += "match1=#{match1.inspect}\n"
          message += "match2=#{match2.inspect}\n"
          message += "match12=#{match12.inspect}\n"
          message += "string.match(#{pattern * repetition_range})=#{string.match(pattern * repetition_range).inspect}"
          assert_equal(answer, parse_string(string, pattern * repetition_range), message)
        end # if
      end # parse_repetition
    end # ClassMethods
    # pattern matches only once in both match and split
    def assert_parse_once(pattern, message = '')
      match_capture = MatchCapture.new(self, pattern)
      split_capture = SplitCapture.new(self, pattern)
      limit_capture = SplitCapture.new(self[0, match_capture.number_matched_characters], pattern)
      message = "match_capture = #{match_capture.inspect}\nsplit_capture = #{split_capture.inspect}"
      #	Capture.assert_method(match_capture, limit_capture, :string, message)
      Capture.assert_method(match_capture, limit_capture, :regexp, message)
      Capture.assert_method(match_capture, limit_capture, :num_captures, message)
      #	Capture.assert_method(match_capture, split_capture, :captures, message)
      Capture.assert_method(match_capture, limit_capture, :repetitions?, message)
      Capture.assert_method(match_capture, limit_capture, :matched_characters, message)
      Capture.assert_method(match_capture, limit_capture, :pre_match, message)
      #	Capture.assert_method(match_capture, limit_capture, :post_match, message)
      Capture.assert_method(match_capture, limit_capture, :delimiters, message)
      #	Capture.assert_method(match_capture, limit_capture, :to_a, message)
      assert_equal(match_capture.output, limit_capture.output[0], message)
      common_capture = match_capture.to_a[0..-2]
      last_common_capture = common_capture.size - 1
      assert_equal(common_capture.join, split_capture.to_a[0..last_common_capture].join, message)
      assert_equal(common_capture, split_capture.to_a[0..last_common_capture], message)
      assert_equal(common_capture, limit_capture.to_a[0..last_common_capture], message)
      assert_equal(common_capture, limit_capture.to_a, message)
    end # assert_parse_once

    def assert_left_parse(pattern, _message = '')
      if pattern.instance_of?(Array)
        pos = 0
        pattern.map do |p|
          ret = self[pos..-1].assert_left_parse(p) # recurse
          pos += ret.number_matched_characters
          ret
        end # map
      else
        match_capture = MatchCapture.new(self, pattern)
        split_capture = SplitCapture.new(self, pattern)
        limit_capture = LimitCapture.new(self, pattern)
        match_capture.assert_left_match
        #		split_capture.assert_left_match
        limit_capture.assert_left_match
        # limit repetitions to pattern, get all captures
        if split_capture.repetitions? == 1
          match_capture
        elsif match_capture.output == split_capture.output[-1] # over-written captures
          split_capture
        else
          match_capture
        end # if
      end # if
    end # assert_left_parse

    def assert_parse(pattern, message = '')
      capture = capture?(pattern)
      capture_runs = capture.enumerate(:chunk) do |c|
        success = c.success?
      end # chunk
      capture_runs.each do |success, _run|
        case success
        when true then message += ' matched'
        when nil then message += ' unmatched'
        end # case
      end # each
      match_capture = MatchCapture.new(self, pattern)
      split_capture = SplitCapture.new(self, pattern)
      limit_capture = LimitCapture.new(self, pattern)
      match_capture.assert_post_conditions(message)
      split_capture.assert_post_conditions(message)
      limit_capture.assert_post_conditions(message)
      # limit repetitions to pattern, get all captures
      if split_capture.repetitions? == 1
        puts message + "\n" + match_capture.inspect
      elsif match_capture.output == split_capture.output[-1] # over-written captures
        puts message + "\n" + split_capture.inspect
      else
        puts message + "\n" + match_capture.inspect
        end # if
    end # assert_parse
  end # Assertions
  include Assertions
  module Examples
    include Constants
    include Regexp::DefinitionalConstants
    LINES_cryptic = /([^\n]*)(?:\n([^\n]*))*/
    CSV = /([^,]*)(?:,([^,]*?))*?/
    Ls_octet_pattern = /rwx/
    Ls_permission_pattern = [/1|l/,
                             Ls_octet_pattern.capture(:system_permissions),
                             Ls_octet_pattern.capture(:group_permissions),
                             Ls_octet_pattern.capture(:owner_permissions)].freeze
    Filename_pattern = /[-_0-9a-zA-Z\/]+/
    Driver_pattern = [
      /\s+/, /[0-9]+/.capture(:permissions),
      /\s+/, /[0-9]+/.capture(:size),
      / /, Ls_permission_pattern,
      /\s+/, /[a-z]+/.capture(:owner),
      /\s+/, /[a-z]+/.capture(:group),
      /\s+/, /[0-9]+/.capture(:size_2),
      /\s+/, /[A-Za-z]+/.capture(:month),
      /\s+/, /[0-9]+/.capture(:date),
      /\s+/, /[0-9]+/.capture(:time),
      /\s+/, '/sys/devices',
      Filename_pattern.capture(:device),
      ' -> ',
      Filename_pattern.capture(:driver)].freeze
    Driver_string = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'.freeze
  end # Examples
end # String

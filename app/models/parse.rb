###########################################################################
#    Copyright (C) 2013-2017 by Greg Lawson
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
class String
	def to_literal(quote = "'") # quote as single  or double quote
		if size == dump.size - 2
			quote + self + quote
		else
			dump
		end # if
	end # to_literal
end # String

class MatchRefinement < Array
  module Constructors
		def [](*array)
				MatchRefinement.new(array.reject {|e| e == '' || e.nil? || (e.instance_of?(MatchCapture) && e.string == '') } ) # remove empty strings as uninteresting
		end # []
  end # Constructors
  extend Constructors

	def [](*args) # make indexing work like Array but return MatchRefinement when appropriate
		if args.size ==2 || args.instance_of?(Range) || args.instance_of?(Regexp)
			MatchRefinement.new(super(*args))
		else
			super(*args)
		end # if
	end # []

	def +(other)
		MatchRefinement[*(to_a + other.to_a)] # splat see: http://blog.honeybadger.io/ruby-splat-array-manipulation-destructuring/
	end # +

	def inspect
		'MatchRefinement ' + kind.inspect + "\n" +
		map do |refinement|
			if refinement.kind_of?(MatchCapture)
				if refinement.regexp.nil?
					'regexp is nil'
				elsif refinement.success?
				refinement.matched_characters.to_literal + 
					' matched by ' + refinement.regexp.to_literal +
					' captures ' + refinement.output.inspect
				else
					refinement.matched_characters.to_literal + 
						' not matched by ' + refinement.regexp.to_literal 
				end # if
			elsif refinement.kind_of?(SplitCapture)
				if refinement.regexp.nil?
					'regexp is nil'
				elsif refinement.success?
				refinement.matched_characters.to_literal + 
					' matched by ' + refinement.regexp.to_literal +
					' captures ' + refinement.output.inspect
				else
					refinement.matched_characters.to_literal + 
						' not matched by ' + refinement.regexp.to_literal 
				end # if
			elsif refinement.instance_of?(String)

				'suggest: /' + Regexp.escape(refinement) + '/'
			else
				refute_kind_of(Capture, refinement, join)
				"unexpected inspect = " + refinement.class.inspect + refinement.inspect
			end # if
		end.join(",\n") # map
	end # inspect

	def join
		map do |refinement|
			if refinement.kind_of?(MatchCapture)
				refinement.matched_characters
					
			elsif refinement.instance_of?(String)
				refinement
			else
				"unexpected inspect = " + refinement.inspect
			end # if
		end.join # map
	end # join
	
	def capture_indices
		(0..(size - 1)).select do |refinement_index|
			self[refinement_index].kind_of?(MatchCapture) && self[refinement_index].success?
		end # each
	end # capture_indices

	def captures
		capture_indices.map do |refinement_index|
			self[refinement_index]
		end # each
	end # captures
	
	def capture_span
		array = capture_indices
		if array == []
			0
		elsif array.size == 1
			1
		else
			1 + (array[-1] - array[0])
		end # if
	end # capture_span
		
	def all_matches_consecutive?
		capture_span == capture_indices.size
	end # all_matches_consecutive?
	
	def unmatched_indices
		(0..(size - 1)).map do |refinement_index|
			if self[refinement_index].kind_of?(MatchCapture)
				if self[refinement_index].success?
					nil
				else
				 refinement_index # expected match?
				end # if
			else
				refinement_index # delimiters, pre_match, post_match
			end # if
		end.compact # map
	end # unmatched_indices

	def unmatches
		unmatched_indices.map do |refinement_index|
			self[refinement_index]
		end # each
	end # unmatches

	def kind
		if capture_span == 0
			:no_matches		
		elsif self == captures
			:exact
		
		elsif self[0, captures.size] == captures
			:left
		elsif self[-captures.size..-1] == captures
			:right	 
		elsif capture_span == capture_indices.size
			:inside
		else
			:scattered
		end # if
	end # kind

	def error_message(explain_kind = self.kind)
		case explain_kind
			when :no_matches then 'A no_matches refinement requires no regexp to succeed and the entire string as the residual.'
			when :exact then 'An exact refinement requires all regexp to succeed with no residual.'
			when :left then 'A left refinement requires all regexp to succeed with left residual.'
			when :right then 'A right refinement requires all regexp to succeed with right residual.'
			when :inside then 'An inside refinement requires all regexp to succeed with left and right residuals.'
			when :scattered then 'An scattered refinement requires all regexp to succeed but interrupted by a residual.'
			else
				fail explain_kind.inspect + ' unexpected'
		end # case
	end # error_message
	
	def suggest_name_value(string, name_regexp = /[A-Za-z]+/, delimiter_regexp = /[ =,; \t\n]/ , value_regexp = /[0-9]+/)
		name_value_pair_regexp = name_regexp.capture(:name) *delimiter_regexp.capture(:delimiter) * value_regexp.capture(:value) */[\ \n]/
		name_value_pairs = SplitCapture.new(string: string, regexp: name_value_pair_regexp).output
		message = 'Net_file_tree_hash = ' + Net_file_tree_hash.inspect + "\n"
		message += 'Lo_hash = ' + Lo_hash.ruby_lines_storage + "\n"
		
		message +=  'name_value_pairs = ' + name_value_pairs.inspect
		puts message
		assert_instance_of(Array, name_value_pairs)
		suggestion = name_value_pairs.map do |pair|
			name = pair[:name]
			value = pair[:value]
				value_regexp.inspect + '.capture(:' + name +')'
		end # map
	end # suggest
		
	module Assertions
    module ClassMethods
			def assert_pre_conditions(message='')
				message+="In assert_pre_conditions, self=#{inspect}"
			#	asset_nested_and_included(:ClassMethods, self)
			#	asset_nested_and_included(:Constants, self)
			#	asset_nested_and_included(:Assertions, self)
				self
			end #assert_pre_conditions

			def assert_post_conditions(message='')
				message+="In assert_post_conditions, self=#{inspect}"
				self
			end #assert_post_conditions
		end #ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
			assert_kind_of(Array, self)
			each do |refinement|
				if refinement.kind_of?(MatchCapture)
					refute_equal(0, refinement.matched_characters)
#					assert(refinement.success?, refinement.inspect)
					assert_instance_of(String, refinement.matched_characters)
				elsif refinement.kind_of?(String)
					refute_equal(0, refinement.size)
				elsif refinement.kind_of?(Array)
					refute_instance_of(Array, refinement, inspect)
				elsif refinement.instance_of?(NilClass)
					fail message + "\n" + to_a.inspect
				else
#!					refute_equal(0, refinement.size)
					refute_instance_of(MatchCapture, refinement, inspect)
				end # if
			end # each
				self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
				self # return for command chaining
    end # assert_post_conditions
		
		def assert_match_kind(desired_kind, message = '')
			assert_pre_conditions
			message += "\n"
			message += error_message(desired_kind) + "\n" + self.inspect
			message += "\n capture_indices = " + capture_indices.inspect + ' out of 0..' + (size - 1).to_s
			message += "\n" + unmatches.ruby_lines_storage
			assert_equal(desired_kind, kind, message)
		end # assert_match_kind
		
		
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
end # MatchRefinement

module TimeTypes
    Week_day_regexp = /[MTWFS][a-z]{2}/.capture(:weekday)
    Day_regexp = /[0-9]{1,2}/.capture(:day_of_month)
    Month_regexp = /[ADFJMNOS][a-z]+/.capture(:month)
    Year_regexp = /[0-9]{2,4}/.capture(:year)
    Hour_regexp = /[0-9][0-9]/.capture(:hour)
    Minute_regexp = /[0-9][0-9]/.capture(:minute)
    Second_regexp = /[0-9][0-9]/.capture(:second)
    AMPM_regexp = / ?([PApa][Mm])?/.capture(:AMPM)
    Timezone_number_regexp = /[-+][0-1][0-9][03]0/.capture(:timezone)
		Day_after_month_regexp = Month_regexp * ' ' * Day_regexp
    Date_regexp = Day_regexp * ' ' * Month_regexp
		Space_regexp = /\ /
    Time_regexp = Hour_regexp * ':' * Minute_regexp * ':' * Second_regexp

    Git_show_medium_timestamp_regexp_array = [Week_day_regexp, 
			Space_regexp * Month_regexp * Space_regexp * Day_regexp, 
			Space_regexp * Time_regexp, Space_regexp * Year_regexp, Space_regexp * Timezone_number_regexp]
		Git_show_medium_timestamp_regexp = Regexp[Git_show_medium_timestamp_regexp_array] 

		Git_reflog_timestamp_regexp_array = [Week_day_regexp,
			/,/ * Space_regexp * Day_regexp * Space_regexp * Month_regexp * Space_regexp * Year_regexp, 
			Space_regexp * Hour_regexp * ':' * Minute_regexp * ':' * Second_regexp * Space_regexp * Timezone_number_regexp]
		Git_reflog_timestamp_regexp = Regexp[Git_reflog_timestamp_regexp_array]
end # TimeTypes

module ReflogRegexp
		include TimeTypes
	  Name_regexp = (/[a-z0-9]+/.capture(:type) * /\//).optional * /[_a-z0-9]+/.capture(:maturity) * (/\+/ * /[_a-z]+/).capture(:test_topic).optional # also matches SHA1!
    Unambiguous_ref_age_pattern = /[0-9]+/.capture(:age)
    Ambiguous_ref_pattern = Name_regexp * /@\{/ * Unambiguous_ref_age_pattern * /}/
    Refs_prefix_regexp = /refs\// * (/heads|remotes/.capture(:ref) * /\//).optional
		Unambiguous_ref_pattern = (Refs_prefix_regexp * Ambiguous_ref_pattern).optional
    Delimiter = /,/.freeze
    SHA1_hex_short = /[[:xdigit:]]{7,9}/.capture(:sha1_hex_short)
    Regexp_array = [Regexp::Start_string * Ambiguous_ref_pattern.optional, Delimiter,
                         Unambiguous_ref_pattern, Delimiter, SHA1_hex_short, Delimiter, Git_reflog_timestamp_regexp].freeze
#    Reflog_line_regexp = Regexp::Start_string * Ambiguous_ref_pattern.group * Regexp::Optional * Delimiter *
#                         Unambiguous_ref_pattern.group * Delimiter * SHA1_hex_short * Delimiter * Timestamp_regexp
		Reflog_line_regexp = Regexp[Regexp_array]
end # ReflogRegexp

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

		def sequential_matches(unmatched, regexp_array)
			capture = unmatched[-1].capture?(regexp_array[0], MatchCapture)
			pre_match = capture.pre_match
			if capture.success?
				if pre_match == ''
					[{ capture.regexp => capture.output}] + sequential_matches(capture.post_match, regexp_array[1..-1])
				else
					[pre_match, { capture.regexp => capture.output}] + sequential_matches(capture.post_match, regexp_array[1..-1])
				end # if
			else
				[regexp] + sequential_matches(capture.post_match, regexp_array[1..-1])
			end # if
		end # sequential_match
		
# includes matches with unmatches in order
		def priority_match(unmatched, regexp_array) # first match deletes string
			regexp_array.map do |regexp|    
        next unless unmatched.instance_of?(String)
					capture = unmatched.capture?(regexp, SplitCapture)
        next unless capture.success?
						delimiters = capture.delimiters.select {|delimiter| delimiter != ''}.uniq
						if delimiters == []
							[{ regexp => capture.output}]
						else
							if regexp_array.size == 1
								[{ regexp => capture.output} ] + delimiters # out of regexps to try
							else
								recurse_on_delimiters = delimiters.map do |delimiter|
									Capture.priority_match(delimiter, regexp_array[1..-1]) # one try in priority order
								end.flatten # map
								[{ regexp => capture.output} ] + recurse_on_delimiters
							end # if
						end # if
        # if
        # if
			end.flatten.uniq.compact.select {|um| um != ''}# map
		end # priority_match
		
		def show_matches(unmatches, regexp_array) # match Array of unmatches, allows delimiter recursion.
			unmatches.map do |unmatched|
				priority_match(unmatched, regexp_array)
			end.flatten # map regexp
		end # show_matches
  end # ClassMethods
  extend ClassMethods

  include Virtus.value_object
  values do
    attribute :string, String
    attribute :regexp, Regexp # Virtus does not error if this is a String or Regexp
  end # values

	def to_regexp
		Regexp.promote(@regexp)
	end # to_regexp
	


  # return a capture object for two Capture instances (assumed consecutive)
  def +(other_capture)
    raise 'Only Capture instances can be added.' unless other_capture.instance_of?(Capture)
    Capture.new(string: string + other_capture.string, regexp: [regexp, other_capture.regexp])
  end # +
  #     named_captures for captures.size > names.size
		
		def show_matches(unmatches, regexp_array) # match Array of unmatches, allows delimiter recursion.
			[@string].map do |unmatched|
				priority_match(unmatched, @regexp)
			end.flatten # map regexp
		end # show_matches

  # Capture::Assertions
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
			def assert_unmatches(unmatches)
			end # assert_unmatches
			
			def assert_show_matches(unmatches, regexp_array, expectations = {unmatches: []})
				assert_instance_of(Array, unmatches, 'unmatches should be a Array.')
				assert_instance_of(Array, regexp_array, 'regexp_array should be a Array.')
				assert_instance_of(String, unmatches[0], 'Expectations elements should be a Hash.')
				assert_instance_of(Regexp, regexp_array[0], 'regexp_array elements should be a Hash.')
				assert_instance_of(Hash, expectations, 'Expectations should be a Hash.')
				assert_equal([], expectations.keys - [:captures, :unmatches], 'Not used as an named argument.')
				show_matches = Capture.show_matches(unmatches, regexp_array)
				assert_instance_of(Array, show_matches)
				matches = show_matches.select{|match| match.instance_of?(Hash)}
        match_regexps = matches.map(&:keys)
				refute_equal(regexp_array, match_regexps )
				unmatches = show_matches.select{|match| match.instance_of?(String)}
				
				assert_equal(regexp_array.size + unmatches.size, show_matches.size, show_matches.inspect)

				unless expectations[:unmatches].nil?
					assert_equal(expectations[:unmatches], unmatches, show_matches.inspect)
				end # unless

				full_hash = []
#				full_hash = {}
				show_matches.each_with_index do |match, i|
					if match.instance_of?(Hash)
						assert_instance_of(Hash, match, show_matches)
						assert_instance_of(Array, match.keys)
						assert_includes(regexp_array, match.keys[0], match)
						match.keys.each do |key|
							assert_instance_of(Regexp, key, match)
							assert_includes(regexp_array, key, match)
						end # each
#						full_hash = full_hash.merge(match)
						assert_instance_of(Array, match.values) # SplitCapture
						match.values.each do |single_SplitCapture|
								assert_instance_of(Array, single_SplitCapture, match)
#								full_hash << single_SplitCapture.uniq
								single_SplitCapture.each do |single_capture|
#									full_hash = full_hash.merge(single_capture)
									full_hash << single_capture
									single_capture.keys.each do |capture_name|
										assert_instance_of(Symbol, capture_name, single_capture)
#										full_hash << single_SplitCapture.uniq
									end # each
									assert_instance_of(Array, single_capture.values, match)
									single_capture.values.each do |capture|
										if capture.instance_of?(String)
											assert_instance_of(String, capture, match)
										elsif capture.instance_of?(Array)
											assert_instance_of(Array, capture, match)
											capture.each do |capture_string|
												assert_instance_of(String, capture_string, single_SplitCapture)
												refute_equal(1, capture_string.size, single_SplitCapture)
											end # each
										else
											assert_instance_of(String, capture, match)
										end # if
									end # each
								end # each
						end # each
					elsif match.instance_of?(String)
						assert_includes(expectations[:unmatches], match)
						assert_match(unmatches.join, match)
					elsif match.nil?
						raise 'show_matches[' + i.to_s + '] = '  + 'show_matches = ' + show_matches.inspect
#						raise 'show_matches[' + i.to_s + '] = ' + match + 'show_matches = ' + show_matches.inspect
					else
						raise match.inspect
					end # if
					if match.instance_of?(String)
						puts match + ' did not match anything.'
					end # if

		#			assert(, match.keys, match.inspect)
				end # each
				full_hash = full_hash.uniq
				unless expectations[:captures].nil?
					assert_equal(expectations[:captures], full_hash, show_matches)
				end # unless
			end # assert_show_matches

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
			@regexp.enumerate do |regexp|
				assert_nil(Regexp.regexp_error(@regexp.to_s))
			end # enumerate
      if raw_captures.nil?
        assert(false, inspect)
      elsif raw_captures.instance_of?(MatchData)
        true
      else # :split
        if num_captures == 0 # no captures
          match_capture = MatchCapture.new(string: string, regexp: regexp)
          match_capture.assert_success
        else # captures
          if raw_captures.size < 2 # split failed
            assert(false, inspect)
          else # split succeeded
            true
          end # if
        end # if
      end # if
      assert(success?, inspect)
			need_capture = sequential_refinements.any? do |refinement|
				refinement.kind_of?(Capture)
			end # any?
			assert(need_capture, sequential_refinements.inspect)
    end # assert_success
		
    # exact match, no left-overs
    def assert_post_conditions(message = '')
      #	assert_left_match(add_default_message(message))
      #	assert_empty(post_match, 'Only a left match.' + add_default_message(message))
    end # assert_post_conditions

    def repetition_options?
      if to_regexp.respond_to?(:repetition_options)
        to_regexp.repetition_options
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

class Bisection < Capture
  include Virtus.value_object
  values do
    attribute :left_length, Fixnum, :default => lambda { |bisection, _attribute| bisection.regexp.size / 2 }
  end # values

	def next_bisection
		regexp.size / 2
	end # next_bisection
	
	def state
		
	end # state
	
	def valid?(regexp_string)
		if Regexp.regexp_rescued(regexp_string).nil?
		else
		end # if
	end # valid?
	
	def left_regexp_string
		@regexp.source[0..@left_length]
	end # left_regexp_string
	
	def right_regexp_string
		@regexp.source[@left_length..-1]
	end # right_regexp_string
	
	def match?(string)
		left_regexp = Regexp.regexp_rescued(left_regexp_string)
		right_regexp = Regexp.regexp_rescued(right_regexp_string)
		if left_regexp || right_regexp
			left_match = @string.match(left_regexp)
			right_match = @string.match(right_regexp)
			left_match || righ
		end # if
	end # match?
end # Bisection


# encapsulates the difference between parsing from MatchData and from Array#split
class RawCapture < Capture

  def num_captures
    to_regexp.named_captures.values.flatten.size
  end # num_captures

  def [](index, _hash_offset = 0)
    to_a(_hash_offset)[index]
  end # []

  def to_hash(_hash_offset = 0)
    named_hash = {}
    to_regexp.named_captures.each_pair do |named_capture, _indices| # return named subexpressions
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
    indices = to_regexp.named_captures[named_capture.to_s]
    named_hash = {}
    indices.each_index do |_capture_index, _i|
      column = GenericColumn.new(regexp_index: 0, variable: variable)
      named_hash = named_hash.merge(named_hash_column(column))
    end # each_index
    named_hash
  end # named_hash_variable

  def named_hash_column(column, hash_offset = 0)
    indices = to_regexp.named_captures[column.variable.name.to_s]
    column.to_hash(self[indices[column.regexp_index], hash_offset])
  end # named_hash_column

  # returns hash of all column names and values captured
  def named_hash(hash_offset = 0)
    named_hash = {}
    to_regexp.named_captures.each_pair do |named_capture, _indices| # return named subexpressions
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


	def priority_refinements
		if @regexp.instance_of?(Array)
			remaining_regexes = @regexp
		else
			remaining_regexes = [@regexp]
		end # if
		if @string.empty?
			MatchRefinement[]
		elsif remaining_regexes.size <= 1
			MatchRefinement[
				pre_match,
				narrowed_capture,
				post_match
			]
		else
			inside_narrowed_capture = narrowed_capture(remaining_regexes[0])
				MatchCapture.new(string: pre_match, regexp: remaining_regexes[1..-1]).priority_refinements +
			MatchRefinement[inside_narrowed_capture] +
				MatchCapture.new(string: inside_narrowed_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements
		end # if
	end # priority_refinements
	
	def next_refinement(remaining_regexes = [])
		if @string.empty?
			MatchRefinement[]
		elsif remaining_regexes.to_a.empty?
			if post_match == ''
				MatchRefinement[]
			else
				MatchRefinement[post_match]
			end # if
		else
			capture = MatchCapture.new(string: post_match, regexp: remaining_regexes[0])
			capture.next_refinement(remaining_regexes[1..-1])
		end # if
	end # next_refinement
	
	def sequential_refinements(remaining_regexes = [])
		if @string.empty?
			MatchRefinement[@string]
		else
			if success?
				MatchRefinement.new((MatchRefinement[pre_match, narrowed_capture] + next_refinement))
			else # recurse after failure
				MatchRefinement[@string]
			end # if
		end # if
	end # sequential_refinements

  # within match excluding pre_match and post_match
  def internal_delimiters
    delimiters[1..-2]
  end # internal_delimiters

			def unmatches
				delimiters.reject {|delimiter| delimiter == '' }
			end # assert_unmatches

		def assert_refinement(desired_kind, message = '')
			message += self.inspect + "\n"
#!			assert_equal(priority_refinements, sequential_refinements)
			priority_refinements.assert_match_kind(desired_kind, message)
			if @regexp.instance_of?(Array)
				assert_equal(@regexp.size, priority_refinements.captures.size, priority_refinements.inspect)
			end # if
			priority_refinements.assert_match_kind(desired_kind, message)
			if @regexp.instance_of?(Array)
				assert_equal(@regexp.size, priority_refinements.captures.size, priority_refinements.inspect)
			end # if
			assert_equal(@string, priority_refinements.join, priority_refinements.inspect)
		end # assert_refinement

		def assert_sequential(desired_kind, message = '')
			assert_refinement(desired_kind, message)
			assert_equal(@string, priority_refinements.join, priority_refinements.inspect)
		end # assert_sequential
end # RawCapture

class MatchCapture < RawCapture
  def raw_captures
    @string.match(to_regexp)
  end # raw_captures

  def success?
    if raw_captures.nil?
      nil
    else
      true
    end # if
  end # success?

  def repetitions
    if raw_captures.nil?
      0
    else
      1
    end # if
  end # repetitions

  # Tranform split and MatchData captures into single (split) form
  def to_a(_repetition = 0)
    raise raw_captures.inspect unless raw_captures.nil? || raw_captures.instance_of?(MatchData)
    raw_captures.to_a[1..-1] # discard $0 = whole string
  end # to_a

  def output
    to_hash(0)
  end # output

  def post_match
		if raw_captures.nil? # specialized to MatchCapture class
			@string # tailored to Capture.sequential_match
		else
			raw_captures.post_match
		end # if
  end # post_match

  def pre_match
    if !success?
      ''
    else
      raw_captures.pre_match

    end # if
  end # pre_match

  def matched_characters
    if raw_captures.nil?
      ''
    else
      raw_captures[0]
    end # if
  end # matched_characters

  def number_matched_characters
    matched_characters.length
  end # number_matched_characters

  def column_output
    if !success?
      {}
    elsif raw_captures.instance_of?(MatchData)
      if raw_captures.names == []
        raw_captures[1..-1] # return unnamed subexpressions
      else
        named_hash(0)
      end # if
    end # if
  end # column_output

  def delimiters
    [pre_match, post_match]
  end # delimiters

	def narrowed_capture(single_regexp = @regexp)
		if @regexp.instance_of?(Regexp)
			if success?
				MatchCapture.new(string: matched_characters, regexp: single_regexp) # narrow string
			else
				MatchCapture.new(string: @string, regexp: @regexp) # no change yet
			end # if
		elsif @regexp.instance_of?(Array)
			if success?
				MatchCapture.new(string: matched_characters, regexp: @regexp[0]) # narrow regexp
			else
				MatchCapture.new(string: @string, regexp: @regexp[0]) # try again with more specific regexp
			end # if
		else
			fail
		end # if
	end # narrowed_capture

  module Examples
    include Capture::Examples
    Branch_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Parse_string = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Branch_line_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Branch_current_capture = MatchCapture.new(string: Newline_Delimited_String, regexp: Branch_current_regexp)
		Empty_capture = MatchCapture.new(string: '', regexp: /a/)
  end # Examples
end # MatchCapture

class SplitCapture < RawCapture
  def raw_captures
    @string.split(to_regexp)
  end # raw_captures

  def success?
    if num_captures == 0 # no captures
      match_capture = MatchCapture.new(string: string, regexp: regexp)
      match_capture.success?
    else # captures
      if raw_captures.size < 2 # split failed
        false
      else # split succeeded
        true
      end # if
    end # if
  end # success?

  def repetitions
    if raw_captures.size <= 2
      0
    else
      ((raw_captures.size - 1).to_f / (num_captures + 1).to_f).ceil
    end # if
  end # repetitions

  # Tranform split and MatchData captures into single (split) form
  def to_a(repetition)
    raise raw_captures.inspect unless raw_captures.nil? || raw_captures.instance_of?(Array)
    raw_captures[1 + repetition * (num_captures + 1), num_captures] # does not include delimiters
  end # to_a

	def narrowed_capture(single_regexp = @regexp)
		if @regexp.instance_of?(Regexp)
			if success?
				SplitCapture.new(string: matched_characters, regexp: single_regexp) # narrow string
			else
				SplitCapture.new(string: @string, regexp: @regexp) # no change yet
			end # if
		elsif @regexp.instance_of?(Array)
			if success?
				SplitCapture.new(string: matched_characters, regexp: @regexp[0]) # narrow regexp
			else
				SplitCapture.new(string: @string, regexp: @regexp[0]) # try again with more specific regexp
			end # if
		else
			fail
		end # if
	end # narrowed_capture

	def priority_refinements
		if @regexp.instance_of?(Array)
			remaining_regexes = @regexp
		else
			remaining_regexes = [@regexp]
		end # if
		if @string.empty?
			MatchRefinement[]
		elsif remaining_regexes.size <= 1
			MatchRefinement[
				pre_match,
				narrowed_capture,
				post_match
			]
		else
			inside_narrowed_capture = narrowed_capture(remaining_regexes[0])
				SplitCapture.new(string: pre_match, regexp: remaining_regexes[1..-1]).priority_refinements +
			MatchRefinement[inside_narrowed_capture] +
				SplitCapture.new(string: inside_narrowed_capture.post_match, regexp: remaining_regexes[1..-1]).priority_refinements
		end # if
	end # priority_refinements

  def output
    (0..(repetitions - 1)).map do |i|
      to_hash(i)
    end # map
  end # output

  def post_match
    if raw_captures.size.odd?
      raw_captures[-1]
    else
      ''
    end # if
  end # post_match

  def pre_match
    raw_captures[0]
  end # pre_match

  def matched_characters
    @string[0, number_matched_characters]
  end # matched_characters

  def number_matched_characters
    @string.length - pre_match.length - post_match.length
  end # number_matched_characters

  def column_output
    (0..repetitions - 1).map do |i|
      named_hash(i * (num_captures + 1))
    end # map
  end # column_output
	
	def num_delimiters
		[2, 1 + (repetitions * num_captures)].max # 1 + repetitions * num_captures
	end # num_delimiters
	
	def terminations # last match at end of string 
    (num_delimiters + repetitions) - raw_captures.size
	end # terminations

	def raw_capture_size_state
		{raw_captures: raw_captures,
		raw_captures_size: raw_captures.size,
		names: to_regexp.names,
		named_captures: to_regexp.named_captures,
		num_captures: num_captures,
		repetitions: repetitions,
		terminations: terminations,
		num_delimiters: num_delimiters,
		delimiter_size: delimiters.size,
		expected_raw_size: 1 + (num_delimiters + repetitions) # prematch, all delimiters, and all captures
		}
	end # raw_capture_size_state

	def num_delimiters
		[2, 1 + (repetitions * num_captures)].max # 1 + repetitions * num_captures
	end # num_delimiters
	
	def terminations # last match at end of string 
    (num_delimiters + repetitions) - raw_captures.size
	end # terminations

  # includes pre_match and post_match
  def delimiters
    delimiters = []
    raw_captures.each_with_index do |raw_capture, _i|
      if (_i % (num_captures + 1)) == 0
        delimiters << raw_capture
      end # if
    end # each_index
    if terminations == 1
			delimiters + ['']
		else
			delimiters
		end # if
  end # delimiters
	
require_relative '../../app/models/assertions.rb'

	module Assertions
    module ClassMethods
			def assert_pre_conditions(message='')
				message+="In assert_pre_conditions, self=#{inspect}"
			#	asset_nested_and_included(:ClassMethods, self)
			#	asset_nested_and_included(:Constants, self)
			#	asset_nested_and_included(:Assertions, self)
				self
			end #assert_pre_conditions

			def assert_post_conditions(message='')
				message+="In assert_post_conditions, self=#{inspect}"
				self
			end #assert_post_conditions
	end #ClassMethods

	def assert_pre_conditions(message='')
		message+="In assert_pre_conditions, self=#{inspect}"
		self
	end #assert_pre_conditions

	def assert_post_conditions(message='')
		message+="In assert_post_conditions, self=#{inspect}"
		
		assert_equal(raw_capture_size_state[:num_delimiters], raw_capture_size_state[:raw_captures_size] -repetitions + terminations, raw_capture_size_state)
		self
	end #assert_post_conditions
	
	def assert_terminations(expected_terminations, message='')
		message+="In assert_terminations, self=#{inspect}"
		message += "\n" + raw_capture_size_state.inspect
		assert_equal(expected_terminations, terminations, message)
	end # assert_terminations
	
	def assert_repetitions(expected_repetitions, message='')
		message+="In assert_repetitions, self=#{inspect}"
		message += "\n" + raw_capture_size_state.inspect
		assert_equal(2.0, (3.0 / 2.0).ceil)
      assert_equal(expected_repetitions, ((raw_captures.size - 1).to_f / (num_captures + 1).to_f).ceil)
		assert_equal(expected_repetitions, repetitions, message)
	end # assert_repetitions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
	
  module Examples
    include Capture::Examples
    Split_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Parse_array = SplitCapture.new(string: Newline_Terminated_String, regexp: Branch_regexp)
    Branch_line_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Branch_regexp_capture = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
    Failed_capture = SplitCapture.new(string: 'cat', regexp: /fish/)
    Syntax_failed_capture = SplitCapture.new(string: 'cat', regexp: 'f)i]s}h')
    Parse_delimited_array = SplitCapture.new(string: Newline_Delimited_String, regexp: Branch_regexp)
		Empty_capture = SplitCapture.new(string: '', regexp: /a/)
  end # Examples
end # SplitCapture

# class ParsedCapture
class ParsedCapture < MatchCapture
	module ClassMethods
	end # ClassMethods
	extend ClassMethods
	
  def parsed_regexp
    Regexp::Parser.parse(regexp.to_s, 'ruby/1.8')
  end # parsed_regexp

  def raw_captures
    raise Exception.new('@string is not String but ' + @string.class.name) unless @string.instance_of?(String)
#    match_extent = @string.match(to_regexp)
    match_extent = MatchCapture.new(string: @string, regexp: to_regexp)
		if match_extent.success?
			if @parsed_regexp.instance_variables.include?(:@quantifier) # quantifier
  # limit match to :match length of string
					string = match_extent[0] # regexp matched string
#					string.split(to_regexp) # after string shortened
					SplitCapture.new(string: string, regexp: to_regexp) # after string shortened
			else
				match_extent # not yet recursing into embeded quantifiers
			end # if
		else
			match_extent
		end # if
  end # raw_captures

	def to_nested_array
	end # to_nested_array
		
	def ruby_lines_storage
		RegexpParseType.inspect_recursive(@parsed_regexp, &RegexpParseType::Mx_format) # Mx_dump_format
	end # ruby_lines_storage

  def column_output
    raw_captures.reduce({}, :merge) { |c| c[:raw_capture].output }
  end # column_output

  def delimiters
    raw_captures.reduce('', :+) { |c| c[:raw_capture].delimiters }
  end # delimiters

require_relative '../../app/models/assertions.rb'

	module Assertions
    module ClassMethods
			def assert_pre_conditions(message='')
				message+="In assert_pre_conditions, self=#{inspect}"
			#	asset_nested_and_included(:ClassMethods, self)
			#	asset_nested_and_included(:Constants, self)
			#	asset_nested_and_included(:Assertions, self)
				self
			end #assert_pre_conditions

			def assert_post_conditions(message='')
				message+="In assert_post_conditions, self=#{inspect}"
				self
			end #assert_post_conditions

	end #ClassMethods

	def assert_pre_conditions(message='')
		message+="In assert_pre_conditions, self=#{inspect}"
		self
	end #assert_pre_conditions

	def assert_post_conditions(message='')
		message+="In assert_post_conditions, self=#{inspect}"
		self
	end #assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions

  module Examples
    include Capture::Examples
    # Branch_line_capture = ParsedCapture.new(Newline_Delimited_String, Branch_line_regexp)
    Parsed_a_capture = ParsedCapture.new(string: 'a,a,', regexp: /a{2}/.capture(:label))
    Parsed_aa_capture = ParsedCapture.new(string: 'a,a,', regexp: (/a,/.capture(:label)) * 2)
    Match_a = { /(?<alpha>a)/ => [{ alpha: 'a' }] }.freeze
    Match_b = { /(?<beta>b)/ => [{ beta: 'b' }] }.freeze
    Unmatched_c = 'c'.freeze
    Ordered_matches = [Match_a, Match_b, Unmatched_c].freeze
  end # Examples
end # ParsedCapture

class LimitCapture < ParsedCapture
  # limit match to :match length of string
  def raw_captures
    raise Exception.new('@string is not String but ' + @string.class.name) unless @string.instance_of?(String)
    method = @string.method(:match)
    match = method.call(to_regexp)
    if match.nil?
      match
    else
      string = match[0] # regexp matched string
      string.method(:split).call(to_regexp) # after string shortened
    end # if
  end # raw_captures
  module Examples
    include Capture::Examples
    Branch_line_capture = LimitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
    Limit_capture = LimitCapture.new(string: Newline_Delimited_String, regexp: Branch_line_regexp)
  end # Examples
  def post_match
    raw_captures[0][:raw_capture].post_match
  end # post_match

  def pre_match
    raw_captures[0][:raw_capture].pre_match
  end # pre_match

  def matched_characters
    raw_captures.reduce('', :+) { |c| c[:raw_capture].matched_characters }
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
      capture = capture_class.new(string: self, regexp: pattern)
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
      match_capture = MatchCapture.new(string: self, regexp: pattern)
      split_capture = SplitCapture.new(string: self, regexp: pattern)
      limit_capture = SplitCapture.new(string: self[0, match_capture.number_matched_characters], regexp: pattern)
      message = "match_capture = #{match_capture.inspect}\nsplit_capture = #{split_capture.inspect}"
      #	Capture.assert_method(match_capture, limit_capture, :string, message)
      Capture.assert_method(match_capture, limit_capture, :regexp, message)
      Capture.assert_method(match_capture, limit_capture, :num_captures, message)
      #	Capture.assert_method(match_capture, split_capture, :captures, message)
      Capture.assert_method(match_capture, limit_capture, :repetitions, message)
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
      match_capture = MatchCapture.new(string: self, regexp: pattern)
      split_capture = SplitCapture.new(string: self, regexp: pattern)
      limit_capture = LimitCapture.new(string: self, regexp: pattern)
      match_capture.assert_post_conditions(message)
      split_capture.assert_post_conditions(message)
      limit_capture.assert_post_conditions(message)
      # limit repetitions to pattern, get all captures
      if split_capture.repetitions == 1
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

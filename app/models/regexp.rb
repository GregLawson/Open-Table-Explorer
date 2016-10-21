# encoding: US-ASCII
###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require 'active_model/naming'
require 'active_model/errors'
class Regexp
  # @see http://en.wikipedia.org/wiki/Kleene_algebra
  # include Comparable
  extend ActiveModel::Naming # allow ActiveModel / ActiveRecord style error attributes. Naming clash?
module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Default_options = 0 # Regexp::EXTENDED | Regexp::MULTILINE # only make sense for literals
    Ascii_characters = (0..127).to_a.map(&:chr)
    Binary_bytes = (0..255).to_a.map(&:chr)  # encoding ASCII-8BIT
    Any_binary_char_string = '[\000-\377]'.freeze
    Any = 0..Float::INFINITY
    Many = 1..Float::INFINITY
    Optional = 0..1
    Start_string = /\A/
    End_string = /\z/
    End_string_less_newline = /\Z/
    Start_line = /^/
    End_line = /$/
		Escape_types = [:escaped, :literal, :meta_character, :nonprintable, :nonprintable_but_named, :regexp_meta_character]
end # DefinitionalConstants
include DefinitionalConstants
	
  module ClassMethods
    def [](*array_form)
      if array_form.size == 1 && array_form[0].instance_of?(Array)
        array_form = array_form[0] # trim double Array nestingas Syntactic sugar
      end # if
      array_form.reduce(//, :*) do |regexp|
        case regexp.class.to_s
        when 'Regexp' then regexp
        when 'String' then Regexp.new(Regexp.escape(node))
        when 'Array' then regexp.map { |e| Regexp[e] }.join
        else
          raise "unexpected node = #{regexp.inspect}"
        end # case
      end # reduce
    end # []

    def to_regexp_escaped_string(alternative_form)
      case alternative_form.class.to_s
      when 'Regexp' then alternative_form.source
      when 'String' then Regexp.escape(alternative_form)
      when 'Fixnum' then '{' + alternative_form.to_s + '}'
      when 'Range' then
        if alternative_form.begin == alternative_form.end
          if alternative_form.begin == 1
            '' # default for {1,1}
          else
            '{' + alternative_form.begin.to_s + '}'
          end # if
        else case alternative_form.end
             when Float::INFINITY then
               case alternative_form.begin
               when 0 then '*'
               when 1 then '+'
               else
                 '{' + alternative_form.begin.to_s + ',' + '}'
               end # if
             when 1 then
               case alternative_form.begin
               when 0 then '?'
               when 1 then ''
               else
                 '{' + alternative_form.begin.to_s + ',' + alternative_form.end.to_s + '}'
               end # if
             else
               if alternative_form.begin == 0
                 '{' + ',' + alternative_form.end.to_s + '}'
               else
                 '{' + alternative_form.begin.to_s + ',' + alternative_form.end.to_s + '}'
               end # if
        end end # if and case
      when 'Array' then alternative_form.map { |a| Regexp.to_regexp_escaped_string(a) }.join
      else raise "unexpected regexp alternative_form = #{alternative_form.inspect}\nalternative_form.class = #{alternative_form.class}"
      end # case
    end # to_regexp_escaped_string

		def escape_state(character)
			raise character + ' size = ' + character.size.to_s unless character.size == 1
			regexp_escape = Regexp.escape(character)
			regexp_escape_kind = 	if character == regexp_escape
				:literal
			else case regexp_escape.size
				when 2 
					if character == regexp_escape[1] 
						:meta_character
					else
						:escaped
					end # if
				when 4 then :binary_byte # e.g. /x00
					:binary_byte
				when 6 then :utf8_chgaracter # e.g. /u0000
					:utf8_wide_character
				else
					raise character.inspect + ' unexpected.'
				end # case
			end # if
			{character: character,
				state: {
					character_size: character.size,
					regexp_escape_length: regexp_escape.size,
					regexp_error: !Regexp.regexp_error(character).nil?,
					string_same: regexp_escape == character.to_s,
					regexp_escape_kind: regexp_escape_kind
					}
				}
		end # escape_state

		def state_characters
			
		end # state_characters
		
		def escape_type(character)
			# use Regexp.escape to classify escape sequences but also identify anomalous escape sequences
			# Regexp escape sequences != String escape sequences
			# named but inconsistantly handled escape sequences
			regexp_escape = Regexp.escape(character)
			byte = character.codepoints[0]
			case regexp_escape.size
			when 1 
				if character == "\b" || character == "\a"
					:nonprintable_but_named
				elsif (byte < 32) || (byte >= 127)
					:nonprintable
				elsif character == '"' || character == "'" || character == "/"
					:regexp_meta_character
				else
					:literal
				end # if
			when 2 
				if character == regexp_escape[1] 
					:meta_character
				else
					:escaped
				end # if
			when 4 then :nonprintable # e.g. /x00
			when 6 then :nonprintable # e.g. /u0000
			else
				raise character.inspect + ' unexpected.'
			end # case
		end # escape_type
		
		def hex_escape(character)
			'\x' + ("%02X" % character.codepoints[0])
		end # hex_escape
		
		def escape_character(character)
			regexp_escape = Regexp.escape(character)
			case Regexp.escape_type(character)
			when :literal
				character
			when :nonprintable
				hex_escape(character)
			when :meta_character, :regexp_meta_character
				'\\' + character # escape back slash works inside single quotes!
			when :nonprintable_but_named
					character.inspect[1..-2] # /a and /b
			when :escaped
				'\\' + regexp_escape[1] # escape back slash works inside single quotes!
			else
				raise character.inspect + ' unexpected.'
			end # case
		end # escape_character
		
		def inspect_character(character)
			escape = case Regexp.escape_type(character)
			when :literal
				quote = "'"
			else
				if character == '"'
					quote = "'"
				else
					quote = '"'
				end # if
			end # case
			quote + escape_character(character) + quote + 
				' ' + Regexp.escape(character).inspect +
				' /' + escape_character(character) + '/'+ 
				' (' + hex_escape(character) + ' ' + character.encoding.to_s + ')'
		end # inspect_character
		
		def readably_escaped(regexp)
			# according to documentation see: https://ruby-doc.org/core-2.1.1/Regexp.html#method-c-escape
			#	Regexp.new(Regexp.escape(str)) =~ str
			correct_escape = regexp.source.bytes.map do |byte|
				regexp_escape = Regexp.escape(byte.chr)
				if regexp_escape != byte.chr # multicharacter escape sequence
					regexp_escape
				elsif (byte < 32) || (byte >= 127)
					hex_escape(byte.chr)
				else
					regexp_escape
				end # if
			end.join # map
		end # readably_escaped
		
    def promote(alternative_form)
      case alternative_form.class.to_s
      when 'Regexp' then alternative_form
      else
        Regexp.new(to_regexp_escaped_string(alternative_form))
        #		raise "unexpected regexp alternative_form = #{alternative_form.inspect}\nalternative_form.class = #{alternative_form.class.to_s}"
      end # case
    end # promote

    # Rescue bad regexp and return nil
    # Example regexp with unbalanced bracketing characters
    def regexp_rescued(regexp_string, options = Regexp::Default_options)
      raise "expecting regexp_string=#{regexp_string}" unless regexp_string.instance_of?(String)
      return Regexp.new(regexp_string, options)
    rescue RegexpError => exception_raised
      return nil
    end # regexp_rescued

    def regexp_error(regexp_string)
      raise "Argument to regexp_error is expected to be a String; but regexp_string=#{regexp_string.inspect}" unless regexp_string.instance_of?(String)
      Regexp.new(regexp_string) # test
      return nil # if no RegexpError
    rescue RegexpError => exception
      return exception
    end # regexp_error

		def select_characters(escape_type)
			raise escape_type.inspect + ' not in ' + Regexp::Escape_types.inspect unless Regexp::Escape_types.include?(escape_type)
			Regexp::Binary_bytes.select do |character|
				escape_type(character) == escape_type
			end # select
		end # select_characters

		def nonprintable_characters
			Regexp::Binary_bytes.select do |character|
				escape = Regexp.escape(character)
				if escape.size == 4
					true
				else
					false
				end # if
			end # select
		end # nonprintable_characters
		
    # A terminator is a delimiter that is at the end (like new line)
    def terminator_regexp(delimiter)
      #	raise "delimiter must be single characters not #{delimiter}." if delimiter.length!=1
      /([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
    end # terminator_regexp

    # A delimiter is generally not at the end (like commas)
    def delimiter_regexp(delimiter)
      raise "delimiters must be single characters not #{delimiter.inspect}." if delimiter.length != 1
      /([^#{delimiter}]*)(?:#{delimiter}([^#{delimiter}]*))*/
    end # delimiter_regexp

    # the useful inverse function of new. String to regexp
    def canonical_repetition_tree(min, max = nil)
      if max.nil?
        if min.instance_of?(Range)
          max = min.end
          min = min.begin
        elsif
          max = min # fixed repetitions
        end # if
      end # if
      if max == Float::INFINITY
        return ['{', min.to_i, ',', '}']
      elsif min == max
        return ['{', min.to_i, '}']
      else
        return ['{', min.to_i, ',', max.to_i, '}']
      end # if
    end # canonical_repetition_tree

    # Return a RegexpTree node for self
    # Concise means to use abbreviations like '*', '+', ''
    # rather than the canonical {n,m}
    # If no repetition returns '' equivalent to {1,1}
    def concise_repetition_node(min, max = nil)
      if max == Float::INFINITY
        if min.to_i == 0
          return '*'
        elsif min.to_i == 1
          return '+'
        end # if
      elsif min.to_i == 0 && max.to_i == 1
        return '?'
      elsif min.to_i == 1 && max.to_i == 1
        return ''
      end # if
      canonical_repetition_tree(min, max).join
    end # concise_repetition_node
  end # ClassMethods
  extend ClassMethods
  # Modeled on Numeric.coerce
  # If a +alternative_form is the same type as self, returns an array containing alternative_form and self.
  # Otherwise, returns an array with both a alternative_form and self represented as Regexp objects or to_regexp_escaped_string.
  # This coercion mechanism is modeled on Ruby's handleing of mixed-type numeric operations:
  # it is intended to find a compatible common type between the two operands of the operator.
  # 1.coerce(2.5)   #=> [2.5, 1.0]
  # 1.2.coerce(3)   #=> [3.0, 1.2]
  # 1.coerce(2)     #=> [2, 1]
  def coerce_escaped_string(alternative_form)
    #	if self.class == alternative_form.class then
    #		[alternative_form, self]
    #	else
    [Regexp.to_regexp_escaped_string(self), Regexp.to_regexp_escaped_string(alternative_form)]
    #	end # if
  end # coerce_escaped_string

  def propagate_options(regexp)
    if regexp.instance_of?(Regexp)
      ret = [(casefold? && regexp.casefold? ? Regexp::IGNORECASE : 0)]
      ret += [regexp.encoding]
    else
      [Regexp::Default_options, Encoding::US_ASCII]
    end # if
  end # propagate_options

  def unescaped_string
    source.to_s
  end # unescape

  def *(other)
    coerced_arguments = coerce_escaped_string(other)
    options = propagate_options(other)
    case other
    #	when Regexp then return Regexp.new(self.unescaped_string + other.unescaped_string)
    #	when String then return Regexp.new(self.unescaped_string + Regexp.escape(other))
    #	when Fixnum then return Regexp.new(self.unescaped_string  + '{' + other.to_s + '}')
    #	when Range then return Regexp.new(self.unescaped_string + '{' + other.begin.to_s + ',' + other.end.to_s + '}')
    when NilClass then raise 'Right argument of :* operator evaluated to nil.'\
                              "\nPossibly add parenthesis to control operator versus method precedence."\
                              "\nIn order to evaluate left to right, place parenthesis around operator expressions."
                       "\nself=#{inspect}"
    else
      escaped_string = coerced_arguments[0] + coerced_arguments[1]
      encoded_string = escaped_string.force_encoding(options[1])

      Regexp.new(encoded_string, options[0])
      #		raise "other.class=#{other.class.inspect}"
    end # case
  end # sequence

  def |(other) # |
    Regexp.new(unescaped_string + '|' + other.unescaped_string)
    #	return Regexp.union(Regexp.new(self.unescaped_string), Regexp.promote(other).unescaped_string)
  end # alterative

  def capture(key = nil)
    if key.nil?
      /(#{source})/
    else
      /(?<#{key.to_s}>#{source})/
    end # if
  end # capture

  # capture backreferences must be all numbered or all named.
  def back_reference(key)
    /#{source}\k<#{key.to_s}>/
  rescue RegexpError => exception
    warn "back_reference regexp=/#{source}\k<#{key}>/ failed."\
          "\nPossibly add parenthesis to control operator versus method precedence."\
          "\nIn order to evaluate left to right, place parenthesis around operator expressions."
  end # back_reference

  def group # non-capturing "parenthesis" for forcing operator precedence
    /(?:#{source})/
  end # group

	def group_not_needed?
		source.size == 1
	end # group_not_needed?
	
  def optional
		if group_not_needed?
			/#{source}?/
		else
			group * Optional
		end # if
	end # optional

  def exact
		Regexp::Start_string * self * Regexp::End_string
	end # exact

  def at_start
		Regexp::Start_string * self
	end # at_start

  def at_end
		self * Regexp::End_string
	end # at_end

  def exact_line
		Regexp::Start_string * self * Regexp::End_string
	end # exact

  def at_start_line
		Regexp::Start_string * self
	end # at_start

  def at_end_line
		self * Regexp::End_string
	end # at_end

  module Assertions
    module ClassMethods
      def assert_post_conditions
      end # assert_post_conditions

      def assert_pre_conditions
      end # assert_pre_conditions
			
			def assert_readably_escaped(character)
			# according to documentation see: https://ruby-doc.org/core-2.1.1/Regexp.html#method-c-escape
			#	Regexp.new(Regexp.escape(str)) =~ str
				refute_nil(Regexp.new(Regexp.escape(character)) =~ character)
				assert_match(Regexp.new(Regexp.escape(character)), character)
				assert_match(Regexp.new(Regexp::Start_string.source + Regexp.escape(character) + Regexp::End_string.source), character, Regexp.inspect_character(character))
				assert_match(Regexp::Start_string * Regexp.new(Regexp.escape(character)) * Regexp::End_string, character, Regexp.inspect_character(character))

				escape = Regexp.escape_character(character)
				assert_instance_of(String, escape, 'By definition.')
				escaped_regexp = eval('/' + escape + '/') # escapes in Regexp literals may not match String escapes!
				regexp = Regexp.regexp_rescued(character)
				if regexp.nil?
					assert_equal(:meta_character, Regexp.escape_type(character))
				else
					assert_equal(character, regexp.source, Regexp.inspect_character(character))
				end # if
				case Regexp.escape_type(character)
				when :literal
					assert_equal(1, escape.size, Regexp.inspect_character(character) + ' is not a literal character.')
					assert_equal(character, escape)
					assert_equal(character, escaped_regexp.source, Regexp.inspect_character(character))
				when :nonprintable
					assert_equal(4, escape.size, Regexp.inspect_character(character) + ' is not a nonprintable character.')
					if character == '/x00'
						assert_equal(character, escaped_regexp.source, Regexp.inspect_character(character))
					else
						assert_equal(escape, escaped_regexp.source, Regexp.inspect_character(character))
					end # if
				when :meta_character
					assert_equal(2, escape.size, Regexp.inspect_character(character) + ' is not an meta_character character.')
					assert_equal(escape, '\\' + character)
					if character == '/'
						assert_equal(character, escaped_regexp.source, Regexp.inspect_character(character))
					else
						assert_equal(escape, escaped_regexp.source, Regexp.inspect_character(character))
					end # if
				when :escaped
					assert_equal(2, escape.size, Regexp.inspect_character(character) + ' is not an escaped character.')
					refute_equal("\\" + character, escape)
					assert_equal(escape, escaped_regexp.source, Regexp.inspect_character(character))
				else
					raise character.inspect + ' unexpected.'
				end # case

#				regexp = Regexp.new(Regexp.readably_escaped(character))
#				assert_equal(regexp.source, Regexp.new(Regexp.readably_escaped(regexp)).source, Regexp.inspect_character(character))
#				assert_equal(regexp.options, Regexp.new(Regexp.readably_escaped(regexp)).options, Regexp.inspect_character(character))
#				assert_equal(regexp.inspect, Regexp.new(Regexp.readably_escaped(regexp)).inspect, Regexp.inspect_character(character))
				regexp = Regexp::Start_string * Regexp.new(Regexp.escape(character)) * Regexp::End_string
#				assert_equal(regexp.source, Regexp.new(Regexp.readably_escaped(regexp)).source, Regexp.inspect_character(character))
				assert_equal(regexp.options, Regexp.new(Regexp.readably_escaped(regexp)).options, Regexp.inspect_character(character))
#				assert_equal(regexp.inspect, Regexp.new(Regexp.readably_escaped(regexp)).inspect, Regexp.inspect_character(character))
			end # assert_readably_escaped
			
    end # ClassMethods
		
    def assert_named_captures
      assert_operator(names.size, :>=, 1, named_captures.inspect)
      assert_operator(named_captures.size, :>=, 1, named_captures.inspect)
      assert_equal(names, named_captures.keys)
      all_indices = named_captures.values.flatten.sort
      assert_equal((1..all_indices.size).to_a, all_indices)
    end # assert_named_captures

    def assert_pre_conditions
      # by definition 	assert_match(Regexp.new(Regexp.escape(str), str)
      #	assert_equal(self, Regexp.promote(self))
      #	assert_equal(self, /#{self.unescaped_string}/)
      #	assert_equal(self, Regexp.promote(self).unescaped_string)
    end # assert_pre_conditions

    def assert_post_conditions
    end # assert_post_conditions

    def assert_no_exception(message)
    end # assert_no_exception
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end #Regexp

class RegexpError
  def assert_pre_conditions
    #	assert_instance_of(RegexpError, Regexp.regexp_error('['))
    #	assert_instance_of(String, backtrace[0])
    #	assert_match(/regexp/, backtrace[0])
    #	assert_instance_of(Thread::Backtrace::Location, backtrace_locations[0])
    #	assert_equal('initialize', backtrace_locations[0].base_label)
    #	assert_equal('initialize', backtrace_locations[0].label)
    #	assert_instance_of(Fixnum, backtrace_locations[0].lineno)
    #	assert_match(/[a-z.]+/, backtrace_locations[0].path)
    #	assert_match(/[a-z.\/]+/, backtrace_locations[0].absolute_path)
    #	assert_equal(message, self.message)
  end # assert_pre_conditions
end # RegexpError

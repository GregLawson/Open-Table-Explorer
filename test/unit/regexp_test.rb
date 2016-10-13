# encoding: US-ASCII
###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
#assert_global_name(:AssertionFailedError)
require_relative '../assertions/regexp_assertions.rb'
class RegexpTest < TestCase
#  include DefaultTests
#  extend DefaultTests
	include Regexp::Examples
	def test_Constants
	end # Constants

	def test_square_brackets
		assert_equal(/a/, Regexp[/a/])
		assert_equal(/a/, Regexp['a'])
		assert_equal(/ab/, ['a', /b/].reduce(//, :*))
		assert_equal(/ab/, Regexp['a', /b/])
		assert_equal(/ab/, Regexp[['a', /b/]])
		assert_equal(/ab/, Regexp['a', [/b/]])
	end # []

  def test_to_regexp_escaped_string
    assert_equal('ab', Regexp.to_regexp_escaped_string(/ab/))
    assert_equal('ab', Regexp.to_regexp_escaped_string('ab'))
    assert_equal('{5}', Regexp.to_regexp_escaped_string(5))
    assert_equal('', Regexp.to_regexp_escaped_string(1..1))
    assert_equal('{5}', Regexp.to_regexp_escaped_string(5..5))
    assert_equal('*', Regexp.to_regexp_escaped_string(Any))
    assert_equal('+', Regexp.to_regexp_escaped_string(Many))
    assert_equal('{5,}', Regexp.to_regexp_escaped_string(5..Float::INFINITY))
    assert_equal('?', Regexp.to_regexp_escaped_string(Optional))
    assert_equal('{1,5}', Regexp.to_regexp_escaped_string(1..5))
    assert_equal('{,5}', Regexp.to_regexp_escaped_string(0..5))
    assert_equal('{2,5}', Regexp.to_regexp_escaped_string(2..5))
  end # to_regexp_escaped_string

	def test_escape_type
		assert_equal(:literal, Regexp.escape_type('a'))
		assert_equal(:nonprintable, Regexp.escape_type("\x00"))
		assert_equal(:meta_chararcter, Regexp.escape_type("\("))
		assert_equal(:escaped, Regexp.escape_type("\t"))

		assert_equal(:meta_chararcter, Regexp.escape_type('"'))
		assert_equal(:meta_chararcter, Regexp.escape_type("'"))
		assert_equal(:escaped, Regexp.escape_type("\a"))
		assert_equal(:nonprintable, Regexp.escape_type("\x00"))
		end # escape_type
		
	def test_hex_escape
		assert_equal('\x00', Regexp.hex_escape("\x00"))
		character = "\x00"
		escape = '\x' + ("%02X" % character.codepoints[0])
		assert_equal([0], character.codepoints, Regexp.inspect_character(character))
		assert_equal(character, eval('"' + escape + '"'), Regexp.inspect_character(character))
		Binary_bytes.each do |character|
			escape = Regexp.hex_escape(character)
			assert_equal(character, eval('"' + escape + '"').force_encoding(Encoding::ASCII_8BIT), Regexp.inspect_character(character))
			assert_match(eval('/^' + escape + '$/'), character, Regexp.inspect_character(character))
		end # each
	end # hex_escape
	
	def test_escape_character
		assert_equal("\'", Regexp.escape_character("'"))
		assert_equal("\a", Regexp.escape_character("\a"), Regexp.inspect_character("\a"))
#		assert_equal('\"', Regexp.escape_character('"'), Regexp.inspect_character('"'))
		Binary_bytes.each do |character|
			escape = Regexp.escape_character(character)
#			assert_equal(escape, eval('"' + escape + '"'), Regexp.inspect_character(character))
#			assert_match(eval('/^' + escape + '$/'), character, Regexp.inspect_character(character))
		end # each
	end # escape_character
		
		def test_inspect_character
				assert_equal([32], ' '.codepoints)
				assert_equal(0x20, ' '.codepoints[0])
				assert_equal('65', "%02X" % 0x65)
			character = 'a'
			escaped = Regexp.reversably_escaped(Regexp.new(character))
			if escaped.size == 1
				quote = "'"
			else
				quote = '"'
			end # if
			quote + escaped + quote + ' (' + Regexp.hex_escape(character) + ')'
			
#			assert_equal("'a'", "'" + Regexp.reversably_escaped(Regexp.new(character)))
#				assert_equal('"a" (0x61)', Regexp.inspect_character('a'))
#				assert_equal('"\x00" (0x00)', Regexp.inspect_character("\00"))
#				assert_equal('"\/" (0x65)', Regexp.inspect_character('/')) # slash not escaped!
#				assert_equal('"\t" (0x09)', Regexp.inspect_character("\t"))
#			assert_equal('"\x00" (0x00)', Regexp.inspect_character("\00"))
#			assert_equal('"\/" (0x65)', Regexp.inspect_character('/')) # slash not escaped!
#			assert_equal('"\t" (0x09)', Regexp.inspect_character("\t"))
		end # inspect_character
		
	def test_regexp_escape_bug
		unescaped_control_characters = (0..31).to_a.map(&:chr)
		unescaped_control_characters.each do |character|
#			assert_equal(character, Regexp.escape(character), Regexp.inspect_character(character))
		end # each
	end # regexp_escape_bug
		
	def test_reversably_escaped
		assert_equal(' ', / /.source)
		assert_equal('\ ', /\ /.source)
		assert_equal('\ ', Regexp.escape(' '))
		assert_equal('\ ', Regexp.escape(/ /.source))
		regexp = /a/
		correct_escape = regexp.source.bytes.map do |byte|
			assert_instance_of(Fixnum, byte)
			if (byte < 32) || (byte >= 127)
				hex_escape(byte.chr)
			else
				Regexp.escape(byte.chr)
			end # if
		end # map
		Regexp.escaped_characters.each do |character|
#			regexp = Regexp.new(character)
#			assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
#			assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
		end # each
		Regexp.nonprintable_characters.each do |character|
			regexp = Regexp.new(character)
			assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
			assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
		end # each
		Regexp.meta_characters.each do |character|
#			regexp = Regexp.new(character)
#			assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
#			assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
		end # each
		character = '/'
		regexp = /\//
		assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
#		assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
		Regexp.literal_characters.each do |character|
			regexp = Regexp.new(character)
#			assert_equal(regexp.source, Regexp.new(Regexp.reversably_escaped(regexp)).source, Regexp.inspect_character(character))
#			assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
#			assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
		end # each

		regexp = /\ /
#		assert_equal(regexp, Regexp.new(Regexp.reversably_escaped(regexp)), Regexp.inspect_character(character))
#		assert_equal(regexp, eval('/' + Regexp.reversably_escaped(regexp) + '/'), Regexp.inspect_character(character))
#		assert_equal(/ /.source, /\ /.source)
#		assert_equal(/ /, /\ /)
#		assert_equal('\ ', Regexp.escape(/\ /.source))
	end # reversably_escaped

	def test_promote
		assert_equal(/ab/, Regexp.promote(/ab/))
		assert_equal(/ab/, Regexp.promote('ab'))
		assert_raises(RegexpError) {Regexp.promote(5)}
		assert_raises(RegexpError) {Regexp.promote(2..5)}
	end #promote

  def test_regexp_rescued
    assert_equal(/]/, Regexp.regexp_rescued(']'))
    assert_equal(nil, Regexp.regexp_rescued('['))
    assert_equal(/}/, Regexp.regexp_rescued('}'))
    assert_equal(/{/, Regexp.regexp_rescued('{'))
    assert_equal(nil, Regexp.regexp_rescued(')'))
    assert_equal(nil, Regexp.regexp_rescued('('))
    assert_nothing_raised(RuntimeError) { Regexp.regexp_rescued(']') } # Regexp error rescued
    assert_raises(RuntimeError) { Regexp.regexp_rescued(/]/) } # Regexp literal syntax error
  end # regexp_rescued

  def test_regexp_error
    assert_equal(nil, Regexp.regexp_error(']'))

    assert_instance_of(RegexpError, Regexp_exception)
    assert_equal('premature end of char-class: /[/', Regexp.regexp_error('[').message)
    #	assert_instance_of(Thread::Backtrace::Location, Regexp.regexp_error('[').backtrace_locations[0])
    assert_instance_of(String, Regexp.regexp_error('[').backtrace[0])
    assert_equal(nil, Regexp.regexp_error('}'))
    assert_equal(nil, Regexp.regexp_error('{'))
    assert_instance_of(RegexpError, Regexp.regexp_error(')'))
    assert_instance_of(RegexpError, Regexp.regexp_error('('))
    assert_equal(nil, Regexp.regexp_error(']'))
    assert_raises(RuntimeError) { Regexp.regexp_error(/]/) } # String only
    assert_nothing_raised(RuntimeError) { Regexp.regexp_error(']') } # Regexp error rescued
    assert_raises(RuntimeError) { Regexp.regexp_error(/]/) } # Regexp literal syntax error
  end # regexp_error

		def test_select_characters
#			assert_equal('\a\b\t\n\v\f\r', Regexp.select_characters(:escaped).map {|c| Regexp.escape_character(c)}.join)
#			assert_equal('0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz', Regexp.select_characters(:literal).map {|c| Regexp.escape_character(c)}.join)
#			assert_equal(' \#$()*+-.?[\\]^{|}', Regexp.select_characters(:meta_character).map {|c| Regexp.escape_character(c)}.join)
#			assert_equal('\x00\x01\x02\x03\x04\x05\x06\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF', Regexp.select_characters(:nonprintable).map {|c| Regexp.escape_character(c)}.join)
		end # select_characters

		def test_literal_characters
			assert_include(Regexp.literal_characters, 'a')

			character = "\n"
			escape = Regexp.escape(character)
			assert_equal(2, escape.size, escape.inspect)
			refute_equal(escape, character)
			assert_equal('\n', escape)

			character = "\x00"
			escape = Regexp.escape(character)
			assert_instance_of(String, escape)
			expected_escape = '\x00'
#			assert_equal(4, expected_escape.size, Regexp.inspect_character(expected_escape))
			assert_equal("\x00", escape)
			assert_equal('\x00', Regexp.hex_escape(character))
#			assert_equal('\x00', escape, Regexp.inspect_character(expected_escape))
#			assert_equal(expected_escape, escape, Regexp.inspect_character(expected_escape))
#			assert_equal(4, escape.size, Regexp.inspect_character(escape))
#			assert_equal(expected_escape, escape, Regexp.inspect_character(expected_escape))
#			refute_equal(escape, character, Regexp.inspect_character(expected_escape))

			Regexp.literal_characters.each do |character|
				escape = Regexp.escape(character)
#				assert_match(Regexp.new(Regexp.escape(character)), character, Regexp.inspect_character(expected_escape))
				assert_equal(1, escape.size, Regexp.inspect_character(character) + ' is not a literal character.')
				assert_equal(character, escape)
			end # each
#			assert_equal('0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz', Regexp.literal_characters.join)
		end # literal_characters
		
		def test_escaped_characters
			assert_include(Regexp.escaped_characters, "\t")
			Regexp.escaped_characters.each do |character|
				escape = Regexp.escape(character)
				assert_equal(2, escape.size, Regexp.inspect_character(character) + ' is not an escaped character.')
#				refute_equal("\\" + character, escape)
			end # each
#			assert_equal('\t', Regexp.escaped_characters.join)
		end # escaped_characters
		
		def test_meta_characters
			assert_include(Regexp.meta_characters, "{")
			Regexp.meta_characters.each do |character|
				escape = Regexp.escape(character)
				assert_equal(2, escape.size, Regexp.inspect_character(character) + ' is not a meta character.')
				assert_equal("\\" + character, escape)
			end # each
#			assert_equal(' \#$()*+-.?[\\]^{|}', Regexp.meta_characters.join)
		end # meta_characters
		
		def test_nonprintable_characters
#			assert_include(Regexp.nonprintable_characters, "{")
			Regexp.nonprintable_characters.each do |character|
				escape = Regexp.escape(character)
				assert_equal(1, character.size, Regexp.inspect_character(character) + ' is not a nonprintable character.')
#				assert_equal('\x' + "%02X" % character.codepoints[0], escape, Regexp.inspect_character(character))
#				assert_equal(4, escape.size, Regexp.inspect_character(character) + ' is not a nonprintable character.')
			end # each
#			assert_equal('\x00\x01\x02\x03\x04\x05\x06\\x00\x01\x02\x03\x04\x05\x06\\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF', Regexp.nonprintable_characters.join)
		end # nonprintable_characters
		
  def test_terminator_regexp
  end # terminator_regexp

  def test_delimiter_regexp
  end # delimiter_regexp

  def test_canonical_repetition_tree
    assert_equal(['{', 0, ',', '}'], Regexp.canonical_repetition_tree(Any))
    assert_equal(['{', 2, '}'], Regexp.canonical_repetition_tree(2, 2))
    assert_equal(['{', 1, ',', 2, '}'], Regexp.canonical_repetition_tree(1, 2))
  end # canonical_repetition_tree

  def test_concise_repetition_node
    assert_equal('*', Regexp.concise_repetition_node(0, Float::INFINITY))
    assert_equal('+', Regexp.concise_repetition_node(1, Float::INFINITY))
    assert_equal('?', Regexp.concise_repetition_node(0, 1))
    assert_equal('', Regexp.concise_repetition_node(1, 1))
    assert_equal('{1,2}', Regexp.concise_repetition_node(1, 2))
    assert_equal('{1,2}', Regexp.concise_repetition_node(1, 2))
    assert_equal('{2}', Regexp.concise_repetition_node(2, 2))
  end # concise_repetition_node

  def test_coerce_escaped_string
    assert_equal('{3}', /a/.coerce_escaped_string(3)[1])
  end # coerce_escaped_string

  def test_propagate_options
    sElf = /a/
    other = 3
    assert_equal([0, Encoding::US_ASCII], sElf.propagate_options(/a/))
    assert_equal([0, Encoding::UTF_8], sElf.propagate_options(/pat/u)) # UTF-8
    assert_equal([0, Encoding::EUC_JP], sElf.propagate_options(/pat/e)) # EUC-JP
    assert_equal([0, Encoding::Windows_31J], sElf.propagate_options(/pat/s)) # Windows-31J
    assert(defined? Regexp)
    #	assert(defined? Regexp::CASE_FOLD)
    assert_equal([0, Encoding::US_ASCII], sElf.propagate_options(/a/x))
    # ruby-bug    assert_equal(Encoding::ASCII_8BIT, /pat/n.encoding) # ASCII-8BIT
    # ruby-bug    assert_equal([0, Encoding::BINARY], sElf.propagate_options(/pat/n)) # ASCII-8BIT
    # ruby-bug    assert_equal([0, Encoding::ASCII_8BIT], sElf.propagate_options(/pat/n)) # ASCII-8BIT
    #	Tests inspired by examples in http://www.ruby-doc.org/core-2.1.1/Regexp.html#method-i-casefold-3F
    assert(!/a/.casefold?) #=> false
    assert(/a/i.casefold?) #=> true
    assert(!/(?i:a)/.casefold?) #=> false
    #	Tests inspired by examples in http://www.ruby-doc.org/core-2.1.1/Regexp.html#method-i-eql-3F
    assert(/abc/  != /abc/x)   #=> false
    assert(/abc/  != /abc/i)   #=> false
    assert(/abc/  != /abc/u)   #=> false
    assert(/abc/u != /abc/n)   #=> false
  end # propagate_options

  def test_unescaped_string
    assert_equal(/#{Escape_string}/, Regexp.new(Escape_string))
    assert_equal(Escape_string, Regexp.new(Escape_string).source)
    assert_equal(Escape_string, Regexp.new(Escape_string).unescaped_string)
    assert_equal('\\n', /\n/.source)
    assert_match(Ip_number_pattern, '123')

    assert_equal(Escape_string, Regexp.new(Escape_string).unescaped_string)
    assert_match(Regexp.new(Ip_number_pattern.unescaped_string), '123')
    ip_pattern = Regexp.new(Array.new(4, Ip_number_pattern.unescaped_string).join('.'))
    assert_match(ip_pattern, '123.2.3.4')
  end # unescape

  def test_sequence
    assert_equal('(?-mix:a)', /a/.to_s)
    assert_equal('/a/', /a/.inspect)
    assert_equal('a', /a/.unescaped_string)
    assert_equal('(?-mix:\\n)', /\n/.to_s)
    assert_equal('/\\n/', /\n/.inspect)
    assert_equal(/a/, Regexp.new(/a/.source))
    assert_equal('a', Regexp.promote(/a/).source)
    assert_equal('a', Regexp.promote(/a/).source)
    assert_equal('a', /a/.coerce_escaped_string(3)[0])
    sELF = /a/
    other = 3
    coerced_arguments = sELF.coerce_escaped_string(other)
    assert_equal('{3}', sELF.coerce_escaped_string(3)[1])
    options = sELF.propagate_options(other)
    assert_equal(/a{3}/, Regexp.new('a' + '{3}'))
    escaped_string = coerced_arguments[0] + coerced_arguments[1]
    Regexp.to_regexp_escaped_string(coerced_arguments[1])
    assert_equal('{3}', coerced_arguments[1])
    assert_equal('a{3}', escaped_string)
    encoded_string = escaped_string.force_encoding(options[1])
    assert_equal('a{3}', encoded_string)
    Regexp.new(encoded_string, options[0])
    assert_equal(/a{3}/, /a/ * 3)
    assert_equal(/a{1,3}/, /a/ * (1..3))
    assert_equal(/a\n/, /a/ * "\n")
    assert_match(/a/ * "\n", "a\n")
  end # sequence

  def test_alterative
    assert_equal(/a|b/, /a/ | /b/)
  end # alterative

  def test_capture
    regexp = /\d/
    str = 'a2c'
    matchData = regexp.capture.match(str)
    message = "matchData.inspect=#{matchData.inspect}"
    assert_equal('2', matchData[0], message)
    assert_equal('2', matchData[1], message)
    assert_equal('2', regexp.capture.match(str)[1])
    matchData = regexp.capture(:digit).match(str)
    message = "matchData.inspect=#{matchData.inspect}"
    #	refute_nil(matchData, message)
    assert_match(/([a-z])/, str, message)
    matchData = /\$(?<dollars>\d+)\.(?<cents>\d+)/.match('$3.67')
    message = "matchData.inspect=#{matchData.inspect}"
    assert_match(/\$(?<dollars>\d+)\.(?<cents>\d+)/, '$3.67', message)
    assert_match(/(?<dollars>\d+)\.(?<cents>\d+)/, '$3.67', message)
    assert_match(/(?<dollars>\d+)\./, '$3.67', message)
    assert_match(/(?<digit>\d)/, '$3.67', message)
    assert_match(/(?'letter'[a-z])/, str, message)
    assert_match(/(?<letter>[a-z])/, str, message)
    assert_match(/(?<digit>[0-9])/, str, message)
    assert_match(regexp.capture(:digit), str, message)
    assert_equal('2', regexp.capture(:digit).match('a2c')[:digit])
  end # capture

  def test_back_reference
    regexp1 = /(?<vowel>[aeiou]).\k<vowel>.\k<vowel>/
    assert_match(regexp1, 'ototomy', 'Regexp doc example.')
    assert_equal('ototo', regexp1.match('ototomy')[0])
    assert_equal('o', regexp1.match('ototomy')[1])
    #	regexp2=/[aeiou]/.capture(:vowel)*/./.back_reference(:vowel)*/./.back_reference(:vowel)
    assert_match(Back_reference, 'ototomy', 'Regexp doc example.')
  end # back_reference

  def test_group
    regexp = /\d/
    str = 'a2c'
    matchData = regexp.group.match(str)
    message = "matchData.inspect=#{matchData.inspect}"
    assert_equal('2', matchData[0], message)
  end # group

  def test_assert_pre_conditions
    assert_instance_of(RegexpError, Regexp_exception)
    assert_instance_of(String, Regexp_exception.backtrace[0])
    assert_match(/regexp/, Regexp_exception.backtrace[0])
    #	assert_includes([:Thread::Backtrace::Location], Regexp_exception.backtrace_locations[0].class.name)
    #	assert_equal('initialize', Regexp_exception.backtrace_locations[0].base_label)
    #	assert_equal('initialize', Regexp_exception.backtrace_locations[0].label)
    #	assert_instance_of(Fixnum, Regexp_exception.backtrace_locations[0].lineno)
    #	assert_match(/[a-z.]+/, Regexp_exception.backtrace_locations[0].path)
    #	assert_match(/[a-z.\/]+/, Regexp_exception.backtrace_locations[0].absolute_path)
    assert_equal('premature end of char-class: /[/', Regexp_exception.message)
    Regexp.new('}').assert_pre_conditions
    Regexp.new('{').assert_pre_conditions
    Regexp.regexp_error(')').assert_pre_conditions
    Regexp.regexp_error('(').assert_pre_conditions
    Regexp.new(']').assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_named_captures
    /a/.capture(:a).assert_named_captures
    (/a/.capture(:a) * /b/.capture).assert_named_captures
    regexp = /b/.capture
    message = regexp.inspect
    assert_raises(AssertionFailedError) { regexp.assert_named_captures }
  end # assert_named_captures
end #Regexp

###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/regexp.rb'
class RegexpTest < TestCase
include DefaultTests
extend DefaultTests
#puts Regexp.methods(false)
#include Minitest::Assertions
include Regexp::Examples
def test_square_brackets
	assert_equal(/a/, Regexp[/a/])
	assert_equal(/a/, Regexp['a'])
	assert_equal(/ab/, ['a', /b/].reduce(//, :*))
end # []
def test_to_regexp_escaped_string
	assert_equal('ab', Regexp.to_regexp_escaped_string('ab'))
	assert_equal('ab', Regexp.to_regexp_escaped_string(/ab/))
	assert_equal('{5}', Regexp.to_regexp_escaped_string(5))
	assert_equal('{2,5}', Regexp.to_regexp_escaped_string(2..5))
end # to_regexp_escaped_string
def test_promote
	assert_equal(/ab/, Regexp.promote(/ab/))
	assert_equal(/ab/, Regexp.promote('ab'))
	assert_raises(RuntimeError) {Regexp.promote(5)}
	assert_raises(RuntimeError) {Regexp.promote(2..5)}
end #promote
def test_regexp_rescued
	assert_equal(/]/, Regexp.regexp_rescued(']'))
	assert_raises(RuntimeError) {assert_equal(/]/, Regexp.regexp_rescued(/]/))} # String only
	assert_equal(nil, Regexp.regexp_rescued('['))
	assert_equal(/}/, Regexp.regexp_rescued('}'))
	assert_equal(/{/, Regexp.regexp_rescued('{'))
	assert_equal(nil, Regexp.regexp_rescued(')'))
	assert_equal(nil, Regexp.regexp_rescued('('))
end #regexp_rescued
def test_regexp_error
	assert_equal(nil, Regexp.regexp_error(']'))

	assert_instance_of(RegexpError, Regexp_exception)
	assert_equal('premature end of char-class: /[/', Regexp.regexp_error('[').message)
	assert_instance_of(Thread::Backtrace::Location, Regexp.regexp_error('[').backtrace_locations[0])
	assert_instance_of(String, Regexp.regexp_error('[').backtrace[0])
	assert_equal(nil, Regexp.regexp_error('}'))
	assert_equal(nil, Regexp.regexp_error('{'))
	assert_instance_of(RegexpError, Regexp.regexp_error(')'))
	assert_instance_of(RegexpError, Regexp.regexp_error('('))
	assert_equal(nil, Regexp.regexp_error(']'))
	assert_raises(RuntimeError) {Regexp.regexp_error(/]/)} # String only
	assert_nothing_raised(RuntimeError) {Regexp.regexp_error(']')} # String only
end #regexp_error
def test_terminator_regexp
end #terminator_regexp
def test_delimiter_regexp
end #delimiter_regexp
def test_propagate_options
	
	assert_equal([0, US_ASCII_encoding], Regexp.propagate_options(/a/))

    assert_equal([0, Encoding::UTF_8], Regexp.propagate_options(/pat/u)) # UTF-8

    assert_equal([0, Encoding::EUC_JP], Regexp.propagate_options(/pat/e)) # EUC-JP

    assert_equal([0, Encoding::Windows_31J], Regexp.propagate_options(/pat/s)) # Windows-31J
    assert_equal(Encoding::ASCII_8BIT, /pat/n.encoding) # ASCII-8BIT
    assert_equal([0, Encoding::BINARY], Regexp.propagate_options(/pat/n)) # ASCII-8BIT
    assert_equal([0, Encoding::ASCII_8BIT], Regexp.propagate_options(/pat/n)) # ASCII-8BIT
	

	assert(defined? Regexp)
#	assert(defined? Regexp::CASE_FOLD)
	assert_equal([0, Encoding.find('US-ASCII')], /a/x.propagate_options)
end #propagate_options
def test_coerce_escaped_string
end # coerce_escaped_string
def test_unescaped_string
	assert_equal(/#{Escape_string}/, Regexp.new(Escape_string))
	assert_equal(Escape_string, Regexp.new(Escape_string).source)
	assert_equal(Escape_string, Regexp.new(Escape_string).unescaped_string)
	assert_equal('\\n', /\n/.source)
	assert_match(Ip_number_pattern, '123')

	assert_equal(Escape_string, Regexp.new(Escape_string).unescaped_string)
	assert_match(Regexp.new(Ip_number_pattern.unescaped_string), '123')
	ip_pattern=Regexp.new(Array.new(4, Ip_number_pattern.unescaped_string).join('.'))
	assert_match(ip_pattern, '123.2.3.4')
end #unescape
def test_sequence
  assert_equal('(?-mix:a)', /a/.to_s)
  assert_equal('/a/', /a/.inspect)
  assert_equal('a', /a/.unescaped_string)
  assert_equal('(?-mix:\\n)', /\n/.to_s)
  assert_equal('/\\n/', /\n/.inspect)
  assert_equal(/a/, Regexp.new(/a/.source))
  assert_equal('a', Regexp.promote(/a/).source)
  assert_equal('a', Regexp.promote(/a/).source)
  assert_equal(/a{3}/, /a/ * 3)
  assert_equal(/a{1,3}/, /a/ * (1..3))
  assert_equal(/a\n/, /a/ * "\n")
  assert_match(/a/ * "\n", "a\n")
end #sequence
def test_alterative
  assert_equal(/a|b/, /a/ | /b/)
end #alterative
def test_capture
	regexp=/\d/
	str='a2c'
	matchData=regexp.capture.match(str)
	message="matchData.inspect=#{matchData.inspect}"
	assert_equal('2', matchData[0], message)
	assert_equal('2', matchData[1], message)
	assert_equal('2', regexp.capture.match(str)[1])
	matchData=regexp.capture(:digit).match(str)
	message="matchData.inspect=#{matchData.inspect}"
#	assert_not_nil(matchData, message)
	assert_match(/([a-z])/, str, message)
	matchData=/\$(?<dollars>\d+)\.(?<cents>\d+)/.match("$3.67")
	message="matchData.inspect=#{matchData.inspect}"
	assert_match(/\$(?<dollars>\d+)\.(?<cents>\d+)/, "$3.67", message)
	assert_match(/(?<dollars>\d+)\.(?<cents>\d+)/, "$3.67", message)
	assert_match(/(?<dollars>\d+)\./, "$3.67", message)
	assert_match(/(?<digit>\d)/, "$3.67", message)
	assert_match(/(?'letter'[a-z])/, str, message)
	assert_match(/(?<letter>[a-z])/, str, message)
	assert_match(/(?<digit>[0-9])/, str, message)
	assert_match(regexp.capture(:digit), str, message)
	assert_equal('2', regexp.capture(:digit).match('a2c')[:digit])
end #capture
def test_back_reference
	regexp1=/(?<vowel>[aeiou]).\k<vowel>.\k<vowel>/
	assert_match(regexp1, 'ototomy', 'Regexp doc example.')
	assert_equal('ototo', regexp1.match('ototomy')[0])
	assert_equal('o', regexp1.match('ototomy')[1])
#	regexp2=/[aeiou]/.capture(:vowel)*/./.back_reference(:vowel)*/./.back_reference(:vowel)
	assert_match(Back_reference, 'ototomy', 'Regexp doc example.')
end #back_reference
def test_group
	regexp=/\d/
	str='a2c'
	matchData=regexp.group.match(str)
	message="matchData.inspect=#{matchData.inspect}"
	assert_equal('2', matchData[0], message)
end #group
def test_assert_pre_conditions

	assert_instance_of(RegexpError, Regexp_exception)
	assert_instance_of(String, Regexp_exception.backtrace[0])
	assert_match(/regexp/, Regexp_exception.backtrace[0])
	assert_instance_of(Thread::Backtrace::Location, Regexp_exception.backtrace_locations[0])
	assert_equal('initialize', Regexp_exception.backtrace_locations[0].base_label)
	assert_equal('initialize', Regexp_exception.backtrace_locations[0].label)
	assert_instance_of(Fixnum, Regexp_exception.backtrace_locations[0].lineno)
	assert_match(/[a-z.]+/, Regexp_exception.backtrace_locations[0].path)
	assert_match(/[a-z.\/]+/, Regexp_exception.backtrace_locations[0].absolute_path)
	assert_equal('premature end of char-class: /[/', Regexp_exception.message)
	Regexp.new('}').assert_pre_conditions
	Regexp.new('{').assert_pre_conditions
	Regexp.regexp_error(')').assert_pre_conditions
	Regexp.regexp_error('(').assert_pre_conditions
	Regexp.new(']').assert_pre_conditions
end # assert_pre_conditions
end #Regexp

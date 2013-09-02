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
include Regexp::Examples
def test_unescaped_string
	escape_string='\d'
	assert_equal(/#{escape_string}/, Regexp.new(escape_string))
	assert_equal(escape_string, Regexp.new(escape_string).source)
	assert_equal(escape_string, Regexp.new(escape_string).unescaped_string)
	assert_equal('\\n', /\n/.source)
	assert_match(Ip_number_pattern, '123')

	assert_equal(escape_string, Regexp.new(escape_string).unescaped_string)
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
def test_group
	regexp=/\d/
	str='a2c'
	matchData=regexp.group.match(str)
	message="matchData.inspect=#{matchData.inspect}"
	assert_equal('2', matchData[0], message)
end #group
end #Regexp

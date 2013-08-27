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
#	assert_equal(, )
	escape_string='\d'
	assert_equal(/#{escape_string}/, Regexp.new(escape_string))
	assert_equal(escape_string, Regexp.new(escape_string).source)
	assert_match(Ip_number_pattern, '123')

	assert_equal(escape_string, Regexp.new(escape_string).unescaped_string)
	assert_match(Regexp.new(Ip_number_pattern.unescaped_string), '123')
	ip_pattern=Regexp.new(Array.new(4, Ip_number_pattern.unescaped_string).join('.'))
	assert_match(ip_pattern, '123.2.3.4')
end #unescape
end #Regexp

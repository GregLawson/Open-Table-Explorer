###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
include Parse::Constants
class MatchDataTest < TestCase
def test_parse
	assert_equal(['1', '2'], LINES.match("1\n2\n").parse)
	assert_equal(['1', '2'], LINES.match("1\n2").parse)
end #parse
end #MatchData

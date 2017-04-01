###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../unit/test_environment'
class MultipleTestsFailTest < TestCase
def test_initialize
end # initialize
def test_fail
	fail
end # fail

def test_fail2
	fail
end # fail2
end # MultipleTestsFail
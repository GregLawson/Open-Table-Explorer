###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../../app/models/test_environment_minitest.rb'
class SingleFailTest < TestCase
def test_initialize
end #initialize
def test_fail
	fail
end # fail
end #Test
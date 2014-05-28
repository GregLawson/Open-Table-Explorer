###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/pathname.rb'
class PathnameTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_touch_rescued!
	assert_kind_of(Exception, Example_no_write.touch_rescued!)
end # touch_rescued
def test_creatable_rescued?(probe_name = 'junk')
	assert_kind_of(Exception, Example_no_write.creatable_rescued?)
end # creatable_rescued?
def test_Examples
#	assert_pathname_exists(Example_no_write)
	Example_no_write.ascend do |ancestral_pathname| 
		print ancestral_pathname.creatable_rescued?.inspect[0,4]
		print ' ' + (ancestral_pathname.writable? ? 'writable' : 'not-writable')
		print ' ' + (ancestral_pathname.owned? ? 'owned' : 'not-owned')
		print ' ' + ancestral_pathname.mode
		p ' ' + ancestral_pathname.inspect
	end # ascend
end # Examples
end # Pathname

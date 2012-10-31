###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
class UnboundedFixnum  # reopen class to add assertions
include UnboundedFixnum::Assertions
extend UnboundedFixnum::Assertions::ClassMethods
end #UnboundedFixnum
class UnboundedFixnumAssertionsTest < Test::Unit::TestCase
def test_assert_weakest_pre_conditions
	UnboundedFixnum.assert_weakest_pre_conditions
end #assert_pre_conditions
def test_assert_UnboundedFixnum_invariant_conditions
	UnboundedFixnum.assert_invariant_conditions	
end #assert_UnboundedFixnum_invariant_conditions

def test_assert_UnboundedFixnum_post_conditions
	UnboundedFixnum::Inf.assert_post_conditions
	UnboundedFixnum::Neg_inf.assert_post_conditions
	UnboundedFixnum.assert_post_conditions	
end #assert_UnboundedFixnum_post_conditions
def test_assert_invariant_conditions
end #assert_invariant_conditions
def test_assert_pre_conditions
end #assert_pre_conditions
def test_assert_post_conditions
	UnboundedFixnum.new(511).assert_post_conditions
end #assert_post_conditions
end #UnboundedFixnum

###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_assertions_test.rb'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
class UnboundedFixnumAssertionsTest < TestCase
Example=UnboundedFixnum.new(3)
include DefaultAssertionTests
def test_Class_assert_pre_conditions
	UnboundedFixnum.assert_pre_conditions
end #assert_pre_conditions
	UnboundedFixnum.assert_invariant	
#test_Class_assert_pre_conditions
def test_Class_assert_invariant
	UnboundedFixnum.assert_invariant	
end #test_Class_assert_invariant_conditions

def test_Class_assert_post_conditions
	UnboundedFixnum::Inf.assert_pre_conditions
	UnboundedFixnum::Neg_inf.assert_pre_conditions
	UnboundedFixnum.assert_pre_conditions	
end #assert_UnboundedFixnum_post_conditions
end #UnboundedFixnum

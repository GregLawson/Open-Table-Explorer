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
def test_CLASS_assert_pre_conditions
end #assert_pre_conditions
	UnboundedFixnum.assert_invariant_conditions	
#test_CLASS_assert_pre_conditions
def test_assert_Class_invariant_conditions
end #assert_UnboundedFixnum_invariant_conditions

	UnboundedFixnum::Inf.assert_post_conditions
	UnboundedFixnum::Neg_inf.assert_post_conditions
	UnboundedFixnum.assert_post_conditions	
def test_assert_Class_post_conditions
end #assert_UnboundedFixnum_post_conditions
def test_assert_invariant_conditions
end #assert_invariant_conditions
def test_assert_pre_conditions
end #assert_pre_conditions
end #UnboundedFixnum

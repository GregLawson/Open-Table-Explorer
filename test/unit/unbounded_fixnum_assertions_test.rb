###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
require_relative '../../test/unit/default_assertions_test.rb'
class UnboundedFixnumAssertionsTest < TestCase
#Example=UnboundedFixnum.new(3)
include DefaultAssertionTests

#UnboundedFixnum.assert_invariant	

def test_class_assert_post_conditions
	UnboundedFixnum.assert_pre_conditions	
	UnboundedFixnum::Inf.assert_pre_conditions
	UnboundedFixnum::Neg_inf.assert_pre_conditions
	UnboundedFixnum.assert_post_conditions	
end #class_assert_post_conditions
end #UnboundedFixnum

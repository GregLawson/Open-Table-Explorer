###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
class UnboundedFixnumTest < ActiveSupport::TestCase
def test_UnboundedFixnum_initialize
	assert_not_nil(UnboundedFixnum)
	assert_instance_of(Class, UnboundedFixnum)
#	explain_assert_respond_to(Fixnum, :new)
#	explain_assert_respond_to(UnboundedFixnum, :new)
#	assert_respond_to(UnboundedFixnum, :new)
	assert_not_nil(UnboundedFixnum::Inf)
	assert_not_nil(UnboundedFixnum::Neg_inf)
end #UnboundedFixnum_initialize
def test_UnboundedFixnum_promote
	assert_equal(UnboundedFixnum.new(1), UnboundedFixnum.promote(1))
	assert_equal(UnboundedFixnum::Inf, UnboundedFixnum.promote(UnboundedFixnum::Inf))
end #promote
def test_UnboundedFixnum_compare
	assert_operator(UnboundedFixnum::Neg_inf, :<, UnboundedFixnum::Inf)
	assert_operator(UnboundedFixnum.new(1), :<, UnboundedFixnum::Inf)
	assert_operator(UnboundedFixnum::Neg_inf, :<, UnboundedFixnum.new(1))
	assert_operator(UnboundedFixnum::Neg_inf, :<, 1)
	assert_operator(UnboundedFixnum.new(1), :<=, UnboundedFixnum.new(1))
	assert_equal(0, UnboundedFixnum.new(1) <=> UnboundedFixnum.new(1))
end #UnboundedFixnum_compare
def test_UnboundedFixnum_plus
	assert_equal(UnboundedFixnum.new(2), UnboundedFixnum.new(1)+UnboundedFixnum.new(1))
	assert_equal(UnboundedFixnum.new(2), UnboundedFixnum.new(1)+1)
	assert_equal(UnboundedFixnum::Inf, UnboundedFixnum::Inf+1)
	assert_equal(UnboundedFixnum::Neg_inf, UnboundedFixnum::Neg_inf+1)
	assert_equal(UnboundedFixnum::Inf, UnboundedFixnum::Inf+UnboundedFixnum::Inf)
	assert_nil(UnboundedFixnum::Inf+UnboundedFixnum::Neg_inf)
	assert_nil(UnboundedFixnum::Neg_inf+UnboundedFixnum::Inf)
end #UnboundedFixnum_compare
end #UnboundedFixnum

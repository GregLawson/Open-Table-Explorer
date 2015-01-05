###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
class UnboundedFixnumTest < TestCase
def test_UnboundedFixnum_initialize
	assert_not_nil(UnboundedFixnum)
	assert_instance_of(Class, UnboundedFixnum)
	assert_not_nil(UnboundedFixnum::Inf)
	assert_not_nil(UnboundedFixnum::Neg_inf)
	assert_equal(3, UnboundedFixnum.new(3).to_i)
	assert_equal(3, UnboundedFixnum.new(UnboundedFixnum.new(3)).to_i)
end #UnboundedFixnum_initialize
def test_UnboundedFixnum_promote
	assert_equal(UnboundedFixnum.new(1), UnboundedFixnum.promote(1), "UnboundedFixnum.new(1)=#{UnboundedFixnum.new(1).inspect}\nUnboundedFixnum.promote(1)=#{UnboundedFixnum.promote(1).inspect}")
	assert_equal(UnboundedFixnum::Inf, UnboundedFixnum.promote(UnboundedFixnum::Inf))
	assert_equal(UnboundedFixnum.new(3), UnboundedFixnum.promote(UnboundedFixnum.new(3)))
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

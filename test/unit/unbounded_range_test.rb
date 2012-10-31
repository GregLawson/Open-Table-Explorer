###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/unbounded_range.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
class UnboundedFixnum  # reopen class to add assertions
include UnboundedFixnum::Assertions
extend UnboundedFixnum::Assertions::ClassMethods
end #UnboundedFixnum
class UnboundedRange  # reopen class to add assertions
include UnboundedRange::Assertions
#extend UnboundedRange::Assertions::ClassMethods
end #UnboundedRange
class UnboundedRangeTest < TestCase
include UnboundedRange::Constants
One_to_ten=UnboundedRange.new(1, 10)
Any_repetition=UnboundedRange.new(0, UnboundedFixnum::Inf)
def test_UnboundedRange_initialize
	assert_equal(1, One_to_ten.first)
	assert_equal(10, One_to_ten.last)
	assert_equal(0, Any_repetition.first)
#	assert(Any_repetition.last_unbounded)
	assert_raise(ArgumentError) {1..nil}	
	assert_raise(ArgumentError) {Range.new(1, nil)}	
	assert_raise(ArgumentError) {1..nil}	
	assert_raise(ArgumentError) {Range.new(1, nil)}	
	assert_nothing_raised {UnboundedFixnum.new(1)..UnboundedFixnum::Inf}	
end #initialize
def test_UnboundedRange_promote
	rhs=UnboundedRange.new(1, UnboundedFixnum::Inf)
	assert_equal(rhs, UnboundedRange.promote(rhs), "rhs=#{rhs.inspect}\n UnboundedRange.promote(rhs)=#{UnboundedRange.promote(rhs).inspect}")
	assert_equal(UnboundedRange::Many_range, UnboundedRange.promote(UnboundedRange.new(1, UnboundedFixnum::Inf)))
	assert_equal(UnboundedRange::Many_range, UnboundedRange.new(1, UnboundedFixnum::Inf))
	assert_equal(UnboundedRange.promote(UnboundedRange.new(1, UnboundedFixnum::Inf)), UnboundedRange::Many_range)
	assert_equal(UnboundedRange::Many_range, UnboundedRange.new(1, nil))
end #promote
def test_compare
	lhs=UnboundedRange::Many_range
	rhs=UnboundedRange.new(1, UnboundedFixnum::Inf)
	lhs.assert_post_conditions
	rhs.assert_post_conditions
	promotion=UnboundedRange.promote(rhs)
	promotion.assert_post_conditions
	lhs.assert_unbounded_range_equal(promotion)
	assert_equal(rhs, promotion)
	assert_equal(rhs, UnboundedRange.promote(rhs))
	rhs=UnboundedRange.promote(rhs)
	assert((rhs.last<=lhs.last))
	assert_instance_of(UnboundedFixnum, lhs.first)
	assert_instance_of(UnboundedFixnum, rhs.first)
	assert_equal(1, rhs.first)
	assert_equal(1, lhs.first)
	assert_equal(1, UnboundedRange::Many_range.first)
	assert_equal(0, 1 <=> 1)
	assert_equal(0, UnboundedRange::Many_range.first <=> 1)
	assert_equal(0, rhs.first <=> 1)
	assert_equal(0, lhs.first <=> rhs.first, "lhs.first=#{lhs.first.inspect} rhs.first=#{rhs.first.inspect}")
	assert(lhs.first<=rhs.first)
	assert(lhs.first<=rhs.first && (rhs.last<=lhs.last))
	assert_equal(UnboundedRange::Many_range, UnboundedRange::Many_range)
	assert_equal(UnboundedRange::Many_range.first, UnboundedRange.new(1, UnboundedFixnum::Inf).first)
	assert_equal(UnboundedRange::Many_range.last, UnboundedRange.new(1, UnboundedFixnum::Inf).last)
	assert(UnboundedRange::Many_range.eql?(UnboundedRange.new(1, UnboundedFixnum::Inf)))
	assert_equal(0, UnboundedRange::Many_range <=> UnboundedRange.new(1, UnboundedFixnum::Inf))
	assert_equal(UnboundedRange::Many_range, UnboundedRange.new(1, UnboundedFixnum::Inf))
	assert_equal(UnboundedRange.new(1, UnboundedFixnum::Inf), UnboundedRange.new(1, UnboundedFixnum::Inf))
	assert_equal(UnboundedRange.new(1, 3), UnboundedRange.new(1, 3))
	assert_operator(UnboundedRange.new(1, 4), :>, UnboundedRange.new(1, 3))
	assert_operator(UnboundedRange.new(0, 3), :>, UnboundedRange.new(1, 3))
	assert_operator(UnboundedRange.new(0, UnboundedFixnum::Inf), :>, UnboundedRange.new(1, UnboundedFixnum::Inf))
	assert_operator(UnboundedRange.new(1, UnboundedFixnum::Inf), :>, UnboundedRange.new(1, 3))
	Once.assert_compare(0, Once)
end #compare
def test_plus
	rep=UnboundedRange.new(1, 2)
	rhs=UnboundedRange.new(1, 2)
	assert_equal(rep+rhs, 2..4)
	assert_equal(UnboundedRange.new(2, UnboundedFixnum::Inf), UnboundedRange.new(1, UnboundedFixnum::Inf)+rep)
	assert_equal(UnboundedFixnum::Inf, rep.last+UnboundedFixnum::Inf, "UnboundedFixnum::Inf=#{UnboundedFixnum::Inf.inspect}, rep.last+UnboundedFixnum::Inf=#{(rep.last+UnboundedFixnum::Inf).inspect}")
	assert_equal(UnboundedRange.new(2, UnboundedFixnum::Inf), rep+UnboundedRange.new(1, UnboundedFixnum::Inf))
end #plus
def test_intersect
	assert_respond_to(self, :assert_include)
	assert_include(UnboundedRange.instance_methods(false), :&)
	assert_equal(UnboundedRange::Many_range, UnboundedRange::Any_range.&(UnboundedRange::Many_range))
	assert_equal(UnboundedRange::Many_range, UnboundedRange::Any_range & UnboundedRange::Many_range)
end #intersect
def test_union
	assert_equal(UnboundedRange::Any_range, UnboundedRange::Any_range | UnboundedRange::Many_range)
end #union / generalization
def assert_post_conditions
	Any_range.assert_post_conditions
	Many_range.assert_post_conditions
	Optional.assert_post_conditions
	Repetition_1_2.assert_post_conditions
	Once.assert_post_conditions
end #assert_post_conditions
def test_assert_compare
	Any_range.assert_compare(1, Many_range)
	Any_range.assert_compare(1, Optional)
	Any_range.assert_compare(1, Repetition_1_2)
	Any_range.assert_compare(1, Once)
	Many_range.assert_compare(1, Repetition_1_2)
	Many_range.assert_compare(1, Once)
	Optional.assert_compare(1, Once)
	Repetition_1_2.assert_compare(1, Once)
	Once.assert_compare(0, Once)
end #assert_operator
def test_assert_operator
# roughly sort from general to speccific ranges
	assert_operator(Any_range, :>, Many_range)
	assert_operator(Many_range, :>, Repetition_1_2)
	assert_operator(Optional, :>, Once)
	assert_operator(Repetition_1_2, :>, Once)
	assert_operator(Once, :>=, Once)
end #assert_operator
def test_assert_unbounded_range_equal
	assert_respond_to(self, :assert_include)
	assert_include(UnboundedRange::Assertions.instance_methods(false), :assert_unbounded_range_equal)
	UnboundedRange::Any_range.assert_unbounded_range_equal(UnboundedRange::Any_range)
	UnboundedRange::Any_range.assert_unbounded_range_equal(UnboundedRange.new(0, UnboundedFixnum::Inf))
	UnboundedRange.new(0, UnboundedFixnum::Inf).assert_unbounded_range_equal(UnboundedRange.new(0, UnboundedFixnum::Inf))
end #assert_unbounded_range_equal
end #UnboundedRangeTest

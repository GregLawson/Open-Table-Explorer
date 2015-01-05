###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/unbounded_range_assertions.rb'
require_relative '../../test/unit/default_assertions_tests.rb'
class UnboundedRangeTest < TestCase
include UnboundedRange::Examples
include DefaultAssertionTests
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

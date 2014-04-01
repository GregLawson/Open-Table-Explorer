###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../assertions/assertions.rb'
require_relative '../../app/models/unbounded_range.rb'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
class UnboundedRange < Range
require_relative '../assertions/default_assertions.rb'
module Assertions
include Minitest::Assertions
module ClassMethods
end #ClassMethods
def assert_post_conditions
	first.assert_post_conditions
	last.assert_post_conditions
	assert_equal(first.class, last.class)
end #assert_post_conditions
def assert_compare(comparison, rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
	
	assert_equal(comparison, lhs <=> rhs)
end #assert_operator
# Allows rhs to be coerced into UnboundedRange
def assert_unbounded_range_equal(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
	message="lhs=#{lhs.inspect}, rhs=#{rhs.inspect}"
	assert_equal(lhs.first.to_i, rhs.first.to_i, "beginning of range does not match."+message)
	assert_equal(lhs.last.to_i, rhs.last.to_i, "end of range does not match."+message)
	assert(lhs.eql?(rhs), "lhs=#{lhs.inspect}, rhs=#{rhs.inspect}")
	assert(lhs==rhs, "lhs=#{lhs.inspect}, rhs=#{rhs.inspect}")
	assert_equal(0, lhs <=> rhs, "lhs=#{lhs.inspect}, rhs=#{rhs.inspect}")
	assert_equal(lhs, rhs, "lhs=#{lhs.inspect}, rhs=#{rhs.inspect}")
end #assert_unbounded_range_equal
end #Assertions
include Assertions
extend Assertions::ClassMethods
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include UnboundedRange::Assertions
#extend UnboundedRange::Assertions::ClassMethods
module Examples
include UnboundedRange::Constants
One_to_ten=UnboundedRange.new(1, 10)
Repetition_1_2=UnboundedRange.new(1,2)
end #Examples
include Examples
end #UnboundedRange

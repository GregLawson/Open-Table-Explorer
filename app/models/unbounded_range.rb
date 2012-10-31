###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require_relative '../../app/models/unbounded_fixnum.rb'
# Extention of Range class to unbounded limits
# Used in RegexpTree for /.*/ and /.+/
# handles comparisons as UnboundedFixnum::Inf means unbounded (i.e. infinity)
class UnboundedRange < Range
include Comparable
def initialize(min, max)
	min=UnboundedFixnum.promote(min, -1)
	max=UnboundedFixnum.promote(max, +1)
	super(min, max)
	raise "min=#{min.inspect} must be less than or equal to max=#{max.inspect}." if min > max
end #initialize
module Constants
Any_range=UnboundedRange.new(0, UnboundedFixnum::Inf)
Many_range=UnboundedRange.new(1, UnboundedFixnum::Inf)
Once=UnboundedRange.new(1, 1)
Optional=UnboundedRange.new(0,1)
Repetition_1_2=UnboundedRange.new(1,2)
end #module Constants
include UnboundedRange::Constants
# Promote (specialize inherited type)  
def UnboundedRange.promote(rhs)
#	if rhs.instance_of?(UnboundedRange) then
#		self
#	elsif rhs.instance_of?(Range)
		UnboundedRange.new(UnboundedFixnum.promote(rhs.first, -1), UnboundedFixnum.promote(rhs.last, +1))
#	end #if
end #promote
def eql?(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
 	if lhs.first.to_i==rhs.first.to_i && lhs.last.to_i==rhs.last.to_i then
		true
	else
		false
	end #if
end #eql
# called by assert_equal
# No coercion of arguments like in Numeric
def ==(rhs)
	eql?(rhs)
end #==
def <=>(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
 	if eql?(rhs) then
		return 0
	elsif lhs.first<=rhs.first && (rhs.last<=lhs.last) then
		return 1
	elsif rhs.first<=lhs.first && (lhs.last<=rhs.last) then
		return -1
	else
		return nil
	end #if

end #compare
# calculate sum for merging sequential repetitions
def +(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
	max=lhs.last+rhs.last
	return UnboundedRange.new(lhs.first+rhs.first, max)
end #plus
# intersection. If neither is a subset of the rhs return UnboundedFixnum::Inf 
def &(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
	min= [lhs.first, rhs.first].max
	max=if lhs.last.nil? then
		rhs.last
	else
		case lhs.last <=> rhs.last
		when 1,0
			rhs.last
		when -1
			lhs.last
		when UnboundedFixnum::Inf
			return UnboundedFixnum::Inf	
		end #case
	end #if
	UnboundedRange.new(min, max)
end #intersect
# Union. Unlike set union disjoint sets return a spanning set.
def |(rhs)
	lhs=self
	rhs=UnboundedRange.promote(rhs)
	min= [lhs.first, rhs.first].min
	max=if lhs.last.nil? then
		UnboundedFixnum::Inf
	else
		case lhs.last <=> rhs.last
		when 1,0
			lhs.last
		when -1
			rhs.last
		when UnboundedFixnum::Inf
			max=[lhs.last, rhs.last].max	
		end #case
	end #if
	UnboundedRange.new(min, max)
end #union / generalization
module Assertions
include Test::Unit::Assertions
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
end #UnboundedRange

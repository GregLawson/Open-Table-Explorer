###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# Extention of FixNum class to unbounded limits
# nil means unbounded (i.e. infinity)
class UnboundedFixnum < Numeric # Fixnum blocks new
include Comparable
attr_reader :sign
def initialize(number, sign=nil)
	raise "In UnboundedFixnum.new infinities must have a sign" if number.nil? && sign.nil?
	if number.instance_of?(UnboundedFixnum) then
		@fixnum=number.to_i
		@sign=number.sign
	else	
		@fixnum=number
		@sign=sign
	end #if
end #UnboundedFixnum_initialize
Inf=UnboundedFixnum.new(nil,+1)
Neg_inf=UnboundedFixnum.new(nil,-1)
# or coerce
def UnboundedFixnum.promote(other)
	if other.instance_of?(UnboundedFixnum) then
		other
	else
		UnboundedFixnum.new(other)
	end #if
end #promote
def integer? # for Numeric Class
	return true 
end #integer
def to_i
	return @fixnum
end #to_i
def unbounded?
	if @fixnum.nil? then
		@sign
	else
		nil
	end #if
end #unbounded
def <=>(rhs)
	rhs=UnboundedFixnum.promote(rhs)
	case [self.unbounded?, rhs.unbounded?] 
	when [nil,nil]
		return self.to_i <=> rhs.to_i
	when [+1,+1], [-1,-1]
		return 0
	when [nil,+1], [-1, nil], [-1,+1]
		return -1
	when [nil,-1], [+1, nil], [+1,-1]
		return +1
	end #if
end #UnboundedFixnum_compare
def +(rhs)
	if !rhs.instance_of?(UnboundedFixnum) then
		rhs=UnboundedFixnum.new(rhs)
		rhs_unbounded=rhs.unbounded?
	else
		rhs_unbounded=rhs.unbounded?
	end #if
	lhs_unbounded=self.unbounded?
	case [lhs_unbounded, rhs_unbounded] 
	when [nil,nil]
		return UnboundedFixnum.new(self.to_i + rhs.to_i)
	when [+1,+1], [-1,-1]
		return self
	when [nil,-1], [-1, nil]
		return UnboundedFixnum::Neg_inf
	when [nil,+1], [+1, nil]
		return UnboundedFixnum::Inf
	when [-1,+1], [+1,-1]
		return nil # could be any value
	end #if
end #UnboundedFixnum_compare
end #UnboundedFixnum

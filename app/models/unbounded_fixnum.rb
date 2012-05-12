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
attr_reader :infinity_sign
# infinity_sign is only needed for number==nil
def initialize(number, infinity_sign=nil)
	raise "In UnboundedFixnum.new infinities must have a infinity_sign" if number.nil? && infinity_sign.nil?
	if number.instance_of?(UnboundedFixnum) then
		@fixnum=number.to_i
		@infinity_sign=number.infinity_sign
	else	
		@fixnum=number
		@infinity_sign=infinity_sign
	end #if
end #UnboundedFixnum_initialize
Inf=UnboundedFixnum.new(nil,+1)
Neg_inf=UnboundedFixnum.new(nil,-1)
# or coerce
def UnboundedFixnum.promote(other, infinity_sign=nil)
	if other.instance_of?(UnboundedFixnum) then
		UnboundedFixnum.new(other.to_i, other.infinity_sign)
	else
		UnboundedFixnum.new(other, infinity_sign)
	end #if
end #promote
def to_s
	case self
	when Inf
		return 'Inf'
	when Neg_inf
		return 'Neg_inf'
	else
		return @fixnum
	end #case
end #inspect
def integer? # for Numeric Class
	return true 
end #integer
def to_i
	return @fixnum
end #to_i
def unbounded?
	if @fixnum.nil? then
		@infinity_sign
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

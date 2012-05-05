###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# Extention of FixNum class to unbounded limits
# nil means unbounded (i.e. infinity)
class UnboundedFixnum #< Fixnum # blocks new
include Comparable
attr_reader :sign
def initialize(number, sign= 0<=>number)
	raise "In UnboundedFixnum.new infinities must have a sign" if number.nil? && sign.nil?
#	else
#		super(number)
#	end #if
	@fixnum=number
	@sign=sign
end #UnboundedFixnum_initialize
Inf=UnboundedFixnum.new(nil,+1)
Neg_inf=UnboundedFixnum.new(nil,-1)
def unbounded?
	if @fixnum.nil? then
		return @sign
	else
		nil
	end #if
end #unbounded
def to_i
	return @fixnum
end #to_i
def <=>(rhs)
	if !rhs.instance_of?(UnboundedFixnum) then
		rhs=UnboundedFixnum.new(rhs)
		rhs_unbounded=rhs.unbounded?
	else
		rhs_unbounded=rhs.unbounded?
	end #if
	lhs_unbounded=self.unbounded?
	case [lhs_unbounded, rhs_unbounded] 
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
	when [nil,+1], [-1, nil]
		return UnboundedFixnum::Neg_inf
	when [nil,-1], [+1, nil]
		return UnboundedFixnum::Inf
	when [-1,+1], [+1,-1]
		return nil # could be any value
	end #if
end #UnboundedFixnum_compare
end #UnboundedFixnum

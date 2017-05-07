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
  def initialize(number, infinity_sign = nil)
    raise 'In UnboundedFixnum.new infinities must have a infinity_sign' if number.nil? && infinity_sign.nil?
    if number.instance_of?(UnboundedFixnum)
      @fixnum = number.to_i
      @infinity_sign = number.infinity_sign
    else
      @fixnum = number
      @infinity_sign = infinity_sign
    end # if
  end # UnboundedFixnum_initialize
  module Constants
    Inf = UnboundedFixnum.new(nil,+1)
    Neg_inf = UnboundedFixnum.new(nil, -1)
  end # Constants
  include Constants
  # or coerce
  def self.promote(other, infinity_sign = nil)
    if other.instance_of?(UnboundedFixnum)
      UnboundedFixnum.new(other.to_i, other.infinity_sign)
    else
      UnboundedFixnum.new(other, infinity_sign)
    end # if
  end # promote

  def to_s
    case self
    when Inf
      return 'Inf'
    when Neg_inf
      return 'Neg_inf'
    else
      return @fixnum
    end # case
  end # to_s

  def inspect
    to_s
  end # inspect

  def integer? # for Numeric Class
    true
  end # integer

  def to_i
    @fixnum
  end # to_i

  def unbounded?
    if @fixnum.nil?
      @infinity_sign
    end # if
  end # unbounded

  def eql?(rhs)
    lhs = self
    if lhs.unbounded? && rhs.unbounded?
      true
    elsif lhs.to_i == rhs.to_i
      true
    else
      false
     end # if
  end # equal

  # no coercion of argument as in Numeric
  def ==(rhs)
    eql?(rhs)
  end #==

  def <=>(rhs)
    rhs = UnboundedFixnum.promote(rhs)
    case [unbounded?, rhs.unbounded?]
    when [nil, nil]
      return to_i <=> rhs.to_i
    when [+1,+1], [-1, -1]
      return 0
    when [nil,+1], [-1, nil], [-1,+1]
      return -1
    when [nil, -1], [+1, nil], [+1, -1]
      return +1
    end # if
  end # UnboundedFixnum_compare

  def +(rhs)
    if !rhs.instance_of?(UnboundedFixnum)
      rhs = UnboundedFixnum.new(rhs)
      rhs_unbounded = rhs.unbounded?
    else
      rhs_unbounded = rhs.unbounded?
    end # if
    lhs_unbounded = unbounded?
    case [lhs_unbounded, rhs_unbounded]
    when [nil, nil]
      return UnboundedFixnum.new(to_i + rhs.to_i)
    when [+1,+1], [-1, -1]
      return self
    when [nil, -1], [-1, nil]
      return UnboundedFixnum::Neg_inf
    when [nil,+1], [+1, nil]
      return UnboundedFixnum::Inf
    when [-1,+1], [+1, -1]
      return nil # could be any value
    end # if
  end # UnboundedFixnum_compare
end # UnboundedFixnum

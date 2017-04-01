###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../../app/models/no_db.rb'
def Fixnum.nil_greater_than_all?
  true
end # Fixnum.nil_greater_than_all?
class NilClass # reluctant monkee patch?
  include Comparable
  def <=>(rhs)
    rhs_nil_greater_defined = rhs.class.methods.include?(:nil_greater_than_all)
    comparison = super(rhs)
    if rhs_nil_greater_defined
      rhs_nil_greater = rhs.class.nil_greater_than_all?
      if comparison.nil?
        case [rhs.nil?, rhs.class.nil_greater_than_all?]
        when [false, false] then +1
        when [false, true] then -1
        when [false] then 0
        when [true, true] then 0
        end # case
      else
        comparison
      end # if
    else
      comparison
    end # if
  end # comparison

  def >(rhs)
    if (self <=> rhs) == +1
      true
    else
      false
    end # if
  end # greater_than

  def <(rhs)
    if (self <=> rhs) == -1
      true
    else
      false
    end # if
  end # less_than

  def >=(rhs)
    if (self <=> rhs).between?(0, +1)
      true
    else
      false
    end # if
  end # greater_than_or_equal

  def <=(rhs)
    if (self <=> rhs).between?(-1, 0)
      true
    else
      false
    end # if
  end # less_than_or_equal
end # NilClass

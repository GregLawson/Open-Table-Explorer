###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nil_comparable.rb'
class NilClassTest < TestCase
  def test_NilClass_comparison
    assert_operator(nil, :==, nil)
    assert_equal(false, !nil.nil?)
    assert_includes(NilClass.instance_methods, :<=>)
    assert_equal(0, nil <=> nil)
    assert_operator(nil, :<=, nil)
    refute_operator(nil, :==, 0)
    assert_equal(true, nil != 0)

    assert_equal(0, nil <=> 0)
  end # comparison

  def test_greater_than
    refute_operator(nil, :>, nil)
    assert_equal(false, nil > 0)
  end # greater_than

  def test_less_than
    refute_operator(nil, :<, nil)
    assert_equal(false, nil < 0)
  end # less_than

  def test_greater_than_or_equal
    assert_includes(NilClass.instance_methods, :>=)
    assert_operator(nil, :>=, nil)
    assert_equal(false, nil >= 0)
  end # greater_than_or_equal

  def test_less_than_or_equal
    assert_equal(false, nil <= 0)
  end # less_than_or_equal
end # NilClass

class NilComparableTest < TestCase
  def test_NilComparable_comparison
    assert_operator(nil, :==, nil)
    assert_operator(0, :!=, nil)
    assert_operator(0, :>=, nil)
    assert_operator(0, :<=, nil)
    assert_operator(0, :>, nil)
    assert_operator(0, :<, nil)
    end # comparison
end # NilComparable

###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# A Stream is a generalization of Array, Enumerator, Enumerable allowing infinite length part of which can be a Tree data store
# make as many methods in common between Array and Hash
# [] is the obvious method in common
# each_index and each_pair seem synonyms but with thier arguments reversed
# Hash#to_a converts a hash to a nested array of key, value pairs
# Array#to_h reverses my expectation and makes the array the keys not the values
# I've added Array#to_hash to create the indexes as keys
# map should be added analogously to Hash
class Array
#  include Tree
  # Array#each_with_index yields only index
  def each_pair
    each.with_index do |element, index|
      if element[index].instance_of?(Array) && element.size == 2 # from Hash#to_a
        yield(element[0], element[1])
      else
        yield(index, element)
      end # if
    end # if
  end # each_pair

  def values
    self
  end # values

  def keys
    (0..size - 1).to_a
  end # keys

#!  def to_hash
#!    hash = {}
#!    each_pair do |key, value|
#!      hash[key] = value
#!    end # each_pair
#!		hash
#!  end # to_hash

  def to_hash_from_to_a
    hash = {}
    each_pair do |key, value|
      hash[key] = value
    end # each_pair
  end # to_hash_from_to_a

  def map_pair
    ret = [] # return Array
    each_pair { |key, value| ret. << yield(key, value) }
    ret
  end # map_pair
	
  module Constants
    Identity_map_pair = proc { |_key, value| value }
  end # Constants
  include Constants
end # Array

class Hash
#  include Tree
  module Constants
    Identity_map_pair = proc { |key, value| { key => value } }
  end # Constants
  include Constants
  def each_with_index(*args, &block)
    each_pair(args, block)
  end # each_with_index

  # More like Array#map.uniq since Hash does not allow duplicate keys
  # If you want to process duplicates try Hash#to_a.map.group_by
  def map_pair
    ret = {} # return Hash
    each_pair { |key, value| ret = ret.merge(yield(key, value)) }
    ret
  end # map_pair

  def map_pair_with_collisions(&block)
    to_a.map_pair(block).group_by { |key, _value| key }
  end # map_pair_with_collisions

  def merge_collisions
    to_a.map_pair { |key, values| yield(key, values) }
  end # merge_collisions

  def map_with_collisions
    to_a.map { |pair_array| call.block(pair_array[0], pair_array[1]) }
  end # map_with_collisions

  # More like Array#.uniq since Hash does not allow duplicate keys
  def +(other)
    merge(other)
  end # +

  def -(rhs)
    ret = {}
    lhs = self
    each_pair do |key, value|
      if value.instance_of?(Hash) || value.instance_of?(Array)
        ret = ret.merge(key => value - rhs[key])
      elsif rhs[key].nil? || lhs[key] != rhs[key]
        ret = ret.merge(key => value)
      end # if
    end # each_pair
    ret
  end # -

  def operator(rhs)
    lhs = self
    ret = {}
    each_pair do |key, value|
      if value.instance_of?(Hash) || value.instance_of?(Array)
        ret = ret.merge(key => lhs[key].operator(rhs[key])) # recurse
      else
        rhs_value = yield(key, lhs, rhs)
        unless rhs_value.nil?
          ret = ret.merge(key => rhs_value)
        end # unless
      end # if
    end # each_pair
    ret
  end # operator

  def &(other)
    other - (self - other)
  end # intersection

  def <<(other)
    merge(other)
  end # :+
	
	def inspect_lines
		ret = '{'
		each_pair do |key, value|
			ret += key.inspect + ' => ' + value.inspect.gsub('}', '}' + "\n") + ",\n"
		end # each_pair
		ret.chomp.chomp + "\n" + "}\n" # remove terminating linefeed and comma
	end # inspect_lines
end # Hash

class Object
  def enumerate_single(enumerator_method = :map, &proc)
    result = [self].enumerate(enumerator_method, &proc) # simulate array
    if result.instance_of?(Array) # map
      return result[0] # discard simulated array
    else # reduction method (not map)
      return result
    end # if
  end # enumerate_single

def enumerate(enumerator_method = :map, &proc)
   if instance_of?(Array)
     method(enumerator_method).call(&proc)
   else
     enumerate_single(enumerator_method, &proc)
   end # if
end # enumerate
end # Object

module Stream # see http://rgl.rubyforge.org/stream/classes/Stream.html
  include Enumerable
end # Stream

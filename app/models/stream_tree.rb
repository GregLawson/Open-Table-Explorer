###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

# An attempt at a universal data type?
# Or is it duck typing modules without inheritance?
# A Stream is a generalization of Array, Enumerable allowing infinite length part of which can be a Tree data store
# A tree is a generalization of Tables and Nested Arrays and Hashes 
# in context see http://rubydoc.info/gems/gratr/0.4.3/file/README
# simple construction would give a tree
# sharing nodes would give a directed acyclic graph
# loops might be possible since ruby objects are references and self references are possible
#require_relative '../../app/models/no_db.rb'
# make as many methods in common between Array and Hash
# [] is the obvious method in common
# each_index and each_pair seem synonyms but with thier arguments reversed
# Hash#to_a converts a hash to a nested array of key, value pairs 
# Array#to_h reverses my expectation and makes the array the keys not the values
# I've added Array#to_hash to create the indexes as keys
# map should be added analogously to Hash
class Array
def each_pair(&block)
	each_with_index do |element, index|
		if element.instance_of?(Array) && element.size == 2 then # from Hash#to_a
			block.call(element[0], element[1])
		else
			block.call(index, element)
		end # if
	end # if
end # each_pair
def values
	self
end # values
def keys
	(0..self.size-1).to_a
end # keys
def to_hash
	hash = {}
	each_pair do |key, value|
		hash[key] = value
	end # each_pair
end # to_hash
def to_hash_from_to_a
	hash = {}
	each_pair do |key, value|
		hash[key] = value
	end # each_pair
end # to_hash_from_to_a
end # Array
class Hash
def each_with_index(*args, &block)
	each_pair(args, block)
end # each_index
# More like Array#map.uniq since Hash does not allow duplicate keys
# If you want to process duplicates try Hash#to_a.map.group_by
def map(&block)
	ret = {} # return Hash
	each_pair {|key, value| ret.merge(block.call(key, element))}
	ret
end # map
def map_pair_with_collisions(&block)
	 to_a.map_pair(block).group_by{|key, value| key}
end # map_pair_with_collisions
def merge_collisions(&block)
	 to_a.map_pair{|key, values| block.call(key, values)}
end # merge_collisions
def map_with_collisions(&block)
	to_a.map{|pair_array| call.block(pair_array[0], pair_array[1])}
end # map_with_collisions
# More like Array#.uniq since Hash does not allow duplicate keys
def +(other)
	merge(other)
end # :+
end # Hash
module Stream # see http://rgl.rubyforge.org/stream/classes/Stream.html
include Enumerable
end # Stream
module Graph # see http://rubydoc.info/gems/gratr/0.4.3/file/README
end # Graph
module Tree
include Graph
# delegate to Array, Enumable and Hash
end # Tree
module StreamTree
include Stream
include Tree
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize
end #initialize
require_relative '../../test/assertions.rb'
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Example_array = [1, 2, 3]
Example_hash = {name: 'Fred', salary: 10, department: :Engineering}
Example_tuples = [Example_hash, {name: 'Bob', salary: 11}]
Example_department = {department: :Engineering, manager: 'Bob'}
Example_database = {employees: Example_tuples, departments: Example_department}

end #Examples
end #StreamTree

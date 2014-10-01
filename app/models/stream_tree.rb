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
#require_relative 'parse.rb'
module Node
module ParentLinked
def all
end # all
def parent?
end # parent?
end # ChildLinked
module ChildLinked
end # ChildLinked
end # Node
module Graph # see http://rubydoc.info/gems/gratr/0.4.3/file/README
# [] is already taken
def at(address)
	if address.parent.instance_of?(TreeAddress) then
		self[address.parent][address.index]
	else
		raise "Parent address in TreeAddress.new must be a TreeAddress or nil for root."
	end # if
end # at
def leaf_addresses
end # 
def expression_class_symbol?
	self.class.name[20..-1].to_sym # should be magic-number-free
end # expression_class_symbol?
module Constants
Identity_map = proc {|e, depth, terminal| e}
Trace_map = proc {|e, depth, terminal| [e, depth, terminal]}
# unlike the usual assumption nil means the node has no children_function
Leaf_map = proc {|e, depth, terminal| (terminal.nil? || terminal ? e : nil)}
Node_format = proc do |e|
	e.inspect
end # Node_format
Tree_node_format = proc do |e, depth, terminal|
	ret = case terminal
	when true then	'terminal'
	when false then 'nonterminal'
	when nil then 'nil'
	else 'unknown'
	end # case
	ret += '[' + depth.to_s + ']'
	ret += ', ' 
	ret += e.inspect_node
end # Tree_node_format
end # Constants
include Constants
def inspect_node(&inspect_proc)
	if !block_given? then
		inspect_proc = Node_format
	end # if
	inspect_proc.call(self)
end # inspect_node
end # Graph
module DAG
include Graph
include Graph::Constants
def inspect_recursive(children_method_name = :to_a, &inspect_proc)
	if !block_given? then
		inspect_proc = Tree_node_format
	end # if
	ret = map_recursive(children_method_name, &inspect_proc)
	ret = if ret.instance_of?(Array) then
		ret.join("\n")
	else
		ret
	end # if
	ret + "\n"
end # inspect_recursive
end # DAG
module Forest
include DAG
end # Forest
module Leaf
include Graph
def leaf?(children_method_name = :to_a)
			true  # end recursion
end # leaf?
end # Leaf
module Tree
include DAG
module Constants
include Graph::Constants
end # Constants
include Constants
# delegate to Array, Enumable and Hash
# returns
# Array of children from children_method, recursion continues
# []  - terminal, children_method returns empty array, recursion stops
# nil - terminal  - children method does not exist, end recursion for bipartite trees where terminal is a different class.
# nil   - 
def children?(children_method_name = :to_a)
	children_method_name = children_method_name.to_sym
	if respond_to?(children_method_name) then
		children = send(children_method_name)
		raise 'Method named ' + children_method_name.to_s + 'does not return an Array (Enumerable?).' unless children.instance_of?(Array)
		children
	else
		nil # end recursion
	end # if
end # children?
# Shortcut for lack of children is a leaf node.
def leaf?(children_method_name = :to_a)
	children?(children_method_name).to_a.empty? # nil.to_a == []
end # leaf?
# Apply block to each node (branch & leaf).
# Nesting structure remains the same.
# Array#map will only process the top level Array. 
def map_recursive(children_method_name = :to_a, depth=0, &visit_proc)
# Handle missing parameters (since any and all can be missing)
#	puts 'children_method_name.inspect =' + children_method_name.inspect
#	puts 'depth.inspect =' + depth.inspect
#	puts 'visit_proc.inspect =' + visit_proc.inspect
#	puts 'block_given? =' + block_given?.inspect
	if !block_given? && (children_method_name.instance_of?(Proc) || depth.instance_of?(Proc)) then
		raise "Block proc argument should be preceded with ampersand."
	end # if
	children_method_name = children_method_name.to_sym
	if leaf?(children_method_name) then
		visit_proc.call(self, depth, true)  # end recursion
	else
		children = send(children_method_name)
		[visit_proc.call(self, depth, false), children.map_pair do |index, sub_tree|
			if sub_tree.respond_to?(:map_recursive) then
				sub_tree.map_recursive(children_method_name, depth+1, &visit_proc)
			else
				visit_proc.call(sub_tree, depth, nil) # end recursion
			end # if
		end ] # map
	end # if
end # map_recursive
# Apply block to each non-leaf or branching node
# Provides a postfix walk
# Two passes:
# 1) Recursively visit descendants
# 2) Visit branching nodes (Arrays)
# Desirable since result tree is constructed bottom-up
# Descendants have the block applied before they are reassembled into a tree.
# Branching node block can take into account changes in subtrees.

def map_branches(depth=0, &visit_proc)
	visited_subtrees= self.map do |sub_tree| 
		if sub_tree.respond_to?(:expressions) then
			self.class.new(sub_tree).map_branches(depth+1){|p| visit_proc.call(p, depth)}
		else
			sub_tree
		end #if
	end
	return visit_proc.call(visited_subtrees, &visit_proc)
end #map_branches
module Examples
include Constants
Flat_array = [0]
Flat_hash = {cat: :fish}
end # Examples
include Examples
end # Tree
# make as many methods in common between Array and Hash
# [] is the obvious method in common
# each_index and each_pair seem synonyms but with thier arguments reversed
# Hash#to_a converts a hash to a nested array of key, value pairs 
# Array#to_h reverses my expectation and makes the array the keys not the values
# I've added Array#to_hash to create the indexes as keys
# map should be added analogously to Hash
class Array
include Tree
# Array#each_with_index yields only index
def each_and_index(&block)
	each_with_index do |index|
		if element[index].instance_of?(Array) && element.size == 2 then # from Hash#to_a
			block.call(element[0], element[1])
		else
			block.call(index, element)
		end # if
	end # if
end # each_pair
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
def map_pair(&block)
	ret = [] # return Array
	each_pair {|key, value| ret. << block.call(key, value)}
	ret
end # map_pair
module Constants
Identity_map_pair = proc {|key, value| value}
end # Constants
include Constants
end # Array

class Hash
include Tree
module Constants
Identity_map_pair = proc {|key, value| {key => value}}
end # Constants
include Constants
def each_with_index(*args, &block)
	each_pair(args, block)
end # each_with_index
# More like Array#map.uniq since Hash does not allow duplicate keys
# If you want to process duplicates try Hash#to_a.map.group_by
def map_pair(&block)
	ret = {} # return Hash
	each_pair {|key, value| ret = ret.merge(block.call(key, value))}
	ret
end # map_pair
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
end # +
def <<(other)
	merge(other)
end # :+
end # Hash
class Object
def enumerate_single(enumerator_method = :map, &proc)
	result=[self].enumerate(enumerator_method, &proc) #simulate array
	if result.instance_of?(Array) then # map
		return result[0] #discard simulated array
	else # reduction method (not map)
		return result
	end #if
end #enumerate_single
def enumerate(enumerator_method=:map, &proc)
	if instance_of?(Array) then
		method(enumerator_method).call(&proc)
	else
		enumerate_single(enumerator_method, &proc)		
	end #if
end #enumerate
end #Object
module Stream # see http://rgl.rubyforge.org/stream/classes/Stream.html
include Enumerable
end # Stream
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

module ClassMethods

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
Children_method_name = :to_a
Example_array = [1, 2, 3]
Nested_array = [1, [2, [3], 4], 5]
Inspect_node_root = '[1, [2, [3], 4], 5]'
Children_nested_array = [[2, 3, 4]]
Son_nested_array = [2, [3], 4]
Grandchildren_nested_array = [[3]]
Grandson_nested_array = 3
Tree_node_root = 'nonterminal[0], [1, [2, [3], 4], 5]'
Grandson_nested_array_map = "terminal[2], 3"
Son_nested_array_map = ["nonterminal[1], [2, [3], 4]",
   ["terminal[2], 2",
    ["nonterminal[2], [3]", ["terminal[3], 3"]],
    "terminal[2], 4"]]
Nested_array_map = ["nonterminal[0], [1, [2, [3], 4], 5]",
   ["terminal[1], 1",
    ["nonterminal[1], [2, [3], 4]",
     ["terminal[2], 2",
      ["nonterminal[2], [3]", ["terminal[3], 3"]],
      "terminal[2], 4"]],
    "terminal[1], 5"]]
Example_hash = {name: 'Fred', salary: 10, department: :Engineering}
Example_tuples = [Example_hash, {name: 'Bob', salary: 11}]
Example_department = {department: :Engineering, manager: 'Bob'}
Example_database = {employees: Example_tuples, departments: Example_department}

end #Examples
end #StreamTree

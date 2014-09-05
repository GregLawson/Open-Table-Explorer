###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/stream_tree.rb'
class Fixnum
include Tree # used as leaf node in test tree
include Leaf # used as leaf node in test tree
end # Fixnum
class StreamTreeTest < TestCase
include DefaultTests
include TE.model_class?::Examples
include Tree::Examples
def test_at
#	assert_equal(Nested_array, Nested_array.at(Root_index))
#	assert_equal(Son_nested_array, Nested_array.at(Root_index))
#	assert_equal(Grandson_nested_array, Nested_array.at(Root_index))
end # at
def test_inspect_node
	assert_equal(Inspect_node_root, Nested_array.inspect_node)
	assert_equal(Inspect_node_root, Nested_array.inspect_node(&Node_format))
	assert_equal('[2, [3], 4]', Son_nested_array.inspect_node)
	assert_equal('3', Grandson_nested_array.inspect_node)
	assert_match(Nested_array.inspect_node, Tree_node_root)
	assert_match(Nested_array.inspect_node(&Node_format), Tree_node_root)
end # inspect_node
def test_Node_format
	assert_equal(Inspect_node_root, Nested_array.inspect_node)
	assert_equal(Inspect_node_root, Nested_array.inspect_node(&Node_format))
end # Node_format
def test_inspect_recursive
	assert_equal(Grandson_nested_array_map, Grandson_nested_array.map_recursive(:to_a, depth=2, &Tree_node_format))
	assert_equal(Son_nested_array_map, Son_nested_array.map_recursive(:to_a, depth=1, &Tree_node_format))
	assert_equal(Nested_array_map, Nested_array.map_recursive(:to_a, &Tree_node_format))
	assert_equal((Nested_array_map.flatten.map{|s| s + "\n"}).join, Nested_array.inspect_recursive(&Tree_node_format), Nested_array.inspect_recursive(&Tree_node_format))
	assert_equal((Nested_array_map.flatten.map{|s| s + "\n"}).join, Nested_array.inspect_recursive, Nested_array.inspect_recursive)

#	assert_equal('ab # ' + Nested_array_map + "\n", Sequence_example.inspect_recursive(&Mx_format))
#	assert_equal('a # ' + Nested_array_map + "\n", Alternative_example.inspect_recursive(&Mx_format))
end # inspect_recursive
def test_map_recursive_simple_block
	assert_equal([[[0], 0, false], [[0, 1, true]]], Flat_array.map_recursive(&Trace_map))
	assert_equal([Flat_array], Flat_array.map_recursive(&Leaf_map).compact)
	assert_equal([[0], [0]], Flat_array.map_recursive(&Identity_map))
	assert_equal([Flat_hash, Flat_hash.values], Flat_hash.map_recursive(&Identity_map))
end # test_map_recursive_simple_block
def test_children?
	assert_empty(nil)
	assert(nil.to_a.empty?) # allows uniform testing of empty Array and nil
	assert_equal(Nested_array, Nested_array.children?)
	assert_equal(Son_nested_array, Son_nested_array.children?, 'Son_nested_array = ' + Son_nested_array.inspect)
	assert_equal(nil, Grandson_nested_array.children?, 'Grandson_nested_array = ' + Grandson_nested_array.inspect)
end # children?
def test_leaf?
	assert_respond_to(Nested_array, Children_method_name)
	assert_equal(Inspect_node_root, Node_format.call(Nested_array))
	assert_equal(1, Children_nested_array.size)
	assert_equal(false, Nested_array.leaf?, Nested_array.inspect)
	assert_equal(false, Nested_array.leaf?(:to_a), Nested_array.inspect)
	assert_respond_to(Son_nested_array, Children_method_name)
	assert_instance_of(Array, Grandchildren_nested_array)
	assert_equal(1, Grandchildren_nested_array.size)
	assert_equal(true, Grandson_nested_array.leaf?(:to_a), Grandson_nested_array.inspect)
	assert_equal(false, Son_nested_array.leaf?(:to_a), Son_nested_array.inspect)
end # leaf?
def test_map_recursive
	depth=0
	visit_proc = Tree_node_format
	assert_respond_to(Nested_array, :to_a)
	assert_equal(Tree_node_root, visit_proc.call(Nested_array, depth, false))
	assert_equal(1, Children_nested_array.size)
	assert_respond_to(Son_nested_array, Children_method_name)
	assert_instance_of(Array, Grandchildren_nested_array)
	assert_equal(1, Grandchildren_nested_array.size)
	assert_not_respond_to(Grandson_nested_array, Children_method_name)
	assert_equal('3', Grandson_nested_array.inspect_node)

	assert_equal('[2, [3], 4]', Son_nested_array.inspect_node, Son_nested_array.inspect)
	assert(Grandson_nested_array.leaf?(:to_a), Grandson_nested_array.inspect) # termination condition
	assert_equal(Grandson_nested_array_map, Grandson_nested_array.map_recursive(:to_a, depth=2, &Tree_node_format))
	assert_equal(Son_nested_array_map, Son_nested_array.map_recursive(:to_a, depth=1, &Tree_node_format))
	assert_equal(Nested_array_map, Nested_array.map_recursive(:to_a, &Tree_node_format))
end # map_recursive
def test_each_pair
	collect = []
	Example_array.each_pair {|key, value| collect << [key, value]}
	assert_equal(collect, [[0, 1], [1, 2], [2, 3]])
end # each_pair
def test_values
	assert_equal(Example_array, Example_array.values)
end # values
def test_keys
	assert_equal([0, 1, 2], Example_array.keys)
end # keys
def test_to_hash
	assert_equal(Example_array, Example_array.to_hash.to_a.values)
end # to_hash
def test_map_pair_Array
	tree = Flat_array
	idenity_map  = tree.class::Constants::Identity_map_pair
	assert_equal(tree, tree.map_pair(&idenity_map))
end # map_pair
def test_each_with_index
end # each_with_index
def test_map_pair_Hash
	tree = Flat_hash
	idenity_map  = tree.class::Constants::Identity_map_pair
	assert_equal(tree, tree.map_pair(&idenity_map))
end # map_pair
def test_enumerate_single
	atom=/5/
	single=atom.enumerate_single(:map){|e| e}
	assert_not_nil(single)
	assert_equal(5, 5.enumerate_single(:map){|e| e})
	assert_equal(5, 5.enumerate_single(:select){|e| e==5})
	assert_equal(nil, 5.enumerate_single(:select){|e| e==6})
	assert_equal(false, 5.enumerate_single(:all?){|e| e==6})
	assert_equal(true, 5.enumerate_single(:all?){|e| e==5})
end #enumerate_single
def test_enumerate
	atom=[/5/]
	single=atom.enumerate(:map){|e| e}
	assert_not_nil(single)
	assert_equal([5], [5].enumerate(:map){|e| e})
	assert_equal([5], [5].enumerate(:select){|e| e==5})
	assert_equal([], [5].enumerate(:select){|e| e==6})
	assert_equal(false, [5].enumerate(:all?){|e| e==6})
	assert_equal(true, [5].enumerate(:all?){|e| e==5})
end #enumerate
end #StreamTree

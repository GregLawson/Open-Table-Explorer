###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/stream_tree.rb'
class StreamTreeTest < TestCase
include DefaultTests
include TE.model_class?::Examples
include Tree::Examples
def test_map_recursive_simple_block
	assert_equal([[[0], 0, false], [[0, 0, nil]]], Flat_array.map_recursive(&Trace_map))
	assert_equal([Flat_array], Flat_array.map_recursive(&Leaf_map))
	assert_equal([Flat_array], Flat_array.map_recursive(&Identity_map))
	assert_equal([Flat_hash], Flat_hash.map_recursive(&Identity_map))
end # test_map_recursive_simple_block
def test_map_recursive
	depth=0
	visit_proc = Tree_node_format
	assert_respond_to(Literal_a, Children_method_name)
	assert_equal(Tree_node_root, visit_proc.call(Literal_a, depth, false))
	assert_equal(1, Children_a.size)
	assert_respond_to(Son_a, Children_method_name)
	assert_instance_of(Array, Grandchildren_a)
	assert_equal(1, Grandchildren_a.size)
	assert_not_respond_to(Grandson_a, Children_method_name)
	assert_equal(Node_a, Grandson_a.inspect_node)

	assert_equal(Node_options, Son_a.inspect_node, Son_a.inspect)
	assert(Grandson_a.leaf?(:expressions), Grandson_a.inspect) # termination condition
	assert_equal(Grandson_a_map, Grandson_a.map_recursive(:expressions, depth=2, &Inspect_format))
	assert_equal(Son_a_map, Son_a.map_recursive(:expressions, depth=1, &Inspect_format))
	assert_equal(Literal_a_map, Literal_a.map_recursive(:expressions, &Inspect_format))
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
def test_each_index
end # each_index
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

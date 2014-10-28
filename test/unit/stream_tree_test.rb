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
#include TE.model_class?::Examples
include GraphPath::Examples
include Tree::Examples
include Connectivity::Examples
def test_GraphPath_initialize
	assert_equal(GraphPath.new(nil), Root_path)
	assert_equal(GraphPath.new(nil), [])
	assert_equal(GraphPath.new, [])
	assert_equal(First_son, GraphPath.new(First_son))
	assert_equal(GraphPath.new(First_son), First_son, First_son.inspect)
	assert_equal(GraphPath.new(First_son[0], First_son[1]), First_son, First_son.inspect)
	assert_equal([[], 0], GraphPath.new(First_son[0], First_son[1]), First_son.inspect)
	assert_equal(GraphPath.new(First_grandson), First_grandson, First_grandson.inspect)
end # initialize
def test_deeper
end # deeper
def test_parent_index
	assert_equal([], Root_path.parent_index, Root_path.inspect)
	assert_equal(First_son, GraphPath.new(First_son), First_son.inspect)
	assert_equal(Root_path, GraphPath.new(First_son)[0], First_son.inspect)
	assert_equal(Root_path, GraphPath.new(GraphPath.new(First_son)[0]), First_son.inspect)
	assert_equal(Root_path, GraphPath.new(First_son).parent_index, First_son.inspect)
	assert_equal([], GraphPath.new(First_son).parent_index, First_son.inspect)
	assert_equal([], GraphPath.new(First_son)[0], First_son.inspect)
	assert_equal([], GraphPath.new(First_son).parent_index, First_son.inspect)
end # parent_index
def test_child_index
	assert_equal(0, GraphPath.new(First_son).child_index, GraphPath.new(First_son).inspect)
	assert_equal(Root_path.child_index, nil, Root_path.inspect)
end # child_index
def test_Constants
	assert_equal(Root_path, GraphPath.new(nil))
end # Constants
# Connectivity
def test_Connectivity_initialize
	example_array = Connectivity.new(node: [1, 2, 3], currently: Root_path)
	example_array = Connectivity.new(node: [1, 2, 3])
	nested_array = Connectivity.new(node: [1, [2, [3], 4], 5])
end # initialize
def test_ref (tree)
end # ref
def test_square_brackets (*params)
end # square_brackets
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
	assert_equal(false, NestedArrayType.leaf?(Nested_array), NestedArrayType.inspect)
	assert_respond_to(Son_nested_array, Children_method_name)
	assert_instance_of(Array, Grandchildren_nested_array)
	assert_equal(1, Grandchildren_nested_array.size)
	assert_equal(true, NestedArrayType.leaf?(Grandson_nested_array), Grandson_nested_array.inspect)
	assert_equal(false, NestedArrayType.leaf?(Son_nested_array), Son_nested_array.inspect)
end # leaf?
def test_inspect_node
	assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array))
	assert_equal('[2, [3], 4]', NestedArrayType.inspect_node(Son_nested_array))
	assert_equal('3', NestedArrayType.inspect_node(Grandson_nested_array))
	assert_match(NestedArrayType.inspect_node(Nested_array), Tree_node_root)
end # inspect_node
def test_map_recursive
	depth=0
	visit_proc = Tree_node_format
	assert_equal(Tree_node_root, visit_proc.call(Nested_array, depth, false))
	assert_equal(1, Children_nested_array.size)
	assert_respond_to(Son_nested_array, Children_method_name)
	assert_instance_of(Array, Grandchildren_nested_array)
	assert_equal(1, Grandchildren_nested_array.size)
	assert_not_respond_to(Grandson_nested_array, Children_method_name)
	assert_equal('3', NestedArrayType.inspect_node(Grandson_nested_array))

	assert_equal('[2, [3], 4]', NestedArrayType.inspect_node(Son_nested_array), Son_nested_array.inspect)
	assert(NestedArrayType.leaf?(Grandson_nested_array), Grandson_nested_array.inspect) # termination condition
	assert_equal(Grandson_nested_array_map, NestedArrayType.map_recursive(Grandson_nested_array,depth=2, &Tree_node_format))
	assert_equal(Son_nested_array_map, NestedArrayType.map_recursive(Son_nested_array, depth=1, &Tree_node_format))
	assert_equal(Nested_array_map, NestedArrayType.map_recursive(Nested_array, &Tree_node_format))
end # map_recursive
def test_inspect_recursive
	assert_equal(Grandson_nested_array_map, NestedArrayType.map_recursive(Grandson_nested_array, depth=2, &Tree_node_format))
	assert_equal(Son_nested_array_map, NestedArrayType.map_recursive(Son_nested_array, depth=1, &Tree_node_format))
	assert_equal(Nested_array_map, NestedArrayType.map_recursive(Nested_array, &Tree_node_format))
	assert_equal((Nested_array_map.flatten.map{|s| s + "\n"}).join, NestedArrayType.inspect_recursive(Nested_array, &Tree_node_format), NestedArrayType.inspect_recursive(Nested_array, &Tree_node_format))
	assert_equal((Nested_array_map.flatten.map{|s| s + "\n"}).join, NestedArrayType.inspect_recursive(Nested_array), NestedArrayType.inspect_recursive(Nested_array))

#	assert_equal('ab # ' + Nested_array_map + "\n", Sequence_example.inspect_recursive(&Mx_format))
#	assert_equal('a # ' + Nested_array_map + "\n", Alternative_example.inspect_recursive(&Mx_format))
end # inspect_recursive
def test_each_pair
	collect = []
	Example_array.each_pair {|key, value| collect << [key, value]}
	assert_equal(collect, [[0, 1], [1, 2], [2, 3]])
end # each_pair
def test_parent_at
	assert_equal(Node::Examples::Nested_array_root.parent_at(nil, 0), Nested_array)
	assert_equal(Node::Examples::Nested_array_root.parent_at(nil), Nested_array)
	assert_equal(Node::Examples::Nested_array_root.parent_at([nil, 0]), Nested_array)
end # parent_at
def test_at
	assert_include(Node::Examples::Nested_array_root.methods, :at, Node::Examples::Nested_array_root.inspect)
	explain_assert_respond_to(Node::Examples::Nested_array_root, :at, Node::Examples::Nested_array_root.inspect)
	assert_equal(GraphPath.new(*Root_path), Root_path)
	path = GraphPath.new(Root_path)
	assert_empty(Root_path.parent_index)
	assert_empty(path.parent_index)
	assert(path.parent_index == [])
	assert_equal(Node::Examples::Nested_array_root.at(nil, 0), Nested_array[0])
	assert_equal(Node::Examples::Nested_array_root.at(Root_path), Nested_array)
#	assert_equal(Nested_array, Node::Examples::Nested_array_root.at(Root_path))
	assert_equal(0, GraphPath.new(First_son).child_index, First_son.inspect)
#	assert_equal(Son_nested_array, Node::Examples::Nested_array_root.at(First_son), First_son.inspect)
#	assert_equal(Grandson_nested_array, Node::Examples::Nested_array_root.at(First_grandson), First_grandson.inspect)
end # at
def test_Node_format
	assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array))
	assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array, &Node_format))
#	assert_match(/cat/, Tree_node_format.call('cat', depth=0, false))
end # Node_format
def test_map_recursive_simple_block
	assert_equal([[[0], 0, false], [[0, 1, true]]], NestedArrayType.map_recursive(Flat_array, &Trace_map))
#	assert_equal([Flat_array], NestedArrayType.map_recursive(Flat_array, &Leaf_map).compact)
	assert_equal([[0], [0]], NestedArrayType.map_recursive(Flat_array, &Identity_map))
#	assert_equal([Flat_hash, NestedArrayType.values], Flat_hash.map_recursive(Flat_array, &Identity_map))
end # test_map_recursive_simple_block
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
	idenity_map  = Array::Constants::Identity_map_pair
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

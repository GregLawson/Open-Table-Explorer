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
	assert_equal([Flat_array], Flat_array.map_recursive{|terminal, e, depth| e})
	assert_equal([Flat_array], Flat_array.map_recursive(&Identity_map))
	assert_equal([Flat_hash], Flat_hash.map_recursive(&Identity_map))
	assert_equal([[nil, [0], 0]], Flat_array.map_recursive(&Trace_map))
end # test_map_recursive_simple_block
def test_map_recursive
	children_method_name = :to_a
	depth=0
	children_method_name = children_method_name.to_sym
	assert_respond_to([0], children_method_name)
		children = [0].send(children_method_name)
		if children.empty? then # termination condition
			assert_empty(children)
			visit_proc.call(true, self, depth)  # end recursion
		else
			children.map_pair do |key, sub_tree|
				assert_not_respond_to(sub_tree, :map_recursive)
#					sub_tree.map_recursive(children_method_name, depth+1){|p| visit_proc.call(false, p, depth)}
#				else
					assert_equal(Flat_array, Identity_map.call(nil, Flat_array, depth)) # end recursion
#				end # if
			end # map
		end # if
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
end #StreamTree

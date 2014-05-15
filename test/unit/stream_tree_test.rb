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
def test_map_recursive
	children_method_name = :to_a
	depth=0
	children_method_name = children_method_name.to_sym
	assert_respond_to(Sequence_example, children_method_name)
		children = Sequence_example.send(children_method_name)
		if children.empty? then # termination condition
			visit_proc.call(true, self, depth)  # end recursion
		else
			children.map_pair do |key, sub_tree|
				if sub_tree.respond_to?(:map_recursive) then
					sub_tree.map_recursive(children_method_name, depth+1){|p| visit_proc.call(false, p, depth)}
				else
					fail 'sub_tree=' + sub_tree.inspect + ' of ' + self.inspect
				end # if
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
def test_each_index
end # each_index
def test_map
end # map
end #StreamTree

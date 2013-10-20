###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets start embeddded arrays
#require 'app/models/inlineAssertions.rb'
class NestedArray < Array # tree or matrix, whatever
module Constants
end #Constants
include Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
def initialize(array=[])
	super(array)
end #initialize
# new object, but of type of self
def promote(value)
	return self.class.new(value)
end #promote
# Makes sure all descendant classes return the proper nested type.
# Calls super [] and if an Array is returned promotes it to self's class
# If returned object is not an Array (e.g. leaf node) retun it unchanged.
def [](index)
	if super(index).kind_of?(Array) then
		return promote(super(index))
	else # unnested node
		return at(index)
	end #if
end #[]index
# reverse nested array
def reverse
	promote(super)
end #reverse
# Should apply to_s to each element before returning
# Use map_recursive
def to_s
	return map_recursive{|leaf| leaf.to_s}.flatten.join
end #to_s
# Apply block to each leaf.
# Nesting structure remains the same.
# Array#map will only process the top level Array. 
def map_recursive(&visit_proc)
	return self.map do |sub_tree| 
		if sub_tree.kind_of?(Array) then
			NestedArray.new(sub_tree).map_recursive{|p| visit_proc.call(p)}
		else
			visit_proc.call(sub_tree) # end recursion
		end #if
	end
end #map_recursive
# Apply block to each non-leaf or branching node
# Provides a postfix walk
# Two passes:
# 1) Recursively visit descendants
# 2) Visit branching nodes (Arrays)
# Desirable since result tree is constructed bottom-up
# Descendants have the block applied before they are reassembled into a tree.
# Branching node block can take into account changes in subtrees.

def map_branches(&visit_proc)
	visited_subtrees= self.map do |sub_tree| 
		if sub_tree.kind_of?(Array) then
			self.class.new(sub_tree).map_branches{|p| visit_proc.call(p)}
		else
			sub_tree
		end #if
	end
	return visit_proc.call(visited_subtrees, &visit_proc)
end #map_branches
# Probably less confusing as !
# The method makes no sense as a question
def merge_single_element_arrays?
	map_branches do |branch| # visit all in postfix order
		if branch.size==1 && branch[0].kind_of?(Array) then
			self.class.new(branch[0]) # remove redundant brankets
		else
			self.class.new(branch)
		end #if
	end #map_branches

end #merge_single_element_arrays
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
Echo_proc=Proc.new{|parseTree| parseTree}
Reverse_proc=Proc.new{|parseTree| parseTree.reverse}
Constant_proc=Proc.new{|parseTree| '*'}
Asymmetrical_Tree_Array=NestedArray.new([['1','2'],'3'])
end #Examples
end #NestedArray

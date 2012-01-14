###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# parse tree internal format is nested Arrays.
# Postfix operators and brackets start embeddded arrays
require 'app/models/inlineAssertions.rb'
class NestedArray < Array # tree or matrix, whatever
def initialize(array=[])
	super(array)
end #initialize
def to_s
	return self.to_a.join
end #to_s
def map_recursive(&visit_proc)
	return self.map do |sub_tree| 
		if sub_tree.kind_of?(Array) then
			NestedArray.new(sub_tree).map_recursive{|p| visit_proc.call(p)}
		else
			visit_proc.call(sub_tree) # end recursion
		end #if
	end
end #map_recursive
def map_branches(&visit_proc)
	visited_subtrees= self.map do |sub_tree| 
		if sub_tree.kind_of?(Array) then
			NestedArray.new(sub_tree).map_branches{|p| visit_proc.call(p)}
		else
			sub_tree
		end #if
	end
	return visit_proc.call(visited_subtrees, &visit_proc)
end #map_branches
end #NestedArray

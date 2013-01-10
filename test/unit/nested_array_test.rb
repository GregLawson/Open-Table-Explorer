###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/nested_array.rb'
require_relative 'default_assertions_test.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class NestedArrayTest  < TestCase

def test_initialize
	assert_not_nil(NestedArray.new(['K']))
	assert_equal(['K'], NestedArray.new(['K']))
	assert_equal(['K'], NestedArray.new(['K']).to_a)
end #initialize
def test_index
	assert_instance_of(NestedArray,NestedArray::Examples::Asymmetrical_Tree_Array)
	assert_respond_to(NestedArray::Examples::Asymmetrical_Tree_Array, :[])
	assert_not_nil(NestedArray::Examples::Asymmetrical_Tree_Array[0])
	assert_instance_of(NestedArray, NestedArray::Examples::Asymmetrical_Tree_Array[0])
end #[]index
def test_to_s
	assert_equal('123',NestedArray.new([1,2,3]).to_s)
	assert_equal('123',NestedArray.new([1,[2,3]]).to_s)
end #to_s
def test_map_recursive
	assert_equal(['*','.'], NestedArray::Examples::Echo_proc.call(['*','.']))
	assert_equal(['1','2'], NestedArray.new(['1','2']).map_recursive{|p| p})
	assert_equal(['String','String'], NestedArray.new(['1','2']).map_recursive{|p| p.class.name})
	assert_equal(['?1','?2'], NestedArray.new(['1','2']).map_recursive{|p| '?'+p})
	assert_equal(['*','*'], NestedArray.new(['*','.']).map_recursive{|p| '*'})
	assert_equal([['String','String']], NestedArray.new([['1','2']]).map_recursive{|p| p.class.name})
	assert_equal([['1','2']], NestedArray.new([['1','2']]).map_recursive{|p| p})
	postfix_tree=NestedArray.new(['*','.'])
	assert_equal([['*','.'],'C'], NestedArray.new([['*','.'],'C']).map_recursive{|p| p})
	assert_equal(['K',['*','.']], NestedArray.new(['K',['*','.']]).map_recursive{|p| p})
	assert_equal(['K',['*','.'],'C'], NestedArray.new(['K',['*','.'],'C']).map_recursive{|p| p})
	visit_proc=Proc.new{|parseTree| parseTree}
#	assert_equal('*', NestedArray::Examples::Echo_proc.call)
	assert_equal(['*','.'], NestedArray::Examples::Echo_proc.call(['*','.']))
	assert_equal(['*','.'], NestedArray.new(['*','.']).map_recursive(&NestedArray::Examples::Echo_proc))
	NestedArray::Examples::Asymmetrical_Tree_Array.map_recursive() do |leaf|
		assert_instance_of(String, leaf)
	end #map_recursive
end #map_recursive
def test_map_branches
	assert_equal(['*','.'], NestedArray.new(['*','.']).map_branches{|p| p})
	assert_equal(['C',['.','*']], NestedArray.new([['*','.'],'C']).map_branches{|p| p.reverse})
	assert_equal('*', ['*','1','2'][0])
	assert_equal('1', ['*','1','2'][1])
	assert_equal('1', NestedArray.new(['*','1','2']).map_branches{|p| p[1]})
	assert_equal('*', NestedArray.new(['*','1','2']).map_branches{|p| p[0]})
	assert_equal('2', NestedArray.new(['*','1','2']).map_branches{|p| p[2]})
	assert_equal('1*2', NestedArray.new(['*','1','2']).map_branches{|p| p[1]+p[0]+p[2]})
	assert_equal(['C',['.','*'],'K'], NestedArray.new(['K',['*','.'],'C']).map_branches{|p| p.reverse})
	assert_equal(['C',['.','*'],'K'], NestedArray.new(['K',['*','.'],'C']).map_branches(&NestedArray::Examples::Reverse_proc))
	assert_equal(['.','*'],NestedArray::Examples::Reverse_proc.call(['*','.']))
	assert_equal([['.','*']], NestedArray.new([['*','.']]).map_branches{|p| p.reverse})
	assert_equal(NestedArray::Examples::Asymmetrical_Tree_Array.reverse,NestedArray::Examples::Reverse_proc.call(NestedArray::Examples::Asymmetrical_Tree_Array))
	assert_equal(NestedArray::Examples::Asymmetrical_Tree_Array.flatten.reverse, NestedArray::Examples::Asymmetrical_Tree_Array.map_branches(&NestedArray::Examples::Reverse_proc).flatten)
	NestedArray::Examples::Asymmetrical_Tree_Array.map_branches() do |leaf|
		assert_instance_of(Array, leaf)
	end #map_branches
end #map_branches
def test_merge_single_element_arrays
	assert_equal(['.','*'], NestedArray.new([['.','*']]).merge_single_element_arrays?)
	assert_equal(['a'], NestedArray.new(['a']).merge_single_element_arrays?)
end #merge_single_element_arrays
end #NestedArray

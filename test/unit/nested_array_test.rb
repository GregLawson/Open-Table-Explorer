###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
require 'app/models/inlineAssertions.rb'
class NestedArrayTest  < ActiveSupport::TestCase
Asymmetrical_Tree_Array=[['1','2'],'3']
Asymmetrical_Tree=RegexpTree.new(Asymmetrical_Tree_Array)
Reverse_proc=Proc.new{|parseTree| parseTree.reverse}

def test_NestedArray
	assert_not_nil(NestedArray.new(['K']))
	assert_equal(['K'], NestedArray.new(['K']))
	assert_equal(['K'], NestedArray.new(['K']).to_a)
end #initialize
def test_to_s
	assert_equal('123',NestedArray.new([1,2,3]).to_s)
	assert_equal('123',NestedArray.new([1,[2,3]]).to_s)
end #to_s
def test_map_recursive
	echo_proc=Proc.new{|parseTree| parseTree}
	assert_equal(['*','.'], echo_proc.call(['*','.']))
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
#	assert_equal('*', echo_proc.call)
	assert_equal(['*','.'], echo_proc.call(['*','.']))
	assert_equal(['*','.'], NestedArray.new(['*','.']).map_recursive(&echo_proc))
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
	assert_equal(['C',['.','*'],'K'], NestedArray.new(['K',['*','.'],'C']).map_branches(&Reverse_proc))
	assert_equal(['.','*'], Reverse_proc.call(['*','.']))
	assert_equal([['.','*']], NestedArray.new([['*','.']]).map_branches{|p| p.reverse})
	assert_equal(Asymmetrical_Tree.reverse, Reverse_proc.call(Asymmetrical_Tree))
	assert_equal(Asymmetrical_Tree.flatten.reverse, Asymmetrical_Tree.map_branches(&Reverse_proc).flatten)
end #map_branches
end #NestedArray

###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../assertions/regexp_tree_assertions.rb'
#require 'test/test_helper_test_tables.rb'
class RegexpTreeTest < DefaultTestCase3
include DefaultTests3
def test_initialize
	assert_not_nil(RegexpTree.new)
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(model_class?)
end #initialize
def test_probability_space_size
	assert_equal(256, RegexpTree::Any.probability_space_size)
	assert_equal(194, RegexpTree::Many.probability_space_size)
	assert_equal(256, RegexpTree::Dot_star.probability_space_size)
	assert_equal(95, Asymmetrical_Tree.probability_space_size)

	assert_equal(95, No_anchor.probability_space_size)
	assert_equal(95, Start_anchor.probability_space_size)
	assert_equal(95, End_anchor.probability_space_size)
	assert_equal(95, Both_anchor.probability_space_size)
	assert_equal(3, Alternative_ab_of_abc_10.probability_space_size)

end #probability_space_size
def test_assert_specialized_repetitions
	my_self=RegexpTree.new('.+')
	my_self.assert_specialized_repetitions('.?')
end #compare_repetitions
A=RegexpTree.new('a')
B=RegexpTree.new('b')
Ab=RegexpTree.new('ab')
end #RegexpTreeTest

###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/regexp_parse_assertions.rb'
class UnboundedRange  # reopen class to add assertions
include UnboundedRange::Assertions
#extend UnboundedRange::Assertions::ClassMethods
end #UnboundedRange
class RegexpParseAssertionsTest < TestCase
#set_class_variables
include RegexpParse::TestCases
def test_RegexpParse_assert_pre_conditions
	RegexpParse.assert_pre_conditions
end #self.assert_pre_conditions
def assert_invariant
	RegexpParse.assert_invariant
end #assert_RegexpParse_invariant_conditions
def assert_post_conditions
	RegexpParse.assert_post_conditions
end #assert_RegexpParse_post_conditions
Asymmetrical_Tree=RegexpParse.new(NestedArray::TestCases::Asymmetrical_Tree_Array)
def test_assert_invariant
	regexp_string='K.*C'
	test_tree=RegexpParse.new(regexp_string)
	assert_not_nil(test_tree.parse_tree)
	assert_not_nil(RegexpParse.new(''))
	assert_equal('', RegexpParse.new(test_tree.rest).to_s)
	assert_equal(["K", [".", "*"], "C"], test_tree.parse_tree)
	assert_not_nil(RegexpParse.new(["K", [".", "*"], "C"].to_s))
	assert_not_nil(RegexpParse.new(test_tree.parse_tree.to_s))
	assert_not_nil(test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest.to_s+test_tree.parse_tree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest+test_tree.parse_tree.to_s)
	test_tree.assert_invariant
end #assert_invariant
def test_assert_pre_conditions
	parser=RegexpParse::TestCases::Sequence_parse
	parser.restartParse!
	parser.assert_pre_conditions
end #assert_pre_conditions
def test_assert_post_conditions
	parser=RegexpParse::TestCases::Sequence_parse
	parser.assert_post_conditions
end #assert_post_conditions
def test_assert_repetition_range
	RegexpParse.new(RegexpParse::TestCases::Empty_language_string).assert_repetition_range(UnboundedRange.new(0,0))
	assert_equal(UnboundedRange::Once, RegexpParse.new('a').repetition_length)
end #assert_repetition_range
def test_assert_round_trip
	RegexpParse.assert_round_trip(RegexpParse::TestCases::Dot_star_array)
	RegexpParse.assert_round_trip(RegexpParse::TestCases::Parenthesized_array)
end #assert_round_trip
RegexpParse.assert_pre_conditions
end #RegexpParseAssertionsTest

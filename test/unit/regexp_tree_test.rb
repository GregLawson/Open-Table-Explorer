###########################################################################
#    Copyright (C) 2010-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/regexp_tree_assertions.rb'
require_relative '../../test/assertions/default_assertions.rb'
require_relative '../../test/unit/default_assertions_tests.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class RegexpTree < NestedArray # reopen class to add assertions
include RegexpTreeAssertions
extend RegexpTreeAssertions::ClassMethods
end #RegexpTree
class RegexpTreeTest < TestCase
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include DefaultAssertionTests
def test_Anchoring_initialize
	No_anchor.assert_anchoring
	Start_anchor.assert_anchoring
	End_anchor.assert_anchoring
	Both_anchor.assert_anchoring
#	assert_equal(Anchor_root_test_case, Anchoring.new(No_anchor))
	assert_equal(No_anchor, Anchoring.new(No_anchor)[:base_regexp])
	assert_equal(No_anchor, Anchoring.new(Start_anchor)[:base_regexp])
	assert_equal(No_anchor, Anchoring.new(End_anchor)[:base_regexp])
	assert_equal(No_anchor, Anchoring.new(Both_anchor)[:base_regexp])
	assert_equal(Anchoring::Start_anchor_regexp, Anchoring.new(Start_anchor)[:start_anchor])
	assert_nil(Anchoring.new(No_anchor)[:start_anchor])
	assert_nil(Anchoring.new(Start_anchor)[:end_anchor])
	assert_equal(Anchoring::End_anchor_regexp, Anchoring.new(End_anchor)[:end_anchor])
end #anchoring
def test_compare_anchor
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
	assert_operator(Anchoring.new(Start_anchor), :>, Anchoring.new(Both_anchor))
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(End_anchor))
	assert_operator(Anchoring.new(End_anchor), :>, Anchoring.new(Both_anchor))
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Both_anchor))
	assert_nil(Anchoring.new(Start_anchor) <=> Anchoring.new(End_anchor))
end #anchor
def regexpParserTest(parser)
	assert_respond_to(parser,:parseOneTerm!)
#	Now test after full parse.
	parser.restartParse!
	assert(!parser.beyondString?)
	assert(parser.rest.length>0)
	assert(parser.rest==parser.regexp_string)
	parser.conservationOfCharacters	
#	Test after a little parsing.
	assert_not_nil(parser.nextToken!)
	assert(parser.rest!=parser.regexp_string)
	parser.restartParse!
	assert_not_nil(parser.parseOneTerm!)
	parser.restartParse!
	assert(parser.parseOneTerm!.size>0)
#	Now test after full parse.
	parser.restartParse!
	assert_not_nil(parser.regexpTree!)
	assert(parser.rest=='')
	parser.restartParse!
	parser.conservationOfCharacters	
	parser.restartParse!
	assert(parser.regexpTree!.size>0)
	assert(parser.beyondString?)
end #def

def test_probability_space_regexp
	assert_equal(RegexpTree.new('[abc]{1,10}'), Alternative_ab_of_abc_10.probability_space_regexp)
end #probability_space_regexp
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
def test_probability_of_sequence
	branch=No_anchor
	assert_equal(0, 1/95)
	assert_not_equal(0, 1.0/95)
	
	assert_equal(1.0/95, No_anchor.probability_of_sequence)
	assert_equal((1.0/95)**3, Asymmetrical_Tree.probability_of_sequence)
	assert_not_equal((1.0/95), Asymmetrical_Tree.probability_of_sequence)
	assert_equal(1.0/95, Start_anchor.probability_of_sequence)
	assert_equal(1.0/95, End_anchor.probability_of_sequence)
	assert_equal(1.0/95, Both_anchor.probability_of_sequence)
end #probability_of_sequence
def test_probability_of_alternatives
	assert_equal(3, [1,2].reduce {|sum, e| sum + e })
	summation=['a','b'].reduce(0) do |sum, e| 
		assert_instance_of(String, e)
		assert_instance_of(Fixnum, sum)
		sum + e.size 
	end #reduce
	assert_equal(2, summation)
	assert_equal(2, ['a','b'].reduce(0) {|sum, e| sum + e.size })
	branch=Alternative_ab_of_abc_10
	assert_equal(2.0/3, branch.probability_of_alternatives)
end #probability_of_alternatives
def test_OpeningBrackets
	assert_equal('(',RegexpTree.OpeningBrackets[RegexpTree.ClosingBrackets.index(')')].chr)
end #OpeningBrackets
def test_ClosingBrackets
	assert_equal(0,RegexpTree.ClosingBrackets.index(')'))
end #ClosingBrackets
def test_initialize
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp_string)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp_string)

	assert_equal(['K'], RegexpTree.new('K').to_a)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal(Asymmetrical_Tree_Array.flatten, Asymmetrical_Tree.to_a.flatten)
	assert_not_nil(RegexpTree.new(['.']))
	assert_not_nil(RegexpTree.new('.'))
	assert_not_nil(RegexpTree.new(/./))
end #initialize
def test_compare_repetitions
	my_self=RegexpTree.new('.+')
	my_self.assert_specialized_repetitions('.?')
end #compare_repetitions
def test_compare_character_class
	assert_equal(Asymmetrical_Tree, Asymmetrical_Tree)
	assert_operator(RegexpTree.new('a'), :==, RegexpTree.new('a'))
	my_cc=RegexpTree.new('[ab]').character_class?
	other_cc=RegexpTree.new('[a]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, my_cc.compare_character_class?(other_cc))
	my_cc.assert_specialized_by(other_cc)

	
	my_cc=RegexpTree.new('[[:print:]]').character_class?
	assert_equal(95, my_cc.to_s.length)
	other_cc=RegexpTree.new('[[:xdigit:]]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, RegexpTree.new('[[:print:]]').compare_character_class?(RegexpTree.new('[[:xdigit:]]')))
end #compare_character_class
def test_compare_anchors
	assert_operator(Anchoring.new(No_anchor), :>, Anchoring.new(Start_anchor))
	No_anchor.assert_anchors_specialized_by(Start_anchor)
	RegexpTree.new('a').assert_anchors_specialized_by('^a')
	assert_equal(1, No_anchor.compare_anchors?(Start_anchor))
end #compare_anchors
def test_sequence_comparison
	assert_equal(1, RegexpTree.new('ab').compare_sequence?(RegexpTree.new('abc')))
	RegexpTree.new('ab').assert_sequence_specialized_by(RegexpTree.new('abc'))	
	RegexpTree.new('ab').assert_sequence_specialized_by(RegexpTree.new('abc'))	
end #sequence_comparison
def test_alternatives_intersect
	rhs=RegexpTree::Many.repeated_pattern
	lhs=RegexpTree::Any.repeated_pattern
	assert_equal('.', rhs.to_s)
	assert_equal(RegexpParse::TestCases::Any_binary_char_string, lhs.to_s)
	lhs_alternatives=lhs.alternatives?
	rhs_alternatives=rhs.alternatives?
	assert_instance_of(Array, lhs_alternatives)
	assert_instance_of(Array, rhs_alternatives)
	alternatives=lhs_alternatives & rhs_alternatives
	assert_instance_of(Array, alternatives)
	assert_equal(RegexpTree::Binary_bytes, lhs.alternatives_intersect(rhs))
end #alternatives_intersect
A=RegexpTree.new('a')
B=RegexpTree.new('b')
Ab=RegexpTree.new('ab')
def test_sequence_intersect
#	alternatives=Ab.alternatives?
	lhs=Ab
	rhs=A
	assert_nil(lhs.alternatives?)
	assert_empty(lhs.alternatives?)
	assert_not_nil(rhs.alternatives?)
	assert_not_empty(rhs.alternatives?)
	assert_instance_of(String, rhs[0])
	assert_nil(lhs.alternatives?)
#	assert_include(rhs[0], lhs.alternatives?)
	assert_equal(rhs, lhs.sequence_intersect(A))
	assert_equal(B, Ab.sequence_intersect(B))
end #sequence_intersect
def test_RegexpTree_intersection
	assert_equal(RegexpTree::Many, RegexpTree::Any & RegexpTree::Many)
end #intersection
def test_compare
	assert_equal(Asymmetrical_Tree, Asymmetrical_Tree)
	assert_operator(RegexpTree.new('a'), :==, RegexpTree.new('a'))
	my_cc=RegexpTree.new('[ab]').character_class?
	other_cc=RegexpTree.new('[a]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, my_cc <=> other_cc)
	assert_operator(my_cc, :>, other_cc)
	my_cc.assert_specialized_by(other_cc)

	
	my_cc=RegexpTree.new('[[:print:]]').character_class?
	assert_equal(95, my_cc.to_s.length)
	other_cc=RegexpTree.new('[[:xdigit:]]').character_class?
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_operator(RegexpTree.new('[[:print:]]'), :>, RegexpTree.new('[[:xdigit:]]'))
	RegexpTree.new('[[:print:]]').assert_specialized_by(RegexpTree.new('[[:xdigit:]]'))
end #<=>
def test_RegexpTree_to_a
	assert_equal(Asymmetrical_Tree_Array, Asymmetrical_Tree.to_a)

end #to_a
Alternatives_4=RegexpTree.new('a|b|c|d')
Nested_alternatives=RegexpTree.new('(a|b)(c|d)')
def test_alternatives
	# Pre-conditions
	assert_equal([["a", "|"], ["b", "|"], ["c", "|"], "d"], Alternatives_4)
	assert_equal([["(", ["a", "|"], "b", ")"], ["(", ["c", "|"], "d", ")"]], Nested_alternatives)
	#line by line known test case (particular invariant conditions)
	# character class test
	branch=RegexpTree.new('[0-2]')
	assert_kind_of(Array, branch)
	
	cc_comparison=branch.character_class?
	assert_not_nil(cc_comparison)
	assert_equal(['0','1','2'], cc_comparison)
	assert_equal(['0', '1', '2'], cc_comparison)
	# Unroll recursion
	# 
	branch=RegexpTree.new('a|b|c')
	assert_equal([["a", "|"], ["b", "|"], "c"], branch)
	assert_kind_of(Array, branch)
	assert_equal(branch[0].size, 2)
	assert_equal(branch[0][-1], '|')
	lhs=branch[0][0]
	assert_equal('a', lhs)
	assert_equal([["b", "|"], 'c'], branch[1..-1])
	# terminal recursion
	branch2=branch[1..-1]
	assert_equal([["b", "|"], "c"], branch2)
	assert_kind_of(Array, branch2)
	assert_equal(branch2[0].size, 2)
	assert_equal(branch2[0][-1], '|')
	lhs=branch2[0][0]
	assert_equal('b', lhs)
	assert_equal(['c'], branch2[1..-1])
	rhs=branch.alternatives?(branch2[1..-1])
	assert_not_nil(rhs)
	assert_equal(['c'], rhs)
	assert_equal(['b', 'c'], ([lhs] + rhs).sort)
	
	lhs=branch[0][0]
	assert_equal('a', lhs)
	assert_equal([["b", "|"], 'c'], branch[1..-1])
	rhs=branch.alternatives?(branch[1..-1])
	assert_not_nil(rhs)
	assert_equal(['b', 'c'], rhs)
	assert_equal(['a', 'b', 'c'], ([lhs] + rhs).sort)
	#test known cases of method (post conditions)
	assert_equal(['a', 'b'], RegexpTree.new('a|b').alternatives?)
	assert_equal(['a', 'b', 'c'], RegexpTree.new('a|b|c').alternatives?)
	assert_equal(['a', 'b', 'c', 'd'], Alternatives_4.alternatives?)
	assert_nil(Nested_alternatives.alternatives?)
	assert_equal(['a'], RegexpTree.new('a').alternatives?('a'))
	assert_equal(['.'], RegexpTree::Any.repeated_pattern)
	assert_instance_of(Array, RegexpTree.new('.').character_class?)
	assert_instance_of(Array, RegexpTree.new('.').alternatives?)
	assert_instance_of(Array, RegexpTree::Any.repeated_pattern.alternatives?)
end #alternatives
def test_character_class
	character_class=RegexpTree.new('[a]')
	assert_instance_of(RegexpTree, character_class)
	assert_instance_of(Array, character_class.character_class?)
	assert_equal('a', character_class.character_class?.to_s)
	promoted_character_class=RegexpTree.new('a')
	assert_kind_of(RegexpTree, promoted_character_class)
	assert_equal(0, character_class <=> promoted_character_class)
	assert_equal(character_class, promoted_character_class)
	assert_equal(['a'], promoted_character_class)
	assert_instance_of(RegexpTree, promoted_character_class)
	assert_equal(1, promoted_character_class.length)
	assert_equal(character_class.character_class?, promoted_character_class.character_class?)
	assert_instance_of(Array, promoted_character_class.character_class?)
	assert_equal(256, RegexpTree::Any.string_of_matching_chars.length)
	assert_instance_of(Array, RegexpTree::Any.repeated_pattern.string_of_matching_chars)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], RegexpTree::Any.repeated_pattern)
	assert_equal(256, RegexpTree::Any.repeated_pattern.character_class?.size)
	assert_instance_of(Array, RegexpTree::Any.repeated_pattern.character_class?)
	assert_instance_of(Array, RegexpTree::Any.repeated_pattern.alternatives?)
end #character_class
def test_postfix_expression
	assert_not_nil(RegexpTree::Dot_star)
	assert(RegexpTree::Dot_star.postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
	assert(!RegexpTree.new(['K',['.','*'],'C']).postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
	assert(!RegexpTree.new(['K',['.','*']]).postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
	assert(!RegexpTree.new([['.','*'],'C']).postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
	assert(!RegexpTree.new([['.','*']]).postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
end #postfix_expression
def test_bracket_operator
	assert_equal([".", ["{", "3", ",", "4", "}"]], RegexpTree.new('.{3,4}'))
	assert_equal(["{", "3", ",", "4", "}"], RegexpTree.new('.{3,4}')[-1].bracket_operator?)
	assert(!RegexpTree.new('.*').bracket_operator?)

	assert(!RegexpTree.new('.').bracket_operator?)
end #bracket_operator
def test_postfix_operator
	assert_instance_of(String,['*','a'][1])
	assert_equal(0,'*+?'.index(['*','a'][0]))
	assert_not_nil(RegexpTree::Dot_star)
	assert(RegexpTree::Dot_star.postfix_operator?('*'),"RegexpTree::Dot_star.to_s=#{RegexpTree::Dot_star.to_s.inspect}")
	assert(!RegexpTree::Dot_star.postfix_operator?('.'),"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
end #postfix_operator
Test_Pattern_Array=["t", "e", "s", "t", "/",
	  	[["[", "a", "-", "z", "A", "-", "Z", "0", "-", "9", "_", "]"], "*"],
	 	["[", ".", "]"],
	 	"r",
		[["[", "a", "-", "z", "]"], "*"]]
Test_Pattern=RegexpTree.new(Test_Pattern_Array)
def test_to_filename_glob
	assert_equal('*', RegexpTree.new(['.','*']).to_pathname_glob)
	assert_equal('*', RegexpTree.new([['.','*']]).to_pathname_glob)
	assert_equal('K*C', RegexpTree.new(['K',['.','*'],'C']).to_pathname_glob)
	assert_equal('app/models/*[.]rb', RegexpTree.new('app/models/([a-zA-Z0-9_]*)[.]rb').to_pathname_glob)
	assert_equal(Test_Pattern_Array, RegexpTree.new('test/[a-zA-Z0-9_]*[.]r[a-z]*').to_a)
	assert_equal(Test_Pattern_Array, Test_Pattern.map_branches{|b| (b[0]=='('?RegexpTree.new(b[1..-2]):RegexpTree.new(b))})
	assert_equal('test/*[.]r*', Test_Pattern.postfix_operator_walk{|p| '*'}.to_s)
	assert_equal('test/*[.]r*', RegexpTree.new('test/[a-zA-Z0-9_]*[.]r[a-z]*').to_pathname_glob)
end #to_pathname_glob
def test_pathnames
	assert_include('app/models', RegexpTree.new('app/.*').pathnames)
end #pathnames
def test_grep
	file_regexp='app/controllers/urls_controller.rb'
	pattern='(\w+)\.all'
	delimiter="\n"
	regexp=Regexp.new(pattern)
	ps=RegexpTree.new(file_regexp).pathnames
	p=ps.first
	assert_equal([p], ps)
	assert_instance_of(String, p)
	l=IO.read(p).split(delimiter).first
	assert_instance_of(String, l)
	matchData=regexp.match(l)
	assert_instance_of(Hash, {:pathname => p, :match => 'Url'})
	if matchData then
		assert_instance_of(Hash, {:pathname => p, :match => matchData[1]})
	end #if
	grep_matches=RegexpTree.new(file_regexp).grep(pattern)
	assert_instance_of(Array, grep_matches)
	assert_equal("app/controllers/urls_controller.rb", grep_matches[0][:context])
	assert_equal("Url", grep_matches[0][:matchData][1])
	assert_instance_of(ActiveSupport::HashWithIndifferentAccess, grep_matches[0])
	assert_equal(file_regexp, grep_matches[0][:context])
end #grep
def test_to_s


	assert_equal(Asymmetrical_Tree_Array,Asymmetrical_Tree.to_a)
	assert_equal('123',Asymmetrical_Tree.to_s)
#recurse	assert_equal('.*',RegexpTree.new('.*').to_s)
	assert_equal('K.*C',RegexpTree.new('K.*C').to_s)
end #to_s
def test_to_regexp
	assert_equal(/.*/mx,RegexpTree.new('.*').to_regexp)
end #to_regexp
def test_editor
	regexpParserTest(KCeditor)
	
	regexpParserTest(KCETeditor)
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(model_class?)
end #test_name_correct
def test_case
	assert_equal(Anchoring, RegexpParse.new(Both_anchor).case?)
	assert_equal(RepetitionLength, Any_binary_string_parse.case?)
end #case
end #RegexpTreeTest

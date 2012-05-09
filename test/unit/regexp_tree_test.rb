###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
#require 'test/test_helper_test_tables.rb'
class RegexpTree < NestedArray # reopen class to add assertions
include RegexpTreeAssertions
extend RegexpTreeAssertions::ClassMethods
end #RegexpTree
class RegexpTreeTest < ActiveSupport::TestCase
set_class_variables
#require 'app/models/regexp_tree.rb'
@@CONSTANT_PARSE_TREE=RegexpParser.new('K')
@@keditor=@@CONSTANT_PARSE_TREE.clone
@@CONSTANT_PARSE_TREE.freeze
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)

KCeditor=RegexpParser.new('KC')
KCETeditor=RegexpParser.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE')
Anchor_root_test_case='a'
No_anchor=RegexpTree.new(Anchor_root_test_case)
Start_anchor=RegexpTree.new(Anchoring::Start_anchor_regexp+Anchor_root_test_case)
End_anchor=RegexpTree.new(Anchor_root_test_case+Anchoring::End_anchor_regexp)
Both_anchor=RegexpTree.new(Anchoring::Start_anchor_regexp+Anchor_root_test_case+Anchoring::End_anchor_regexp)
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
Asymmetrical_Tree_Array=[['1','2'],'3']
Asymmetrical_Tree=RegexpTree.new(Asymmetrical_Tree_Array)
Sequence=RegexpTree.new(Asymmetrical_Tree.to_a.flatten)
Echo_proc=Proc.new{|parseTree| parseTree}
Constant_proc=Proc.new{|parseTree| '*'}
Alternative_ab_of_abc_10=RegexpTree.new('a|b', '[abc]{1,10}')

def test_probability_space_regexp
	assert_equal(RegexpTree.new('[abc]{1,10}'), Alternative_ab_of_abc_10.probability_space_regexp)
end #probability_space_regexp
def test_probability_space_size
	assert_equal(256, Any.probability_space_size)
	assert_equal(194, Many.probability_space_size)
	assert_equal(256, RegexpTree::Dot_star.probability_space_size)
	assert_equal(95, Asymmetrical_Tree.probability_space_size)

	assert_equal(95, No_anchor.probability_space_size)
	assert_equal(95, Start_anchor.probability_space_size)
	assert_equal(95, End_anchor.probability_space_size)
	assert_equal(95, Both_anchor.probability_space_size)
	assert_equal(3, Alternative_ab_of_abc_10.probability_space_size)

end #probability_space_size

def test_probability_of_repetition
	rhs=Any
	alternative_list=rhs.repeated_pattern.alternatives? # kludge for now
	assert_not_nil(alternative_list)
	alternatives=alternative_list.size
	assert_equal(256, alternatives)
	character_probability=alternatives/rhs.probability_space_size
	assert_equal(1.0, character_probability)
	length=0
	assert_equal(0, length)
	assert_equal(1.0, rhs.probability_of_repetition(0))
	assert_equal(1.0, rhs.probability_of_repetition(1))
	assert_equal(1.0, rhs.probability_of_repetition(nil))

	assert_equal(1/95, No_anchor.probability_of_repetition(1))
end #probability_of_repetition
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
	assert_equal(Sequence, Asymmetrical_Tree_Array.flatten)
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
end #sequence_comparison
def binary_case?(branch=self)
end #binary_case
def test_case
	assert_equal(Anchoring, Both_anchor.case?)
	assert_equal(RepetitionLength, Any.case?)
end #case
def test_alternatives_intersect
	rhs=Many.repeated_pattern
	lhs=Any.repeated_pattern
	assert_equal(Binary_range, rhs.to_s)
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
	assert_equal(['.'], Any.repeated_pattern)
	assert_instance_of(Array, RegexpTree.new('.').character_class?)
	assert_instance_of(Array, RegexpTree.new('.').alternatives?)
	assert_instance_of(Array, Any.repeated_pattern.alternatives?)
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
	assert_equal(256, Any.string_of_matching_chars.length)
	assert_instance_of(Array, Any.repeated_pattern.string_of_matching_chars)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], Any.repeated_pattern)
	assert_equal(256, Any.repeated_pattern.character_class?.size)
	assert_instance_of(Array, Any.repeated_pattern.character_class?)
	assert_instance_of(Array, Any.repeated_pattern.alternatives?)
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
def test_postfix_operator_walk
	assert_equal(['1', '2', '3'], Asymmetrical_Tree.to_a.flatten)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal('*', Constant_proc.call(Sequence))
	assert_equal(Sequence, Echo_proc.call(Sequence))
	assert_equal(Asymmetrical_Tree, Echo_proc.call(Asymmetrical_Tree))
	reverse_proc=Proc.new{|parseTree| parseTree.reverse}
	assert_equal(Sequence.to_a.reverse, reverse_proc.call(Sequence))

	assert_not_nil(RegexpTree.new(Asymmetrical_Tree))

	assert_kind_of(Array, RegexpTree::Dot_star)
	assert_equal(['.','*'], RegexpTree::Dot_star)
	assert_equal(RegexpTree::Dot_star[-1], '*')
	assert_not_equal(RegexpTree::Dot_star[0].class, Array)
	assert_equal(RegexpTree::Dot_star, RegexpTree::Dot_star.postfix_operator_walk(&Echo_proc))
	assert_equal(RegexpTree::Dot_star, RegexpTree::Dot_star.postfix_operator_walk{|p| p})
	assert_equal(['.', '*'], RegexpTree.new(RegexpTree::Dot_star).postfix_operator_walk(&Echo_proc))
	assert_equal(Sequence, RegexpTree.new(Sequence).postfix_operator_walk(&Constant_proc))
	assert_equal(Sequence, RegexpTree.new(Sequence).postfix_operator_walk(&Echo_proc))
	assert_equal(Asymmetrical_Tree, RegexpTree.new(Asymmetrical_Tree).postfix_operator_walk{|p| p})

	assert_equal(['*'], RegexpTree.new([['.','*']]).postfix_operator_walk{|p| '*'})
	assert(RegexpTree::Dot_star.postfix_expression?,"RegexpTree::Dot_star=#{RegexpTree::Dot_star.inspect}")
	assert_equal(['*', 'C'], RegexpTree.new([['.','*'],'C']).postfix_operator_walk{|p| '*'})
	assert_equal('*', Constant_proc.call(['.','*']))
	assert_equal('*', RegexpTree::Dot_star.postfix_operator_walk(&Constant_proc))
	assert_equal(['*'], Proc.new{|parseTree| parseTree[1..-1]}.call(RegexpTree::Dot_star))
	assert_equal(RegexpTree, Proc.new{|parseTree| parseTree[1..-1].class}.call(RegexpTree::Dot_star))
	visit_proc=Proc.new{|parseTree| parseTree[1..-1]}
	assert_equal(['*'], visit_proc.call(RegexpTree::Dot_star))
	assert_equal('.', ['.','*'][0])
	assert_equal('.', [['.','*']][0][0])
	visit_proc=Proc.new{|parseTree| parseTree[0]}
	assert_equal('.', visit_proc.call(RegexpTree::Dot_star))
	visit_proc=Proc.new{|parseTree| parseTree[1..-1]<<parseTree[0]}
	assert_equal(['*', '.'], visit_proc.call(RegexpTree::Dot_star))
	assert_equal(['*', '.'], RegexpTree::Dot_star.postfix_operator_walk(&visit_proc))
	assert_equal('test/*[.]r*', Test_Pattern.postfix_operator_walk{|p| '*'}.to_s)
	assert_equal('test/*[.]r*', Test_Pattern.to_pathname_glob)
end #postfix_operator_walk
def test_macro_call
	macro=RegexpTree.new("[:alnum:]")
	assert_equal(["[", ":", "a", "l", "n", "u", "m", ":", "]"], macro)
	assert_equal('[', macro[0])
	assert_equal(']', macro[-1])
	inner_colons=macro[1..-2] # not another nested array
	assert_equal(':', inner_colons[0])
	assert_equal(':', inner_colons[-1])
	assert_equal('alnum', macro.macro_call?)
end #macro_call?
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
Quantified_repetition=RegexpTree.new([".", ["{", "3", ",", "4", "}"]])
def test_repeated_pattern

	assert_equal(['.','*'], RegexpTree.new('.*'))
	assert(RegexpTree.new('.*').postfix_expression?)
	assert_equal(['.'], RegexpTree.new('.*').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.+').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.?').repeated_pattern)
	assert_equal(['a'], RegexpTree.new('a'))
	assert_equal(['a'], RegexpTree.new('a').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.').repeated_pattern)
	assert_equal(Quantified_repetition, RegexpTree.new('.{3,4}'))
	assert_equal(['.'], RegexpTree.new('.{3,4}').repeated_pattern)
	assert_equal('*', Any.postfix_expression?)
	assert_instance_of(RegexpTree, Any.repeated_pattern('a'))
	assert_instance_of(RegexpTree, Any.repeated_pattern)
	assert_instance_of(RegexpTree, Quantified_repetition.repeated_pattern)
	assert_instance_of(RegexpTree, Sequence.repeated_pattern)
	assert_equal(Binary_range, Any.repeated_pattern.to_s[1..-2])
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], Any.repeated_pattern)
end #repeated_pattern
Tree123=RegexpTree.new('[1-3]')
def test_string_of_matching_chars
	regexp=Regexp.new('\d')
	char='9'
	assert_match(regexp, char)
	ascii_characters=(0..255).to_a.map { |i| i.chr}
	assert_equal(256, ascii_characters.size)
	assert_equal(['1','2','3'], ("\x31".."\x33").to_a)
	assert_equal(['A','B','C'], ("\x41".."\x43").to_a)
	assert_equal(['Q','R','S'], ("\x51".."\x53").to_a)
	assert_equal(['a','b','c'], ("\x61".."\x63").to_a)
	matches=(("\x31".."\x33").to_a.select do |char|
		if regexp.match(char) then
			char
		else
			nil
		end #if
	end) #select
	assert_equal('123', matches.join)
	assert_match(/[a-z]/, 'a')
	assert_instance_of(Array, Tree123.string_of_matching_chars)
	assert_instance_of(String, Tree123.string_of_matching_chars[0])
	assert_equal(['[', '1', '-', '3', ']'], Tree123)
	assert_equal(['[', '1', '-', '3', ']'], Tree123.to_a)
	assert_equal(['1', '2', '3'], Tree123.string_of_matching_chars)
	assert_equal('123', Tree123.string_of_matching_chars.join)
	assert_equal('0123456789', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('0123456789', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz'.upcase, Tree123.string_of_matching_chars(/[A-Z]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz', Tree123.string_of_matching_chars(/[a-z]/).join)
	assert_equal('abcdefghijklmnopqrstuvwxyz', Tree123.string_of_matching_chars(Regexp.new('[a-z]')).join)
	assert_match(/[[:print:]]/, 'a')
	assert_equal(95, RegexpTree.new('[[:print:]]').string_of_matching_chars.length)
	assert_equal(194, RegexpTree.new('.').string_of_matching_chars.length)
	assert_equal(256, RegexpTree.new("#{Binary_range}").string_of_matching_chars.length)
	assert_equal(256, Any.string_of_matching_chars.length)
	assert_instance_of(Array, Any.repeated_pattern.string_of_matching_chars)
end #string_of_matching_chars
def test_editor
	regexpParserTest(KCeditor)
	
	regexpParserTest(KCETeditor)
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(@@model_class)
end #test_name_correct
def test_repetition_length
	assert_equal({"end"=>nil, "min"=>1}, RegexpTreeTest::Sequence.repetition_length('+'))
	assert_equal({"end"=>1, "min"=>0}, RegexpTreeTest::Sequence.repetition_length('?'))
	assert_equal({"end"=>nil, "min"=>0}, RegexpTreeTest::Sequence.repetition_length('*'))
	assert_equal(Repetition_1_2, RepetitionLength.new(1,2).concise_repetition_node)
	assert_equal({"end"=>0, "min"=>0}, RegexpTree.new('').repetition_length)
	assert_equal({"end"=>1, "min"=>1}, RegexpTree.new('.').repetition_length)
	assert_equal(["{", ["1", ',', "2"], "}"], RepetitionLength.new(1,2).concise_repetition_node)
	assert_equal({"end"=>3, "min"=>3}, RegexpTreeTest::Sequence.repetition_length)
end #repetition_length
end #RegexpTreeTest

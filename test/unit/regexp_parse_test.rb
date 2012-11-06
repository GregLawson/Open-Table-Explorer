###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/regexp_parse_assertions.rb'
class UnboundedRange  # reopen class to add assertions
include UnboundedRange::Assertions
#extend UnboundedRange::Assertions::ClassMethods
end #UnboundedRange
class RegexpParse  # reopen class to add assertions
include RegexpParse::Assertions
#include UnboundedRange::Assertions #not needed?
extend RegexpParse::Assertions::ClassMethods
end #RegexpParse
class RegexpParseTest < TestCase
#set_class_variables
include RegexpParse::TestCases
RegexpParse.assert_pre_conditions #verify class
# The following test case constants should be used only internally
# For external use use  RegexpParse::TestCases
# assert_pre_consitions and assert_invariant are used
Asymmetrical_Tree=RegexpParse.new(NestedArray::TestCases::Asymmetrical_Tree_Array)
CONSTANT_PARSE_TREE=RegexpParse.new('K')
Restartable_parse=CONSTANT_PARSE_TREE.clone
#CONSTANT_PARSE_TREE.freeze
	assert_equal(['K'],CONSTANT_PARSE_TREE.to_a)

KC_parse=RegexpParse.new('KC')
RowsRegexp='(<tr.*</tr>)'
Rows_parse=RegexpParse.new(RowsRegexp)
RowsEdtor2=RegexpParse.new('\s*(<tr.*</tr>)')
KCET_parse=RegexpParse.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE')
def test_OpeningBrackets
	assert_equal('(', RegexpParse::OpeningBrackets[RegexpParse::ClosingBrackets.index(')')].chr)
end #OpeningBrackets
def test_ClosingBrackets
	assert_equal(0, RegexpParse::ClosingBrackets.index(')'))
end #ClosingBrackets
def test_initialize
	regexp_string=['.', '*']
	assert_kind_of(Array, regexp_string)
	assert_instance_of(Array, regexp_string)
	regexp_parse=RegexpParse.new(regexp_string)
	assert_equal(['.', '*'], regexp_string.to_a, "regexp_string=#{regexp_string.inspect}, regexp_string.to_a=#{regexp_string.to_a.inspect}")
	assert_equal('.*', regexp_string.join, "regexp_string=#{regexp_string.inspect}, regexp_string.join=#{regexp_string.join.inspect}")
	assert_equal('.*', regexp_parse.regexp_string, "regexp_parse=#{regexp_parse.inspect}")
	assert_equal('.*', regexp_parse.regexp_string.to_s)
	assert_equal(['.', '*'], regexp_parse.parse_tree)
	regexp_parse.assert_invariant
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', regexp_parse.inspect, "regexp_parse=#{regexp_parse.inspect}")
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.new(['.', '*']).inspect, "RegexpParse.new(['.', '*'])=#{RegexpParse.new(['.', '*']).inspect}")
	regexp_string='K.*C'
	test_tree=RegexpParse.new(regexp_string)
	assert_equal(regexp_string,test_tree.to_s)
	assert_not_nil(test_tree.regexp_string)
	assert_not_nil(RegexpParse.new(test_tree.rest).to_s)
#	assert_not_nil(RegexpParse.new(nil))
	assert_instance_of(NestedArray, RegexpParse.new(['.', '*']).parse_tree)
	assert_instance_of(NestedArray, RegexpParse.new(CONSTANT_PARSE_TREE).parse_tree)
	assert_instance_of(NestedArray, RegexpParse.new(/.*/).parse_tree)
	assert_instance_of(NestedArray, RegexpParse.new('.*').parse_tree)
	assert_instance_of(RegexpParse, RegexpParse::TestCases::Parenthesized_parse)
	RegexpParse::TestCases::Parenthesized_parse.assert_post_conditions
	CONSTANT_PARSE_TREE.assert_post_conditions
	KC_parse.assert_post_conditions
	Rows_parse.assert_post_conditions
	RowsEdtor2.assert_post_conditions
	KCET_parse.assert_post_conditions
	assert_equal(2, RegexpParse.new('.*').parse_tree.size)
	assert_equal(['.','*'], RegexpParse.new('.*').parse_tree)
#	assert_equal(RegexpParse::TestCases::Nested_Test_Array, NestedArray.new(RegexpParse::TestCases::Nested_Test_Array).map_recursive(&NestedArray::TestCases::Echo_proc))
#	assert_equal(RegexpParse::TestCases::Nested_Test_Array, NestedArray.new(RegexpParse::TestCases::Nested_Test_Array).map_branches(&NestedArray::TestCases::Echo_proc))
end #initialize
def test_inspect
	inspect_string='@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1'
	assert_equal(inspect_string, RegexpParse.new('.*').inspect)
	assert_equal(inspect_string, RegexpParse::TestCases::Dot_star_parse.inspect)
end #inspect
def test_equal_operator
	rhs=RegexpParse::TestCases::Dot_star_parse
	lhs=RegexpParse.new('.*')
	assert_include(lhs.methods, :==)

	assert_equal(rhs, lhs)
end #equal_operator
def test_equal
	rhs=RegexpParse::TestCases::Dot_star_parse
	lhs=RegexpParse.new('.*')
	assert_include(lhs.methods, :eql?)

	assert(lhs.eql?(rhs))
	assert_equal(rhs, lhs)
end #equal
def test_compare
	rhs=RegexpParse::TestCases::Dot_star_parse
	lhs=RegexpParse.new('.*')
	compare=rhs <=> lhs
	assert_equal(0, compare)
	assert_equal([".", "*"], [".", "*"])
	assert(lhs.eql?(rhs))
	assert_equal(rhs, lhs)
end #compare
def test_RegexpParse_promotable
	assert(RegexpParse.promotable?(/.*/))
	assert(RegexpParse.promotable?('.*'))
	assert(RegexpParse.promotable?(['.', '*']))
end #RegexpParse.promotable
def test_RegexpParse_promote
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse.promote(RegexpParse::TestCases::Dot_star_parse))
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse.promote('.*'))
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.new(['.', '*']).inspect, "RegexpParse.new(['.', '*'])=#{RegexpParse.new(['.', '*']).inspect}")
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.promote(['.', '*']).inspect, "RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse.promote(['.', '*']), "RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}, RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse.promote(/.*/))
end #RegexpParse.promote
def test_to_a
	CONSTANT_PARSE_TREE.assert_post_conditions
	assert_equal(['K'], CONSTANT_PARSE_TREE.parse_tree, "KC_parse=#{KC_parse.inspect}")
	assert_equal(['K'], CONSTANT_PARSE_TREE.to_a, "KC_parse=#{KC_parse.inspect}")
	assert_equal(NestedArray::TestCases::Asymmetrical_Tree_Array.flatten, Asymmetrical_Tree.to_a.flatten)
	RegexpParse::TestCases::Dot_star_parse.assert_invariant
	RegexpParse::TestCases::Dot_star_parse.assert_post_conditions
	message="RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}"
	message+=" RegexpParse::TestCases::Dot_star_parse.parse_tree=#{RegexpParse::TestCases::Dot_star_parse.parse_tree.inspect}"
	message+=" RegexpParse::TestCases::Dot_star_parse.parse_tree.join=#{RegexpParse::TestCases::Dot_star_parse.parse_tree.join.inspect}"
	assert_equal(RegexpParse::TestCases::Dot_star_parse.regexp_string, RegexpParse::TestCases::Dot_star_parse.parse_tree.join, message)
	assert_equal(RegexpParse::TestCases::Dot_star_parse.regexp_string, RegexpParse::TestCases::Dot_star_parse.parse_tree.to_a.join, "")
end #to_a
def test_RegexpParse_to_s
	assert_equal('.*', RegexpParse::TestCases::Dot_star_parse.to_s)
	assert_equal(Asymmetrical_Tree.regexp_string, Asymmetrical_Tree.parse_tree.to_s)
end #to_s
def test_postfix_expression
	assert_not_nil(RegexpParse::TestCases::Dot_star_parse)
	assert(RegexpParse::TestCases::Dot_star_parse.postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
	assert(!RegexpParse.new(['K',['.','*'],'C']).postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
	assert(!RegexpParse.new(['K',['.','*']]).postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
	assert(!RegexpParse.new([['.','*'],'C']).postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
#	assert(!RegexpParse.new([['.','*']]).postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
end #postfix_expression
def test_bracket_operator
	assert_equal(RegexpParse::TestCases::Quantified_repetition_array, RegexpParse.new(RegexpParse::TestCases::Quantified_repetition_string).parse_tree)
	assert_not_nil(RegexpParse.new(RegexpParse::TestCases::Quantified_operator_string).parse_tree)
	assert_not_nil(RegexpParse.new(RegexpParse::TestCases::Quantified_operator_string).parse_tree[-1])
	assert_equal('}', RegexpParse.new(RegexpParse::TestCases::Quantified_operator_string).parse_tree[-1])
	assert_not_nil(RegexpParse.bracket_operator?(RegexpParse.new(RegexpParse::TestCases::Quantified_operator_string).parse_tree[-1]))
	assert_equal('}', RegexpParse.bracket_operator?(RegexpParse.new(RegexpParse::TestCases::Quantified_operator_string).parse_tree[-1]))
	assert(!RegexpParse.bracket_operator?(RegexpParse.new('.*')))

	assert(!RegexpParse.bracket_operator?(RegexpParse.new('.')))
end #bracket_operator
def test_postfix_operator
	assert_instance_of(String,['*','a'][1])
	assert_equal(0,'*+?'.index(['*','a'][0]))
	assert_not_nil(RegexpParse::TestCases::Dot_star_parse)
	assert(RegexpParse.postfix_operator?('*'),"RegexpParse::TestCases::Dot_star_parse.to_s=#{RegexpParse::TestCases::Dot_star_parse.to_s.inspect}")
	assert_equal('*', Any_binary_string_parse.postfix_expression?)
	assert(!RegexpParse.postfix_operator?('.'),"RegexpParse.postfix_operator?('.')=#{RegexpParse.postfix_operator?('.')}")
end #postfix_operator
def test_postfix_operator_walk
	assert_equal(['1', '2', '3'], Asymmetrical_Tree.to_a.flatten)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal('*',NestedArray::TestCases::Constant_proc.call(RegexpParse::TestCases::Sequence_parse))
	assert_equal(RegexpParse::TestCases::Sequence_parse,NestedArray::TestCases::Echo_proc.call(RegexpParse::TestCases::Sequence_parse))
	assert_equal(Asymmetrical_Tree,NestedArray::TestCases::Echo_proc.call(Asymmetrical_Tree))
	reverse_proc=Proc.new{|parse_tree| parse_tree.reverse}
	assert_equal(RegexpParse::TestCases::Sequence_parse.to_a.reverse, reverse_proc.call(RegexpParse::TestCases::Sequence_parse))
	RegexpParse::TestCases::Dot_star_parse.assert_post_conditions

	assert_equal(['.','*'], RegexpParse::TestCases::Dot_star_parse.parse_tree)
	assert_equal(RegexpParse::TestCases::Dot_star_parse.parse_tree[-1], '*')
	assert_not_equal(RegexpParse::TestCases::Dot_star_parse.parse_tree[0].class, Array)
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse::TestCases::Dot_star_parse.postfix_operator_walk(&NestedArray::TestCases::Echo_proc))
	assert_equal(RegexpParse::TestCases::Dot_star_parse, RegexpParse::TestCases::Dot_star_parse.postfix_operator_walk{|p| p})
	assert_equal(['.', '*'], RegexpParse::TestCases::Dot_star_parse.postfix_operator_walk(&NestedArray::TestCases::Echo_proc).parse_tree)
	assert_equal(RegexpParse::TestCases::Sequence_parse, RegexpParse.new(RegexpParse::TestCases::Sequence_parse).postfix_operator_walk(&NestedArray::TestCases::Constant_proc).parse_tree)
	assert_equal(RegexpParse::TestCases::Sequence_parse, RegexpParse.new(RegexpParse::TestCases::Sequence_parse).postfix_operator_walk(&NestedArray::TestCases::Echo_proc))
	assert_not_nil(RegexpParse.new(Asymmetrical_Tree))
	assert_equal(Asymmetrical_Tree, RegexpParse.new(Asymmetrical_Tree).postfix_operator_walk{|p| p})

	assert_equal(['*'], RegexpParse.new([['.','*']]).postfix_operator_walk{|p| '*'})
	assert(RegexpParse::TestCases::Dot_star_parse.postfix_expression?,"RegexpParse::TestCases::Dot_star_parse=#{RegexpParse::TestCases::Dot_star_parse.inspect}")
	assert_equal(['*', 'C'], RegexpParse.new([['.','*'],'C']).postfix_operator_walk{|p| '*'})
	assert_equal('*',NestedArray::TestCases::Constant_proc.call(['.','*']))
	assert_equal('*', RegexpParse::TestCases::Dot_star_parse.postfix_operator_walk(&NestedArray::TestCases::Constant_proc))
	assert_equal(['*'], Proc.new{|parse_tree| parse_tree[1..-1]}.call(RegexpParse::TestCases::Dot_star_parse))
	assert_equal(RegexpParse, Proc.new{|parse_tree| parse_tree[1..-1].class}.call(RegexpParse::TestCases::Dot_star_parse))
	visit_proc=Proc.new{|parse_tree| parse_tree[1..-1]}
	assert_equal(['*'], visit_proc.call(RegexpParse::TestCases::Dot_star_parse))
	assert_equal('.', ['.','*'][0])
	assert_equal('.', [['.','*']][0][0])
	visit_proc=Proc.new{|parse_tree| parse_tree[0]}
	assert_equal('.', visit_proc.call(RegexpParse::TestCases::Dot_star_parse))
	visit_proc=Proc.new{|parse_tree| parse_tree[1..-1]<<parse_tree[0]}
	assert_equal(['*', '.'], visit_proc.call(RegexpParse::TestCases::Dot_star_parse))
	assert_equal(['*', '.'], RegexpParse::TestCases::Dot_star_parse.postfix_operator_walk(&visit_proc))
	assert_equal('test/*[.]r*', Test_Pattern.postfix_operator_walk{|p| '*'}.to_s)
	assert_equal('test/*[.]r*', Test_Pattern.to_pathname_glob)
end #postfix_operator_walk
def test_RegexpParse_operator_range
	assert_equal(UnboundedRange::Many_range, RegexpParse.operator_range('+'))
	assert_equal(UnboundedRange::Optional, RegexpParse.operator_range('?'))
	assert_equal(UnboundedRange::Any_range, RegexpParse.operator_range('*'))
end #operator_range
def test_repetition_length
# line by line test
	node=Any_binary_string_parse
	node=RegexpParse.promote(node)
	assert_kind_of(RegexpParse, node)
	post_op=node.postfix_expression?
	node.assert_postfix_expression

	assert_equal('*', Any_binary_string_parse.postfix_expression?)
	assert_equal(post_op, '*')
	assert_equal(node.repetition_length, UnboundedRange.new(0, nil))
# constant tests
	assert_equal(UnboundedRange::Once, RegexpParse.new('.').repetition_length)
#bomb	assert_equal(UnboundedRange::Once, RegexpParse::TestCases::Sequence_parse.repetition_length)
# now test a variable parse and repetiton_length

	assert_equal(Any_binary_string_parse.repetition_length, UnboundedRange.new(0, UnboundedFixnum::Inf))
	Any_binary_string_parse.assert_repetition_range(UnboundedRange.new(0, UnboundedFixnum::Inf))
	Dot_star_parse.assert_repetition_range(UnboundedRange.new(0, UnboundedFixnum::Inf))
	Empty_language_parse.assert_repetition_range(UnboundedRange.new(0, 0))
	Parenthesized_parse.assert_repetition_range(UnboundedRange.new(1, 1))
	No_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
	Start_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
	End_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
	Both_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
	Quantified_repetition_parse.assert_repetition_range(UnboundedRange.new(3, 3))
	Composite_regexp_parse.assert_repetition_range(UnboundedRange.new(3, 3))


	parse=RegexpParse::TestCases::Any_binary_string_parse
	parse=RegexpParse::TestCases::Quantified_repetition_parse
	parse=RegexpParse::TestCases::Composite_regexp_parse
	parse=RegexpParse::TestCases::Dot_star_parse
	parse=RegexpParse::TestCases::Empty_language_parse
	rep=UnboundedRange::Once
	parse=RegexpParse::TestCases::Parenthesized_parse
	parse=RegexpParse::TestCases::No_anchor
	parse=RegexpParse::TestCases::Start_anchor
	parse=RegexpParse::TestCases::End_anchor
	parse=RegexpParse::TestCases::Both_anchor
	parse=RegexpParse::TestCases::Sequence_parse
	parse.assert_invariant
#temp	parse.assert_post_conditions
	rep=parse.repetition_length
	assert_not_nil(rep)
	assert_instance_of(UnboundedRange, rep)
	assert_instance_of(UnboundedFixnum, rep.first)
	assert_not_nil(rep.first)

	RegexpParse.new(RegexpParse::TestCases::Empty_language_string).assert_repetition_range(UnboundedRange.new(0,0))
	assert_equal(UnboundedRange::Once, RegexpParse.new('a').repetition_length)

#temp	parse.assert_repetition_range(rep)

	rep_first=rep.first
	assert_instance_of(UnboundedFixnum, rep_first)
	assert_equal(3, UnboundedFixnum.new(3))
	assert_not_nil(rep_first)

	Sequence_parse.assert_repetition_range(UnboundedRange.new(3, 3))
	assert_equal(3, rep_first.to_i, "rep=#{rep.inspect}, rep.first=#{rep.first.inspect}")
	assert_equal(3, rep_first, "rep=#{rep.inspect}")
	assert_operator(rep_first, :>=, 1)
	assert_operator(rep.first, :>=, 3)
	assert_equal(3, rep.first)
	assert_operator(rep.first, :==, 3)
	assert(rep.first.eql?(rep.first), "rep=#{rep.inspect}, rep.first=#{rep.first.inspect}")
	assert(rep.first.eql?(3))
	assert_equal(rep.first, 3)
	assert_operator(rep.first, :>, 0)
	assert_equal(3, rep.last)
	assert_not_nil(UnboundedRange.new(3, 3))
	assert_equal(0, UnboundedRange.new(3, 3) <=> RegexpParse::TestCases::Sequence_parse.repetition_length)
#	assert_equal(3, RegexpParse::TestCases::Sequence_parse.repetition_length)
	assert_equal(UnboundedRange.new(3, 3), RegexpParse::TestCases::Sequence_parse.repetition_length)
end #repetition_length
def test_repeated_pattern

	assert_equal(['.','*'], RegexpParse.new('.*').parse_tree)
	assert(RegexpParse.new('.*').postfix_expression?)
	assert_equal(['.'], RegexpParse.new('.*').repeated_pattern)
	assert_equal(['.'], RegexpParse.new('.+').repeated_pattern)
	assert_equal(['.'], RegexpParse.new('.?').repeated_pattern)
	assert_equal(['a'], RegexpParse.new('a').parse_tree)
	assert_equal(['a'], RegexpParse.new('a').repeated_pattern)
	assert_equal(['.'], RegexpParse.new('.').repeated_pattern)
	assert_equal(RegexpParse::TestCases::Quantified_repetition_parse, RegexpParse.new('.{3,4}'))
	assert_equal(['.'], RegexpParse.new('.{3,4}').repeated_pattern)
	assert_equal('*', RegexpParse::TestCases::Any_binary_string_parse.postfix_expression?)
	assert_instance_of(NestedArray, RegexpParse::TestCases::Any_binary_string_parse.repeated_pattern('a'))
	assert_instance_of(NestedArray, RegexpParse::TestCases::Any_binary_string_parse.repeated_pattern)
	assert_instance_of(NestedArray, RegexpParse::TestCases::Quantified_repetition_parse.repeated_pattern)
	assert_instance_of(NestedArray, RegexpParse::TestCases::Sequence_parse.repeated_pattern)
	assert_equal(RegexpParse::TestCases::Binary_range, RegexpParse::TestCases::Any_binary_string_parse.repeated_pattern.to_s)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], RegexpParse::TestCases::Any_binary_string_parse.repeated_pattern		)
 	assert_not_nil(RepetitionLength.new('.', 1, nil).repeated_pattern)
end #repeated_pattern
def test_case
	assert_equal(Anchoring, RegexpParse.new(RegexpParse::TestCases::Both_anchor).case?)
	assert_equal(RepetitionLength, RegexpParse::TestCases::Any_binary_string_parse.case?)
end #case
def test_restartParse
	Restartable_parse.restartParse!
	Restartable_parse.assert_pre_conditions
end #restartParse
def test_nextToken

	Restartable_parse.restartParse!
	assert_equal(Restartable_parse.nextToken!,'K')
	KC_parse.restartParse!
	assert_equal('C',KC_parse.nextToken!)
	Rows_parse.restartParse!
	assert_equal(Rows_parse.nextToken!,')')
end #nextToken!
def test_rest
	
	Restartable_parse.restartParse!
	assert_equal(Restartable_parse.rest,'K')

	KC_parse.restartParse!
	assert_equal(KC_parse.rest,'KC')
end #rest
def test_curlyTree
end #curlyTree
def test_parseOneTerm
	

	Restartable_parse.restartParse!
	assert_equal(Restartable_parse.parseOneTerm!,'K')
	KC_parse.restartParse!
	assert_equal('C',KC_parse.parseOneTerm!)
	KCET_parse.restartParse!
	assert_equal('E',KCET_parse.parseOneTerm!)
	assert_equal('I',KCET_parse.parseOneTerm!)
	assert_equal('V',KCET_parse.parseOneTerm!)
	assert_equal('K',KCET_parse.parseOneTerm!)
	assert_equal(['.','*'],KCET_parse.parseOneTerm!)
end #parseOneTerm!
def test_regexpTree
	
	Restartable_parse.restartParse!
	assert_equal(Restartable_parse.regexpTree!,['K'])
	KC_parse.restartParse!
	assert_equal(['K','C'],KC_parse.regexpTree!)
	assert_equal(["(", "<", "t", "r", [".", "*"], "<", "/", "t", "r", ">"],Rows_parse.regexpTree!('('))
end #regexpTree!
def test_value_of
	name=:Parenthesized
	form=:string
	assert_equal(RegexpParse::TestCases::Parenthesized_string, RegexpParse::TestCases.value_of?(name, form))
end #value_of
def test_constant_name
	name=:Parenthesized
	form=:string
	assert_equal('RegexpParse::TestCases::Parenthesized_string', RegexpParse::TestCases.constant_reference?(name, form))
end #constant_name
def test_parse_of
	string=RegexpParse::TestCases::Parenthesized_string
end #parse_of
def test_string_of
	name=:Parenthesized
	form=:string
	array=RegexpParse::TestCases::Parenthesized_array
end #string_of
def test_array_of
	string=RegexpParse::TestCases::Parenthesized_string
end #array_of
def test_name_of
	constant='Parenthesized_parse'
	match=/([A-Z][a-z_]*)_(array|string|parse)/.match(constant)
	assert_not_nil(match)
	assert_equal(3, match.size, "match=#{match.inspect}")
end #name_of
def test_names
	constants=RegexpParse::TestCases.constants
	assert_not_empty(constants)
	constants.map do |name|
		constant=('RegexpParse::TestCases::'+name).constantize
		assert_not_nil(name, "name=#{name.inspect}, constants=#{constants.inspect}")
		constant=('RegexpParse::TestCases::'+name).constantize
		match=RegexpParse::TestCases.name_of?(name)
		if !match.nil? && (constant.class==String || constant.class==Array || constant.class==RegexpParse) then
			assert_not_nil(match, "name.class=#{name.class.inspect}, name=#{name.inspect}, constants=#{constants.inspect}")
			match[1]
		else
			nil
		end #if
	end.compact.uniq #map
	assert_include(RegexpParse::TestCases.names, :Sequence)

end #names
def test_strings
	assert_not_nil(RegexpParse::TestCases.constants)
	assert_include(RegexpParse::TestCases.constants, :Dot_star_string)

	assert_include(RegexpParse::TestCases.methods(false), :strings)

	assert_include(RegexpParse::TestCases::strings, :Dot_star_string)

end #strings
def test_arrays
	assert_include(RegexpParse::TestCases::arrays, :Dot_star_array)

end #arrays
def test_parses
	assert_include(RegexpParse::TestCases::parses, :Dot_star_parse)

end #parses
RegexpParse.assert_pre_conditions
end #RegexpParerTest

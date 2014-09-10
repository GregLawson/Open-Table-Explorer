###########################################################################
#    Copyright (C) 2010-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../assertions/regexp_parse_assertions.rb'
class RegexpParseTest < TestCase
#include DefaultTests
include Regexp::Expression::Base::Examples
include RegexpParse::Examples
include Regexp::Expression::Base::Constants
include RegexpToken::Constants
include RegexpParse::Assertions
include NestedArray::Examples
include Graph::Constants
include TreeAddress::Constants
def test_initialize
	assert_equal(Root_index, TreeAddress.new(nil, 0))
end # initialize
def test_deeper
end # deeper
def test_Constants
end # Constants
def test_inspect_node
	assert_equal(Inspect_node_root, Literal_a.inspect_node(&Node_format))
	assert_equal(Inspect_node_root, Literal_a.inspect_node)
	assert_equal(Node_options, Son_a.inspect_node)
	assert_equal(Node_a, Grandson_a.inspect_node)
	assert_match(Literal_a.inspect_node, Tree_node_root)
	assert_match(Literal_a.inspect_node(&Node_format), Tree_node_root)
end # inspect_node
def test_Node_format
	assert_equal(Inspect_node_root, Literal_a.inspect_node)
	assert_equal(Inspect_node_root, Literal_a.inspect_node(&Node_format))
end # Node_format
def test_inspect_recursive
	assert_equal(Grandson_a_map, Grandson_a.map_recursive(:expressions, depth=2, &Tree_node_format))
	assert_equal(Son_a_map, Son_a.map_recursive(:expressions, depth=1, &Tree_node_format))
	assert_equal(Literal_a_map, Literal_a.map_recursive(:expressions, &Tree_node_format))
	assert_equal((Literal_a_map.flatten.map{|s| s + "\n"}).join, Literal_a.inspect_recursive(:expressions, &Tree_node_format), Literal_a.inspect_recursive(:expressions, &Tree_node_format))
	assert_equal((Literal_a_map.flatten.map{|s| s + "\n"}).join, Literal_a.inspect_recursive(:expressions), Literal_a.inspect_recursive)


#	assert_equal('ab # ' + Literal_a_map + "\n", Sequence_example.inspect_recursive(&Mx_format))
#	assert_equal('a # ' + Literal_a_map + "\n", Alternative_example.inspect_recursive(&Mx_format))
end # inspect_recursive
def test_Mx_format
	assert_match(Tree_node_root, Mx_format.call(Literal_a, 0, false))
	assert_equal(Mx_node_root, Mx_format.call(Literal_a, depth=0, false))
	assert_equal(Mx_node_options, Mx_format.call(Son_a, depth=1, false))
	assert_equal(Mx_node_a, Mx_format.call(Grandson_a, depth=2, true))
	assert_equal([Mx_node_root, Mx_node_options, Mx_node_a].map{|s| s + "\n"}.join, Literal_a.inspect_recursive(:expressions, &Mx_format))
end # Mx_format
def test_Tree_node_format
	assert_equal(Tree_node_root, Tree_node_format.call(Literal_a, depth=0, false))
	assert_equal(Tree_node_options, Tree_node_format.call(Son_a, depth=1, false))
	assert_equal(Tree_node_a, Tree_node_format.call(Grandson_a, depth=2, true))
	assert_equal('terminal[1], ' + Inspect_node_root, Tree_node_format.call(Literal_a, depth=1, true))
	assert_equal('nil[2], ' + Inspect_node_root, Tree_node_format.call(Literal_a, depth=2, nil))
	assert_equal('unknown[3], ' + Inspect_node_root, Tree_node_format.call(Literal_a, depth=3, 1)) # unknown
end # Tree_node_format
def test_Constants
end # Constants
def test_leaf?
	assert_respond_to(Literal_a, Children_method_name)
	assert_equal(Inspect_node_root, Node_format.call(Literal_a))
	assert_equal(1, Children_a.size)
	assert_equal(false, Literal_a.leaf?(:expressions), Literal_a.inspect)
	assert_equal(true, Literal_a.leaf?, Literal_a.inspect) # to_a not a method. Watch out!
	assert_respond_to(Son_a, Children_method_name)
	assert_instance_of(Array, Grandchildren_a)
	assert_equal(1, Grandchildren_a.size)
	assert_equal(true, Grandson_a.leaf?(:expressions), Grandson_a.inspect)
	assert_equal(false, Son_a.leaf?(:expressions), Son_a.inspect)
end # leaf?
def test_map_recursive
	assert_include(Graph::Constants.constants, :Tree_node_format)
	assert_include(RegexpParseTest.constants, :Tree_node_format)
	depth=0
	visit_proc = Tree_node_format
	assert_respond_to(Literal_a, Children_method_name)
	assert_equal(Tree_node_root, visit_proc.call(Literal_a, depth, false))
	assert_equal(1, Children_a.size)
	assert_respond_to(Son_a, Children_method_name)
	assert_instance_of(Array, Grandchildren_a)
	assert_equal(1, Grandchildren_a.size)
	assert_not_respond_to(Grandson_a, Children_method_name)
	assert_equal(Node_a, Grandson_a.inspect_node)

	assert_equal(Node_options, Son_a.inspect_node, Son_a.inspect)
	assert(Grandson_a.leaf?(:expressions), Grandson_a.inspect) # termination condition
	assert_equal(Grandson_a_map, Grandson_a.map_recursive(:expressions, depth=2, &Tree_node_format))
	assert_equal(Son_a_map, Son_a.map_recursive(:expressions, depth=1, &Tree_node_format))
	assert_equal(Literal_a_map, Literal_a.map_recursive(:expressions, &Tree_node_format))
end # map_recursive
def test_Examples
end # Examples
# Example from readme
def test_readme
	regex = /a?(b)*[c]+/m

	# using #to_s on the Regexp object to include options
	root = Regexp::Parser.parse( regex.to_s, 'ruby/1.8')

	assert_equal(root.multiline?, true)
	assert_equal(root.case_insensitive?, false)

	# simple tree walking method
	def walk(e, depth = 0)
	  puts "#{'  ' * depth}> #{e.class}"
	termination_condition = e.instance_of?(Regexp::Expression::Literal) # no subexpressions
#	termination_condition ||= e.expressions.empty?
	termination_condition = e.terminal?
	if termination_condition then
	else
	    e.each {|s| walk(s, depth+1) }
	end
	end # walk
	assert_equal('Regexp::Expression::Root', root.class.name)
	assert_instance_of(Regexp::Parser::Root, root)
	assert_include(root.methods, :expressions)
	puts 'root=' + root.inspect
	walk(root)
	# output
#	> Regexp::Expression::Root
#	  > Regexp::Expression::Literal
#	  > Regexp::Expression::Group::Capture
#	    > Regexp::Expression::Literal
#	  > Regexp::Expression::CharacterSet
end # readme
def test_Base_inspect
	root = Regexp::Parser.parse( /a/.to_s, 'ruby/1.8')
#	assert_equal([], root.map_recursive(:expressions, &Tree_node_format))
#	assert_equal([], root.map_recursive(:expressions){|terminal, e, depth| "#{e.class}(:#{e.type}, :#{e.token}, '#{e.text}')" })
end # inspect
RegexpParse.assert_pre_conditions #verify class
def test_brackets_RegexpTree
	assert_not_nil(RegexpTree[Any_binary_char_parse])
	assert_kind_of(NestedArray, RegexpTree[Any_binary_char_parse])
	assert_instance_of(CharacterClass, RegexpTree[Any_binary_char_parse])
	assert_global_name(:RegexpTree)
	assert(global_name?(:RegexpTree))
#	assert_instance_of(RegexpRepetition, RegexpTree[Any_binary_string_parse])
#	assert_instance_of(RegexpRepetition, RegexpTree[Dot_star_parse])
#	assert_instance_of(CharacterClass, RegexpTree[Any_binary_char])
##	assert_match(Empty_language_parse.to_regexp, '')
##	assert_no_match(Empty_language_parse.to_regexp, 'a')
##	assert_equal(['a', '|'], RegexpParse.new(/a|b/).to_a[0])
#	assert_instance_of(RegexpAlternative, RegexpTree[/a|b/])
#	assert_instance_of(RegexpSequence, RegexpTree[/ab/])
#	assert_instance_of(RegexpSequence, RegexpTree['ab'])
#	assert_instance_of(RegexpParen, RegexpTree[/(b)/])
#	assert_instance_of(RegexpEmpty, RegexpTree[/\A\z/])
end #brackets
def test_Constants_RegexpToken
	assert_instance_of(Hash, To_s)
	assert_equal(256, To_s.values.size)
	key_types=To_s.keys.map {|k| k.class}.uniq
	assert_equal([Symbol], key_types)
	value_types=To_s.values.map {|k| k.class}.uniq
	assert_equal([String], value_types)
	value_sizes=To_s.values.map {|k| k.size}.uniq
	assert_equal([1], value_sizes)
end #Constants_RegexpToken
def test_square_brackets_RegexpToken
	assert_instance_of(RegexpToken, RegexpToken[")"])
	assert_equal(RegexpToken[")"].inspect, ':'+:end_capture.to_s)
	assert_equal(To_s[:end_capture], ')')
	assert_equal(RegexpToken[:end_capture].to_sym, :end_capture)
	assert_equal(RegexpToken[:end_capture].inspect, ':'+:end_capture.to_s)
end #square_brackets_RegexpToken
def test_inspect_RegexpToken
	assert_equal(RegexpToken["*"].inspect, ':'+:any.to_s)
end #inspect
def test_to_sym_RegexpToken
	assert_equal(RegexpToken.new(["("]).inspect, ':'+:begin_capture.to_s)
	assert_equal(RegexpToken.new([")"]).inspect, ':'+:end_capture.to_s)
	assert_equal(RegexpToken.new(["{"]).inspect, ':'+:begin_repetition.to_s)
	assert_equal(RegexpToken.new(["}"]).inspect, ':'+:end_repetition.to_s)
	assert_equal(RegexpToken.new(["["]).inspect, ':'+:begin_class.to_s)
	assert_equal(RegexpToken.new(["]"]).inspect, ':'+:end_class.to_s)
	assert_equal(RegexpToken.new(["."]).inspect, ':'+:any_char.to_s)
	assert_equal(RegexpToken.new(["?"]).inspect, ':'+:optional.to_s)
	assert_equal(RegexpToken.new(["+"]).inspect, ':'+:many.to_s)
	assert_equal(RegexpToken.new(["*"]).inspect, ':'+:any.to_s)
	assert_equal(RegexpToken["*"].inspect, ':'+:any.to_s)
	assert_equal(RegexpToken["*"].to_sym, :any)
	assert_equal(RegexpToken[" "].to_sym, :space)
	assert_equal(RegexpToken["\t"].to_sym, :tab)
	assert_equal(RegexpToken["\n"].to_sym, :newline)
	assert_equal(RegexpToken["a"].to_sym, :a)
end #string
def test_to_pathname_glob_RegexpSequence
#	assert_instance_of(RegexpSequence, RegexpTree[/ab/])
#	assert_equal('ab', RegexpTree[/ab/].to_pathname_glob)	
end #to_pathname_glob
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
	assert_instance_of(RegexpParse, Parenthesized_parse)
	Parenthesized_parse.assert_post_conditions
	CONSTANT_PARSE_TREE.assert_post_conditions
	KC_parse.assert_post_conditions
	Rows_parse.assert_post_conditions
	RowsEdtor2.assert_post_conditions
	KCET_parse.assert_post_conditions
	assert_equal(2, RegexpParse.new('.*').parse_tree.size)
	assert_equal(['.','*'], RegexpParse.new('.*').parse_tree)
#	assert_equal(Nested_Test_Array, NestedArray.new(Nested_Test_Array).map_recursive(&NestedArray::Examples::Echo_proc))
#	assert_equal(Nested_Test_Array, NestedArray.new(Nested_Test_Array).map_branches(&NestedArray::Examples::Echo_proc))
end #initialize
def test_inspect
	inspect_string='@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1'
	assert_equal(inspect_string, RegexpParse.new('.*').inspect)
	assert_equal(inspect_string, Dot_star_parse.inspect)
end #inspect
def test_regexp_error
	assert_nothing_raised{RegexpParse.regexp_error('(')}
end #regexp_error
def test_equal_operator
	rhs=Dot_star_parse
	lhs=RegexpParse.new('.*')
	assert_include(lhs.methods, :==)

	assert_equal(rhs, lhs)
end #equal_operator
def test_equal
	rhs=Dot_star_parse
	lhs=RegexpParse.new('.*')
	assert_include(lhs.methods, :eql?)

	assert(lhs.eql?(rhs))
	assert_equal(rhs, lhs)
end #equal
def test_compare
	rhs=Dot_star_parse
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
	assert_equal(Dot_star_parse, RegexpParse.promote(Dot_star_parse))
	assert_equal(Dot_star_parse, RegexpParse.promote('.*'))
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.new(['.', '*']).inspect, "RegexpParse.new(['.', '*'])=#{RegexpParse.new(['.', '*']).inspect}")
	assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.promote(['.', '*']).inspect, "RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
	assert_equal(Dot_star_parse, RegexpParse.promote(['.', '*']), "Dot_star_parse=#{Dot_star_parse.inspect}, RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
	assert_equal(Dot_star_parse, RegexpParse.promote(/.*/))
end #RegexpParse.promote
def test_to_a
	CONSTANT_PARSE_TREE.assert_post_conditions
	assert_equal(['K'], CONSTANT_PARSE_TREE.parse_tree, "KC_parse=#{KC_parse.inspect}")
	assert_equal(['K'], CONSTANT_PARSE_TREE.to_a, "KC_parse=#{KC_parse.inspect}")
	Dot_star_parse.assert_invariant
	Dot_star_parse.assert_post_conditions
	message="Dot_star_parse=#{Dot_star_parse.inspect}"
	message+=" Dot_star_parse.parse_tree=#{Dot_star_parse.parse_tree.inspect}"
	message+=" Dot_star_parse.parse_tree.join=#{Dot_star_parse.parse_tree.join.inspect}"
	assert_equal(Dot_star_parse.regexp_string, Dot_star_parse.parse_tree.join, message)
	assert_equal(Dot_star_parse.regexp_string, Dot_star_parse.parse_tree.to_a.join, "")
end #to_a
def test_RegexpParse_to_s
	assert_equal('.*', Dot_star_parse.to_s)
end #to_s
def test_to_regexp
	regexp=/abc/
	assert_equal(RegexpParse.new(regexp).to_regexp, regexp)
end #to_regexp
def test_RegexpParse_postfix_expression?
	node=Quantified_repetition_parse
	assert_equal(node, RegexpParse.promote(node))
	assert(node.postfix_expression?, "node=#{node.inspect}")
	assert_equal(["{", "3", ",", "4", "}"], node.postfix_expression?, "Quantified_repetition_parse=#{Quantified_repetition_parse.inspect}")
end #postfix_expression
def test_postfix_expression
	assert_not_nil(Dot_star_parse)
	assert(Dot_star_parse.postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
# embedded postfix expressions return false (nil)
	assert(!RegexpParse.new(['K',['.','*'],'C']).postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
	assert(!RegexpParse.new(['K',['.','*']]).postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
	assert(!RegexpParse.new([['.','*'],'C']).postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
#	redundant nested Array is stripped
	assert(RegexpParse.new([['.','*']]).postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
	assert_instance_of(String, Any_binary_string_parse.parse_tree[-1])
	assert_equal('*', RegexpParse.postfix_operator?(Any_binary_string_parse.parse_tree[-1]))
	assert_equal('*', Any_binary_string_parse.postfix_expression?)
	assert(Quantified_repetition_parse.postfix_expression?, "Quantified_repetition_parse=#{Quantified_repetition_parse.inspect}")
end #postfix_expression
def test_bracket_operator
# node is parse tree or string to test
# detect bracket operator (not postfix characters)
	assert_equal('{3,4}', Quantified_operator_string)
	assert_not_nil(RegexpParse.new(Quantified_operator_string).parse_tree)
	assert_not_nil(RegexpParse.new(Quantified_operator_string).parse_tree[-1])
	assert_equal('}', RegexpParse.new(Quantified_operator_string).parse_tree[-1])
	assert_not_nil(RegexpParse.bracket_operator?(RegexpParse.new(Quantified_operator_string).parse_tree[-1]))
	assert_equal('}', RegexpParse.bracket_operator?(RegexpParse.new(Quantified_operator_string).parse_tree[-1]))
	assert(!RegexpParse.bracket_operator?(RegexpParse.new('.*')))

	assert(!RegexpParse.bracket_operator?(RegexpParse.new('.')))
	assert_equal('*', Dot_star_array[-1])
	assert_nil(RegexpParse.bracket_operator?(Dot_star_array[-1]))
# unlike postfix expression node, only last node should be passed
	assert_equal('.{3,4}', Quantified_repetition_string)
	assert_equal(Quantified_repetition_array, RegexpParse.new(Quantified_repetition_string).parse_tree)
	assert_nil(RegexpParse.bracket_operator?(Quantified_repetition_array[-1]))
	assert_nil(RegexpParse.bracket_operator?(Dot_star_array[-1]))
	node=Quantified_repetition_parse
	last_node=node.parse_tree[-1]
	assert_equal(RegexpParse.new(last_node), RegexpParse.promote(last_node))
	assert_equal(["{", "3", ",", "4", "}"], last_node, "last_node=#{last_node.inspect}")
	assert_instance_of(NestedArray, last_node)
	assert_equal(last_node, RegexpParse.bracket_operator?(last_node), "RegexpParse.bracket_operator?(last_node)=#{RegexpParse.bracket_operator?(last_node).inspect}")
end #bracket_operator
def test_postfix_operator
	node='*'
	assert_instance_of(String, node)
	assert_equal(0,'*+?'.index(['*','a'][0]))
	assert_equal(1,	PostfixOperators.index(node))	
	assert_not_nil(Dot_star_parse)
	node=Dot_star_array
	assert_nil(RegexpParse.bracket_operator?(Dot_star_array[-1]))
	assert(RegexpParse.postfix_operator?('*'),"Dot_star_parse.to_s=#{Dot_star_parse.to_s.inspect}")
	assert(!RegexpParse.postfix_operator?('.'),"RegexpParse.postfix_operator?('.')=#{RegexpParse.postfix_operator?('.')}")
	assert_equal('*', RegexpParse.postfix_operator?(Any_binary_string_parse.parse_tree[-1]))
	
	node=Quantified_repetition_parse
	last_node=node.parse_tree[-1]
	assert_equal(RegexpParse.new(last_node), RegexpParse.promote(last_node))
	assert_equal(["{", "3", ",", "4", "}"], last_node, "last_node=#{last_node.inspect}")
	assert_instance_of(NestedArray, last_node)
	assert_equal(last_node, RegexpParse.bracket_operator?(last_node), "RegexpParse.bracket_operator?(last_node)=#{RegexpParse.bracket_operator?(last_node).inspect}")
	assert_equal(last_node, RegexpParse.postfix_operator?(last_node), "RegexpParse.postfix_operator?(last_node)=#{RegexpParse.postfix_operator?(last_node).inspect}")
end #postfix_operator
def test_postfix_operator_walk
	assert_equal('*',NestedArray::Examples::Constant_proc.call(Sequence_parse))
	assert_equal(Sequence_parse,NestedArray::Examples::Echo_proc.call(Sequence_parse))
#	reverse_proc=Proc.new{|parse_tree| parse_tree.reverse}
#	assert_equal(Sequence_parse.to_a.reverse, reverse_proc.call(Sequence_parse))
	Dot_star_parse.assert_post_conditions

	assert_equal(['.','*'], Dot_star_parse.parse_tree)
	assert_equal(Dot_star_parse.parse_tree[-1], '*')
	assert_not_equal(Dot_star_parse.parse_tree[0].class, Array)
#	assert_equal(Dot_star_parse, Dot_star_parse.postfix_operator_walk(&NestedArray::Examples::Echo_proc))
#	assert_equal(Dot_star_parse, Dot_star_parse.postfix_operator_walk{|p| p})
#	assert_equal(['.', '*'], Dot_star_parse.postfix_operator_walk(&NestedArray::Examples::Echo_proc).parse_tree)
#	assert_equal(Sequence_parse, RegexpParse.new(Sequence_parse).postfix_operator_walk(&NestedArray::Examples::Constant_proc).parse_tree)
#	assert_equal(Sequence_parse, RegexpParse.new(Sequence_parse).postfix_operator_walk(&NestedArray::Examples::Echo_proc))
#	assert_not_nil(RegexpParse.new(Asymmetrical_Tree_Parse))
#	assert_equal(Asymmetrical_Tree_Parse, RegexpParse.new(Asymmetrical_Tree_Parse).postfix_operator_walk{|p| p})

#	assert_equal(['*'], RegexpParse.new([['.','*']]).postfix_operator_walk{|p| '*'})
	assert(Dot_star_parse.postfix_expression?,"Dot_star_parse=#{Dot_star_parse.inspect}")
#	assert_equal(['*', 'C'], RegexpParse.new([['.','*'],'C']).postfix_operator_walk{|p| '*'})
	assert_equal('*',NestedArray::Examples::Constant_proc.call(['.','*']))
	assert_equal('*', Dot_star_parse.postfix_operator_walk(&NestedArray::Examples::Constant_proc))
#	assert_equal(['*'], Proc.new{|parse_tree| parse_tree[1..-1]}.call(Dot_star_parse))
#	assert_equal(RegexpParse, Proc.new{|parse_tree| parse_tree[1..-1].class}.call(Dot_star_parse))
	visit_proc=Proc.new{|parse_tree| parse_tree[1..-1]}
#	assert_equal(['*'], visit_proc.call(Dot_star_parse))
	assert_equal('.', ['.','*'][0])
	assert_equal('.', [['.','*']][0][0])
	visit_proc=Proc.new{|parse_tree| parse_tree[0]}
#	assert_equal('.', visit_proc.call(Dot_star_parse))
	visit_proc=Proc.new{|parse_tree| parse_tree[1..-1]<<parse_tree[0]}
#	assert_equal(['*', '.'], visit_proc.call(Dot_star_parse))
#	assert_equal(['*', '.'], Dot_star_parse.postfix_operator_walk(&visit_proc))
#	assert_equal('test/*[.]r*', Test_Pattern.postfix_operator_walk{|p| '*'}.to_s)
#	assert_equal('test/*[.]r*', Test_Pattern.to_pathname_glob)
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
#bomb	assert_equal(UnboundedRange::Once, Sequence_parse.repetition_length)
# now test a variable parse and repetiton_length

	assert_equal(Any_binary_string_parse.repetition_length, UnboundedRange.new(0, UnboundedFixnum::Inf))
	Any_binary_string_parse.assert_repetition_range(UnboundedRange.new(0, UnboundedFixnum::Inf))
	Dot_star_parse.assert_repetition_range(UnboundedRange.new(0, UnboundedFixnum::Inf))
#	Empty_language_parse.assert_repetition_range(UnboundedRange.new(0, 0))
#	Parenthesized_parse.assert_repetition_range(UnboundedRange.new(1, 1))
	No_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
#	Start_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
#	End_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
#	Both_anchor.assert_repetition_range(UnboundedRange.new(1, 1))
#	Quantified_repetition_parse.assert_repetition_range(UnboundedRange.new(3, 3))
#	Composite_regexp_parse.assert_repetition_range(UnboundedRange.new(3, 3))


	parse=Any_binary_string_parse
	parse=Quantified_repetition_parse
	parse=Composite_regexp_parse
	parse=Dot_star_parse
	parse=Empty_language_parse
	rep=UnboundedRange::Once
	parse=Parenthesized_parse
	parse=No_anchor
	parse=Start_anchor
	parse=End_anchor
	parse=Both_anchor
	parse=Sequence_parse
	parse.assert_invariant
#temp	parse.assert_post_conditions
	rep=parse.repetition_length
	assert_not_nil(rep)
	assert_instance_of(UnboundedRange, rep)
	assert_instance_of(UnboundedFixnum, rep.first)
	assert_not_nil(rep.first)

#	RegexpParse.new(Empty_language_string).assert_repetition_range(UnboundedRange.new(0,0))
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
	assert_equal(0, UnboundedRange.new(3, 3) <=> Sequence_parse.repetition_length)
#	assert_equal(3, Sequence_parse.repetition_length)
	assert_equal(UnboundedRange.new(3, 3), Sequence_parse.repetition_length)
end #repetition_length
def test_repeated_pattern

	assert_equal(['.','*'], RegexpParse.new('.*').parse_tree)
	assert(RegexpParse.new('.*').postfix_expression?)
	assert_equal(['.'], RegexpParse.new('.*').repeated_pattern.parse_tree)
	assert_equal(['.'], RegexpParse.new('.+').repeated_pattern.parse_tree)
	assert_equal(['.'], RegexpParse.new('.?').repeated_pattern.parse_tree)
	assert_equal(['a'], RegexpParse.new('a').parse_tree)
	assert_equal(['a'], RegexpParse.new('a').repeated_pattern.parse_tree)
	assert_equal(['.'], RegexpParse.new('.').repeated_pattern.parse_tree)

	node=Quantified_repetition_parse
	assert_equal(node, RegexpParse.promote(node))
	assert_equal([".", ["{", "3", ",", "4", "}"]], RegexpParse.new('.{3,4}').parse_tree)
	assert(Quantified_repetition_parse.postfix_expression?, "Quantified_repetition_parse=#{Quantified_repetition_parse.inspect}")
	assert(node.postfix_expression?, "node=#{node.inspect}")
	assert_equal(["."], [RegexpParse.new('.{3,4}').parse_tree[0]])

	assert_equal(['.'], RegexpParse.new('.{3,4}').repeated_pattern.parse_tree)
	assert_equal('*', Any_binary_string_parse.postfix_expression?)
	assert_instance_of(RegexpParse, Any_binary_string_parse.repeated_pattern('a'))
	assert_kind_of(NestedArray, Any_binary_string_parse.repeated_pattern.parse_tree)
	assert_instance_of(RegexpParse, Quantified_repetition_parse.repeated_pattern)
	assert_kind_of(NestedArray, Sequence_parse.repeated_pattern.parse_tree)
	assert_equal(Any_binary_char_string, Any_binary_string_parse.repeated_pattern.to_s)
	assert_equal(["[", "\\0", "0", "0", "-", "\\3", "7", "7", "]"], Any_binary_string_parse.repeated_pattern.parse_tree		)
# 	assert_not_nil(RepetitionLength.new('.', 1, nil).repeated_pattern)
end #repeated_pattern
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
def test_to_pathname_glob
	assert_equal('ab', RegexpParse.new(/ab/).to_pathname_glob)
	assert_equal('[ab]', RegexpParse.new(/[ab]/).to_pathname_glob)
	assert_equal('ab', RegexpParse.new(/(ab)/).to_pathname_glob)
#	open_tax_filler_directory="../OpenTaxFormFiller/(?<tax_year>[0-9]{4}}"
	open_tax_filler_directory="../OpenTaxFormFiller/([0-9]{4})"
#	assert_equal('ab', RegexpTree.new(open_tax_filler_directory).to_pathname_glob)
	file_regexp="#{open_tax_filler_directory}/field_dump/Federal/f*.pjson"
#	regexp=RegexpTree.new(file_regexp)
#	assert_equal('*', regexp.to_pathname_glob)
end #to_pathname_glob
def test_pathnames
	open_tax_filler_directory="../OpenTaxFormFiller/(?<tax_year>[0-9]{4}}"
	file_regexp="#{open_tax_filler_directory}/field_dump/Federal/f*.pjson"
	regexp=RegexpParse.new(file_regexp)
#	regexp.pathnames.compact.map{|matchData| matchData[1]}
end #pathnames
def test_grep
	delimiter="\n"
end #grep
def test_old_case
#	assert_instance_of(RegexpSequence, RegexpParse.typed?('ab'))
#	assert_instance_of(RegexpRepetition, RegexpParse.typed?(Any_binary_string_parse))
#	assert_instance_of(RegexpRepetition, RegexpParse.typed?(Dot_star_parse))
#	assert_instance_of(CharacterClass, RegexpParse.typed?(Any_binary_char))
#	assert_instance_of(RegexpParen, RegexpParse.typed?(/(b)/))
#	assert_match(Empty_language_parse.to_regexp, '')
#	assert_no_match(Empty_language_parse.to_regexp, 'a')
#	assert_instance_of(RegexpEmpty, RegexpParse.typed?(/\A\z/))
#	assert_instance_of(RegexpSequence, RegexpParse.typed?(/ab/))
#	assert_equal(['a', '|'], RegexpParse.new(/a|b/).to_a[0])
#	assert_instance_of(RegexpAlternative, RegexpParse.typed?(/a|b/))
end #case
def test_typed
	assert_not_nil(RegexpParse.typed?(Any_binary_char_parse))

	node='ab'
	node=RegexpParse.promote(node)
	if node.instance_of?(Array) then
		node.map{|e| typed?(e)}
	end #if
#	assert_equal(RegexpSequence[RegexpToken["a"], RegexpToken["b"]], node)
	assert_equal(["a", "b"], RegexpParse.new('ab').parse_tree)
#	assert_instance_of(RegexpSequence, RegexpParse.typed?('ab'))
#	assert_equal([:a, :b], RegexpParse.typed?('ab'))

#	assert_kind_of(NestedArray, RegexpParse.typed?(Any_binary_char_parse))
#	assert_instance_of(CharacterClass, RegexpParse.typed?(Any_binary_char_parse))
##	assert(global_name?(RegexpTree))
#	assert_instance_of(RegexpRepetition, RegexpParse.typed?(Any_binary_string_parse))
#	assert_instance_of(RegexpRepetition, RegexpParse.typed?(Dot_star_parse))
#	assert_instance_of(CharacterClass, RegexpParse.typed?(Any_binary_char))
#	assert_match(Empty_language_parse.to_regexp, '')
#	assert_no_match(Empty_language_parse.to_regexp, 'a')
#	assert_equal(['a', '|'], RegexpParse.new(/a|b/).to_a[0])
#	assert_instance_of(RegexpAlternative, RegexpParse.typed?(/a|b/))
#	assert_instance_of(RegexpSequence, RegexpParse.typed?(/ab/))
#	assert_instance_of(RegexpSequence, RegexpParse.typed?('ab'))
#	assert_instance_of(RegexpParen, RegexpParse.typed?(/(b)/))
#	assert_instance_of(RegexpEmpty, RegexpParse.typed?(/\A\z/))
	

end #typed
RegexpParse.assert_pre_conditions
end #RegexpParerTest

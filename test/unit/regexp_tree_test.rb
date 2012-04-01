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
def test_to_exact_regexp
#	RegexpTree::Binary_bytes.each do |c|
	RegexpTree::Ascii_characters.each do |c|
		assert_not_nil(RegexpTree.regexp_rescued(Regexp.escape(c)), "Invalid regexp for character='#{c.to_exact_regexp}'.")
		assert_equal(Regexp.escape(c), RegexpTree.regexp_rescued(Regexp.escape(c)).source)	
		assert_equal(c.to_exact_regexp, RegexpTree.regexp_rescued(Regexp.escape(c)))
	end #each
end #to_exact_regexp
def test_String_to_a
	assert_equal(['a', 'b', 'c'],'abc'.to_a)
	assert_not_equal(['b', 'b', 'c'],'abc'.to_a)
end #to_a
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
Postfix_tree=RegexpTree.new(['.','*'])
Echo_proc=Proc.new{|parseTree| parseTree}
Constant_proc=Proc.new{|parseTree| '*'}
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
def test_RegexpTree_to_a
	assert_equal(Asymmetrical_Tree_Array, Asymmetrical_Tree.to_a)

end #to_a
def test_postfix_expression
	assert_not_nil(Postfix_tree)
	assert(Postfix_tree.postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new(['K',['.','*'],'C']).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new(['K',['.','*']]).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new([['.','*'],'C']).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new([['.','*']]).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
end #postfix_expression
def test_postfix_operator
	assert_instance_of(String,['*','a'][1])
	assert_equal(0,'*+?'.index(['*','a'][0]))
	assert_not_nil(Postfix_tree)
	assert(RegexpTree.postfix_operator?('*'),"Postfix_tree.to_s=#{Postfix_tree.to_s.inspect}")
	assert(!RegexpTree.postfix_operator?('.'),"Postfix_tree=#{Postfix_tree.inspect}")
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

	assert_kind_of(Array, Postfix_tree)
	assert_equal(['.','*'], Postfix_tree)
	assert_equal(Postfix_tree[-1], '*')
	assert_not_equal(Postfix_tree[0].class, Array)
	assert_equal(Postfix_tree, Postfix_tree.postfix_operator_walk(&Echo_proc))
	assert_equal(Postfix_tree, Postfix_tree.postfix_operator_walk{|p| p})
	assert_equal(['.', '*'], RegexpTree.new(Postfix_tree).postfix_operator_walk(&Echo_proc))
	assert_equal(Sequence, RegexpTree.new(Sequence).postfix_operator_walk(&Constant_proc))
	assert_equal(Sequence, RegexpTree.new(Sequence).postfix_operator_walk(&Echo_proc))
	assert_equal(Asymmetrical_Tree, RegexpTree.new(Asymmetrical_Tree).postfix_operator_walk{|p| p})

	assert_equal(['*'], RegexpTree.new([['.','*']]).postfix_operator_walk{|p| '*'})
	assert(Postfix_tree.postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert_equal(['*', 'C'], RegexpTree.new([['.','*'],'C']).postfix_operator_walk{|p| '*'})
	assert_equal('*', Constant_proc.call(['.','*']))
	assert_equal('*', Postfix_tree.postfix_operator_walk(&Constant_proc))
	assert_equal(['*'], Proc.new{|parseTree| parseTree[1..-1]}.call(Postfix_tree))
	assert_equal(RegexpTree, Proc.new{|parseTree| parseTree[1..-1].class}.call(Postfix_tree))
	visit_proc=Proc.new{|parseTree| parseTree[1..-1]}
	assert_equal(['*'], visit_proc.call(Postfix_tree))
	assert_equal('.', ['.','*'][0])
	assert_equal('.', [['.','*']][0][0])
	visit_proc=Proc.new{|parseTree| parseTree[0]}
	assert_equal('.', visit_proc.call(Postfix_tree))
	visit_proc=Proc.new{|parseTree| parseTree[1..-1]<<parseTree[0]}
	assert_equal(['*', '.'], visit_proc.call(Postfix_tree))
	assert_equal(['*', '.'], Postfix_tree.postfix_operator_walk(&visit_proc))
	assert_equal('test/*[.]r*', Test_Pattern.postfix_operator_walk{|p| '*'}.to_s)
	assert_equal('test/*[.]r*', Test_Pattern.to_pathname_glob)
end #postfix_operator_walk
def test_macro_call
	parseTree=RegexpTree.new("[[:alnum:]]")
	assert_equal([["[", ["[", ":", "a", "l", "n", "u", "m", ":", "]"], "]"]], parseTree)
	macro=parseTree[0] #first and only in test case list
	assert_equal(parseTree[0], parseTree[-1])
	assert_equal('[', macro[0])
	assert_equal(']', macro[-1])
	inner_brackets=macro[1..-2][0]
	assert_equal('[', inner_brackets[0], "macro=#{macro}, inner_brackets=#{inner_brackets}(#{inner_brackets.inspect}), , inner_brackets[0]=#{inner_brackets[0]}.")
	assert_equal(']', inner_brackets[-1])
	inner_colons=inner_brackets[1..-2] # not another nested array
	assert_equal(':', inner_colons[0])
	assert_equal(':', inner_colons[-1])
	assert_equal('alnum', RegexpTree.macro_call?(parseTree[0]))
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
def test_repeated_pattern

	assert_equal(['.','*'], RegexpTree.new('.*'))
	assert(RegexpTree.new('.*').postfix_expression?)
	assert_equal(['.'], RegexpTree.new('.*').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.+').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.?').repeated_pattern)
	assert_equal(['a'], RegexpTree.new('a'))
	assert_equal(['a'], RegexpTree.new('a').repeated_pattern)
	assert_equal(['.'], RegexpTree.new('.').repeated_pattern)
	assert_equal([".", ["{", "3", ",", "4", "}"]], RegexpTree.new('.{3,4}'))
	assert_equal(['.'], RegexpTree.new('.{3,4}').repeated_pattern)
end #repeated_pattern
def test_repetition_length
	Sequence.assert_equal([1, nil], Sequence.repetition_length('+'))
	Sequence.assert_equal([0, 1], Sequence.repetition_length('?'))
	Sequence.assert_equal([0, nil], Sequence.repetition_length('*'))
	Sequence.assert_equal(Repetition_1_2, Sequence.concise_repetion_node(1,2))
	Sequence.assert_equal([0, 0], Sequence.repetition_length(''))
	Sequence.assert_equal([1, 1], Sequence.repetition_length('.'))
	Sequence.assert_equal(["{", ["1", ',', "2"], "}"], Sequence.concise_repetion_node(1,2))
	assert_equal([3, 3], Sequence.repetition_length)
end #repetition_length
def test_merge_to_repetition
	branch=RegexpTree.new([['a','?'], ['a']])
	assert_equal(['a',['{',['1',',','2'], '}']], branch.merge_to_repetition)
end #merge_to_repetition
Repetition_1_2=["{", ["1", ",", "2"], "}"]
def test_canonical_repetion_tree
	assert_equal(Repetition_1_2, Sequence.canonical_repetion_tree(1,2))
end #canonical_repetion_tree
def test_concise_repetion_node
	Sequence.assert_equal('', Sequence.concise_repetion_node(1, 1))
	Sequence.assert_equal("+", Sequence.concise_repetion_node(1, nil))
	Sequence.assert_equal("?", Sequence.concise_repetion_node(0, 1))
	Sequence.assert_equal("*", Sequence.concise_repetion_node(0, nil))
	Sequence.assert_equal(Repetition_1_2, Sequence.concise_repetion_node(1,2))
end #concise_repetion_node
def test_editor
	regexpParserTest(KCeditor)
	
	regexpParserTest(KCETeditor)
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(@@model_class)
end #test_name_correct
end #test class

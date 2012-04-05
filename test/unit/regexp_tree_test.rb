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
One_to_ten=RepetitionLength.new(1, 10)
Any_repetition=RepetitionLength.new(0, nil)
def test_RepetitionLength_initialize
	assert_equal(1, One_to_ten[:min])
	assert_equal(10, One_to_ten[:max])
	assert_equal(0, Any_repetition[:min])
	assert_nil(Any_repetition[:max])
	
end #initialize
def test_compare
	assert_equal(RepetitionLength.new(1, nil), RepetitionLength.new(1, nil))
end #compare
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
def test_compare_repetitions
	my_self=RegexpTree.new('.+')
	my_self.assert_specialized_repetitions('.+')
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

	
	my_cc=RegexpTree.new('[[:print:]]').character_class?[1..-2]
	assert_equal(95, my_cc.to_s.length)
	other_cc=RegexpTree.new('[[:xdigit:]]').character_class?[1..-2]
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_equal(1, RegexpTree.new('[[:print:]]').compare_character_class?(RegexpTree.new('[[:xdigit:]]')))
end #compare_character_class
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

	
	my_cc=RegexpTree.new('[[:print:]]').character_class?[1..-2]
	assert_equal(95, my_cc.to_s.length)
	other_cc=RegexpTree.new('[[:xdigit:]]').character_class?[1..-2]
	intersection=my_cc & other_cc
	assert_not_equal(my_cc, intersection)
	assert_equal(other_cc, intersection)
	assert_operator(RegexpTree.new('[[:print:]]'), :>, RegexpTree.new('[[:xdigit:]]'))
	RegexpTree.new('[[:print:]]').assert_specialized_by(RegexpTree.new('[[:xdigit:]]'))
end #<=>
def test_RegexpTree_to_a
	assert_equal(Asymmetrical_Tree_Array, Asymmetrical_Tree.to_a)

end #to_a
def test_character_class
	character_class=RegexpTree.new('[a]')
	assert_kind_of(Array, character_class)
	assert_instance_of(RegexpTree, character_class.character_class?)
	assert_equal('[a]', character_class.character_class?.to_s)
	promoted_character_class=RegexpTree.new('a')
	assert_kind_of(RegexpTree, promoted_character_class)
	assert_not_equal(character_class, promoted_character_class)
	assert_equal(['a'], promoted_character_class)
	assert_instance_of(RegexpTree, promoted_character_class)
	assert_equal(1, promoted_character_class.length)
	assert_equal(character_class.character_class?, promoted_character_class.character_class?)
	assert_instance_of(RegexpTree, promoted_character_class.character_class?)
end #character_class
def test_postfix_expression
	assert_not_nil(Postfix_tree)
	assert(Postfix_tree.postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new(['K',['.','*'],'C']).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new(['K',['.','*']]).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new([['.','*'],'C']).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
	assert(!RegexpTree.new([['.','*']]).postfix_expression?,"Postfix_tree=#{Postfix_tree.inspect}")
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
	assert_not_nil(Postfix_tree)
	assert(Postfix_tree.postfix_operator?('*'),"Postfix_tree.to_s=#{Postfix_tree.to_s.inspect}")
	assert(!Postfix_tree.postfix_operator?('.'),"Postfix_tree=#{Postfix_tree.inspect}")
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
	Sequence.assert_equal(Repetition_1_2, RegexpTree.concise_repetion_node(1,2))
	Sequence.assert_equal([0, 0], Sequence.repetition_length(''))
	Sequence.assert_equal([1, 1], Sequence.repetition_length('.'))
	Sequence.assert_equal(["{", ["1", ',', "2"], "}"], RegexpTree.concise_repetion_node(1,2))
	assert_equal([3, 3], Sequence.repetition_length)
end #repetition_length
def test_merge_to_repetition
	side=['a']
	branch=RegexpTree.new([side, side])
	first=branch[0]
	second=branch[1]
	assert_equal(first, second)
	first_repetition=branch.repetition_length(first)
	second_repetition=branch.repetition_length(second)
	merged_repetition=RegexpTree.concise_repetion_node(first_repetition[0]+second_repetition[0], first_repetition[1]+second_repetition[1])
	assert_equal(["{", ["2", ",", "2"], "}"], merged_repetition)
	assert_equal(['a'], first.repeated_pattern)
	assert_equal([2, 2], [first_repetition[0]+second_repetition[0], first_repetition[1]+second_repetition[1]])
	assert_equal(['{',['2',',','2'], '}'], merged_repetition)
	assert_instance_of(RegexpTree, first.repeated_pattern)
	branch.merge_to_repetition([first.repeated_pattern, merged_repetition])
	assert_equal(['a',['{',['2',',','2'], '}']], branch.merge_to_repetition)
	branch=RegexpTree.new('a?a')
	assert_instance_of(RegexpTree, branch)
	assert_equal([["a", "?"], "a"], branch)
	first=branch[0]
	second=branch[1]
	assert_instance_of(RegexpTree, first)
	assert_instance_of(String, second)
	assert_equal(['a'], branch.repeated_pattern(first))
	assert_equal(['a'], branch.repeated_pattern(second))
	first_repetition=branch.repetition_length(first)
	second_repetition=branch.repetition_length(second)
	assert_equal([1, 2], [first_repetition[0]+second_repetition[0], first_repetition[1]+second_repetition[1]])
	assert_equal(['a'], branch.repeated_pattern(first))
	assert_equal(['a'], branch.repeated_pattern(second))
	merged_repetition=RegexpTree.concise_repetion_node(first_repetition[0]+second_repetition[0], first_repetition[1]+second_repetition[1])
	assert_equal(["{", ["1", ",", "2"], "}"], merged_repetition)
	assert_equal([], branch[2..-1])
	merged_pattern=['a',['{',['1',',','2'], '}']]
	assert_equal(merged_pattern, first.repeated_pattern << merged_repetition)
	assert_equal(merged_pattern, branch.merge_to_repetition(first.repeated_pattern << merged_repetition+branch[2..-1]))
	assert_equal(merged_pattern, branch.merge_to_repetition)
end #merge_to_repetition
Repetition_1_2=RegexpTree.new(["{", ["1", ",", "2"], "}"])
def test_canonical_repetion_tree
	assert_equal(Repetition_1_2, RegexpTree.canonical_repetion_tree(1,2))
end #canonical_repetion_tree
def test_concise_repetion_node
	Sequence.assert_equal('', RegexpTree.concise_repetion_node(1, 1))
	Sequence.assert_equal("+", RegexpTree.concise_repetion_node(1, nil))
	Sequence.assert_equal("?", RegexpTree.concise_repetion_node(0, 1))
	Sequence.assert_equal("*", RegexpTree.concise_repetion_node(0, nil))
	Sequence.assert_equal(Repetition_1_2, RegexpTree.concise_repetion_node(1,2))
	assert_equal(['{',['2',',','2'], '}'], RegexpTree.concise_repetion_node(2, 2))
end #concise_repetion_node
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
	assert_instance_of(RegexpTree, Tree123.string_of_matching_chars)
	assert_instance_of(String, Tree123.string_of_matching_chars[0])
	assert_equal(['[', '1', '-', '3', ']'], Tree123)
	assert_equal(['[', '1', '-', '3', ']'], Tree123.to_a)
	assert_equal(['[', '1', '2', '3', ']'], Tree123.string_of_matching_chars)
	assert_equal('[123]', Tree123.string_of_matching_chars.join)
	assert_equal('[0123456789]', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('[0123456789]', Tree123.string_of_matching_chars(/[0-9]/).join)
	assert_equal('[abcdefghijklmnopqrstuvwxyz]'.upcase, Tree123.string_of_matching_chars(/[A-Z]/).join)
	assert_equal('[abcdefghijklmnopqrstuvwxyz]', Tree123.string_of_matching_chars(/[a-z]/).join)
	assert_equal('[abcdefghijklmnopqrstuvwxyz]', Tree123.string_of_matching_chars(Regexp.new('[a-z]')).join)
	assert_match(/[[:print:]]/, 'a')
	assert_equal(95, RegexpTree.new('[[:print:]]').string_of_matching_chars[1..-2].length)
end #string_of_matching_chars
def test_editor
	regexpParserTest(KCeditor)
	
	regexpParserTest(KCETeditor)
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(@@model_class)
end #test_name_correct
end #test class

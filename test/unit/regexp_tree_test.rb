###########################################################################
#    Copyright (C) 2010-2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
require 'app/models/inlineAssertions.rb'
class RegexpTreeTest < ActiveSupport::TestCase
require 'test/test_helper'
require 'app/models/regexp_tree.rb'
WhiteSpacePattern=' '
WhiteEditor=RegexpParser.new(WhiteSpacePattern)	
@@CONSTANT_PARSE_TREE=RegexpParser.new('K')
@@keditor=@@CONSTANT_PARSE_TREE.clone
@@CONSTANT_PARSE_TREE.freeze
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)

KCeditor=RegexpParser.new('KC')
RowsRegexp='(<tr.*</tr>)'
RowsEditor=RegexpParser.new(RowsRegexp)
RowsEdtor2=RegexpParser.new('\s*(<tr.*</tr>)')
KCETeditor=RegexpParser.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE')
def test_RegexpParser
	regexp_string='K.*C'
	test_tree=RegexpParser.new(regexp_string)
	assert_equal(regexp_string,test_tree.to_s)
	assert_not_nil(test_tree.regexp_string)
	assert_not_nil(RegexpParser.new(test_tree.rest).to_s)
#	assert_not_nil(RegexpParser.new(nil))
end #initialize
def test_RegexpParser_to_a
	assert_equal(['K','C'], KCeditor.to_a)
end #to_a
def test_RegexpParser_to_s
	assert_equal('KC', KCeditor.to_s)
end #to_s
def test_nextToken

	@@keditor.restartParse!
	assert_equal(@@keditor.nextToken!,'K')
	KCeditor.restartParse!
	assert_equal('C',KCeditor.nextToken!)
	RowsEditor.restartParse!
	assert_equal(RowsEditor.nextToken!,')')
end #nextToken!
def test_rest
	
	@@keditor.restartParse!
	assert_equal(@@keditor.rest,'K')

	KCeditor.restartParse!
	assert_equal(KCeditor.rest,'KC')
end #rest
def test_curlyTree
end #curlyTree
def test_parseOneTerm
	

	@@keditor.restartParse!
	assert_equal(@@keditor.parseOneTerm!,'K')
	KCeditor.restartParse!
	assert_equal('C',KCeditor.parseOneTerm!)
	KCETeditor.restartParse!
	assert_equal('E',KCETeditor.parseOneTerm!)
	assert_equal('I',KCETeditor.parseOneTerm!)
	assert_equal('V',KCETeditor.parseOneTerm!)
	assert_equal('K',KCETeditor.parseOneTerm!)
	assert_equal(['.','*'],KCETeditor.parseOneTerm!)
end #parseOneTerm!
def test_regexpTree
	
	@@keditor.restartParse!
	assert_equal(@@keditor.regexpTree!,['K'])
	KCeditor.restartParse!
	assert_equal(['K','C'],KCeditor.regexpTree!)
	assert_equal(["(", "<", "t", "r", [".", "*"], "<", "/", "t", "r", ">"],RowsEditor.regexpTree!('('))
end #regexpTree!
def test_conservationOfCharacters
	regexp_string='K.*C'
	test_tree=RegexpParser.new(regexp_string)
	assert_not_nil(test_tree.parseTree)
	assert_not_nil(RegexpParser.new(''))
	assert_equal('', RegexpParser.new(test_tree.rest).to_s)
	assert_equal(["K", [".", "*"], "C"], test_tree.parseTree)
	assert_not_nil(RegexpParser.new(["K", [".", "*"], "C"].to_s))
	assert_not_nil(RegexpParser.new(test_tree.parseTree.to_s))
	assert_not_nil(test_tree.rest.to_s+test_tree.parseTree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest.to_s+test_tree.parseTree.to_s)
	assert_equal(test_tree.regexp_string, test_tree.rest+test_tree.parseTree.to_s)
	test_tree.conservationOfCharacters
end #conservationOfCharacters
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
def explain_assert_block(message="assert_block failed.") # :yields: 
  _wrap_assertion do
  if message.instance_of?(String) then
    exception=message.to_s
  elsif message.instance_of?(Test::Unit::Assertions::AssertionMessage) then
    exception='how do I get past to_s bug?'	
  else
    message="assert_block failed. message.class=#{message.class}"
    exception=message.to_s
  end #if
    if (! yield)
      raise exception
      raise message.to_s
      raise Test::Unit::AssertionFailedError.new(message.to_s)
    end
  end
end
def explain_assert_equal(expected, actual, message=nil)
  full_message = build_message(message, "<?> expected but was<?>.", expected, actual)
  puts "actual=#{actual.inspect}"
  puts "expected=#{expected.inspect}"
  puts "expected == actual=#{expected == actual}"
  condition=expected == actual
  explain_assert_block(full_message) { condition }
end #explain_assert_equal
def test_initialize
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp_string)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.to_a)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp_string)

	assert_equal(['K'], RegexpTree.new('K').to_a)
	assert_equal([['1', '2'], '3'], Asymmetrical_Tree.to_a)
	assert_equal(Asymmetrical_Tree_Array.flatten, Asymmetrical_Tree.to_a.flatten)
	assert_equal(Sequence, Asymmetrical_Tree_Array.flatten)
end #initialize
def test_index
	assert_instance_of(RegexpTree,Asymmetrical_Tree)
	assert_respond_to(Asymmetrical_Tree, :[])
	assert_not_nil(Asymmetrical_Tree[0])
	assert_instance_of(RegexpTree,Asymmetrical_Tree[0])
	assert_not_nil(RegexpTree.new(['K']))
	assert_instance_of(RegexpTree,RegexpTree.new(['K']))
	assert_instance_of(String,RegexpTree.new(['K'])[0])
	assert_equal(RegexpTree,RegexpTree)
	arg1=RegexpTree
	arg2=RegexpTree
	assert_equal(arg1, arg2)
	arg2=Array
end #[]index
def test_to_a
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

	assert_equal('*', RegexpTree.new([['.','*']]).postfix_operator_walk{|p| '*'})
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
end #postfix_operator_walk
def test_to_filename_glob
	assert_equal('*', RegexpTree.new(['.','*']).to_filename_glob)
	assert_equal('*', RegexpTree.new([['.','*']]).to_filename_glob)
	assert_equal('K*C', RegexpTree.new(['K',['.','*'],'C']).to_filename_glob)
end #to_filename_glob
def test_to_s


	assert_equal(Asymmetrical_Tree_Array,Asymmetrical_Tree.to_a)
	assert_equal('123',Asymmetrical_Tree.to_s)
#recurse	assert_equal('.*',RegexpTree.new('.*').to_s)
	assert_equal('K.*C',RegexpTree.new('K.*C').to_s)
end #to_s
def test_to_regexp
	assert_equal(/.*/,RegexpTree.new('.*').to_regexp)
end #to_regexp
def test_editor
	regexpParserTest(KCeditor)
	
	regexpParserTest(KCETeditor)
end #def
def setup
	define_model_of_test # allow generic tests
#	assert_module_included(@model_class,Generic_Table)
#	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
end #def
def test_zero_parameter_new
	assert_nothing_raised{RegexpTree.new} # 0 arguments
	assert_not_nil(@model_class)
end #test_name_correct
end #test class

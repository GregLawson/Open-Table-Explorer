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
#require 'regexp_parse.rb'
# Where does this def outside a class end up in RDOC?
def regexpParserTest(parser)
	assert_respond_to(parser,:parseOneTerm!)
#	Now test after full parse.
	parser.restartParse!
	assert(!parser.beyondString?)
	assert(parser.rest.length>0)
	assert(parser.rest==parser.regexp)
	parser.conservationOfCharacters	
#	Test after a little parsing.
	assert_not_nil(parser.nextToken!)
	assert(parser.rest!=parser.regexp)
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
class RegexpTreeTest < ActiveSupport::TestCase
require 'test/test_helper'
WhiteSpacePattern=' '
WhiteEditor=RegexpTree.new(WhiteSpacePattern,false)	
@@CONSTANT_PARSE_TREE=RegexpTree.new('K')
@@keditor=@@CONSTANT_PARSE_TREE.clone
@@CONSTANT_PARSE_TREE.freeze
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)

KCeditor=RegexpTree.new('KC',false)
RowsRegexp='(<tr.*</tr>)'
RowsEditor=RegexpTree.new(RowsRegexp,false)
RowsEdtor2=RegexpTree.new('\s*(<tr.*</tr>)',false)
KCETeditor=RegexpTree.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE',false)
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
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp)

	assert_equal(['K'], RegexpTree.new('K').parseTree)
	assert_equal([], RegexpTree.new('K', false).parseTree)

	parser=RegexpTree.new(RowsRegexp)
	assert_equal(parser.regexp,parser.to_s)
end #initialize
def test_index
	assert_instance_of(RegexpTree,@@CONSTANT_PARSE_TREE)
	assert_respond_to(@@CONSTANT_PARSE_TREE, :[])
	assert_not_nil(@@CONSTANT_PARSE_TREE[0])
	assert_instance_of(RegexpTree,@@CONSTANT_PARSE_TREE[0])
	assert_not_nil(RegexpTree.new(['K']))
	assert_instance_of(RegexpTree,RegexpTree.new(['K']))
	assert_instance_of(RegexpTree,RegexpTree.new(['K'])[0])
	assert_equal(RegexpTree,RegexpTree)
	arg1=RegexpTree
	arg2=RegexpTree
	assert_equal(arg1, arg2)
	arg2=Array
#	explain_assert_equal(arg1, arg2)
#	explain_assert_equal(RegexpTree.new,RegexpTree)
#	explain_assert_equal(RegexpTree.new(['K']),RegexpTree)
#	explain_assert_equal(nil,@@CONSTANT_PARSE_TREE[0])
	explain_assert_equal(RegexpTree.new(['K']),@@CONSTANT_PARSE_TREE[0])
end #[]index
def test_leaf_apply
	assert_equal(['*','*'], RegexpTree.new(['*','.']).leaf_apply{|p| '*'})
	assert_equal([['*','*']], RegexpTree.new([['*','.']]).leaf_apply{|p| '*'})
	postfix_tree=RegexpTree.new(['*','.'])
	assert(postfix_tree.postfix_expression?(['*',',']),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
	assert_equal([['*','.'],'C'], RegexpTree.new([['*','.'],'C']).leaf_apply{|p| p})
	assert_equal(['K',['*','.']], RegexpTree.new(['K',['*','.']]).leaf_apply{|p| p})
	assert_equal(['K',['*','.'],'C'], RegexpTree.new(['K',['*','.'],'C']).leaf_apply{|p| p})
	visit_proc=Proc.new{|parseTree| parseTree}
#	assert_equal('*', visit_proc.call)
	assert_equal(['*','.'], visit_proc.call(['*','.']))
	assert_equal(['*','.'], postfix_tree.leaf_apply(['*','.'], &visit_proc))
	visit_proc=Proc.new{|parseTree| postfix_tree.leaf_apply(parseTree[1..-1], &visit_proc)}
	assert_equal('.', visit_proc.call(['*','.']))
	assert_equal('*', ['*','.'][0])
	assert_equal('*', [['*','.']][0][0])
	visit_proc=Proc.new{|parseTree| postfix_tree.leaf_apply(parseTree[0], &visit_proc)}
	assert_equal('*', visit_proc.call(['*','.']))
	visit_proc=Proc.new{|parseTree| postfix_tree.leaf_apply(parseTree[0], &visit_proc)}
	assert_equal('*', visit_proc.call(['*','.']))
	visit_proc=Proc.new{|parseTree| postfix_tree.leaf_apply(parseTree[1..-1]<<parseTree[0], &visit_proc)}
	assert_equal('.*', visit_proc.call(['*','.']))
	postfix_tree.leaf_apply(['*','.'], &visit_proc)
end #leaf_apply
def test_branch_apply
	assert_equal(['*','.'], RegexpTree.new(['*','.']).branch_apply{|p| p})
	assert_equal(['C',['.','*']], RegexpTree.new([['*','.'],'C']).branch_apply{|p| p.reverse})
	assert_equal('*', ['*','1','2'][0])
	assert_equal('1', ['*','1','2'][1])
	assert_equal('1', RegexpTree.new(['*','1','2']).branch_apply{|p| p[1]})
	assert_equal('*', RegexpTree.new(['*','1','2']).branch_apply{|p| p[0]})
	assert_equal('2', RegexpTree.new(['*','1','2']).branch_apply{|p| p[2]})
	assert_equal('1*2', RegexpTree.new(['*','1','2']).branch_apply{|p| p[1]+p[0]+p[2]})
	assert_equal(['C',['.','*'],'K'], RegexpTree.new(['K',['*','.'],'C']).branch_apply{|p| p.reverse})
	visit_proc=Proc.new{|parseTree| parseTree.reverse}
	assert_equal(['.','*'], visit_proc.call(['*','.']))
	assert_equal([['.','*']], RegexpTree.new([['*','.']]).branch_apply{|p| p.reverse})
end #branch_apply
def test_postfix_expression
	postfix_tree=RegexpTree.new(['*','.'])
	assert_not_nil(postfix_tree)
	assert(postfix_tree.postfix_expression?,"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
	assert(postfix_tree.postfix_expression?(['*','.']),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
	assert(!postfix_tree.postfix_expression?(['K',['*','.'],'C']),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")

	assert(!postfix_tree.postfix_expression?(['K',['*','.']]))
	assert(!postfix_tree.postfix_expression?([['*','.'],'C']))
	assert(postfix_tree.postfix_expression?([['*','.']])) #ambiguous
end #postfix_expression
def test_postfix_operator
	postfix_tree=RegexpTree.new(['*','.'])
	assert_not_nil(postfix_tree)
	assert(postfix_tree.postfix_operator?('*'),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
	assert(!postfix_tree.postfix_operator?('.'),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
end #postfix_operator
def test_postfix_operator_walk
	assert_equal('*', RegexpTree.new(['*','.']).postfix_operator_walk{|p| '*'})
	assert_equal('*', RegexpTree.new([['*','.']]).postfix_operator_walk{|p| '*'})
	postfix_tree=RegexpTree.new(['*','.'])
	assert(postfix_tree.postfix_expression?(['*',',']),"postfix_tree.parseTree=#{postfix_tree.parseTree.inspect}")
	assert_equal('*C', RegexpTree.new([['*','.'],'C']).postfix_operator_walk{|p| '*'})
	assert_equal('K*', RegexpTree.new(['K',['*','.']]).postfix_operator_walk{|p| '*'})
	assert_equal('K*C', RegexpTree.new(['K',['*','.'],'C']).postfix_operator_walk{|p| '*'})
	visit_proc=Proc.new{|parseTree| '*'}
#	assert_equal('*', visit_proc.call)
	assert_equal('*', visit_proc.call(['*','.']))
	assert_equal('*', postfix_tree.postfix_operator_walk(['*','.'], &visit_proc))
	visit_proc=Proc.new{|parseTree| postfix_tree.postfix_operator_walk(parseTree[1..-1], &visit_proc)}
	assert_equal('.', visit_proc.call(['*','.']))
	assert_equal('*', ['*','.'][0])
	assert_equal('*', [['*','.']][0][0])
	visit_proc=Proc.new{|parseTree| postfix_tree.postfix_operator_walk(parseTree[0], &visit_proc)}
	assert_equal('*', visit_proc.call(['*','.']))
	visit_proc=Proc.new{|parseTree| postfix_tree.postfix_operator_walk(parseTree[0], &visit_proc)}
	assert_equal('*', visit_proc.call(['*','.']))
	visit_proc=Proc.new{|parseTree| postfix_tree.postfix_operator_walk(parseTree[1..-1]<<parseTree[0], &visit_proc)}
	assert_equal('.*', visit_proc.call(['*','.']))
	postfix_tree.postfix_operator_walk(['*','.'], &visit_proc)
end #postfix_operator_walk
def test_to_filename_glob
	assert_equal('*', RegexpTree.new(['*','.']).to_filename_glob)
	assert_equal('*', RegexpTree.new([['*','.']]).to_filename_glob)
	assert_equal('K*C', RegexpTree.new(['K',['*','.'],'C']).to_filename_glob)
end #to_filename_glob
def test_to_s


	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)
	assert_equal('K',@@CONSTANT_PARSE_TREE.to_s)
#recurse	assert_equal('.*',RegexpTree.new('.*').to_s)
	assert_equal('K.*C',RegexpTree.new('K.*C').to_s)
end #to_s
def test_to_regexp
	assert_equal(/.*/,RegexpTree.new('.*').to_regexp)
end #to_regexp
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
	assert_equal(['*','.'],KCETeditor.parseOneTerm!)
end #parseOneTerm!
def test_regexpTree
	
	@@keditor.restartParse!
	assert_equal(@@keditor.regexpTree!,['K'])
	KCeditor.restartParse!
	assert_equal(['K','C'],KCeditor.regexpTree!)
	assert_equal(["(", "<", "t", "r", ["*", "."], "<", "/", "t", "r", ">"],RowsEditor.regexpTree!('('))
end #regexpTree!
def test_conservationOfCharacters
	regexp='K.*C'
	test_tree=RegexpTree.new(regexp)
	assert_equal(regexp,test_tree.to_s)
	test_tree.conservationOfCharacters
end #conservationOfCharacters
def test_editor
	assert_instance_of(String,['*','a'][1])
	assert_equal(0,'*+?'.index(['*','a'][0]))
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

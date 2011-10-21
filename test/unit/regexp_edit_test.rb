###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
#require 'regexp_edit.rb'
require 'test_helper'

def regexpTest(editor)
	editor.restartParse
	testCall(editor,:regexpTree)
	editor.restartParse
	parseTree=editor.regexpTree
	assert_not_nil(parseTree)
	assert(parseTree.size>0)
	assert_respond_to(editor,:consecutiveMatches)
	assert_respond_to(editor,:consecutiveMatches)
	assert_not_nil(editor.consecutiveMatches(parseTree,+1,0,0))
	assert(editor.consecutiveMatches(parseTree,+1,0,0).size>0)
	assert_respond_to(editor,:matchedTreeArray)
	assert_not_nil(editor.matchedTreeArray(parseTree))
	assert_operator(editor.matchedTreeArray(parseTree).size,:>,0)
	assert_respond_to(editor,:matchedTreeArray)
	assert_not_nil(editor.matchSubTree(parseTree))
	assert_operator(editor.matchSubTree(parseTree).size,:>,0)
end #def
class Test_Generic < ActiveSupport::TestCase
#include Test_Helpers
WhiteSpacePattern=' '
WhiteSpace=' '
WhiteEditor=RegexpEdit.new(WhiteSpacePattern,WhiteSpace,false)	
Keditor=RegexpEdit.new('K','K')
KCeditor=RegexpEdit.new('KC','KC',false)
RowsRegexp='(<tr.*</tr>)'
RowsEditor=RegexpEdit.new(RowsRegexp,'',false)
RowsEdtor2=RegexpEdit.new('\s*(<tr.*</tr>)',' <tr height=14>
  <td height=14 class=xl33 width=39>&nbsp;</td>
  <td class=xl32 width=68>Date</td>
  <td class=xl33 width=106>Time</td>
  <td class=xl33 width=60>Series</td>
  <td class=xl33 width=54>Show #</td>
  <td class=xl33 width=200>Title</td>
 </tr>',false)
KCETeditor=RegexpEdit.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE','<tr height=16>
  <td height=16 class=xl29> </td>
  <td colspan=5 class=xl80>KCET  / Los Angeles  Mon-Fri (7:30 PM &amp; 12:30
  AM); Sat &amp; Sundays (7-8 PM)</td>
 </tr>
 <tr height=14>
  <td height=14 class=xl33 width=39>&nbsp;</td>
  <td class=xl32 width=68>Date</td>
  <td class=xl33 width=106>Time</td>
  <td class=xl33 width=60>Series</td>
  <td class=xl33 width=54>Show #</td>
  <td class=xl33 width=200>Title</td>
 </tr>
 <tr height=13>
  <td height=13 class=xl34 width=39>&nbsp;</td>
  <td class=xl35 width=68>7/1</td>
  <td class=xl36 width=106>7:30 PM</td>
  <td class=xl37 width=60>VIS</td>
  <td class=xl38 width=54>1702</td>
  <td class=xl38 width=200>Leonis Adobe</td>
 </tr>
 <tr height=13>
  <td height=13 class=xl34 width=39>&nbsp;</td>
  <td class=xl35 width=68>7/2</td>
  <td class=xl36 width=106>7;30 PM</td>
  <td class=xl37 width=60>CG</td>
  <td class=xl38 width=54>6007</td>
  <td class=xl38 width=200>Skunk Train</td>
 </tr>
 <tr height=13>
  <td height=13 class=xl24></td>
  <td colspan=5 class=xl84>KVIE / Sacramento   Tuesdays (7:00 PM); Thursday
  (8:00 - 10:00 PM)</td>
 </tr>',false)

def test_editor
	assert_match(WhiteSpacePattern,WhiteSpace)
	Keditor.restartParse
	assert_equal(WhiteSpacePattern,WhiteEditor.nextToken)
	explain_assert_respond_to(self,:testAnswer)

	testAnswer(KCETeditor,:matchSubTree,['a'],['a'])
	testAnswer(KCETeditor,:consecutiveMatch,0..1,['K','C'],+1,0,0)
	testAnswer(KCETeditor,:consecutiveMatches,[0..1],['K','C'],+1,0,0)
	assert_equal(['K','C'],KCETeditor.matchedTreeArray(['K','C']))
	assert_equal(['K','C'],KCETeditor.matchSubTree(['K','C']))

	assert_equal(0..0,KCETeditor.consecutiveMatch(['K','xyz'],+1,0,0))
	assert_equal([0..0],KCETeditor.consecutiveMatches(['K','xyz'],+1,0,0))
	assert_equal(['K'],KCETeditor.matchedTreeArray(['K','xyz']))
	assert_equal(['K'],KCETeditor.matchSubTree(['K','xyz']))

	assert_equal([0..0,2..2],KCETeditor.consecutiveMatches(['K','xyz','C'],+1,0,0))
	assert_nil(KCETeditor.consecutiveMatch(['K','xyz','C'],-1,1,1))
	assert_equal(2..2,KCETeditor.consecutiveMatch(['K','xyz','C'],-1,2,2))
	assert_equal(['K','C'],KCETeditor.matchedTreeArray(['K','xyz','C']))
	assert_equal(['K','C'],KCETeditor.matchSubTree(['K','xyz','C']))

	KCETeditor.restartParse
	parseTree=KCETeditor.regexpTree
	assert_not_nil(KCETeditor.matchRescued(KCETeditor.parsedString(KCETeditor.matchSubTree(parseTree))))
	expectedParse=["K",
	"C",
	"E",
	"T",
	["*", ["[", "^", "\n", "]"]],
	"<",
	"/",
	"t",
	"r",
	">",
	["*", "\\s"],
	["(", "<", "t", "r", ["*", "."], "<", "/", "t", "r", ">", ")"],
	["*", "."],
	"K",
	"V",
	"I",
	"E"]
# debug made not to pass for now.
	assert_not_equal(expectedParse,KCETeditor.matchSubTree(parseTree))
	regexpTest(KCETeditor)
end #def
end #test class
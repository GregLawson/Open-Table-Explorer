###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

def regexpTest(editor)
	assert_respond_to(editor,:consecutiveMatches)
	assert_not_nil(editor.consecutiveMatches(+1,0,0))
	assert(editor.consecutiveMatches(+1,0,0).size>0)
	assert_respond_to(editor,:matchedTreeArray)
	assert_not_nil(editor.matchedTreeArray)
	assert_operator(editor.matchedTreeArray.size,:>,0)
	assert_respond_to(editor,:matchedTreeArray)
	assert_not_nil(editor.matchSubTree)
	assert_operator(editor.matchSubTree.size,:>,0)
end #def
class RegexpMatchTest < ActiveSupport::TestCase
#require 'test/unit'
#include Test_Helpers
#require 'test/assertions/ruby_assertions.rb'
WhiteSpacePattern=' '
WhiteSpace=' '
White_Match=RegexpMatch.new(WhiteSpacePattern,WhiteSpace)	

Keditor=RegexpMatch.new('K','K')
RowsRegexp='(<tr.*</tr>)'
Rows_Match=RegexpMatch.new(RowsRegexp,'')
RowsEdtor2=RegexpMatch.new('\s*(<tr.*</tr>)',' <tr height=14>
  <td height=14 class=xl33 width=39>&nbsp;</td>
  <td class=xl32 width=68>Date</td>
  <td class=xl33 width=106>Time</td>
  <td class=xl33 width=60>Series</td>
  <td class=xl33 width=54>Show #</td>
  <td class=xl33 width=200>Title</td>
 </tr>')
KCETeditor=RegexpMatch.new('KCET[^
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
 </tr>')
def test_initialize
	assert_match(WhiteSpacePattern,WhiteSpace)
#	Keditor.restartParse!
#	assert_equal(WhiteSpacePattern,White_Match.nextToken!)
	
end #initialize
Macaddr_Column=GenericType.find_by_name('Macaddr_Column')
# test match and explain mismatch
def test_assert_match
	regexp='KC'
	string='KxyxC'
	match_data=regexp.match(string)
	assert_nil(match_data)
#	RegexpMatch.explain_assert_match(regexp, string)
	regexp_tree=RegexpMatch.new(regexp, string)
	new_tree=regexp_tree.matchSubTree
	assert_equal(["K",['.','*'],"C"],new_tree)
	assert_equal('K.*C',RegexpTree.new('K.*C').to_s)
	assert_equal('K.*C',RegexpTree.new(["K",['.','*'],"C"]).to_s)
#Array does not reverse postfix operators	assert_equal("K.*C",new_tree.to_s)
	assert_equal("K.*C",Regexp.new("K.*C").source)
	assert_match(/K.*C/, string)
	assert_instance_of(Regexp, RegexpTree.new("K.*C").to_regexp)
	assert_match(RegexpTree.new("K.*C").to_regexp, string)
	new_regexp=RegexpTree.new(new_tree.to_s).to_regexp
	assert_match(new_regexp, string)
#?	assert_equal("K\.\*C",Regexp.escape("K.*C"))
#?	assert_equal("K.*C",Regexp.new("K.*C").to_s)
	mac_example='12:34:56:78'
	assert_match(/[[:xdigit:]]{2}:/, mac_example)
	assert_match(/[[:xdigit:]]{2}(:[[:xdigit:]]{2}){3}/, mac_example)
	data_regexp=Macaddr_Column[:data_regexp]
	assert_match(Regexp.new(data_regexp), mac_example)
	assert_match(data_regexp, mac_example)
	mac_match=RegexpMatch.new(data_regexp, mac_example)
	assert_equal([], mac_match.matchSubTree)
	assert_equal([Macaddr_Column], start.most_specialized?(mac_example))
	
end #assert_match
def test_matchSubTree
	string_to_parse='KxC'
	candidateParseTree=RegexpMatch.new('KC',string_to_parse)
	assert_equal(['K',['.', '*'],'C'],candidateParseTree.matchSubTree)
	assert_equal(['K'],RegexpMatch.new('K',string_to_parse).matchSubTree)
	assert_not_nil(KCETeditor.matchRescued(RegexpTree.new(KCETeditor.matchSubTree)))
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
	assert_not_equal(expectedParse,KCETeditor.matchSubTree)

end #matchSubTree
def test_mergeMatches
	string_to_parse='KxC'
	candidateParseTree=RegexpMatch.new('KC',string_to_parse)
	matches=[0..0,1..1]
	assert_operator(matches.size,:>=,2)
	assert_operator(matches[0].end,:<,matches[1].begin)
	assert_operator(matches.size, :<=, 2)

	assert_instance_of(Array, [matches[0]])
	matchesForRecursion=matches[1..-1]
	assert_not_empty(matchesForRecursion)
	assert_equal(1..1, matchesForRecursion[0])
	assert_not_empty(candidateParseTree[matchesForRecursion[0]])
	workingParseTree=candidateParseTree.mergeMatches(matchesForRecursion)
	assert_not_nil(workingParseTree)
	assert_instance_of(RegexpTree, workingParseTree)
	assert_instance_of(Array, [matches[0]]+workingParseTree)


	mergedParseTree=candidateParseTree.mergeMatches(matches)
	assert_not_nil(mergedParseTree)
	assert_equal(['K', ['.','*'], 'C'],mergedParseTree)
	assert_match(RegexpTree.new(mergedParseTree).to_regexp,string_to_parse)
end #mergeMatches
def test_matchedTreeArray
	matchFail=RegexpMatch.new('KxC', 'KC')
	assert_equal(['K', [".", "*"],'C'],matchFail.matchedTreeArray)
end #matchedTreeArray
def test_consecutiveMatches
	matchFail=RegexpMatch.new('KxC', 'KC')
	assert_equal([0..0,2..2],matchFail.consecutiveMatches(+1,0,0))
end #consecutiveMatches
def test_consecutiveMatch
#fail	assert_respond_to(self,:testAnswer)
#	explain_assert_respond_to(self,:testAnswer)
#	testAnswer(KCETeditor,:consecutiveMatch,0..1,+1,0,0)
	matchFail=RegexpMatch.new('KxC', 'KC')
	assert_equal(['K','x','C'],matchFail.to_a)

	assert_equal(0..0,matchFail.consecutiveMatch(+1,0,0))

	assert_nil(matchFail.consecutiveMatch(-1,1,1))
	startPos=2
	endPos=2
	matchData=matchFail.matchRescued(matchFail[startPos..endPos])
	assert_equal(['C'], matchFail[startPos..endPos])
	assert(matchData)
	assert_equal(2..2,matchFail.consecutiveMatch(-1,2,2))
end #consecutiveMatch
def test_editor


#	KCETeditor.restartParse!
#	parseTree=KCETeditor.regexpTree!
	regexpTest(KCETeditor)
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

###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# Ensure assertions are included in classes.
class GenericType < ActiveRecord::Base
include GenericTypeAssertions
extend GenericTypeAssertions::ClassMethods
end #class GenericType < ActiveRecord::Base

class RegexpMatch < RegexpTree # reopen class to add assertions
include RegexpMatchAssertions
extend RegexpMatchAssertions::ClassMethods
end #RegexpMatch

class RegexpGeneralizationTest < TestCase #file context
set_class_variables(RegexpMatchTest,false)
#require 'test/unit'
#include Test_Helpers
#require 'test/assertions/ruby_assertions.rb'


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
#	assert_match(data_regexp, mac_example)
	mac_match=RegexpMatch.new(data_regexp, mac_example)
	
end #assert_match
def test_matchSubTree
	string_to_parse='KxC'
	candidateParseTree=RegexpMatch.new('KC',string_to_parse)
	assert_equal(['K',['.', '*'],'C'],candidateParseTree.matchSubTree)
	assert_equal(['K'],RegexpMatch.new('K',string_to_parse).matchSubTree)
	explain_assert_respond_to(RegexpMatch,:explain_assert_match)
	RegexpMatch.methods.grep(/explain_assert_match/)
	RegexpMatch.explain_assert_match(KCETeditor.matchSubTree, KCETeditor.dataToParse)
	assert_not_nil(RegexpMatch.match_data?(RegexpTree.new(KCETeditor.matchSubTree), KCETeditor.dataToParse))
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
	
	assert_not_nil(Alternative.matchSubTree)
	assert_not_empty(Alternative.matchSubTree)
	RegexpMatch.assert_mergeable('a', 'b')
	RegexpMatch.assert_mergeable(%{<Url:0xb5f22960>}, %{<Url:0xb5ce4e3c>})
	string=%{\#<NoMethodError:\ undefined\ method\ `uri'\ for\ \#<Url:0xb5f22960>}
	regexp=string.to_exact_regexp
	string2=%{\#<NoMethodError:\ undefined\ method\ `uri'\ for\ \#<Url:0xb5ce4e3c>}
	RegexpMatch.explain_assert_match(regexp, string2)
	RegexpMatch.assert_mergeable(string, string2)
end #matchSubTree
def test_mergeMatches
	candidateParseTree=RegexpMatch.new('a','b')
	matches=[]
	new_regexp=candidateParseTree.mergeMatches(matches)
	assert_match(new_regexp.to_regexp, candidateParseTree.dataToParse)
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
	assert_instance_of(RegexpMatch, workingParseTree)
	assert_instance_of(Array, [matches[0]]+workingParseTree)


	mergedParseTree=candidateParseTree.mergeMatches(matches)
	assert_not_nil(mergedParseTree)
	assert_equal(['K', ['.','*'], 'C'],mergedParseTree)
	assert_match(RegexpTree.new(mergedParseTree).to_regexp,string_to_parse)
end #mergeMatches
def test_matchedTreeArray
	assert_not_empty(Alternative.matchedTreeArray)
	assert_equal(['K', [".", "*"],'C'],Insertion.matchedTreeArray)
	assert_equal(['K', 'C'],Deletion.matchedTreeArray)
end #matchedTreeArray
def test_generalize_characters
	Lower.assert_most_specialized([:digit], '9')

	assert_equal([], Lower.generalize_characters('9'))
end #generalize_characters
def test_generalize_sequence
end #generalize_sequence
def test_generalize_repetition
end #generalize_repetition
def test_generalize
	minimax=RegexpMatch.new('[[:print:]]{16,16}', Addresses.dataToParse)
	branch=Addresses
	data_to_match=Addresses.dataToParse
	most_specialized=Digit
	c='c'
	Lower.assert_most_specialized([:lower], 'l')
	Lower.assert_most_specialized([:digit], '9')
	Digit.assert_most_specialized([:xdigit], 'c')
		message="most_specialized=#{most_specialized.inspect}"
		message+=", most_specialized.most_specialized?(c)=#{most_specialized.most_specialized?(c)}"
		message+=", c=#{c}"
 		assert_not_nil(most_specialized, message)
		assert_not_nil(most_specialized.most_specialized?(c), message)
		assert_instance_of(Array, most_specialized.most_specialized?(c), message)
		assert_not_empty(most_specialized.most_specialized?(c), message)
		assert_not_nil(most_specialized.most_specialized?(c)[-1], message)
	most_specialized=most_specialized.most_specialized?(c)[-1]
		assert_not_nil(most_specialized.most_specialized?(c)[-1], message)
		assert_not_nil(most_specialized, message)
		message="most_specialized=#{most_specialized.inspect}"
		message+=", most_specialized.most_specialized?(c)=#{most_specialized.most_specialized?(c)}"
		message+=", c=#{c}"
		assert_not_nil(most_specialized, message)
	
	most_specialized=[GenericType.find_by_name('ascii')]
		assert_instance_of(Array, most_specialized)
	data_to_match.each_char do |c|
		ret=most_specialized.each do |m|
			message="m=#{m.inspect}"
			assert_instance_of(GenericType, m)
			assert_kind_of(Array, m.most_specialized?(c))
			message+=", m.most_specialized?(c)=#{m.most_specialized?(c)}"
			message+=", c=#{c}"
			assert_not_nil(m, message)
			most_specialized=m.most_specialized?(c)
			assert_kind_of(Array, most_specialized)
			assert_not_nil(most_specialized, message)
		end #each
	end #each_char
	assert_equal(minimax.to_s, Addresses.generalize.to_s)
	assert_equal(/<Url:0xb[[:xdigit:]]{7,7}>/, Addresses.generalize.to_regexp)
end #generalize
def test_map_prefix
	assert_equal(['*','.'], NestedArray.new(['*','.']).map_prefix{|p| p})
	assert_equal(['C',['.','*']], NestedArray.new([['*','.'],'C']).map_prefix{|p| p.reverse})
	assert_equal('*', ['*','1','2'][0])
	assert_equal('1', ['*','1','2'][1])
	assert_equal('1', NestedArray.new(['*','1','2']).map_prefix{|p| p[1]})
	assert_equal('*', NestedArray.new(['*','1','2']).map_prefix{|p| p[0]})
	assert_equal('2', NestedArray.new(['*','1','2']).map_prefix{|p| p[2]})
	assert_equal('1*2', NestedArray.new(['*','1','2']).map_prefix{|p| p[1]+p[0]+p[2]})
	assert_equal(['C',['.','*'],'K'], NestedArray.new(['K',['*','.'],'C']).map_prefix{|p| p.reverse})
	assert_equal(['C',['.','*'],'K'], NestedArray.new(['K',['*','.'],'C']).map_prefix(&Reverse_proc))
	assert_equal(['.','*'], Reverse_proc.call(['*','.']))
	assert_equal([['.','*']], NestedArray.new([['*','.']]).map_prefix{|p| p.reverse})
	assert_equal(Asymmetrical_Tree.reverse, Reverse_proc.call(Asymmetrical_Tree))
	assert_equal(Asymmetrical_Tree.flatten.reverse, Asymmetrical_Tree.map_prefix(&Reverse_proc).flatten)
	assert_equal(Nested_Test_Array, NestedArray.new(Nested_Test_Array).map_prefix(&Echo_proc))
end #map_prefix
end #test class

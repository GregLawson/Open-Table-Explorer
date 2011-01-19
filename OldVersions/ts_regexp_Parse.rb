###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require 'inlineAssertions.rb'
require 'regexp_Parse.rb'
def regexpParserTest(parser)
	assert_respond_to(parser,:parseOneTerm)
#	Now test after full parse.
	parser.restartParse
	assert(!parser.beyondString?)
	assert(parser.rest.length>0)
	assert(parser.rest==parser.regexp)
	parser.conservationOfCharacters([])	
#	Test after a little parsing.
	assert_not_nil(parser.nextToken)
	assert(parser.rest!=parser.regexp)
	parser.restartParse
	assert_not_nil(parser.parseOneTerm)
	parser.restartParse
	assert(parser.parseOneTerm.size>0)
#	Now test after full parse.
	parser.restartParse
	assert_not_nil(parser.regexpTree)
	assert(parser.rest=='')
	parser.restartParse
	parser.conservationOfCharacters(parser.regexpTree)	
	parser.restartParse
	assert(parser.regexpTree.size>0)
	assert(parser.beyondString?)
end #def
class Test_Generic <Test::Unit::TestCase
require 'test_helpers.rb'
WhiteSpacePattern=' '
WhiteEditor=Regexp_Parse.new(WhiteSpacePattern,false)	
Keditor=Regexp_Parse.new('K')
KCeditor=Regexp_Parse.new('KC',false)
RowsRegexp='(<tr.*</tr>)'
RowsEditor=Regexp_Parse.new(RowsRegexp,false)
RowsEdtor2=Regexp_Parse.new('\s*(<tr.*</tr>)',false)
KCETeditor=Regexp_Parse.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE',false)

def test_editor
	Keditor.restartParse
	assert_equal('a',Keditor.parsedString(['a']))
	assert_equal('ab',Keditor.parsedString(['a','b']))
	assert_equal('ab',Keditor.parsedString(['a',['b']]))
	assert_instance_of(String,['*','a'][1])
	assert_equal(0,'*+?'.index(['*','a'][0]))

	assert_equal('a*',Keditor.parsedString(['*','a']))
	Keditor.restartParse
	assert_equal(Keditor.rest,'K')
	assert_equal(Keditor.nextToken,'K')
	Keditor.restartParse
	assert_equal(Keditor.parseOneTerm,'K')
	Keditor.restartParse
	assert_equal(Keditor.regexpTree,['K'])
	regexpParserTest(Keditor)
	KCeditor.restartParse
	assert_equal(KCeditor.rest,'KC')
	assert_equal('C',KCeditor.nextToken)
	KCeditor.restartParse
	assert_equal('C',KCeditor.parseOneTerm)
	KCeditor.restartParse
	assert_equal(['K','C'],KCeditor.regexpTree)
	RowsEditor.restartParse
	assert_equal(RowsEditor.nextToken,')')
	assert_equal(0,Regexp_Parse.ClosingBrackets.index(')'))
	assert_equal('(',Regexp_Parse.OpeningBrackets[Regexp_Parse.ClosingBrackets.index(')')].chr)
	assert_equal(["(", "<", "t", "r", ["*", "."], "<", "/", "t", "r", ">"],RowsEditor.regexpTree('('))
	RowsEditor.restartParse
	assert_equal(RowsRegexp,RowsEditor.parsedString(RowsEditor.parseOneTerm))
	regexpParserTest(KCeditor)
	KCETeditor.restartParse
	assert_equal('E',KCETeditor.parseOneTerm)
	assert_equal('I',KCETeditor.parseOneTerm)
	assert_equal('V',KCETeditor.parseOneTerm)
	assert_equal('K',KCETeditor.parseOneTerm)
	assert_equal(['*','.'],KCETeditor.parseOneTerm)
	assert_equal('(<tr.*</tr>)',KCETeditor.parsedString(KCETeditor.parseOneTerm))
	regexpParserTest(KCETeditor)
end #def
end #test class
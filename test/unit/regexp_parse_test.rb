###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
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
	parser.conservationOfCharacters([])	
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
	parser.conservationOfCharacters(parser.regexpTree!)	
	parser.restartParse!
	assert(parser.regexpTree!.size>0)
	assert(parser.beyondString?)
end #def
class RegexpParseTest < ActiveSupport::TestCase
require 'test_helper'
WhiteSpacePattern=' '
WhiteEditor=RegexpParse.new(WhiteSpacePattern,false)	
@@CONSTANT_PARSE_TREE=RegexpParse.new('K')
@@keditor=@@CONSTANT_PARSE_TREE.clone
@@CONSTANT_PARSE_TREE.freeze
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)

KCeditor=RegexpParse.new('KC',false)
RowsRegexp='(<tr.*</tr>)'
RowsEditor=RegexpParse.new(RowsRegexp,false)
RowsEdtor2=RegexpParse.new('\s*(<tr.*</tr>)',false)
KCETeditor=RegexpParse.new('KCET[^
]*</tr>\s*(<tr.*</tr>).*KVIE',false)
def test_OpeningBrackets
	assert_equal('(',RegexpParse.OpeningBrackets[RegexpParse.ClosingBrackets.index(')')].chr)
end #OpeningBrackets
def test_ClosingBrackets
	assert_equal(0,RegexpParse.ClosingBrackets.index(')'))
end #ClosingBrackets
def test_initialize
	assert_not_nil(@@CONSTANT_PARSE_TREE.regexp)
	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)
	assert_equal('K', @@CONSTANT_PARSE_TREE.regexp)

	assert_equal(['K'], RegexpParse.new('K').parseTree)
	assert_equal([], RegexpParse.new('K', false).parseTree)

	parser=RegexpParse.new(RowsRegexp)
	assert_equal(parser.regexp,parser.to_s)
end #initialize
def test_class_to_s
	assert_equal('a',RegexpParse.to_s(['a']))
	assert_equal('a*',RegexpParse.to_s(['*','a']))
end #to_s
def test_to_s


	assert_equal(['K'],@@CONSTANT_PARSE_TREE.parseTree)
	assert_equal('K',@@CONSTANT_PARSE_TREE.to_s)
end #to_s
def test_to_regexp
	assert_equal(/.*/,RegexpParse.new('.*').to_regexp)
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
	assert_nothing_raised{RegexpParse.new} # 0 arguments
	assert_not_nil(@model_class)
end #test_name_correct
end #test class

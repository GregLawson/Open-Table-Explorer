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
class RegexpParerTest < ActiveSupport::TestCase
set_class_variables
#require 'app/models/regexp_tree.rb'
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
def test_initialize
	regexp_string='K.*C'
	test_tree=RegexpParser.new(regexp_string)
	assert_equal(regexp_string,test_tree.to_s)
	assert_not_nil(test_tree.regexp_string)
	assert_not_nil(RegexpParser.new(test_tree.rest).to_s)
#	assert_not_nil(RegexpParser.new(nil))
	assert_instance_of(NestedArray, RegexpParser.new('.*').parseTree)
	assert_equal(2, RegexpParser.new('.*').parseTree.size)
	assert_equal(['.','*'], RegexpParser.new('.*').parseTree)
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
end #RegexpParerTest

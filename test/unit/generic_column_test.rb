###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/generic_column.rb'
class GenericColumnTest < TestCase
include GenericColumn::Examples
#include DefaultTests
def test_GenericVariable_name
	assert_equal(:Col, Col.name)
	assert_equal(:name, Name.name)
	assert_equal(:Var, Var.name)
end # name
def test_equal
	assert_equal(Name, GenericVariable.promote(:name))
end # ==
def test_GenericVariable_header
	assert_equal('Col', Col.header)
	assert_equal('Name', Name.header)
	assert_equal('Var', Var.header)
end # header
def test_promote 
	assert_equal(Name_0, GenericColumn.promote(Name_0))
	assert_equal(Name_0, GenericColumn.promote(Name))
	assert_equal(Name_0.variable.ruby_type, GenericColumn.promote(:name).variable.ruby_type)

#suprise	assert_equal(Name_0.variable.ruby_type, GenericColumn.promote(:name).variable.ruby_type)
	assert_equal(Name_0, GenericColumn.promote(:name))
end # promote
def test_equal
	assert_equal(Name_0, GenericColumn.promote(:name))
end # ==
def test_GenericColumn_name
	assert_equal(:name, Name_0.name)
	assert_equal(:name_3, Name3.name)
	assert_equal(:Var_1, Var_1.name)
	assert_equal(:Col_1, Col_1.name)
end # name
def test_GenericColumn_header
	assert_equal('Col 1', Col_1.header)
	assert_equal('Name', Name.header)
	assert_equal('Name 3', Name3.header)
	assert_equal('Var 1', Var_1.header)
end # header
def test_to_hash
	assert_equal({Col_1 => '123'}, Col_1.to_hash('123'))
	memory_address_regexp = /[[:xdigit:]]{14}/
#	assert_equal('\', Regexp.new(Regexp.to_regexp_escaped_string('\')).source)
#	assert_equal('\"', Regexp.new(Regexp.to_regexp_escaped_string('\"')).source)
#	assert_equal('\"', /\\"/.source)
	string_quote_inspected_regexp = Regexp.new(Regexp.to_regexp_escaped_string('\"'))
	name_string_regexp = /:[A-Z][a-z0-9]+/
	assert_match(name_string_regexp, Col_1.to_hash('123').inspect)
	ruby_type_regexp = /ruby_type=/ * name_string_regexp
	assert_match(ruby_type_regexp, Col_1.to_hash('123').inspect)
	name_inspect_regexp = /name=:Col /
	assert_match(name_inspect_regexp, Col_1.to_hash('123').inspect)
	genericVariable_regexp = /#<GenericVariable / * name_inspect_regexp * ruby_type_regexp
	assert_match(genericVariable_regexp, Col_1.to_hash('123').inspect)
	genericColumn_regexp = /{#<GenericColumn variable=/ * genericVariable_regexp */ all_numbered=nil> regexp_index=1>=>\"123\"}/
	assert_match(genericVariable_regexp, Col_1.to_hash('123').inspect)
	assert_match(/{#<GenericColumn variable=/, Col_1.to_hash('123').inspect)
	assert_match(/{#<GenericColumn variable=/ * genericVariable_regexp, Col_1.to_hash('123').inspect)
	assert_match(                                                       						  /regexp_index=1/,   			 Col_1.to_hash('123').inspect)
	assert_match(                                                       						  /regexp_index=1>=>/,         Col_1.to_hash('123').inspect)
	assert_match(                                                       /regexp_index=1>=>\"123\"}/           , Col_1.to_hash('123').inspect)
	assert_match(                                                       / all_numbered=nil> regexp_index=1>=>/        , Col_1.to_hash('123').inspect)
	assert_match(                                                       / all_numbered=nil> regexp_index=1>=>/, Col_1.to_hash('123').inspect)
	assert_match(                               genericVariable_regexp */ all_numbered=nil> regexp_index=1>=>\"123\"}/, Col_1.to_hash('123').inspect)
	assert_match(/{#<GenericColumn variable=/ * genericVariable_regexp */ all_numbered=nil> regexp_index=1>=>\"123\"}/, Col_1.to_hash('123').inspect)
	assert_match(genericColumn_regexp, Col_1.to_hash('123').inspect)
end # to_hash
end # GenericColumn

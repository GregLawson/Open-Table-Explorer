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
def test_name
	assert_equal(:Col_1, Col_1.name)
	assert_equal(:name, Name.name)
	assert_equal(:name_3, Name3.name)
	assert_equal(:Var_1, Var_1.name)
end # name
def test_header
	assert_equal('Col 1', Col_1.header)
	assert_equal('Name', Name.header)
	assert_equal('Name 3', Name3.header)
	assert_equal('Var 1', Var_1.header)
end # header
def test_to_hash
	assert_equal({Col_1 => '123'}, Col_1.to_hash('123'))
	assert_match(/{#<GenericColumn regexp_name=:Col regexp_index=1 ruby_type=#<Class:0x/ * /[[:xdigit:]]{14}/ * /> all_numbered=nil>=>\"123\"}/, Col_1.to_hash('123').inspect)
end # to_hash
end # GenericColumn

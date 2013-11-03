###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/test_method.rb'
class TestMethodTest < TestCase
include DefaultTests
include TE.model_class?::Examples
include Parse
def test_initialize
	test_executable=$0
	grep=ShellCommands.new('grep "def test_" '+test_executable)
	parse(grep.output, Parse_grep)
	assert_match(Parse_grep, grep.output)
	assert_equal([:initialize], TestMethod.new(test_executable).method_test_names)
end #initialize
end #TestMethod

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
	grep=ShellCommands.new('grep "def test_" test/unit/work_flow_test.rb')
	parse(grep.output, /def test_/.capture(:method_name))
	assert_match(/def test_/*/[a-zA-Z0-9_]*/.capture(:method_name), grep.output)
	assert_equal([:initialize], TestMethod.new($0).method_test_names)
end #initialize
end #TestMethod

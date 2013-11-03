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
	assert_equal([:initialize], TestMethod.new($0))
end #initialize
end #TestMethod

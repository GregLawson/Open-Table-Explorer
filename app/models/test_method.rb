###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/no_db.rb'
class TestMethod
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
include Parse
attr_reader :test_executable, :method_test_names
def initialize(test_executable)
	grep=ShellCommands.new(' grep "def test_" '+test_executable)
	@test_executable=test_executable
	@method_test_names=parse(grep.output, /def test_/.capture(:method_name))
end #initialize
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end #TestMethod

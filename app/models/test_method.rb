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
Parse_grep=/def test_/*/[a-zA-Z0-9_?]*/.capture
Parse_library_grep=/def /*/[a-zA-Z0-9_?]*/.capture
end #Constants
include Constants
include Parse
attr_reader :test_executable, :method_test_names, :method_names
def initialize(test_executable)
	grep_test=ShellCommands.new('grep "def test_" '+test_executable)
	grep_lines=parse(grep_test.output, LINES)
	@test_executable=test_executable
	@method_test_names=parse(grep_lines, Parse_grep)
	library_file=Unit.new_from_path?(test_executable).pathname_pattern?(:model)
	grep_library=ShellCommands.new('grep "def " '+library_file)
	grep_library_lines=parse(grep_library.output, LINES)
	@method_names=parse(grep_library_lines, Parse_library_grep)
end #initialize
def untested_methods
	@method_names-@method_test_names
end #untested_methods
def tested_nonmethods
	@method_test_names-@method_names
end #untested_methods
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
	assert(@method_test_names-@method_names!=@method_test_names)
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
SELF_tested_methods=TestMethod.new($0)
include Constants
end #Examples
end #TestMethod

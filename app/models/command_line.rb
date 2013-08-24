###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'optparse'
require 'ostruct'
require 'pp'
require 'test/unit'
class CommandLine
module ClassMethods
def create_from_path(path)
	ShellCommands("file "+path).execute.assert_post_conditions.puts
	basename=File.basename(path)
	ShellCommands("man "+basename).execute.assert_post_conditions.puts
end #create_from_path
end #ClassMethods
extend ClassMethods
def initialize(name, description=name, help_source='man')
	@name=name
	@description=description
	@help_source=help_source
end #initialize
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #CommandLine
class CommandLineScript < CommandLine
def add_option(name, description=name, help_source='man')
	option=CommandLineOption.new(name, description, help_source)
	@options = (@options.nil? ? [] : @options)+[option]
end #add_option
end #CommandLine
class CommandLineOption
def initialize(name, description=name, short_option=name[0], long_option=name)
	@name=name
	@description=description
	@short_option=short_option
	@long_option=long_option
end #initialize
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
end #Examples
include Examples
end #CommandLineOption

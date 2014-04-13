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
require 'mime/types' # new ruby detailed library
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/command.rb'
class CommandLineScript < Command
def add_option(name, description=name, long_option=name, short_option=name[0])
	option=CommandLineOption.new(name, description, long_option, short_option)
	@options = (@options.nil? ? [] : @options)+[option]
end #add_option
def parse_options
	@commands = []
	OptionParser.new do |opts|
		opts.banner = "Usage: #@basename} --<command> files"
		@options.each do |option|
			opts.on(option.short_option, "--[no-]#{option.long_option}", option.description) do |o|
				@commands+=[option.name] if o
		  end #on
	  end #each
	end.parse!
end #parse_options
def run
	case ARGV.size
	when 0 then # scite testing defaults command and file
		puts "work_flow --<command> <file>"
		this_file=File.expand_path(__FILE__)
		argv=[this_file] # incestuous default test case for scite
	else
		argv=ARGV
	end #case
	if @coomands.size=0 then
		@commands=[:test]
	end #if
	argv.each do |f|
		command_line=CommandLine.new(f)
		@commands.each do |c|
			command_line.method(c)
		end #each
	end #each
end #run
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
SELF=CommandLineScript.new($0)
end #Examples
include Examples
end #CommandLineScript
class CommandLineOption
def initialize(name, description=name, long_option=name, short_option=name[0])
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

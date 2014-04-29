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
def parse_options(banner= @banner)
	@commands = []
	OptionParser.new do |opts|
		opts.banner = banner
		@options.each do |option|
			opts.on(option.short_option, "--[no-]#{option.long_option}", option.description) do |o|
				@commands+=[option.name] if o
		  end #on
	  end #each
	end.parse!
end #parse_options
def run(&non_default_actions)
	case ARGV.size # paths after switch removal?
	when 0 then # scite testing defaults command and file
		puts script.banner
		this_file=File.expand_path(__FILE__)
		argv=[this_file] # incestuous default test case for scite
		@commands=[:test]
	else
		argv=ARGV
	end #case
	commands.each do |c|
		ret = non_default_actions.call
		if ret.nil? then
		else argv.each do |f|
			unit=CommandLine.new(f)
			if unit.respond_to?(c.to_sym) then
				unit.send(c.to_sym, *argv)
			else
				puts "#{c.to_sym} is not a method in #{unit_files.inspect}"
			end # if
		end # if
		scripting_workflow.script_deserves_commit!(:passed)
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
attr_reader :name, :description, :short_option, :long_option
def initialize(name, description=name.to_s, long_option=name.to_s, short_option=name[0])
	@name=name.to_s
	@description=description
	@short_option=short_option
	@short_option=long_option
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

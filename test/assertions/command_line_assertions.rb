###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/command_line.rb'
class CommandLine < Command
module Assertions

module ClassMethods
def assert_pre_conditions
#	CommandLine.assert_ARGV	# don't know why ARGV getsn screwed up in tests
end #assert_pre_conditions

def assert_post_conditions
end #assert_post_conditions
def assert_command_run(args)
	test_run = ShellCommands.new('ruby -W0 script/command_line.rb ' + args)
	test_run.assert_pre_conditions
	last_line = test_run.output.split("\n")[-1]
#	assert_not_equal('', test_run.output, test_run.inspect)
#	assert_not_match(/0 tests, 0 assertions, 0 failures, 0 errors, 0 skips/, last_line)
	test_run
end # assert_command_run
def assert_ARGV
	message = "in assert_ARGV\nARGV = " + ARGV.inspect
	message += "\nCommandLine::Sub_command = '" + CommandLine::Sub_command.inspect
	message += "\nCommandLine::Arguments = '" + CommandLine::Arguments.inspect
	message += "\nCommandLine::Number_of_arguments = '" + CommandLine::Number_of_arguments.to_s
	case CommandLine::Number_of_arguments
	when 0 then 
		assert_equal(:help, CommandLine::Sub_command, message)
	when 1 then
		message += "\nCommandLine::Argument_types = '" + CommandLine::Argument_types.inspect
		assert_includes(CommandLine::Argument_types, Argument_types[0])
	else
	end # case
	if ARGV.size >= 1 then
		assert_equal(ARGV[0].to_sym, CommandLine::Sub_command, message)
		assert_includes(CommandLine::SUB_COMMANDS, CommandLine::Sub_command.to_s, message)
		assert_operator(ARGV.size, :>=, 1, message)
		assert_operator(ARGV.size, :<=, 2, message)
	end # if
end # ARGV
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#TestWorkFlow.assert_pre_conditions
module Constants
end #Constants
include Constants
module Examples
include Constants
SELF=CommandLine.new($0)
Readme_opts = Trollop::options do
    opt :monkey, "Use monkey mode"                    # flag --monkey, default false
    opt :name, "Monkey name", :type => :string        # string --name <s>, default nil
    opt :num_limbs, "Number of limbs", :default => 4  # integer --num-limbs <i>, default to 4
  end
end #Examples
include Examples
end # CommandLine

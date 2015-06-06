###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'trollop'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/command.rb'
require_relative '../../app/models/test_executable.rb'
class CommandLine < Command
module Constants
SUB_COMMANDS = %w(inspect test)
Command_line_opts = Trollop::options do
	banner 'Usage: ' + Command.to_s + ' subcommand  path_patterns' 
   opt :inspect, "Inspect file object"                    # flag --monkey, default false
   opt :test, "Test unit."       # string --name <s>, default nil
  stop_on SUB_COMMANDS
  end
if ARGV.size > 0 then
	Sub_command = ARGV[0].to_sym # get the subcommand
else
	Sub_command = :help # default subcommand
end # if
Command = Unit::Executing_Unit.model_basename
Command_line_test_opts = Trollop::options do
	banner 'Usage: ' + Command.to_s + ' subcommand  path_patterns' 
    opt :inspect, "Inspect file object"                    # flag --monkey, default false
    opt :test, "Test unit."       # 
    opt :help, "Commands" # 
    opt :individual_test, "Run only one individual test",  :short => "-n" # 
  end
end # Constants
include Constants
attr_accessor :executable, :options
def initialize(executable, options = Command_line_opts)
	@executable = executable
	@options = options
end # initialize
def run(&non_default_actions)
	puts "enterring run ARGV = " + ARGV.inspect
	if ARGV.size < 2 then
		fail RuntimeError.new("Expect a subcommand and a file argument.")
	else
		ARGV[1..-1].each do |file_argument|
			executable_object = Unit::Executing_Unit.model_class?.new(TestExecutable.new_from_pathname(file_argument))
			if executable_object.respond_to?(Sub_command) then
				puts 'Sub_command = ' + Sub_command.to_s + 'arity = ' + method.arity
				method = executable_object.method(Sub_command)
				case method.arity
				when -1 then
					executable_object.inspect
				when 0 then
					puts 'Calling method.call(file_argument) ' + "\nmethod = " + method.inspect
					method.call
				when 1 then
					puts 'Calling method.call(file_argument) ' + "\nmethod = " + method.inspect + "\n file_argument =" + file_argument
					method.call(file_argument)
				else
					message = 'In CommandLine#run, '
					message += "\nfile_argument =  " + file_argument
					message += "\nSub_command =  " + Sub_command.to_s
					message += "\narity =  " + method.arity.to_s
					fail Exception.new(message)
				end # case
			else
				puts "#{Sub_command} is not a method in #{self.class.inspect}"
			end # if
		end # each
	end # if
	puts "Exiting run"
#		scripting_workflow.script_deserves_commit!(:passed)
end #run
def test
	puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
end # test
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods
def assert_pre_conditions
	CommandLine.assert_ARGV	# don't know why ARGV getsn screwed up in tests
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

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
require_relative '../../app/models/unit.rb'
class CommandLine < Command
module Constants
SUB_COMMANDS = %w(inspect test)
Command_line_opts = Trollop::options do
	banner "magic file deleting and copying utility"
   opt :inspect, "Inspect file object"                    # flag --monkey, default false
   opt :test, "Test unit."       # string --name <s>, default nil
  stop_on SUB_COMMANDS
  end
if ARGV.size > 0 then
	Sub_command = ARGV[0].to_sym # get the subcommand
else
	Sub_command = :help # default subcommand
end # if
Command_line_test_opts = Trollop::options do
    opt :inspect, "Inspect file object"                    # flag --monkey, default false
    opt :test, "Test unit."       # 
    opt :help, "Commands" # 
    opt :individual_test, "Run only one individual test",  :short => "-n" # 
  end
end # Constants
attr_accessor :executable, :options
def initialize(executable, options = Command_line_opts)
	@executable = executable
	@options = options
end # initialize
def run(&non_default_actions)
		@options.each do |f|
			executable_object = self.class.new(TestExecutable.new_from_pathname(f))
			unit= self.class.new(f)
			if unit.respond_to?(c.to_sym) then
				unit.send(c.to_sym, *argv)
			else
				if executable_object.respond_to?(sub_command.to_sym) then
					executable_object.send(sub_command.to_sym, *argv)
				else
					puts "#{sub_command.to_sym} is not a method in #{self.class.inspect}"
				end # if
			end # if
		end # each
#		scripting_workflow.script_deserves_commit!(:passed)
end #run
def test
	puts 'Method :test called in class ' + self.class.name + ' but not over-ridden.'
end # test
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods

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
SELF=CommandLine.new($0)
Readme_opts = Trollop::options do
    opt :monkey, "Use monkey mode"                    # flag --monkey, default false
    opt :name, "Monkey name", :type => :string        # string --name <s>, default nil
    opt :num_limbs, "Number of limbs", :default => 4  # integer --num-limbs <i>, default to 4
  end
end #Examples
include Examples
end # CommandLine

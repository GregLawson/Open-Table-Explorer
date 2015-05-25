###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/command_line.rb'
class CommandLineTest < TestCase
include CommandLine::Examples

def test_Constants
	
	assert_equal({:inspect=>false, :test=>false, :help=>false, :individual_test=>false}, Command_line_test_opts)
global_opts = Trollop::options do
  banner "magic file deleting and copying utility"
  opt :dry_run, "Don't actually do anything", :short => "-n"
  stop_on SUB_COMMANDS
end
end # Constants

def test_initialize
end #initialize
def test_no_arg_command
	no_arg_run=ShellCommands.new('ruby -W0 script/command_line.rb').assert_post_conditions
	assert_equal('', no_arg_run.errors)
	assert_not_equal('', no_arg_run.output)
#	assert_match(/Usage/, no_arg_run.output)
end # inspect_command
def test_help_command
	help_run = ShellCommands.new('ruby -W0 script/command_line.rb --help ')
	assert_equal('', help_run.errors)
	assert_not_equal('', help_run.output)
	assert_match(/Usage/, help_run.output)
end # inspect_command
def test_test_command
	test_run = ShellCommands.new('ruby -W0 script/command_line.rb test ' + $0).assert_pre_conditions
	assert_equal('', test_run.errors)
	last_line = test_run.output.split("/n")[-1]
	assert_not_match(/0 tests, 0 assertions, 0 failures, 0 errors, 0 skips/, last_line)
end # test_command
def test_inspect_command
	ShellCommands.new('ruby -W0 script/command_line.rb inspect ' + $0).assert_pre_conditions
end # inspect_command
def test_readme_example
	assert_instance_of(Hash, Readme_opts)
	help_run = ShellCommands.new('ruby -W0 script/command_line.rb --help ')
	assert_equal([], ARGV)

	assert_equal(false, Readme_opts[:monkey])   #=> 192.168.0.1
	assert_equal(nil, Readme_opts[:name])
	assert_equal(4, Readme_opts[:num_limbs])

	assert_equal({:monkey=>false, :name=>nil, :num_limbs=>4, :help=>false}, Readme_opts.to_hash)  #=> { host: "192.168.0.1", port: 80, verbose: true, quiet: false }end #Examples
end #Examples
end #CommandLine

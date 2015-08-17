###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions.rb'
require_relative '../assertions/command_line_assertions.rb'
#CommandLine.assert_ARGV
CommandLine.assert_pre_conditions
class CommandLineTest < TestCase
include CommandLine::Examples
def teardown
	cleanup_ARGV
end # teardown

def test_Constants
	CommandLine.assert_pre_conditions
	assert_equal({:inspect=>false, :test=>false, :help=>false, :individual_test=>false}, Command_line_test_opts)
	global_opts = Trollop::options do
	  banner "magic file deleting and copying utility"
	  opt :dry_run, "Don't actually do anything", :short => "-n"
	  stop_on SUB_COMMANDS
	end
	if Number_of_arguments > 0 then
		Arguments.each_with_index do |argument, i|
			puts argument.to_s + ' type of ' + Argument_types[i]
		end # each
	else
		puts "No arguments"
	end # if
end # Constants

def test_initialize
end #initialize
def test_run
	CommandLine.assert_pre_conditions
	assert_not_nil(ARGV)
	assert_nothing_raised do
		SELF.run do
		end # do run
	end # assert_raises
end # run
# ruby -W0 script/command_line.rb
# ruby -W0 script/command_line.rb --help
# ruby -W0 script/command_line.rb help
# ruby -W0 script/command_line.rb help test/unit/command_line_test.rb
def test_no_arg_command
	no_arg_run = CommandLine.assert_command_run('')

	assert_equal('', no_arg_run.errors)
	assert_equal('', no_arg_run.output)
end # no_arg_command
def test_help_command
	help_run = CommandLine.assert_command_run('--help')
	assert_match(/Usage/, help_run.output)
end # help_command
def test_test_command
	CommandLine.assert_command_run('test ' + $0)
end # test_command
def test_inspect_command
	CommandLine.assert_command_run('inspect ' + $0)
end # inspect_command
def test_readme_example
	CommandLine.assert_pre_conditions
	assert_instance_of(Hash, Readme_opts)
	help_run = ShellCommands.new('ruby -W0 script/command_line.rb --help ')
	assert_equal([], ARGV)

	assert_equal(false, Readme_opts[:monkey])   #=> 192.168.0.1
	assert_equal(nil, Readme_opts[:name])
	assert_equal(4, Readme_opts[:num_limbs])

	assert_equal({:monkey=>false, :name=>nil, :num_limbs=>4, :help=>false}, Readme_opts.to_hash)  #=> { host: "192.168.0.1", port: 80, verbose: true, quiet: false }end #Examples
	CommandLine.assert_pre_conditions
end #Examples
end #CommandLine

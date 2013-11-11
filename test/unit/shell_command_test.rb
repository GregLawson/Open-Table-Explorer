###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/default_test_case.rb'
class ShellCommandsTest < DefaultTestCase2
include DefaultTests
include ShellCommands::Examples
def test_execute
end #execute
def test_assemble_command_string
end #assemble_command_string
def test_initialize
	assert_equal(COMMAND_STRING, EXAMPLE.command_string)
	assert_equal("1 2;3 4\n", EXAMPLE.output)
	assert_equal("", EXAMPLE.errors)
	assert_equal(0, EXAMPLE.process_status.exitstatus)
	assert_equal("Hello World\n", Hello_world.output)
	Hello_world.assert_post_conditions
	assert_not_equal('', ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']]).output)
	assert_pathname_exists($0)
	guaranteed_existing_directory=File.expand_path(File.dirname($0))+'/'
	guaranteed_existing_basename=File.basename($0)
	cd_command=['cd', guaranteed_existing_directory]
	cd_command={:command => 'cd', :in => guaranteed_existing_directory}
#	shell_execution1=ShellCommands.new([cd_command]).assert_post_conditions(shell_execution1.command_string.inspect)
	relative_command=['pwd']
#	relative_command=['ls', guaranteed_existing_basename]
#	relative_command=['ls', 'guaranteed_existing_basename', '>', 'blank in filename.shell_command']
	shell_execution2=ShellCommands.new([relative_command]).assert_post_conditions(shell_execution2.inspect)
	shell_execution=ShellCommands.new([cd_command, '&&', relative_command])
	shell_execution.assert_post_conditions
#	assert_equal(guaranteed_existing_directory+"\n", shell_execution.output, shell_execution.inspect)
	assert_equal("$SECONDS > blank in filename.shell_command\n", ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS', '>', 'blank in filename.shell_command']]).output)
end #initialize
def test_success?
	assert(EXAMPLE.success?)
end #success
def test_inspect
	Hello_world.assert_post_conditions
	assert_equal("Hello World\n", Hello_world.output)
	assert_equal("Hello World\n", Hello_world.inspect)
	assert_equal("1 2;3 4\n", EXAMPLE.inspect)
end #inspect
def test_puts
	assert_equal(Example_output, EXAMPLE.output)
	assert_kind_of(Enumerable, caller)
	assert_instance_of(Array, caller)
	explain_assert_respond_to(caller, :grep)
	shorter_callers=caller.grep(/^[^\/]/)
	assert_equal(EXAMPLE, EXAMPLE.puts) #allow command chaining
end #puts
def test_assert_post_conditions
	Hello_world.assert_post_conditions
end #assert_post_conditions
end #ShellCommands

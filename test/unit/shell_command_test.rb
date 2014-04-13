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
def test_assemble_hash_command
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_hash_command(Cd_command_hash))
end #assemble_hash_command
def test_assemble_array_command
	assert_match(/[$]/, '$SECONDS')
	assert_equal('$SECONDS', ShellCommands.assemble_array_command(["$SECONDS"]))
	assert_equal('$SECONDS', ShellCommands.assemble_array_command(["$SECONDS"]))
	assert_equal('cd /tmp ; echo $SECONDS', ShellCommands.assemble_array_command(["cd", "/tmp", ";", "echo", "$SECONDS"]))
	assert_equal(Redirect_command_string, ShellCommands.assemble_array_command(Redirect_command))
	assert_equal(Redirect_command_string, ShellCommands.assemble_array_command([Redirect_command]))
	assert_equal(Redirect_command_string, ShellCommands.assemble_array_command(Redirect_command))
end #assemble_array_command
def test_assemble_command_string
	assert_equal(COMMAND_STRING, EXAMPLE.command_string)
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string(Cd_command_array))
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string(Cd_command_hash))
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string([Cd_command_array]))
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string([Cd_command_hash]))
	assert_equal('cd '+Shellwords.escape(Guaranteed_existing_directory)+' && ls shell_command_test.rb', ShellCommands.assemble_command_string([Cd_command_hash, '&&', Relative_command]))
	assert_equal('cd /tmp ; echo $SECONDS', ShellCommands.assemble_command_string(["cd", "/tmp", ";", "echo", "$SECONDS"]))
	assert_equal(Redirect_command_string, ShellCommands.assemble_command_string(Redirect_command))
	assert_equal(Redirect_command_string, ShellCommands.assemble_command_string([Redirect_command]))
end #assemble_command_string
def test_execute
end #execute
def test_initialize
	assert_equal("1 2;3 4\n", EXAMPLE.output)
	assert_equal("", EXAMPLE.errors)
	assert_equal(0, EXAMPLE.process_status.exitstatus)
	assert_equal("Hello World\n", Hello_world.output)
	Hello_world.assert_post_conditions
	assert_not_equal('', ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']]).output)
	shell_execution1=ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']])
	shell_execution1=ShellCommands.new([['cd', '/tmp'], '&&', ['echo', '$SECONDS']])
	shell_execution1=ShellCommands.new('cd /tmp;pwd')
	shell_execution1=ShellCommands.new('cd /tmp;')
	relative_command=['pwd']
	shell_execution2=ShellCommands.new([relative_command]).assert_post_conditions(shell_execution2.inspect)
	relative_command=Redirect_command
	relative_command=['ls', Guaranteed_existing_basename]
	assert_equal(Redirect_command_string, ShellCommands.assemble_array_command(Redirect_command))
	shell_execution=ShellCommands.new([Cd_command_array, '&&', relative_command])
	shell_execution.assert_post_conditions
	assert_equal(Guaranteed_existing_basename+"\n", shell_execution.output, shell_execution.inspect)
	assert_equal("", ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS', '>', 'blank in filename.shell_command']]).output)
	assert_not_equal("", ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']]).output)
	switch_dir=ShellCommands.new([['cd', Guaranteed_existing_directory], '&&', ['pwd']])
	assert_equal(Guaranteed_existing_directory+"\n", switch_dir.output)

	assert_instance_of(Hash, :chdir=>"/")
	switch_dir=ShellCommands.new('pwd', :chdir=>Guaranteed_existing_directory)
	assert_equal(Guaranteed_existing_directory+"\n", switch_dir.output, switch_dir.inspect(true))
end #initialize
def test_01
	shell_execution1=ShellCommands.new('ls /tmp')
	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
#	shell_execution1=ShellCommands.new('cd')
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
#	shell_execution1=ShellCommands.new('pushd /tmp')
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
#	shell_execution1=ShellCommands.new('cd /tmp')
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #1
def test_02
	shell_execution1=ShellCommands.new([['cd', '/tmp']])
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #2
def test_03
	shell_execution1=ShellCommands.new(ShellCommands.assemble_hash_command(Cd_command_hash))
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #3
def test_04
	shell_execution1=ShellCommands.new(ShellCommands.assemble_command_string(Cd_command_hash))
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #4
def test_05
	shell_execution1=ShellCommands.new(Cd_command_hash)
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #5
def test_06
#	shell_execution1=ShellCommands.new([Cd_command_hash])
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #6
def test_07
#	shell_execution1=ShellCommands.new([Cd_command_array])
#	shell_execution1.assert_post_conditions(shell_execution1.command_string.inspect)
end #7
def test_08
end #8
def test_09
end #9
def test_10
	switch_dir=ShellCommands.new([['cd', Guaranteed_existing_directory], '&&', ['pwd']])
	assert_instance_of(String, switch_dir.output)
	assert_equal(Guaranteed_existing_directory+"\n", switch_dir.output)
end #10
def test_11
#	assert_equal('shell_command_test.rb', ShellCommands.new([['cd', Guaranteed_existing_directory], '&&', ['ls', Guaranteed_existing_basename]]))
end #11
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
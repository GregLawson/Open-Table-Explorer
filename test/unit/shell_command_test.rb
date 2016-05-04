###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/shell_command_assertions.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/default_test_case.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
class ShellCommandsTest < DefaultTestCase2
#include DefaultTests
include ShellCommands::Examples
include Shell::Ssh::Examples
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
	refute_equal('', ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']]).output)
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
	refute_equal("", ShellCommands.new([['cd', '/tmp'], ';', ['echo', '$SECONDS']]).output)
	switch_dir=ShellCommands.new([['cd', Guaranteed_existing_directory], '&&', ['pwd']])
	assert_equal(Guaranteed_existing_directory+"\n", switch_dir.output)

	assert_instance_of(Hash, :chdir=>"/")
	switch_dir=ShellCommands.new('pwd', :chdir=>Guaranteed_existing_directory)
	assert_equal(Guaranteed_existing_directory+"\n", switch_dir.output, switch_dir.inspect(true))
end #initialize
def test_parse_argument_array
	argument_array=[{'G' => 'e'}, 'git rebase']
	command=ShellCommands.new
	command.parse_argument_array(argument_array)
	assert_includes(command.methods(true), :env)
	assert_equal(argument_array[0], command.env)
	assert_equal(argument_array[1], command.command)
	assert_equal({}, command.opts)
end #parse_argument_array
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
	assert(Hello_world.success?)
	assert_equal(127, Bad_status.success?)
	assert_equal(2, Error_message_run.success?)
end #success
def test_clear_error_message
	assert_equal(0, Hello_world.clone.clear_error_message!(0xFF).success?)
	assert_equal(0, Bad_status.clone.clear_error_message!(0xFF).success?)
	assert_equal(0, Error_message_run.clone.clear_error_message!(0xFF).success?)
	assert_equal(0, Hello_world.clone.clear_error_message!(0).success?)
	assert_equal(0, Bad_status.clone.clear_error_message!(127).success?)
	assert_equal(0, Error_message_run.clone.clear_error_message!(2).success?)
end # clear_error_message!
def test_force_success
	Hello_world.force_success(0).assert_post_conditions
	Bad_status.force_success(127).assert_post_conditions
	Error_message_run.force_success(2).assert_post_conditions
	assert_equal(0, Error_message_run.clone.clear_error_message!(0xFF).success?)
	Error_message_run.force_success(0xFF).assert_post_conditions
end # force_success
def test_tolerate_status(tolerated_status = 1)
	Hello_world.tolerate_status.assert_post_conditions
	Bad_status.tolerate_status(127).assert_post_conditions
end # tolerate_status
def test_tolerate_error_pattern(tolerated_error_pattern = /^warning/)
	Hello_world.tolerate_error_pattern.assert_post_conditions
	Error_message_run.tolerate_error_pattern(/No such file/).assert_post_conditions
end # tolerate_error_pattern
def test_tolerate_status_and_error_message(tolerated_status = 1, tolerated_error_pattern = /^warning/)
	Hello_world.tolerate_status_and_error_pattern.assert_post_conditions
	assert_equal(Bad_status.process_status.exitstatus, 127, Bad_status.inspect)
	assert_match(/not found/, Bad_status.errors, Bad_status.inspect)
	assert(Bad_status.process_status.exitstatus == 127 && /not found/.match(Bad_status.errors), Bad_status.inspect)
	Bad_status.tolerate_status_and_error_pattern(127, /not found/).assert_post_conditions
	assert_match(/No such file/, Error_message_run.errors, Error_message_run.inspect)
	assert_equal(2, Error_message_run.process_status.exitstatus, Error_message_run.inspect)
	Error_message_run.tolerate_status_and_error_pattern(2, /No such file/).assert_post_conditions
end # tolerate_status_and_error_message
def test_tolerate
end # tolerate
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

class FileDependancyTest < TestCase
include FileDependancy::Examples # for FileIPO
def test_input_updated?
	assert(Pwd.input_updated?, Pwd.inspect)
	assert(Cat.input_updated?, Cat.inspect)
#	refute(Touch_fail.input_updated?, Touch_fail.inspect)
#	refute(Cat_fail.input_updated?, Cat_fail.inspect)
	assert(Touch_create.input_updated?, Touch_create.inspect)
	FileIPO::Examples::Touch.run # creates IO file
	input_times = Touch.input_paths.map{|p| Pathname.new(p).mtime}
	output_times = Touch.output_paths.map{|p| Pathname.new(p).mtime}
	if input_times.empty?
		true
	elsif output_times.empty?
		true
	else
		input_times.max > output_times.min
	end # if
	assert(Touch.input_updated?, Touch.inspect)
	refute(Touch_fail.input_updated?, Touch_fail.inspect)
	refute(Cat_fail.input_updated?, Cat_fail.inspect)
end # input_updated?
end # FileDependancyTest

class FileIPOTest < TestCase
include FileIPO::Examples # for FileIPO
def test_FileIPO_virtus
	assert_equal([], Pwd.input_paths)
	assert_equal([], Pwd.output_paths)
	assert_equal([], Touch_create.input_paths)
	assert_equal([Touch_create_path], Touch.input_paths)
	assert_equal([Touch_create_path], Touch.output_paths)
	assert_equal(['/dev/null'], Cat.input_paths)
	assert_equal([], Cat.output_paths)
	assert_empty(Pwd.errors, Pwd)
	assert_empty(Touch.errors, Touch)
	assert_empty(Cat.errors, Cat)
	refute_empty(Touch_fail.errors, Touch_fail)
	refute_empty(Cat_fail.errors, Cat_fail)
end # values
def test_run
	assert_equal(0, Pwd.run.errors[:exitstatus], Pwd.inspect)
	assert_equal(0, Chdir.run.errors[:exitstatus], Chdir.inspect)
	assert_equal("/tmp\n", Chdir.run.cached_run.output, Pwd.inspect)
	assert_equal(0, Touch.run.errors[:exitstatus], Touch)
	assert_equal(0, Cat.run.errors[:exitstatus], Cat)
	assert_equal(:output_does_not_exist, Touch_fail.run.errors["/tmp/junk2"], Touch_fail)
	assert_equal(:input_does_not_exist, Cat_fail.run.errors["/dev/null2"], Cat_fail)
	assert_equal(0, Touch_create.run.errors[:exitstatus], Touch_create.inspect)
end # run
def test_success?
	assert(Pwd.run.success?, Pwd.inspect)
	assert(Touch.run.success?, Touch.inspect)
	assert(Cat.run.success?, Cat.inspect)
	refute(Touch_fail.run.success?, Touch_fail.inspect)
	refute(Cat_fail.run.success?, Cat_fail.inspect)
end # success?
end # FileIPO

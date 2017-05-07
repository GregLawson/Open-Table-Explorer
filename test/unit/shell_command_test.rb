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
class ShellTest < TestCase
  # include DefaultTests
#  include Shell::Server::Examples
    module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
      include Shell::Base::DefinitionalConstants
#      include ReferenceObjects
      Example_output = "1 2;3 4\n".freeze
      COMMAND_STRING = 'echo "1 2;3 4"'.freeze
      Guaranteed_existing_directory = File.expand_path(File.dirname($PROGRAM_NAME))
      Cd_command_array = ['cd', Guaranteed_existing_directory].freeze
      Cd_command_hash = { command: 'cd', in: Guaranteed_existing_directory }.freeze
      Guaranteed_existing_basename = File.basename($PROGRAM_NAME)
      Redirect_command = ['ls', Guaranteed_existing_basename, '>', 'blank in filename.shell_command'].freeze
      Redirect_command_string = 'ls ' + Shellwords.escape(Guaranteed_existing_basename) + ' > ' + Shellwords.escape('blank in filename.shell_command')
      Relative_command = ['ls', Guaranteed_existing_basename].freeze
    end # Examples
		include Examples
		
  include Shell::Ssh::Examples
  def test_Shell_Base_Default_run
	end # Default_run

  def test_assemble_hash_command
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_hash_command(Cd_command_hash))
  end # assemble_hash_command

  def test_assemble_array_command
    assert_match(/[$]/, '$SECONDS')
    assert_equal('$SECONDS', ShellCommands.assemble_array_command(['$SECONDS']))
    assert_equal('$SECONDS', ShellCommands.assemble_array_command(['$SECONDS']))
    assert_equal('cd /tmp ; echo $SECONDS', ShellCommands.assemble_array_command(['cd', '/tmp', ';', 'echo', '$SECONDS']))
    assert_equal(Redirect_command_string, ShellCommands.assemble_array_command(Redirect_command))
    assert_equal(Redirect_command_string, ShellCommands.assemble_array_command([Redirect_command]))
    assert_equal(Redirect_command_string, ShellCommands.assemble_array_command(Redirect_command))
  end # assemble_array_command

  def test_assemble_command_string
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string(Cd_command_array))
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string(Cd_command_hash))
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string([Cd_command_array]))
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory), ShellCommands.assemble_command_string([Cd_command_hash]))
    assert_equal('cd ' + Shellwords.escape(Guaranteed_existing_directory) + ' && ls shell_command_test.rb', ShellCommands.assemble_command_string([Cd_command_hash, '&&', Relative_command]))
    assert_equal('cd /tmp ; echo $SECONDS', ShellCommands.assemble_command_string(['cd', '/tmp', ';', 'echo', '$SECONDS']))
    assert_equal(Redirect_command_string, ShellCommands.assemble_command_string(Redirect_command))
    assert_equal(Redirect_command_string, ShellCommands.assemble_command_string([Redirect_command]))
  end # assemble_command_string
  end # Shell::Base
	
class ServerTest < TestCase

    module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
			include ShellTest::Examples
      Hello_world = Shell::Server.new(command_string: 'echo "Hello World"')
      EXAMPLE = Shell::Server.new(command_string: COMMAND_STRING)
      Bad_status = Shell::Server.new(command_string: '$?=1')
      Error_message_run = Shell::Server.new(command_string: 'ls happyHappyFailFail.junk')
    end # Examples
		include Examples
  def test_Server_DefinitionalConstants
  end # DefinitionalConstants

  def test_Server_Virtus
    refute_nil(Hello_world.command_string)
    refute_nil(Hello_world.env, Hello_world.inspect)
    refute_nil(Hello_world.opts)
  end # values

			def test_select
				Hello_world.start
				all3 = [Hello_world.stdout, Hello_world.stderr, Hello_world.stdin]
				all3x3 = [all3, all3, all3]
				assert_equal([Hello_world.stdin], Hello_world.select[1], IO.select(all3, all3, all3, 0.01))
				stdout_waiting = Hello_world.select[0]
				assert_includes([[], [Hello_world.stdout]], stdout_waiting)
			end # select						


		def test_tee
    Hello_world.start
    Hello_world.tee
    Hello_world.close
		end # tee

  def test_success?
  end # success

  def test_Server_Constructors # such as alternative new methods
  end # Constructors

  def test_Server_assert_pre_conditions
    Shell::Server.assert_pre_conditions
  end # assert_pre_conditions

  def test_Server_assert_post_conditions
  end # assert_post_conditions


	def test_assert_readable
    Hello_world.start
		Shell::Server.assert_readable(Hello_world.stdout)
		Shell::Server.assert_readable(Hello_world.stderr)
#		assert_raises(AssertionFailedError) {Shell::Server.assert_readable(Hello_world.stdin)}
			end # readable
			
	def test_assert_writable
    Hello_world.start
		Shell::Server.assert_writable(Hello_world.stdin)
		assert_raises(AssertionFailedError) {Shell::Server.assert_writable(Hello_world.stderr)}
#		assert_raises(AssertionFailedError) {Shell::Server.assert_writable(Hello_world.stdout)}
			end # writable
			

  def test_Server_instance_assert_pre_conditions
  end # assert_pre_conditions

  def test_Server_instance_assert_post_conditions
  end # assert_post_conditions

	def test_assert_started
	end # assert_started

	def test_assert_ended
      end # assert_started
  def test_Server_Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    assert_equal([:@allowed_writer_methods, :@command_string, :@env, :@opts, :@errors, :@cached_run, :@start_time, :@elapsed_time, :@timeout, :@stdin, :@stdout, :@stderr, :@wait_thr, :@output], EXAMPLE.instance_variables, EXAMPLE.inspect)
    assert_equal(COMMAND_STRING, EXAMPLE.command_string, EXAMPLE.inspect)
  end # Examples
  end # Server

class CommandTest < TestCase
  include Shell::Command::Examples

  def test_Command_Virtus
 end # values

  def test_Command_Examples
    assert_include(EXAMPLE.class.ancestors, Shell::Server)
    assert_equal(COMMAND_STRING, EXAMPLE.command_string, EXAMPLE.inspect)
    assert_equal("1 2;3 4\n", EXAMPLE.start.close.output, EXAMPLE.inspect)
    assert_equal({}, EXAMPLE.errors)
    assert_equal(0, EXAMPLE.process_status.exitstatus)
    assert_equal("Hello World\n", Hello_world.start.close.output)
    Hello_world.assert_post_conditions
    shell_execution1 = Shell::Command.new(command_string: 'cd /tmp;pwd')
    shell_execution1 = Shell::Command.new(command_string: 'cd /tmp;')
    relative_command = Redirect_command
    relative_command = ['ls', Guaranteed_existing_basename]
    assert_equal(Redirect_command_string, Shell::Command.assemble_array_command(Redirect_command))

    assert_instance_of(Hash, chdir: '/')
    switch_dir = Shell::Command.new(command_string: 'pwd', chdir: Guaranteed_existing_directory)
  end # Examples
  end # Command

class SshTest < TestCase
  include Shell::Ssh::Examples
 end # Shell

class FileDependancyTest < TestCase
  include FileDependancy::Examples # for FileIPO
  def test_input_updated?
    assert(Pwd.input_updated?, Pwd.inspect)
    assert(Cat.input_updated?, Cat.inspect)
    #	refute(Touch_fail.input_updated?, Touch_fail.inspect)
    #	refute(Cat_fail.input_updated?, Cat_fail.inspect)
    assert(Touch_create.input_updated?, Touch_create.inspect)
    FileIPO::Examples::Touch.run # creates IO file
    input_times = Touch.input_paths.map { |p| Pathname.new(p).mtime }
    output_times = Touch.output_paths.map { |p| Pathname.new(p).mtime }
    if input_times.empty?
      true
    elsif output_times.empty?
      true
    else
      input_times.max > output_times.min
    end # if
    refute(Touch.input_updated?, Touch.inspect)
    assert(Touch_fail.input_updated?, Touch_fail.inspect + Touch_fail.explain_updated)
    refute(Cat_fail.input_updated?, Cat_fail.inspect)
  end # input_updated?

  def test_explain_updated
    assert_equal('input files are missing', Pwd.explain_updated, Pwd.inspect)
    assert_equal('if inputs are missing, there can\'t be an update yet.', Touch.explain_updated, Touch.inspect)
    assert_equal('output files are missing', Cat.explain_updated, Cat.inspect)
    assert_equal('if there are missing outputs, an update is required to create them.', Touch_fail.explain_updated, Touch_fail.inspect)
    assert_equal('if inputs are missing, there can\'t be an update yet.', Cat_fail.explain_updated, Cat_fail.inspect)
  end # explain_updated

  def test_delete_output_files!
  end # delete_output_files!

  def test_Examples
  end # Examples
end # FileDependancy

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
    assert_empty(Pwd.run.errors, Pwd)
    assert_empty(Touch_create.run.errors, Touch)
    # assert_empty(Touch.errors, Touch)
    assert_empty(Cat.run.errors, Cat)
    refute_empty(Touch_fail.run.errors, Touch_fail)
    refute_empty(Cat_fail.run.errors, Cat_fail)
  end # values

  def test_run
    assert_equal(0, Pwd.run.cached_run.process_status.exitstatus, Pwd.inspect)
    assert_equal(0, Chdir.run.cached_run.process_status.exitstatus, Chdir.inspect)
    assert_equal("/tmp\n", Chdir.run.cached_run.output, Pwd.inspect)
    assert_equal(0, Touch.run.cached_run.process_status.exitstatus, Touch)
    assert_equal(0, Cat.run.cached_run.process_status.exitstatus, Cat)
    assert_equal(:output_does_not_exist, Touch_fail.run.errors['/tmp/junk2'], Touch_fail)
    assert_equal(:input_does_not_exist, Cat_fail.run.errors['/dev/null2'], Cat_fail)
    assert_equal(0, Touch_create.run.cached_run.process_status.exitstatus, Touch_create.inspect)
  end # run

  def test_success?
    assert_equal(0, Pwd.run.cached_run.process_status.exitstatus, Pwd.inspect)
    assert(Pwd.run.success?, Pwd.inspect)
    assert(Touch.run.success?, Touch.inspect)
    assert(Cat.run.success?, Cat.inspect)
    refute(Touch_fail.run.success?, Touch_fail.inspect)
    refute(Cat_fail.run.success?, Cat_fail.inspect)
  end # success?
end # FileIPO

class ShellCommandsTest < TestCase
  # include DefaultTests
  include ShellCommands::Examples
  include Shell::Ssh::Examples
end # ShellCommands

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

  def test_start
    stdout, stdin = IO.pipe
    Shell::Server.assert_pipe(stdin)
    Shell::Server.assert_pipe(stdout)
    Shell::Server.assert_writable(stdin)
    Shell::Server.assert_readable(stdout)
    Hello_world.start
    assert_includes(%w(sleep run), Hello_world.wait_thr.status)
    Hello_world.assert_post_conditions
    Hello_world.assert_started

    pause_delimiter = Shell::Command.new(command_string: 'echo "Hello World";sleep 10;echo "Bye"')
    pause_delimiter.start
    assert_equal(true, pause_delimiter.wait_thr.alive?)
    pause_delimiter.assert_post_conditions
    pause_delimiter.assert_started
    begin
      first_output = pause_delimiter.stdout.read_nonblock(11)
    rescue StandardError => exception_object_raised
      puts exception_object_raised.inspect
      selection = IO.select([pause_delimiter.stdout], [pause_delimiter.stdin], [pause_delimiter.stderr], 15)
      assert_equal([], selection[0])
      assert_equal([pause_delimiter.stdin], selection[1])
      assert_equal([], selection[2])
    end
    assert_equal('Hello World', first_output)
   end # start

  def test_wait
  end # wait

  def test_close
    Hello_world.start
    Hello_world.assert_started

    pause_delimiter = Shell::Command.new(command_string: 'echo "Hello World";sleep 10;echo "Bye"')
    pause_delimiter.start
    pause_delimiter.assert_post_conditions
    pause_delimiter.assert_started
    first_output = pause_delimiter.stdout.read_nonblock(11)
    assert_equal('Hello World', first_output)
    pause_delimiter.assert_started('during pause presumably.')
    pause_delimiter.close
    pause_delimiter.assert_ended('after pause')
    assert_equal("\nBye\n", pause_delimiter.output)
  end # close

  def test_assert_pipe
    Hello_world.start
    Shell::Server.assert_pipe(Hello_world.stdin)
    Shell::Server.assert_pipe(Hello_world.stdout)
    Shell::Server.assert_pipe(Hello_world.stderr)
    pause_delimiter = Shell::Command.new(command_string: 'echo "Hello World";sleep 10;echo "Bye"')
    pause_delimiter.start
    Shell::Server.assert_pipe(pause_delimiter.stdin)
    Shell::Server.assert_pipe(pause_delimiter.stdout)
    Shell::Server.assert_pipe(pause_delimiter.stderr)
      end # pipe

  def test_Server_Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    assert_equal([:@allowed_writer_methods, :@command_string, :@env, :@opts, :@errors, :@cached_run, :@start_time, :@elapsed_time, :@timeout, :@stdin, :@stdout, :@stderr, :@wait_thr, :@output], EXAMPLE.instance_variables, EXAMPLE.inspect)
    assert_equal(COMMAND_STRING, EXAMPLE.command_string, EXAMPLE.inspect)
  end # Examples
  end # Server

class CommandTest < TestCase
  include Shell::Command::Examples
  end # Command

class SshTest < TestCase
  include Shell::Ssh::Examples
 end # Shell

class FileDependancyTest < TestCase
  include FileDependancy::Examples # for FileIPO
end # FileDependancy

class FileIPOTest < TestCase
  include FileIPO::Examples # for FileIPO
end # FileIPO

class ShellCommandsTest < DefaultTestCase2
  # include DefaultTests
  include ShellCommands::Examples
  include Shell::Ssh::Examples
end # ShellCommands

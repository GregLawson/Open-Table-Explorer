###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/shell_command.rb'
module Shell
  class Ssh
    module Assertions
      module ClassMethods
        def assert_pre_conditions(message = '')
          message += "In assert_pre_conditions, self=#{inspect}"
        end # assert_pre_conditions

        def assert_post_conditions(message = '')
          message += "In assert_post_conditions, self=#{inspect}"
        end # assert_post_conditions
      end # ClassMethods
      def assert_pre_conditions(message = '')
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
      end # assert_post_conditions
    end # Assertions
    # self.assert_pre_conditions
    module Examples
      Central = Ssh.new('greg@localhost')
    end # Examples
  end # Ssh
end # Shell
class ShellCommands
  require_relative '../../test/assertions.rb'
  module Assertions
    def assert_pre_conditions(_message = '')
      self # return for command chaining
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "self=#{inspect(true)}"
      puts unless success? && @errors.empty?
      assert_empty(@errors, message + 'expected errors to be empty\n')
      assert_equal(0, @process_status.exitstatus & ~@accumulated_tolerance_bits, message)
      refute_nil(@errors, 'expect @errors to not be nil.')
      refute_nil(@process_status)
      assert_instance_of(Process::Status, @process_status)

      self # return for command chaining
    end # assert_post_conditions
  end # Assertions
  include Assertions
  module Examples
    Hello_world = ShellCommands.new('echo "Hello World"')
    Example_output = "1 2;3 4\n".freeze
    COMMAND_STRING = 'echo "1 2;3 4"'.freeze
    EXAMPLE = ShellCommands.new(COMMAND_STRING)
    Guaranteed_existing_directory = File.expand_path(File.dirname($PROGRAM_NAME))
    Cd_command_array = ['cd', Guaranteed_existing_directory].freeze
    Cd_command_hash = { command: 'cd', in: Guaranteed_existing_directory }.freeze
    Guaranteed_existing_basename = File.basename($PROGRAM_NAME)
    Redirect_command = ['ls', Guaranteed_existing_basename, '>', 'blank in filename.shell_command'].freeze
    Redirect_command_string = 'ls ' + Shellwords.escape(Guaranteed_existing_basename) + ' > ' + Shellwords.escape('blank in filename.shell_command')
    Relative_command = ['ls', Guaranteed_existing_basename].freeze
    Bad_status = ShellCommands.new('$?=1')
    Error_message_run = ShellCommands.new('ls happyHappyFailFail.junk')
  end # Examples
  include Examples
end # ShellCommands

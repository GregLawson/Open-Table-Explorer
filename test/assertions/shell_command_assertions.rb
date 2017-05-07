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
    require_relative '../../app/models/assertions.rb'
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
      #      puts unless success? && @errors.empty?
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
  end # Examples
  include Examples
end # ShellCommands

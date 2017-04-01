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
  # include DefaultTests
  include ShellCommands::Examples
  include Shell::Ssh::Examples
  def self.startup
    ssh_pid = ShellCommands.new('echo $SSH_AGENT_PID $SSH_AUTH_SOCK')
    ps = ShellCommands.new('ps -C ssh-agent').assert_post_conditions.output.split("\n")[1..-1]
    spaced_column_regexp = /[^\s]+/.capture(:column) * /\s/
    integer_regexp = /[0-9]+/
    white_space = /\s/
    string_spaceless = /[^\s]/
    ps.map do |process_line|
      columns = Parse.parse_into_array(process_line, spaced_column_regexp)
      puts columns.inspect
      ps_regexp = integer_regexp.capture(:pid)
      assert_instance_of(Fixnum, Parse.parse(process_line, ps_regexp)[:pid].to_i)
      ps_regexp *= white_space * string_spaceless.capture(:tty) * white_space
      assert_equal('?', Parse.parse(process_line, ps_regexp)[:tty])
      ps_regexp *= white_space * string_spaceless.capture(:time) * white_space
      assert_instance_of(Hash, Parse.parse(process_line, ps_regexp))
      assert_equal('00:00:00', Parse.parse(process_line, ps_regexp)[:time])
      ps_regexp *= string_spaceless.capture(:command)
      assert_equal('ssh-agent', Parse.parse(process_line, ps_regexp)[:command])
      process = Parse.parse(process_line, ps_regexp)
      puts process.inspect
    end # map
    assert_equal(1, ps.size, ps)
  end # self.startup

  def test_Ssh_initialize
    refute_empty(Central.user)
  end # initialize

  def test_command_on_remote
    remote_run = Central['echo "cat"'].assert_post_conditions
    assert_equal("cat\n", remote_run.output)
    assert_equal("/home/greg\n", Central['pwd'].output)
    #	assert_equal("greg", Central['ls -l /shares/Public/Non-media/Git_repositories/Open-Table-Explorer/.git/./objects'].output)
  end # []
end # ShellCommands

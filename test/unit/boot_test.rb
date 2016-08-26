###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/boot.rb'
class BootTest < TestCase
  # include DefaultTests
  # include RailsishRubyUnit::Executable.model_class?::Examples

  def test_Minimal_DefinitionalConstants
    run_levels = ShellCommands.new('/sbin/runlevel')
    assert_equal("N 3\n", run_levels.output, run_levels.inspect)
    is_system_running = ShellCommands.new('systemctl is-system-running')
    assert_include(["degraded\n", "offline\n"], is_system_running.output, is_system_running.inspect)
    uname = ShellCommands.new('uname -a')
    assert_equal("Linux acer-desktop 4.6.0-1-rt-amd64 #1 SMP PREEMPT RT Debian 4.6.4-1 (2016-07-18) x86_64 GNU/Linux\n", uname.output, uname.inspect)
    grubs_run = ShellCommands.new('grep "linux .*/vmlinu" /boot/grub/grub.cfg')
    menuentry_regexp = /menuentry \'Debian GNU\/Linux, with Linux /
    assert_match(/menuentry/, grubs_run.output, grubs_run.inspect)
    grubs_regexp = menuentry_regexp
    assert_match(menuentry_regexp, grubs_run.output, grubs_run.inspect)
    grubs = grubs_run.output.capture?(grubs_regexp)
    assert_equal({}, grubs.output, grubs.inspect)
  end # DefinitionalConstants

  def test_Minimal_Virtus
  end # values

  def test_Minimal_assert_pre_conditions
  end # assert_pre_conditions

  def test_Minimal_assert_post_conditions
  end # assert_post_conditions

  def assert_pre_conditions
  end # assert_pre_conditions

  def assert_post_conditions
  end # assert_post_conditions

  def test_Minimal_Examples
  end # Examples
end # Minimal

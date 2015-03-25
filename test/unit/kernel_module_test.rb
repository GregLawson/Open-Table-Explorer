###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
TestCase=Test::Unit::TestCase
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/shell_command.rb'
class UsbtmcTest < TestCase
def test_script
	install_execution=ShellCommands.new('locate usbtmc').assert_post_conditions
	install_execution=ShellCommands.new('sudo /sbin/modinfo usbtmc').assert_post_conditions
	install_execution=ShellCommands.new('sudo /sbin/modprobe usbtmc').assert_post_conditions
	install_execution=ShellCommands.new('ls -l /dev/usbtmc*').assert_post_conditions
	install_execution=ShellCommands.new('dmesg').assert_post_conditions
	install_execution=ShellCommands.new('lsmod|grep usbtmc').assert_post_conditions
end # script
end # Usbtmc

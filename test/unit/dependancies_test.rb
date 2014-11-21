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
#require_relative '../../app/models/related_file.rb'
require_relative '../../app/models/shell_command.rb'
class DependanciesTest < TestCase
require 'pathname'
def test_script
	install_execution=ShellCommands.new('sudo apt-get install pmount').assert_post_conditions
	install_execution=ShellCommands.new('sudo apt-get install active_model').assert_post_conditions
	install_execution=ShellCommands.new('sudo apt-get install activemodel').assert_post_conditions
	install_execution=ShellCommands.new('sudo apt-get install vrms').assert_post_conditions
	install_execution=ShellCommands.new('sudo gem install grit').assert_post_conditions
	install_execution=ShellCommands.new('sudo gem install regexp_parser').assert_post_conditions
	install_execution=ShellCommands.new('sudo gem install virtus').assert_post_conditions
	install_execution=ShellCommands.new('sudo gem install mysql').assert_post_conditions
	install_execution=ShellCommands.new('sudo wajig install  ruby-activemodel-3.2').assert_post_conditions
	install_execution=ShellCommands.new('bundle install').assert_post_conditions
end # script
def test_dpkg_lock
	pathname = '/var/cache/apt/archives/lock'
	assert(!File.exist?(pathname), pathname)
end # dpkg_lock
end # Dependancies

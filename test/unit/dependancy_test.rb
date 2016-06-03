###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/dependancy.rb'
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
TestCase=Test::Unit::TestCase
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
#require_relative '../../app/models/related_file.rb'
class DependanciesTest < TestCase
def test_grit
	Dependancy.new('grit').gem
#	install_execution=ShellCommands.new('sudo gem install grit').assert_post_conditions
end # grit
def test_
end # 
def test_bundle
	install_execution=ShellCommands.new('bundle install').assert_post_conditions
end # bundle
def test_dpkg_lock
	pathname = '/var/cache/apt/archives/lock'
	assert(!File.exist?(pathname), pathname)
end # dpkg_lock
end # Dependancies

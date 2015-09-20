###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
require 'fileutils'
require_relative '../../app/models/version.rb'
class RubyInterpreter # < ActiveRecord::Base
include Virtus.model
  attribute :processor_version, String, :default => nil # system version
  attribute :options, String, :default => '-W0'
module Constants
include Version::Constants
# see http://semver.org/
Ruby_pattern = [/ruby /, Version]
Parenthetical_date_pattern = / \(/ * /2014-05-08/.capture(:compile_date) * /\)/
Bracketed_os = / \[/ * /i386-linux-gnu/ * /\]/ * "\n"
Version_pattern = [Ruby_pattern, Parenthetical_date_pattern, Bracketed_os]
end # Constants
include Constants
#include Generic_Table
#has_many :bugs
module ClassMethods
def ruby_version(executable_suffix = '')
	ShellCommands.new('ruby --version').output.split(' ')
	testRun = RubyInterpreter.new(test_command: 'ruby', options: '--version').run
	testRun.output.parse(Version_pattern).output
end # ruby_version
def shell(command, &proc)
#	puts "command='#{command}'"
	run =ShellCommands.new(command)
	if block_given? then
		proc.call(run)
	else
		run.assert_post_conditions
	end # if
end #shell
# Run rubyinterpreter passing arguments
def ruby(args, &proc)
	shell("ruby #{args}",&proc)
end #ruby
end # ClassMethods
extend ClassMethods
# attr_reader
def assert_logical_primary_key_defined(message=nil)
	message=build_message(message, "self=?", self.inspect)	
	refute_nil(self, message)
	assert_instance_of(RubyInterpreter,self, message)

#	puts "self=#{self.inspect}"
	refute_nil(self.attributes, message)
	refute_nil(self[:test_type], message)
	refute_nil(self.test_type, message)
	refute_nil(self['test_type'], message)
	refute_nil(self.singular_table, message)
end #assert_logical_primary_key_defined
module Examples
include Constants
Ruby_version = ShellCommands.new('ruby --version').output
end # Examples
end # RubyInterpreter

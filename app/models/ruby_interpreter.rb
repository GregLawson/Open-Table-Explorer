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
require_relative '../../app/models/parse.rb'
class RubyInterpreter # < ActiveRecord::Base
include Virtus.model
  attribute :processor_version, String, :default => nil # system version
  attribute :options, String, :default => '-W0'
module Constants
# see http://semver.org/
Version_digits = /[0-9]{1,4}/
Version = [Version_digits.capture(:major), '.'] + 
	[Version_digits.capture(:minor)] + 
	[Version_digits.capture(:patch)] +
	[/[-.a-zA-Z0-9]*/.capture(:pre_release)]
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
	testRun = TestRun.new(test_command: 'ruby', options: '--version').run
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
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
def assert_logical_primary_key_defined(message=nil)
	message=build_message(message, "self=?", self.inspect)	
	assert_not_nil(self, message)
	assert_instance_of(RubyInterpreter,self, message)

#	puts "self=#{self.inspect}"
	assert_not_nil(self.attributes, message)
	assert_not_nil(self[:test_type], message)
	assert_not_nil(self.test_type, message)
	assert_not_nil(self['test_type'], message)
	assert_not_nil(self.singular_table, message)
end #assert_logical_primary_key_defined
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Ruby_version = ShellCommands.new('ruby --version').output
end # Examples
end # RubyInterpreter

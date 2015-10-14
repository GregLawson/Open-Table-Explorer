###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
require_relative '../../app/models/version.rb'
class Grub
  include Virtus.value_object
  values do
 	attribute :kernel_version, String
	attribute :root_partition, String
#	attribute :timestamp, Time, :default => Time.now
	end # values
module Constants # constant parameters of the type
Generated_file = Unit::Executable.data_sources_directory? + '/generated.cfg'
Config_run = IO.read(Generated_file)
Indent = /^\s*/.capture(:indent)
UUID_regexp =/[-0-9a-fA-F]{36}/.capture(:uuid)
Config_pattern = Indent * /linux\s/ * (/\/boot/.group * Regexp::Optional).capture(:boot) * /\/vmlinuz-/ * Version::Version_regexp * ' root=UUID=' * UUID_regexp
Search_regexp = Indent * /search\s+--no-floppy/ * /.+/ * UUID_regexp
end #Constants
include Constants
module ClassMethods
include Constants
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
def mkconfig
  ShellCommands.new('sudo /usr/sbin/grub-mkconfig --output=' + Generated_file)
end # mkconfig
module Constants # constant objects of the type
end # Constants
include Constants
# attr_reader
require_relative 'assertions.rb'
require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
#	assert_nested_and_included(:ClassMethods, self)
#	assert_nested_and_included(:Constants, self)
#	assert_nested_and_included(:Assertions, self)
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
	self
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
	self
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end # Examples
end # Grub

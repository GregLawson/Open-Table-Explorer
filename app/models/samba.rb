###########################################################################
#    Copyright (C) 2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'virtus'
#require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/parse.rb'
class Samba
module ClassMethods
end # ClassMethods
extend ClassMethods
module Constants
Default_server = '192.168.0.12'
end # Constants
include Constants
attr_reader :host, :share_name, :mount_point, :options
def initialize(host, share_name, mount_point, options)
	@host = host
	@type = 'cifs'
	@share_name = share_name
	@mount_point = mount_point
	@options = options
end # initialize
def state?
	file_run = ShellCommands.new('file ' + @mount_point)
	case file_run.output
	when /#{@mount_point}: ERROR: cannot open `#{@mount_point}' (No such file or directory)/ then
		:no_mount_point
	when /#{@mount_point}: directory/ then
		:unmounted_directory
	when /#{@mount_point}: ERROR: cannot open `#{@mount_point}' (Host is down)/ then
		:host_is_down
	when // then
		:mounted
	else
		fail Exception.new(file_run.inspect)
	end # case
end # state?
def mount_or_remount
	if mounted? then
		umount
	end # if
	mount
end # mount_or_remount
def mount_with_mkdir
	case state?
	when :no_mount_point
		puts "!File.exists?(#{@mount_point}) = " + (!File.exists?(@mount_point)).inspect
		puts "File.exists?(#{@mount_point}) = " + (File.exists?(@mount_point)).inspect
		puts "#{@mount_point} = " + @mount_point
		mkdir_run = ShellCommands.new('mkdir ' + @mount_point)
		if !mkdir_run.success? then
			return mkdir_run
		end # if
	end # if
end # mount_with_mkdir
def mount
	@command_string = 'mount -t ' + @type + ' ' + @share_name + ' ' + @mount_point
	@command_string += ' -o ip=' + @host + ',' +@options
	ShellCommands.new(@command_string)
end # mount
def umount
	@command_string = 'umount ' + @mount_point
	ShellCommands.new(@command_string)
end # umount
def mounted?
	mtab_grep = ShellCommands.new('grep ' + @mount_point + ' /etc/mtab')
	mtab_grep.output == ''
end # mounted?
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def nested_scope_modules?
	nested_constants = self.class.constants
	message = ''
	assert_include(included_modules.map{|m| m.name}, :Assertions, message)
	assert_equal([:Constants, :Assertions, :ClassMethods], Version.nested_scope_modules?)
end # nested_scopes
def assert_nested_scope_submodule(module_symbol, context = self, message='')
	message+="\nIn assert_nested_scope_submodule for class #{context.name}, "
	message += "make sure module Constants is nested in #{context.class.name.downcase} #{context.name}"
	message += " but not in #{context.nested_scope_modules?.inspect}"
	assert_include(constants, :Contants, message)
end # assert_included_submodule
def assert_included_submodule(module_symbol, context = self, message='')
	message+="\nIn assert_included_submodule for class #{self.name}, "
	message += "make sure module Constants is nested in #{self.class.name.downcase} #{self.name}"
	message += " but not in #{self.nested_scope_modules?.inspect}"
	assert_include(included_modules, :Contants, message)
end # assert_included_submodule
def asset_nested_and_included(module_symbol, context = self, message='')
	assert_nested_scope_submodule(module_symbol)
	assert_included_submodule(module_symbol)
end # asset_nested_and_included
def assert_pre_conditions(message='')
#	asset_nested_and_included(:ClassMethods, self)
#	asset_nested_and_included(:Constants, self)
#	asset_nested_and_included(:Assertions, self)
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
def assert_mounted(message='')
	message+="In assert_mounted, self=#{inspect}"
	assert_equal(true, mounted?, message)
	self
end #assert_post_conditions
def assert_unmounted(message='')
	message+="In assert_mounted, self=#{inspect}"
	assert_equal(false, mounted?, message)
	self
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants

end # Examples
end # Samba

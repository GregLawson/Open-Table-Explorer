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
module Constants
Default_server = '192.168.0.12'
Comment_regexp = /^#/ * (/./ * Regexp::Any).capture(:comment) * /$/
File_system_image_regexp = /^[-\/=a-zA-Z0-9]+/
Pathname_regexp = /[-\/a-zA-Z0-9]+/
Fs_type_regexp = /[a-z0-9,]{4,}/
Options_regexp = /[-_.0-9a-zA-Z,=\/]+/
Whitespace_delimiter = /\s+/
Whitespace_padding = /\s*/
Mount_table_regexp = Comment_regexp | 
	File_system_image_regexp.capture(:filesystem_image) *
	Whitespace_delimiter * Pathname_regexp.capture(:mount_point) *
	Whitespace_delimiter * Fs_type_regexp.capture(:file_system_type) *
	Whitespace_delimiter * Options_regexp.capture(:options)
Smb_tree_workgroup_regexp = /^[-A-Z0-9]+/.capture(:name)
Smb_tree_regexp = Whitespace_padding.capture(:indent) * /-[A-Z0-9]+/.capture(:name) * Whitespace_delimiter * /[a-zA-z0-9 ]+/.capture(:dewcription)

Smb_domains = ShellCommands.new('smbtree --no-pass -D')
Smb_servers = ShellCommands.new('smbtree --no-pass -S')
Smb_tree = ShellCommands.new('smbtree --no-pass')
end # Constants
include Constants
module ClassMethods
include Constants
def workgroups
	Smb_domains.output.parse(Smb_tree_workgroup_regexp)[:name]
end # workgroups
def servers(workgroup)
	Smb_servers.output?.parse(Smb_tree_regexp)
end # servers
def tree(workgroup, server)
	Smb_tree.output?.parse(Smb_tree_regexp)
end # tree
def parse_options(options_string)
	option_strings = options_string.split(',')
	options_hash = {} # start accumulating
	option_strings.each do |option_string|
		assignment = option_string.split('=')
		
		options_hash[assignment[0].to_sym] = assignment[1]
	end # each
	options_hash
end # parse_options
def new_from_table(line)
	capture = line.capture?(Mount_table_regexp)
	if capture.output?[:comment] then
		nil
	else
		options_hash = Samba.parse_options(capture.output?[:options])	
		host = options_hash[:ip]
		Samba.new(host, capture.output?[:filesystem_image],
			capture.output?[:mount_point],
			options_hash
		)

	end #if 
end # new_from_table
def fstab
	fstab = IO.read('/etc/fstab')
	lines = fstab.split("\n").map do |line|
		Samba.new_from_table(line)
	end # each
end # fstab
def mtab
	mstab = IO.read('/etc/mtab')
	lines = mtab.split("\n").map do |line|
		Samba.new_from_table(line)
	end # each
end # mtab
end # ClassMethods
extend ClassMethods
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
Recent_central_ip = '172.31.42.182'
Comment_line = '# /etc/fstab: static file system information.'
Test_line = '//Seagate-414103/Public	/media/central	cifs				auto,rw,ip=172.31.42.182,credentials=/home/greg/.samba/credentials/central,file_mode=0777,dir_mode=0777,serverino,acl	0	0'
Options_string = 'auto,rw,ip=' + Recent_central_ip = ',credentials=/home/greg/.samba/credentials/central,file_mode=0777,dir_mode=0777,serverino,acl'
Default_workgroup = 'WORKGROUP'
Default_server =  `hostname`
Default_share = 'IPC$'
end # Examples
end # Samba

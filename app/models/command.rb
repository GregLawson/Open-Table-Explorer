###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
require 'mime/types' # new ruby detailed library
require_relative '../../app/models/shell_command.rb'
class Command
module ClassMethods
def path_of_command(command)
		whereis=ShellCommands.new("whereis "+command).output
end #path_of_command
def paths?
	command_string = 'echo $PATH'
	ShellCommands.new(command_string).output.chomp.split(':')
end # paths?
end #ClassMethods
extend ClassMethods
attr_reader :banner
def initialize(command, description=nil, help_source=nil)
	@command_name = command
	if /\//.match(command) then # pathname
		@path=command
	else
		@type=ShellCommands.new('bash -c "type '+command+'"').output
		@whereis=ShellCommands.new("whereis "+command).output
		@path=@whereis.split(' ')[2]
	end #if
	@description=description
	@banner = "Usage: #{File.basename(command, '.rb')} --<command> files\n#{@description}"
	@help_source=help_source
	@file_type=	ShellCommands.new("file -b "+@path).output
	@mime_type=	ShellCommands.new("file -b --mime "+@path).output
	@dpkg="grep "#{@path}$"  /var/lib/*/info/*.list"
	if @mime_type=='application/octet' then
		@basename=File.basename(path,File.extname(path))
		@version=ShellCommands.new(@basename+" --version").output
		@v=ShellCommands.new(basename+" -v").output
		@man=ShellCommands.new("man "+@basename).output
		@info=ShellCommands.new("info "+@basename).output
		@help=ShellCommands.new(@basename+" --help").output
		@h=ShellCommands.new(@basename+" -h").output
	end #if
end #initialize
def what_is?
	command_string = 'whatis ' + @command_name.to_s
	@what_is = ShellCommands.new(command_string).output
end # what_is?
def where_is?
	command_string = 'whereis ' + @command_name.to_s
	ShellCommands.new(command_string).output.chomp.split(' ')
end # where_is?
#mime/types in a ruby library
def ruby_mime
    plaintext = MIME::Types[@mime_type]
    # returns [text/plain, text/plain]
    text      = plaintext.first
end #ruby_mime
module Constants
end #Constants
include Constants
require_relative '../../test/assertions.rb'
require 'test/unit/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
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
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
SELF=Command.new($0)
end #Examples
end # Command

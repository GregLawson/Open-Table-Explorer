###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
class Rsync
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
def initialize(pairing)
	@source_dir = pairing[:dir]
	@backup_dir = pairing[:backup]
	@options = '-ruav --links'
end #initialize
def backup
	command_string = 'rsync ' + @options + ' ' + @source_dir + '* ' + @backup_dir
#	ShellCommands.new(command_string)
end # backup
def merge_back
	command_string = 'rsync ' + @options + ' ' + @backup_dir + '* ' + @source_dir
#	ShellCommands.new(command_string)
end # merge_back
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
	message+="In assert_pre_conditions, self=#{inspect}"
	assert_not_nil(@source_dir, message)
	assert_not_nil(@backup_dir, message)
	assert_not_nil(@options, message)
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
end # Rsync
class Backup
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
end #Constants
include Constants
# attr_reader
require_relative '../../test/assertions.rb';module Assertions
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
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
Backups_dir='/media/central-greg/'
Media_dir = '/media/central/'
Space = Rsync.new({dir:'/mnt/space/', backup: Backups_dir + 'space/'})
Space_audiobooks = Rsync.new({dir: '/mnt/space/Audiobooks/', backup:'/media/central/Music/past/Audiobooks/'})
WD1TG_videos  = Rsync.new({dir: '/media/usb0/My_Videos/', backup:'/media/central/Videos/'})
WD1TG = Rsync.new({dir: '/media/usb0/', backup: Backups_dir + 'WD1TB/'})
include Constants
end #Examples
end # Backup

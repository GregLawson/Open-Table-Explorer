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
def initialize(pairing={dir: '', backup: '/media/central/'})
	@source_dir = pairing.source_dir
	@destination_dir = pairing.destination_dir
	@options = '-ruav --links'
end #initialize
def backup
	command_string = 'rsync ' + @options + ' ' + @source_dir + ' ' + @destination_dir
	ShellCommands.new(command_string)
end # rsync
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
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
#self.assert_pre_conditions
module Examples
Backups_dir='/media/central-greg/'
Media_dir = '/media/central/'
Space = {dir:'/mnt/space', backup: Backups_dir}
Space_audiobooks = {dir: '/mnt/space/Audiobooks/*', backup:'/media/central/Music/past/Audiobooks/'}
WD1TG_videos  = {dir: '/media/usb0/My_Videos/*', backup:'/media/central/Videos/'}
WD1TG = {dir: '/media/usb0/*', backup: Backups_dir + '/WD1TB'}
include Constants
end #Examples
end # Rsync

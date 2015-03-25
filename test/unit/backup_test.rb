###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/backup.rb'
class BackupTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_backup
#	assert_equal(Rsync.new().backup, 'rsync -ruav --links /mnt/crashed_gui /media/central-greg/')
	assert_equal(Backup::Examples::Space.backup, 'rsync -ruav --links /mnt/space/* /media/central-greg/space/')
	assert_equal(Backup::Examples::Space_audiobooks.backup, 'rsync -ruav --links /mnt/space/Audiobooks/* /media/central/Music/past/Audiobooks/')
	assert_equal(Backup::Examples::WD1TG_videos.backup, 'rsync -ruav --links /media/usb0/My_Videos/* /media/central/Videos/')
	assert_equal(Backup::Examples::WD1TG.backup, 'rsync -ruav --links /media/usb0/* /media/central-greg/WD1TB/')
end # backup
def test_Examples
	Backup::Examples::Space.assert_pre_conditions
	Backup::Examples::Space_audiobooks.assert_pre_conditions
	Backup::Examples::WD1TG_videos.assert_pre_conditions
	Backup::Examples::WD1TG.assert_pre_conditions
end # Examples
end # Backup

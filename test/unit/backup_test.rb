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
	assert_equal(Rsync.new().backup, 'rsync -ruav /mnt/crashed_gui /media/central-greg/')
	assert_equal(Rsync.new().backup, 'rsync -ruav /mnt/space /media/central-greg/')
	assert_equal(Rsync.new().backup, 'rsync -ruav /mnt/space/Audiobooks/* /media/central/Music/past/Audiobooks/')
	assert_equal(Rsync.new().backup, 'rsync -ruav /media/usb0/My_Videos/* /media/central/Videos/')
	assert_equal(Rsync.new().backup, 'rsync -ruav /media/usb0/* /media/central-greg/WD1TB/usb0/')
end # backup
end # Backup

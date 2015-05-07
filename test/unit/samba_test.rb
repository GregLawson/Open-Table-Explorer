###########################################################################
#    Copyright (C) 2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/samba.rb'
class SambaTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_mount
	mount_point = '/media/central'
	central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
	central.mount.assert_post_conditions
	assert_equal(central.mount_point)
	puts '!File.exists?(central.mount_point) = ' + !File.exists?(central.mount_point)
	puts 'File.exists?(central.mount_point) = ' + File.exists?(central.mount_point)
	puts 'central.mount_point = ' + central.mount_point
	assert_equal(true, central.mounted?)
end # mount
def test_umount
	mount_point = '/media/central'
	central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
	central.assert_post_conditions
	assert_equal(false, central.mounted?)
	central.assert_unmounted
end # umount
def test_mounted?
	mount_point = '/tmp/this_shouldnt_exist'
	central = Samba.new(Default_server, '\\Seagate-414103/Public', mount_point, 'auto')
	mtab_grep = ShellCommands.new('grep ' + central.mount_point + ' /etc/mtab')
	assert_equal('', mtab_grep.output)
	assert(central.mounted?)
	central.assert_mounted
end # mounted?
end # Samba

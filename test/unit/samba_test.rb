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
def test_fstab
	comment_regexp = /^#/ * (/./ * Regexp::Any).capture(:comment) * /$/
	file_system_image_regexp = /[-\/=a-zA-Z0-9]+/
	pathname_regexp = /[-a-zA-Z0-9]+/
	fs_type_regexp = /[a-z0-9]{4}/
	options_regexp = /[a-z,]+/
	fstab = IO.read('/etc/fstab')
	delimiter = /\s+/
	lines = fstab.split("\n").each do |line|
		fstab_regexp = file_system_image_regexp.capture(:filesystem_image)
		capture = line.capture?(comment_regexp | fstab_regexp)
		if !capture.output?[:comment] then
			assert_nil(capture.output?[:comment], 'capture should not be nil; raw_captures can be nil')
			puts capture.output?.inspect, capture.regexp.inspect if capture.success?
			fstab_regexp *= delimiter * pathname_regexp.capture(:mount_point)
			capture =  line.capture?(comment_regexp | fstab_regexp)
			puts capture.output?.inspect, capture.regexp if capture.success?
			fstab_regexp *= delimiter * fs_type_regexp.capture(:file_system_type)
			capture =  line.capture?(comment_regexp | fstab_regexp)
			puts capture.output?.inspect, capture.regexp if capture.success?
			fstab_regexp *= delimiter * options_regexp.capture(:options)
			capture =  line.capture?(comment_regexp | fstab_regexp)
			assert_not_nil(capture, 'capture should not be nil; raw_captures can be nil')
			assert_kind_of(Capture, capture, 'capture should not be nil; raw_captures can be nil')
	#		assert_not_nil(capture.success?, 'capture should not be nil; raw_captures can be nil')
			puts capture.output?.inspect, capture.regexp if capture.success?
			end #if 
	end # each
	
end # fstab
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

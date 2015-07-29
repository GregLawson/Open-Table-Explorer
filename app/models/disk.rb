###########################################################################
#    Copyright (C) 2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/parse.rb'
class Disk
module Constants
Uuid_glob = '/dev/disk/by-uuid/*'
Kernel_glob = '/boot/vmlinuz*'
Name_pattern = /[-_0-9a-zA-Z\/]+/
Filename_pattern = (Name_pattern * (/\./ * Name_pattern).group * Regexp::Many).capture(:filename)
Msdos_hint_regexp = /--hint-bios=hd0,msdos15 --hint-efi=hd0,msdos15 --hint-baremetal=ahci0,msdos15 --hint='hd0,msdos15'\ /.group
Uuid_regexp = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/
Grub_grep_regexp = Filename_pattern * /:\s*/ * ' search --no-floppy --fs-uuid --set=root ' * Msdos_hint_regexp * Regexp::Optional * Uuid_regexp.capture(:uuid)
end #Constants
include Constants
module ClassMethods
include Constants
def disks
	disks = Dir[Constants::Uuid_glob]
	disks.map do |link_name|
		{uuid: link_name[18..-1], partition_name:  File.readlink(link_name)[6..-1]}
		
	end # map
end # disks
def kernels
	kernel_files = Dir[Kernel_glob]
end # kernels
def grubs
	grep = `grep "uuid" /boot/grub/*`
	grep.lines.map do |line|
		line.capture?(Grub_grep_regexp)
	end # map
end # grubs
def ls
	ls_run = `ls -l #{Uuid_glob}`
	ls_octet_pattern = /rwx/
	ls_permission_pattern = [/1|l/,
					ls_octet_pattern.capture(:system),
					ls_octet_pattern.capture(:group), 
					ls_octet_pattern.capture(:owner)] 
	short = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'
	short.assert_parse(driver_pattern)
end # ls
end # ClassMethods
extend ClassMethods
#def initialize
#end # initialize
module Constants
end # Constants
include Constants
# attr_reader
def initialize
end # initialize
end # Disk

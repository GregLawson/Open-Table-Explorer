###########################################################################
#    Copyright (C) 2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Disk
module Constants
end #Constants
include Constants
module ClassMethods
def disks
	uuid_glob = '/dev/disk/by-uuid/*'
	disks = Dir[uuid_glob]
	disks.map do |link_name|
		{uuid: link_name[18..-1], partition_name:  File.readlink(link_name)[6..-1]}
		
	end # map
end # disks

def ls
	filename_pattern = /[-_0-9a-zA-Z\/]+/
	ls_run = `ls -l #{uuid_glob}`
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

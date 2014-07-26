###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/usb.rb'
require_relative '../../app/models/parse.rb'
class UsbBbusTest < TestCase
def test_usb_gem
end #usb_gem
def test_find_devices
	devs = Dir['/dev/bus/usb/*/*']
	dev_pattern = ['/dev/bus/usb/', /[0-9]{3}/.capture(:bus_number), /[0-9]{3}/.capture(:device_number)]
	dev_numbers = devs.map{|path| path.parse(dev_pattern) }
	lsusb = ShellCommands.new('lsusb').assert_post_conditions.output
	disk_devs = ShellCommands.new('ls -l /dev/disk/by-*|grep usb').assert_post_conditions.output
	drivers = ShellCommands.new("find /sys/ -name driver -ls").assert_post_conditions.output
	ls_octet_pattern = /rwx/
	ls_permission_pattern = [/1/,
					ls_octet_pattern.capture(:system),
					ls_octet_pattern.capture(:group), 
					ls_octet_pattern.capture(:owner)] 
	filename_pattern = /[-_0-9a-zA-Z\/]+/
	driver_pattern = ['/sys/devices', ls_permission_pattern,
							'  ', /[0-9]+/.capture(:number), /    /,
							ls_permission_pattern,
							filename_pattern.capture(:device),
							' -> ', 
							filename_pattern.capture(:driver)]
	drivers.assert_parse(driver_pattern)
	events =Dir['ls /dev/event*']
	events_by_id = ShellCommands.new('ls -l /dev/input/by-id*').assert_post_conditions.output
	events_by_path = ShellCommands.new('ls -l /dev/input/by-path/*').assert_post_conditions.output
	event_by_path_pattern = ['/dev/input/', /[a-zA-Z0-9]+/.capture(:name)]
	eventPaths = events_by_path.parse(event_by_path_pattern)
end # find_devices
end # UsbBus

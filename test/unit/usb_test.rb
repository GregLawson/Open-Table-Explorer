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
	assert_match(/\s/, drivers)
	driver_pattern = [
							'  ', /[0-9]+/.capture(:number), /    /,
							'  ', /[0-9]+/.capture(:number), /    /,
							ls_permission_pattern,
							'/sys/devices',
							filename_pattern.capture(:device),
							' -> ', 
							filename_pattern.capture(:driver)]
	short = drivers[0..10]
	short = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'
	assert_match(/ /, short)
	assert_match(/\s/, drivers)
	assert_match(/\s/, drivers)
	assert_match('  ', short)
	assert_match(/  /, short)
	assert_match(/\ \ /, short)
	'  '.assert_parse(/  /)
	short.assert_parse(/  /)
	short.assert_parse([/\s/])
	short.assert_parse([/\s+/])
	short.assert_parse([/  /])
	short.assert_parse(['  '])
	drivers.assert_parse(driver_pattern)
	events =Dir['ls /dev/event*']
	events_by_id = ShellCommands.new('ls -l /dev/input/by-id*').assert_post_conditions.output
	events_by_path = ShellCommands.new('ls -l /dev/input/by-path/*').assert_post_conditions.output
	event_by_path_pattern = ['/dev/input/', /[a-zA-Z0-9]+/.capture(:name)]
	eventPaths = events_by_path.parse(event_by_path_pattern)
end # find_devices
def test_libusb
	usb = LIBUSB::Context.new
	device = usb.devices(:idVendor => 0x04b4, :idProduct => 0x8613).first
#example	device.open_interface(0) do |handle|
#	  handle.control_transfer(:bmRequestType => 0x40, :bRequest => 0xa0, :wValue => 0xe600, :wIndex => 0x0000, :dataOut => 1.chr)
#	end
end # libusb
end # UsbBus

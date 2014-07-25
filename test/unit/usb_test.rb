###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/usb.rb'
class UsbBbusTest < TestCase
def test_usb_gem
end #usb_gem
def test_find_devices
	devs = ShellCommands.new('ls /dev/bus/usb/*/*').assert_post_conditions
	lsusb = ShellCommands.new('lsusb').assert_post_conditions
	disk_devs = ShellCommands.new('ls -l /dev/disk/by-*|grep usb').assert_post_conditions
	drivers = ShellCommands.new('ls -l /sys/bus/usb/drivers/*').assert_post_conditions
	events = ShellCommands.new('find /dev -name "*event*"').assert_post_conditions

end # find_devices
end # UsbBus

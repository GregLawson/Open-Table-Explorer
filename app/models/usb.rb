###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'libusb'
require_relative 'shell_command.rb'
require_relative '../../app/models/parse.rb'
class UsbBus
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
Devices = Dir['/dev/bus/usb/*/*']
Dev_pattern = /\// * 'dev/bus/usb/' * /[0-9]{3}/.capture(:bus_number) * /[0-9]{3}/.capture(:device_number)
Dev_numbers = Devices.map{|path| path.parse(Dev_pattern) }
Lsusb = ShellCommands.new('lsusb').output.split("/n")
Disk_devs = ShellCommands.new('ls -l /dev/disk/by-*|grep usb').output.split("/n")
Drivers = ShellCommands.new("find /sys/ -name driver -ls").output.split("/n")
end # Constants
include Constants
module Examples
Short = '  7771    0 lrwxrwxrwx   1 root     root            0 Jul 27 08:20 /sys/devices/pnp0/00:0d/driver -> ../../../bus/pnp/drivers/ns558'
Events =Dir['ls /dev/event*']
Events_by_id = ShellCommands.new('ls -l /dev/input/by-id*').output
Events_by_path = ShellCommands.new('ls -l /dev/input/by-path/*').output
Event_by_path_pattern = ['/dev/input/', /[a-zA-Z0-9]+/.capture(:name)]
EventPaths = Events_by_path.parse(Event_by_path_pattern)
end #Examples
end # UsbBus

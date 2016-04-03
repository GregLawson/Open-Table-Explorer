###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require 'virtus'
require_relative 'shell_command.rb'
class Iw
module Constants
Device_name_regexp = /[a-z]+[0-9]+/.capture(:device_name)
Hex_digit_lc_regexp = /[0-9a-f]/
Hex_byte_lc_regexp = Hex_digit_lc_regexp * Hex_digit_lc_regexp
Hw_address_regexp = ((Hex_byte_lc_regexp * /:/).group * 5 * Hex_byte_lc_regexp).capture(:hw_address)

Cell_regexp = /Cell / * /0-9+/.capture(:cell_number) * / - Address: / * Hw_address_regexp
Channel__regexp = /                    Channel:/ * /0-9+/.capture(:cell_number) * /157/
Frequency__regexp = /                    Frequency:/ * /0-9+/.capture(:cell_number) * /5.785 GHz/
Quality__regexp = /                    Quality=/ * /0-9+/.capture(:signal_quality) * /\// * /0-9+/.capture(:signal_noise) * /  Signal level=/ * /0-9+/.capture(:signal_dBm) * /dBm  /
Encryption__regexp = /                    Encryption key:on/
ESSID__regexp = /                    ESSID:"/ * /[a-zA-Z0-9]+/.capture(:essid) * /"/

Bit_rate_regexp = /                    Bit Rates:6 Mb\/s; 9 Mb\/s; 12 Mb\/s; 18 Mb\/s; 24 Mb\/s/
Bit_rate2__regexp = /                              36 Mb\/s; 48 Mb\/s; 54 Mb\/s/
Mode__regexp = /                    Mode:Master/
Extra_tsf__regexp = /                    Extra:tsf=00000e7df783804a/
Last_beacon_regexp = /                    Extra: Last beacon: / * /[0-9]+/.capture(:last_beacon) * /ms ago/
end # Constants
module ClassMethods
def scan(device = :wlan0)
	scan= ShellCommands.new('/sbin/iwlist ' + device.to_s + ' scanning')
end # scan

end # ClassMethods
extend ClassMethods
include Constants
# attr_reader
def initialize
end # initialize
#require_relative '../../app/models/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Iw_list = ShellCommands.new("/sbin/iw list")
Scan = ShellCommands.new("/sbin/iwlist wlan0 scanning")
Iwconfig = ShellCommands.new("/sbin/iwconfig wlan0")
Scan_dump = ShellCommands.new("/sbin/iw dev wlan0 scan dump")
Link_string = ShellCommands.new("/sbin/iw dev wlan0 link")
Wifi_channels = IO.read('test/data_sources/iwup/iwlist.scanning')
Iwconfig_regexp = /wlan0     IEEE 802.11bgn  ESSID:"\(/ * /.+/.capture(:ESSID) * /\)/
end # Examples
end # Iw
